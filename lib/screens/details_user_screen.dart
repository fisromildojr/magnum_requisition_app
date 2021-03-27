import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:magnum_requisition_app/components/departments_user_list.dart';
import 'package:magnum_requisition_app/components/details_user_form.dart';
import 'package:magnum_requisition_app/models/auth_data.dart';

class UserDetailsScreen extends StatefulWidget {
  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: Text('Detalhes do Usuário'),
    );

    final availableHeight = MediaQuery.of(context).size.height -
        appBar.preferredSize.height -
        MediaQuery.of(context).padding.top;

    final user = ModalRoute.of(context).settings.arguments as AuthData;
    return Scaffold(
      appBar: appBar,
      body: SingleChildScrollView(
        child: Container(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.id)
                // .collection('departmens')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else {
                // print(snapshot.data['name']);
                return Column(
                  children: [
                    Container(
                      height: availableHeight * 0.6,
                      child: DetailsUserForm(user),
                    ),
                    Container(
                      height: availableHeight * 0.4,
                      child: DepartmentsUserList(user),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
