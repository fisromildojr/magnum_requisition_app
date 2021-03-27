import 'package:magnum_requisition_app/models/category.dart';
import 'package:flutter/material.dart';

class CategoryForm extends StatefulWidget {
  final void Function(Category) onSubmit;

  CategoryForm(this.onSubmit);
  @override
  _CategoryFormState createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final _nameController = TextEditingController();

  _submitForm() {
    final category = Category(
      name: _nameController.text,
    );

    if (category.name.trim().isEmpty) {
      return;
    }
    widget.onSubmit(category);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: 450,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      onSubmitted: (_) => _submitForm(),
                      decoration: InputDecoration(
                        labelText: 'Nome da Nova Categoria',
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        RaisedButton(
                          child: Text('Nova Categoria'),
                          color: Theme.of(context).primaryColor,
                          textColor: Theme.of(context).textTheme.button.color,
                          onPressed: _submitForm,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
