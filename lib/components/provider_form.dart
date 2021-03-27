import 'package:flutter/material.dart';
import 'package:magnum_requisition_app/models/provider.dart';

class ProviderForm extends StatefulWidget {
  final void Function(Provider) onSubmit;

  ProviderForm(this.onSubmit);
  @override
  _ProviderFormState createState() => _ProviderFormState();
}

class _ProviderFormState extends State<ProviderForm> {
  final _fantasyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _ufController = TextEditingController();
  // final _departmentIdController = TextEditingController();

  _submitForm() {
    final provider = Provider(
      fantasyName: _fantasyNameController.text,
      email: _emailController.text,
      address: _addressController.text,
      city: _cityController.text,
      uf: _ufController.text,
    );

    if (provider.fantasyName.trim().isEmpty || provider.email.trim().isEmpty) {
      return;
    }
    widget.onSubmit(provider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomPadding: true,
      body: SingleChildScrollView(
        child: Container(
          // height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      TextField(
                        controller: _fantasyNameController,
                        onSubmitted: (_) => _submitForm(),
                        decoration: InputDecoration(
                          labelText: 'Nome Fantasia *',
                        ),
                      ),
                      TextField(
                        controller: _emailController,
                        onSubmitted: (_) => _submitForm(),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'E-Mail *',
                        ),
                      ),
                      TextField(
                        controller: _addressController,
                        onSubmitted: (_) => _submitForm(),
                        decoration: InputDecoration(
                          labelText: 'Endereço',
                        ),
                      ),
                      TextField(
                        controller: _cityController,
                        onSubmitted: (_) => _submitForm(),
                        decoration: InputDecoration(
                          labelText: 'Cidade',
                        ),
                      ),
                      TextField(
                        controller: _ufController,
                        onSubmitted: (_) => _submitForm(),
                        decoration: InputDecoration(
                          labelText: 'UF',
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          RaisedButton(
                            child: Text('Novo Fornecedor'),
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
      ),
    );
  }
}
