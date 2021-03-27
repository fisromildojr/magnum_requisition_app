import 'package:flutter/material.dart';
import 'package:magnum_requisition_app/models/sector.dart';

class SectorForm extends StatefulWidget {
  final void Function(Sector sector) onSubmit;
  // final Department department;

  SectorForm(this.onSubmit);

  @override
  _SectorFormState createState() => _SectorFormState();
}

class _SectorFormState extends State<SectorForm> {
  final _nameController = TextEditingController();
  // final _departmentIdController = TextEditingController();

  _submitForm() {
    final sector = Sector(
      name: _nameController.text,
    );

    // final departmentId = _departmentIdController.text;

    if (sector.name.trim().isEmpty) {
      return;
    }
    widget.onSubmit(sector);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // TextField(
            //   controller: _departmentIdController,
            //   onSubmitted: (_) => _submitForm(),
            //   decoration: InputDecoration(
            //     labelText: 'ID do Departamento',
            //   ),
            // ),
            TextField(
              controller: _nameController,
              onSubmitted: (_) => _submitForm(),
              decoration: InputDecoration(
                labelText: 'Nome do Novo Centro de Custo',
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                RaisedButton(
                  child: Text('Novo Centro de Custo'),
                  color: Theme.of(context).primaryColor,
                  textColor: Theme.of(context).textTheme.button.color,
                  onPressed: _submitForm,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
