import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:magnum_requisition_app/components/department_form.dart';
import 'package:magnum_requisition_app/models/department.dart';
import 'package:magnum_requisition_app/utils/app_routes.dart';

class DepartmentsScreen extends StatefulWidget {
  @override
  _DepartmentsScreenState createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen> {
  _openDepartmentFormModal(context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return DepartmentForm(_addDepartment);
      },
    );
  }

  Future<void> _addDepartment(String name) async {
    Navigator.of(context).pop();

    final Department newDepartment = Department(
      id: null,
      name: name.toUpperCase(),
    );

    await FirebaseFirestore.instance.collection('departments').add({
      'name': newDepartment.name,
      'excluded': false,
    });
  }

  Future<void> _deleteDepartment(department) async {
    Navigator.of(context).pop();

    FirebaseFirestore.instance
        .collection('departments')
        .doc(department.id)
        .collection('sectors')
        .snapshots()
        .forEach((snapshotSectors) {
      snapshotSectors.docs.forEach((docSector) {
        docSector.reference.update({'excluded': true}).then((_) {
          FirebaseFirestore.instance
              .collection('departments')
              .doc(department.id)
              .update({'excluded': true}).then((_) {
            FirebaseFirestore.instance
                .collection('users')
                .snapshots()
                .forEach((snapshotUsers) {
              snapshotUsers.docs.forEach((docUser) {
                docUser.reference
                    .collection('departments')
                    .doc(department.id)
                    .delete();
              });
            });
          });
        });
      });

      FirebaseFirestore.instance
          .collection('users')
          .snapshots()
          .forEach((snapshot) {
        for (var i = 0; i < snapshot.docs.length; i++) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(snapshot.docs[i].id)
              .collection('departments')
              .doc(department.id)
              .get()
              .then((departmentUser) {
            if (departmentUser.exists)
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(snapshot.docs[i].id)
                  .collection('departments')
                  .doc(department.id)
                  .delete();
            print('Departamento Excluído...');
          });
        }
      });
    });

    // print(users[].id;

    // Navigator.of(context).pop();
    // print('Excluindo o departamento: ${department.name}');
  }

  void showAlert() {
    AlertDialog(
      title: Text("Exclusão"),
      content: Text("Você deseja excluir o departamento?"),
      actions: [
        FlatButton(
          child: Text('Cancel'),
          onPressed: () => null,
        ),
        FlatButton(
          child: Text('Continuar'),
          onPressed: () => null,
        ),
      ],
    );
  }

  void _selectDepartment(BuildContext context, Department department) {
    Navigator.of(context).pushNamed(
      AppRoutes.SECTORS,
      arguments: department,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Departamentos'),
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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('departments')
            .where('excluded', isEqualTo: false)
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
              final Department department = Department(
                id: documents[i].id,
                name: documents[i]['name'],
              );
              return Container(
                child: Card(
                  elevation: 1,
                  child: ListTile(
                    title: Text(documents[i]['name']),
                    // onTap: () => null,
                    onTap: () => _selectDepartment(context, department),
                    // leading: Text('T'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      color: Theme.of(context).errorColor,
                      onPressed: () {
                        return showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Confirmação"),
                                content: Text(
                                    "Você deseja excluir o departamento ${department.name} ?"),
                                actions: [
                                  FlatButton(
                                    child: Text('Cancel'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                  FlatButton(
                                    child: Text('Continuar'),
                                    onPressed: () =>
                                        _deleteDepartment(department),
                                  ),
                                ],
                              );
                            });
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () => _openDepartmentFormModal(context),
      ),
    );
  }
}
