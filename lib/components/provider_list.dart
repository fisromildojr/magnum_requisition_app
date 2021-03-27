import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:magnum_requisition_app/models/provider.dart';

class ProviderList extends StatefulWidget {
  final void Function(Provider provider) onTap;

  ProviderList(this.onTap);

  @override
  _ProviderListState createState() => _ProviderListState();
}

class _ProviderListState extends State<ProviderList> {
  _selectProvider(BuildContext context, Provider provider) {
    // Navigator.of(context).pop();
    widget.onTap(provider);
  }

  // _onTap(BuildContext context, Provider provider) =>
  //     widget.onTap(context, provider);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('providers')
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
            );
            // print(provider.fantasyName + ' => ' + provider.email);
            return Container(
              child: ListTile(
                title: Text(provider.fantasyName),
                subtitle: Text(provider.email),
                onTap: () => _selectProvider(context, provider),
              ),
            );
          },
        );
      },
    );
  }
}
