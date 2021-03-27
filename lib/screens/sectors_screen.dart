import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:magnum_requisition_app/components/sector_form.dart';
import 'package:magnum_requisition_app/models/department.dart';
import 'package:magnum_requisition_app/models/sector.dart';

class SectorsScreen extends StatefulWidget {
  @override
  _SectorsScreenState createState() => _SectorsScreenState();
}

class _SectorsScreenState extends State<SectorsScreen> {
  _openSectorFormModal(context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SectorForm(_addSector);
      },
    );
  }

  Future<void> _addSector(Sector sector) async {
    final department = ModalRoute.of(context).settings.arguments as Department;
    Navigator.of(context).pop();

    await FirebaseFirestore.instance
        .collection('departments')
        .doc(department.id)
        .collection('sectors')
        .add({
      'name': sector.name.toUpperCase(),
      'excluded': false,
    });
  }

  Future<void> _deleteSector(Sector sector) async {
    final department = ModalRoute.of(context).settings.arguments as Department;
    Navigator.of(context).pop();

    await FirebaseFirestore.instance
        .collection('departments')
        .doc(department.id)
        .collection('sectors')
        .doc(sector.id)
        .update({'excluded': true});
  }

  @override
  Widget build(BuildContext context) {
    final department = ModalRoute.of(context).settings.arguments as Department;
    // final sectors = FirebaseFirestore.instance
    //     .collection('departments')
    //     .doc(department.id)
    //     .get();

    return Scaffold(
      appBar: AppBar(
        title: Text('Centros de Custo de ' + department.name),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('departments')
            .doc(department.id)
            .collection('sectors')
            .where('excluded', isEqualTo: false)
            .orderBy('name')
            .snapshots(),
        builder: (ctx, snapshot) {
          // print('ID do Departamento: ' + department.id);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasData) {
            final documents = snapshot.data.documents;

            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (ctx, i) {
                final Sector sector = Sector(
                  id: documents[i].id,
                  name: documents[i]['name'],
                );
                return Container(
                  child: Card(
                    elevation: 1,
                    child: ListTile(
                      title: Text(sector.name),
                      onTap: () => null,
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
                                      "Você deseja excluir o Centro de Custo ${sector.name} ?"),
                                  actions: [
                                    FlatButton(
                                      child: Text('Cancel'),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                    FlatButton(
                                      child: Text('Continuar'),
                                      onPressed: () => _deleteSector(sector),
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
          } else {
            return Center(
              child: Text(
                'Você não tem permissão para acessár essa tela...',
                style: Theme.of(context).textTheme.headline6,
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openSectorFormModal(context),
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
