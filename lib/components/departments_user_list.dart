import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:magnum_requisition_app/components/department_with_user_form.dart';
import 'package:magnum_requisition_app/models/auth_data.dart';
import 'package:magnum_requisition_app/models/department.dart';

class DepartmentsUserList extends StatefulWidget {
  final AuthData user;

  DepartmentsUserList(this.user);

  @override
  _DepartmentsUserListState createState() => _DepartmentsUserListState();
}

class _DepartmentsUserListState extends State<DepartmentsUserList> {
  _openDepartmentWithUserFormModal(context, user) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return DepartmentWithUserForm(_addDepartmentWithUser, user);
      },
    );
  }

  Future<void> _addDepartmentWithUser(Department department) async {
    final user = ModalRoute.of(context).settings.arguments as AuthData;
    Navigator.of(context).pop();

    // final Future departmentsUser = await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(user.id)
    //     .collection('departments')
    //     .get();

    // print(departmentsUser);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .collection('departments')
        .doc(department.id)
        .set({
      'name': department.name,
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.id)
          .collection('departments')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // print(snapshot.data.id);

          final documents = snapshot.data.documents;
          return SingleChildScrollView(
              child: Card(
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Departamentos:',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                      RaisedButton(
                        elevation: 6,
                        onPressed: () => _openDepartmentWithUserFormModal(
                            context, widget.user),
                        color: Colors.green,
                        child: Icon(Icons.add),
                      ),
                    ],
                  ),
                  if (documents.length < 1)
                    FittedBox(
                      child: Row(
                        children: [
                          SizedBox(
                            height: 60,
                          ),
                          Text(
                              'O usuário não possui nenhum departamento associado...'),
                        ],
                      ),
                    ),
                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: documents.length,
                      itemBuilder: (context, i) {
                        if (documents.length > 0) {
                          // final department = Department(
                          //   id: documents[i].id,
                          //   name: documents[i]['name'],
                          // );

                          // widget.user.departments.add(department);
                          print(documents[i].id);

                          return Card(
                            elevation: 1,
                            child: ListTile(
                              title: Text(documents[i]['name']),
                            ),
                          );
                        }
                      }),
                ],
              ),
            ),
          ));
        } else {
          return Center(child: CircularProgressIndicator());
        }

        // if (snapshot.hasError) print(snapshot.error);
      },
    );
  }
}
