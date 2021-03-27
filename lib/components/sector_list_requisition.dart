import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:magnum_requisition_app/models/department.dart';
import 'package:magnum_requisition_app/models/sector.dart';

class SectorListRequisition extends StatefulWidget {
  final void Function(Sector sector) onTap;
  final Department department;

  SectorListRequisition(this.onTap, this.department);

  @override
  _SectorListRequisitionState createState() => _SectorListRequisitionState();
}

class _SectorListRequisitionState extends State<SectorListRequisition> {
  _selectSector(BuildContext context, Sector sector) {
    // Navigator.of(context).pop();
    widget.onTap(sector);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('departments')
          .doc(widget.department.id)
          .collection('sectors')
          .orderBy('name')
          .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final documents = snapshot.data.documents;

        if (documents.length < 1) {
          return Card(
            child: Container(
              height: 300,
              child: FittedBox(
                child: Text(
                  'Nenhum Centro de Custo no Departamento Selecionado...',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
            ),
          );
        }
        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (ctx, i) {
            final Sector sector = Sector(
              id: documents[i].id,
              name: documents[i]['name'],
            );

            return Container(
              child: ListTile(
                title: Text(sector.name),
                // subtitle: Text(provider.email),
                onTap: () => _selectSector(context, sector),
              ),
            );
          },
        );
      },
    );
  }
}
