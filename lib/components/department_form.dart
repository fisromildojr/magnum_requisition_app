import 'package:flutter/material.dart';

class DepartmentForm extends StatefulWidget {
  final void Function(String) onSubmit;

  DepartmentForm(this.onSubmit);
  @override
  _DepartmentFormState createState() => _DepartmentFormState();
}

class _DepartmentFormState extends State<DepartmentForm> {
  final _nameController = TextEditingController();

  _submitForm() {
    final name = _nameController.text;

    if (name.trim().isEmpty) {
      return;
    }
    widget.onSubmit(name);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              onSubmitted: (_) => _submitForm(),
              decoration: InputDecoration(
                labelText: 'Nome do Novo Departamento',
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                RaisedButton(
                  child: Text('Novo Departamento'),
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
