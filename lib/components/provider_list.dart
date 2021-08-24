import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:magnum_requisition_app/models/provider.dart';
import 'package:flutter/services.dart';

class ProviderList extends StatefulWidget {
  final void Function(Provider provider) onTap;
  final bool isReportsScreen;

  ProviderList(this.onTap, {this.isReportsScreen});

  @override
  _ProviderListState createState() => _ProviderListState();
}

class _ProviderListState extends State<ProviderList> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _fantasyNameController = TextEditingController();

  _selectProvider(BuildContext context, Provider provider) {
    widget.onTap(provider);
  }

  _searchProvider(value) {
    setState(() {
      _fantasyNameController.text = value;
      _fantasyNameController.selection = TextSelection.fromPosition(
          TextPosition(offset: _fantasyNameController.text.length));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: TextField(
            controller: _fantasyNameController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: 'Fornecedor',
            ),
            onChanged: (value) => _searchProvider(value.toUpperCase()),
          ),
        ),
        StreamBuilder(
          stream: widget.isReportsScreen
              ? FirebaseFirestore.instance
                  .collection('providers')
                  .orderBy('fantasyName')
                  .snapshots()
              : FirebaseFirestore.instance
                  .collection('providers')
                  .orderBy('fantasyName')
                  .where('excluded', isEqualTo: false)
                  .snapshots(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            final documents = snapshot.data.documents;

            return Container(
              child: Expanded(
                child: ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (ctx, i) {
                    final Provider provider = Provider(
                      id: documents[i].id,
                      fantasyName: documents[i]['fantasyName'],
                      email: documents[i]['email'],
                      address: documents[i]['address'],
                      city: documents[i]['city'],
                      uf: documents[i]['uf'],
                    );

                    return provider.fantasyName
                                .indexOf(_fantasyNameController.text) >
                            -1
                        ? Container(
                            child: ListTile(
                              title: Text(provider.fantasyName),
                              subtitle: Text(provider.email),
                              onTap: () => _selectProvider(context, provider),
                            ),
                          )
                        : Container();
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
