import 'dart:io';

import 'package:magnum_requisition_app/components/provider_update_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:magnum_requisition_app/components/provider_form.dart';
import 'package:magnum_requisition_app/models/provider.dart';
import 'package:magnum_requisition_app/utils/app_routes.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

class ProvidersScreen extends StatefulWidget {
  @override
  _ProvidersScreenState createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _fantasyNameController = TextEditingController();

  _openProviderFormModal(context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ProviderForm(_addProvider);
      },
    );
  }

  _searchProvider(value) {
    setState(() {
      _fantasyNameController.text = value;
      _fantasyNameController.selection = TextSelection.fromPosition(
          TextPosition(offset: _fantasyNameController.text.length));
    });
  }

  _setSearchParam(String fantasyName) {
    List<String> providerSearchList = [];
    String temp = "";
    for (int i = 0; i < fantasyName.length; i++) {
      temp = temp + fantasyName[i];
      providerSearchList.add(temp);
    }
    return providerSearchList;
  }

  Future<void> _addProvider(Provider provider) async {
    Navigator.of(context).pop();

    await FirebaseFirestore.instance.collection('providers').add({
      'fantasyName': provider.fantasyName.toUpperCase(),
      'email': provider.email.toLowerCase(),
      'address': provider.address.toUpperCase(),
      'city': provider.city.toUpperCase(),
      'uf': provider.uf.toUpperCase(),
      'excluded': false,
      'providerSearch':
          this._setSearchParam(provider.fantasyName.toUpperCase()),
    });
  }

  _openProviderUpdateFormModal(context, provider) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ProviderUpdateForm(_updateProvider, provider);
      },
    );
  }

  Future<void> _updateProvider(Provider provider) async {
    Navigator.of(context).pop();

    await FirebaseFirestore.instance
        .collection('providers')
        .doc(provider.id)
        .update({
      'fantasyName': provider.fantasyName.toUpperCase(),
      'email': provider.email.toLowerCase(),
      'address': provider.address.toUpperCase(),
      'city': provider.city.toUpperCase(),
      'uf': provider.uf.toUpperCase(),
      'providerSearch':
          this._setSearchParam(provider.fantasyName.toUpperCase()),
    });
  }

  Future<void> _deleteProvider(Provider provider) async {
    Navigator.of(context).pop();

    await FirebaseFirestore.instance
        .collection('providers')
        .doc(provider.id)
        .update({'excluded': true});
  }

  _getCsv(List<dynamic> providers) async {
    List<List<dynamic>> rows = [];
    List<dynamic> row = [];
    row.add("#");
    row.add("Nome Fantasia");
    row.add("E-Mail");
    row.add("Endereço");
    row.add("Cidade");
    row.add("UF");
    row.add("Excluído");
    rows.add(row);
    for (int i = 0; i < providers.length; i++) {
      List<dynamic> row = [];
      row.add(i + 1);
      row.add(providers[i].fantasyName ?? '');
      row.add(providers[i].email ?? '');
      row.add(providers[i].address ?? '');
      row.add(providers[i].city ?? '');
      row.add(providers[i].uf ?? '');
      row.add((providers[i].excluded == true) ? 'SIM' : 'NÃO');
      rows.add(row);
    }

    String csv = const ListToCsvConverter().convert(rows);

    Directory tempDir = await getTemporaryDirectory();
    final fileName = "/fornecedores.csv";
    final filePath = tempDir.path + fileName;
    await File(filePath).writeAsString(csv);
    final List<String> files = [];
    files.add(filePath as String);
    Share.shareFiles(files, text: "Relação de Fornecedores");
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> providers = [];
    return Scaffold(
      appBar: AppBar(
        title: Text('Fornecedores'),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton(
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).primaryIconTheme.color,
              ),
              items: [
                DropdownMenuItem(
                  value: 'compartilhar',
                  child: Container(
                    child: Row(
                      children: [
                        Icon(Icons.share),
                        SizedBox(width: 8),
                        Text('Compartilhar'),
                      ],
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: 'logout',
                  child: Container(
                    child: Row(
                      children: [
                        Icon(Icons.exit_to_app),
                        SizedBox(width: 8),
                        Text('Sair'),
                      ],
                    ),
                  ),
                ),
              ],
              onChanged: (item) {
                if (item == 'logout') {
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushNamed(
                    AppRoutes.HOME,
                  );
                }
                if (item == 'compartilhar') {
                  return _getCsv(providers);
                }
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            child: TextField(
              controller: _fantasyNameController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Pesquisar...',
              ),
              onChanged: (value) => _searchProvider(value.toUpperCase()),
            ),
          ),
          Expanded(
            child: Container(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('providers')
                    .where('excluded', isEqualTo: false)
                    .orderBy('fantasyName')
                    .snapshots(),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final documents = snapshot.data.documents;

                  for (var i = 0; i < documents.length; i++) {
                    final provider = Provider(
                      id: documents[i].id,
                      fantasyName: documents[i]['fantasyName'],
                      email: documents[i]['email'],
                      address: documents[i]['address'],
                      city: documents[i]['city'],
                      uf: documents[i]['uf'],
                      excluded: documents[i]['excluded'],
                    );
                    providers.add(provider);
                  }

                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (ctx, i) {
                      final Provider provider = Provider(
                        id: documents[i].id,
                        fantasyName: documents[i]['fantasyName'],
                        email: documents[i]['email'],
                        address: documents[i]['address'],
                        city: documents[i]['city'],
                        uf: documents[i]['uf'],
                        excluded: documents[i]['excluded'],
                      );
                      return provider.fantasyName
                                  .indexOf(_fantasyNameController.text) >
                              -1
                          ? Container(
                              child: Card(
                                elevation: 1,
                                child: ListTile(
                                  title: Text(documents[i]['fantasyName']),
                                  subtitle: Text(documents[i]['email']),
                                  trailing: Container(
                                    width: 100,
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () =>
                                              _openProviderUpdateFormModal(
                                                  context, provider),
                                          color: Colors.orange,
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          color: Theme.of(context).errorColor,
                                          onPressed: () {
                                            return showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: Text("Confirmação"),
                                                    content: Text(
                                                        "Você deseja excluir o Fornecedor ${provider.fantasyName} ?"),
                                                    actions: [
                                                      TextButton(
                                                        child: Text('Cancel'),
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(),
                                                      ),
                                                      TextButton(
                                                        child:
                                                            Text('Continuar'),
                                                        onPressed: () =>
                                                            _deleteProvider(
                                                                provider),
                                                      ),
                                                    ],
                                                  );
                                                });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  // onTap: () => null,
                                  // onTap: () => _selectDepartment(context, department),
                                  // leading: Text('T'),
                                  // trailing: IconButton(
                                  //   icon: Icon(Icons.delete),
                                  //   color: Theme.of(context).errorColor,
                                  //   onPressed: () {},
                                  // ),
                                ),
                              ),
                            )
                          : Container();
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () => _openProviderFormModal(context),
      ),
    );
  }
}
