import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:magnum_requisition_app/models/auth_data.dart';

class DetailsUserForm extends StatelessWidget {
  final AuthData user;
  DetailsUserForm(this.user);

  Future<void> _updateStateUser(
      BuildContext context, String userId, bool active) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'active': !active,
    });
  }

  Future<void> _updateStateAdmin(
      BuildContext context, String userId, bool isAdmin) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'isAdmin': !isAdmin,
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          // .collection('departmens')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Card(
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                child: Column(
                  children: [
                    TextFormField(
                      key: ValueKey('name'),
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Nome',
                      ),
                      initialValue: user.name,
                    ),
                    TextFormField(
                      key: ValueKey('email'),
                      readOnly: true,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                      ),
                      initialValue: user.email,
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Text('Usuário Ativo?'),
                        snapshot.data['active']
                            ? IconButton(
                                icon: CircleAvatar(
                                  child: Icon(Icons.thumb_up),
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                // onPressed: () => null,
                                onPressed: () => _updateStateUser(
                                    context, user.id, snapshot.data['active']),
                              )
                            : IconButton(
                                icon: CircleAvatar(
                                  child: Icon(Icons.thumb_down),
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                // onPressed: () => null,
                                onPressed: () => _updateStateUser(
                                    context, user.id, snapshot.data['active']),
                              ),
                      ],
                    ),
                    // SizedBox(height: 1),
                    Row(
                      children: [
                        Text('É Administrador?'),
                        snapshot.data['isAdmin']
                            ? IconButton(
                                icon: CircleAvatar(
                                  child: Icon(Icons.thumb_up),
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                // onPressed: () => null,
                                onPressed: () => _updateStateAdmin(
                                    context, user.id, snapshot.data['isAdmin']),
                              )
                            : IconButton(
                                icon: CircleAvatar(
                                  child: Icon(Icons.thumb_down),
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,

                                  // foregroundColor: Colors.white,
                                ),
                                // onPressed: () => null,
                                onPressed: () => _updateStateAdmin(
                                    context, user.id, snapshot.data['isAdmin']),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
