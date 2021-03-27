import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:magnum_requisition_app/models/auth_data.dart';
import 'package:magnum_requisition_app/models/department.dart';

class ListTileDepartmentWithUser extends StatefulWidget {
  final Department department;
  final AuthData user;
  ListTileDepartmentWithUser(this.department, this.user);

  @override
  _ListTileDepartmentWithUserState createState() =>
      _ListTileDepartmentWithUserState();
}

class _ListTileDepartmentWithUserState
    extends State<ListTileDepartmentWithUser> {
  bool exists;

  Future<bool> departmentExists() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.id)
        .collection('departments')
        .doc(widget.department.id)
        .get();

    setState(() {
      exists = doc.exists;
    });

    return doc.exists;
  }

  Future<void> _actionAddOrRemoveDepartmentUser() async {
    print(widget.department.id + ' => ' + widget.department.name);
    print(widget.user.id + ' => ' + widget.user.name);

    if (await departmentExists()) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.id)
          .collection('departments')
          .doc(widget.department.id)
          .delete();
      print('Não Existe... => Agora Sim...');
    } else {
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.id)
          .collection('departments')
          .doc(widget.department.id)
          .set({
        'name': widget.department.name,
      });
      print('Existe... => Agora Não...');
    }
  }

  @override
  Widget build(BuildContext context) {
    // _actionAddOrRemoveDepartmentUser();
    departmentExists();
    if (exists == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    if (exists == false) {
      return ListTile(
        title: Text(widget.department.name),
        trailing: IconButton(
          icon: CircleAvatar(
            child: Icon(Icons.radio_button_unchecked),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: () => _actionAddOrRemoveDepartmentUser(),
          // onPressed: () =>
          //     _updateStateUser(context, documents[i].id, active),
        ),
      );
    } else {
      return ListTile(
        title: Text(widget.department.name),
        trailing: IconButton(
          icon: CircleAvatar(
            child: Icon(Icons.check),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          onPressed: () => _actionAddOrRemoveDepartmentUser(),
          // onPressed: () =>
          //     _updateStateUser(context, documents[i].id, active),
        ),
      );
    }
  }
}
