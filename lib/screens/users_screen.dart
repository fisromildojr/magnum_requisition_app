import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:magnum_requisition_app/models/auth_data.dart';
import 'package:magnum_requisition_app/utils/app_routes.dart';

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

Future<void> _updateStateUser(
    BuildContext context, String userId, bool active) async {
  await FirebaseFirestore.instance.collection('users').doc(userId).update({
    'active': !active,
  });
}

class _UserScreenState extends State<UserScreen> {
  void _selectUser(BuildContext context, AuthData user) {
    Navigator.of(context).pushNamed(
      AppRoutes.USER_DETAILS,
      arguments: user,
    );
  }

  @override
  Widget build(BuildContext context) {
    // final user = ModalRoute.of(context).settings.arguments as AuthData;
    return Scaffold(
      appBar: AppBar(
        title: Text('Usuários'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('name')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final documents = snapshot.data.documents;

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, i) {
              final bool active = documents[i]['active'];
              final user = AuthData(
                id: documents[i].id,
                name: documents[i]['name'],
                email: documents[i]['email'],
                active: documents[i]['active'],
                isAdmin: documents[i]['isAdmin'],
              );
              return ListTile(
                // leading: avatar,
                onTap: () => _selectUser(context, user),
                leading: CircleAvatar(
                  child: Icon(Icons.perm_identity),
                ),
                title: Text(documents[i]['name']),
                subtitle: Text(documents[i]['email']),
                trailing: active
                    ? IconButton(
                        icon: CircleAvatar(
                          child: Icon(Icons.thumb_up),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () =>
                            _updateStateUser(context, documents[i].id, active),
                      )
                    : IconButton(
                        icon: CircleAvatar(
                          child: Icon(Icons.thumb_down),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          // foregroundColor: Colors.white,
                        ),
                        onPressed: () =>
                            _updateStateUser(context, documents[i].id, active),
                      ),
                // trailing: Container(
                //   width: 100,
                //   child: Row(
                //     children: <Widget>[
                //       IconButton(
                //         icon: Icon(Icons.edit),
                //         onPressed: () {},
                //         color: Colors.orange,
                //       ),
                //       IconButton(
                //         icon: Icon(Icons.delete),
                //         onPressed: () {},
                //         color: Colors.red,
                //       ),
                //     ],
                //   ),
                // ),
              );
            },
          );
        },
      ),
    );
  }
}
