import 'package:magnum_requisition_app/models/auth_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserList extends StatefulWidget {
  final void Function(AuthData user) onTap;

  UserList(this.onTap);

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  _selectUser(BuildContext context, AuthData user) {
    // Navigator.of(context).pop();
    widget.onTap(user);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('name')
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
            final AuthData user = AuthData(
              id: documents[i].id,
              name: documents[i]['name'],
              email: documents[i]['email'],
              active: documents[i]['active'],
              isAdmin: documents[i]['isAdmin'],
            );
            return Container(
              child: ListTile(
                title: Text(user.name),
                subtitle: Text(user.email),
                onTap: () => _selectUser(context, user),
              ),
            );
          },
        );
      },
    );
  }
}
