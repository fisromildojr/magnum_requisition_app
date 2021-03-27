import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:magnum_requisition_app/models/auth_data.dart';
import 'package:magnum_requisition_app/models/department.dart';

class DepartmentListRequisition extends StatefulWidget {
  final void Function(Department department) onTap;
  final AuthData user;

  DepartmentListRequisition(this.onTap, this.user);

  @override
  _DepartmentListRequisitionState createState() =>
      _DepartmentListRequisitionState();
}

class _DepartmentListRequisitionState extends State<DepartmentListRequisition> {
  // final user = FirebaseAuth.instance.currentUser;

  _selectDepartment(BuildContext context, Department department) {
    // Navigator.of(context).pop();
    widget.onTap(department);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.user.isAdmin
          ? FirebaseFirestore.instance
              .collection('departments')
              .orderBy('name')
              .snapshots()
          : FirebaseFirestore.instance
              .collection('users')
              .doc(widget.user.id)
              .collection('departments')
              .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final documents = snapshot.data.documents;
        print('Retornado' + documents.length.toString());
        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (ctx, i) {
            final Department department = Department(
              id: documents[i].id,
              name: documents[i]['name'],
            );

            return Container(
              child: ListTile(
                title: Text(department.name),
                // subtitle: Text(provider.email),
                onTap: () => _selectDepartment(context, department),
              ),
            );
          },
        );
      },
    );
  }
}
