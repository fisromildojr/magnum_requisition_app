import 'package:magnum_requisition_app/components/provider_update_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:magnum_requisition_app/components/provider_form.dart';
import 'package:magnum_requisition_app/models/provider.dart';
import 'package:magnum_requisition_app/utils/app_routes.dart';

class ProvidersScreen extends StatefulWidget {
  @override
  _ProvidersScreenState createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen> {
  _openProviderFormModal(context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ProviderForm(_addProvider);
      },
    );
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
    });
  }

  Future<void> _deleteProvider(Provider provider) async {
    Navigator.of(context).pop();

    await FirebaseFirestore.instance
        .collection('providers')
        .doc(provider.id)
        .update({'excluded': true});
  }

  @override
  Widget build(BuildContext context) {
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
              },
            ),
          ),
        ],
      ),
      body: Container(
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
                return Container(
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
                              onPressed: () => _openProviderUpdateFormModal(
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
                                          FlatButton(
                                            child: Text('Cancel'),
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                          ),
                                          FlatButton(
                                            child: Text('Continuar'),
                                            onPressed: () =>
                                                _deleteProvider(provider),
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
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () => _openProviderFormModal(context),
      ),
    );
  }
}
