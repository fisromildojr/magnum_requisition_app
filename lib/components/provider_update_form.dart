import 'package:flutter/material.dart';
import 'package:magnum_requisition_app/models/provider.dart';

class ProviderUpdateForm extends StatefulWidget {
  final void Function(Provider) onSubmit;
  final Provider provider;

  ProviderUpdateForm(this.onSubmit, this.provider);

  @override
  _ProviderUpdateFormState createState() => _ProviderUpdateFormState();
}

class _ProviderUpdateFormState extends State<ProviderUpdateForm> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  // final _fantasyNameController = TextEditingController();

  // final _emailController = TextEditingController();

  // final _addressController = TextEditingController();

  // final _cityController = TextEditingController();

  // final _ufController = TextEditingController();

  _submitForm() {
    bool isValid = _formKey.currentState.validate();
    if (isValid) {
      print(this.widget.provider.fantasyName);
      print(this.widget.provider.email);
      print(this.widget.provider.address);
      print(this.widget.provider.city);
      print(this.widget.provider.uf);

      this.widget.onSubmit(this.widget.provider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          // height: MediaQuery.of(context).size.height,
          child: Form(
            key: _formKey,
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
                        TextFormField(
                          key: ValueKey('fantasyName'),
                          initialValue: this.widget.provider.fantasyName,
                          // controller: _fantasyNameController,
                          // onSubmitted: (_) => null,
                          onChanged: (value) =>
                              this.widget.provider.fantasyName = value,
                          decoration: InputDecoration(
                            labelText: 'Nome Fantasia *',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().length < 4) {
                              return 'Nome deve ter no mínimo 4 caracteres...';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          key: ValueKey('email'),
                          keyboardType: TextInputType.emailAddress,
                          initialValue: this.widget.provider.email,
                          // controller: _emailController
                          // ..text = this.widget.provider.email,
                          onChanged: (value) =>
                              this.widget.provider.email = value,
                          // onSubmitted: (_) => null,
                          // keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'E-Mail *',
                          ),
                          validator: (value) {
                            if (value == null || !value.contains('@')) {
                              return 'Forneça um e-mail válido.';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          key: ValueKey('address'),
                          initialValue: this.widget.provider.address,
                          // controller: _addressController
                          //   ..text = this.widget.provider.address,
                          // onSubmitted: (_) => null,
                          onChanged: (value) =>
                              this.widget.provider.address = value,
                          decoration: InputDecoration(
                            labelText: 'Endereço',
                          ),
                        ),
                        TextFormField(
                          key: ValueKey('city'),
                          initialValue: this.widget.provider.city,
                          // controller: _cityController
                          //   ..text = this.widget.provider.city,
                          // onSubmitted: (_) => null,
                          onChanged: (value) =>
                              this.widget.provider.city = value,
                          decoration: InputDecoration(
                            labelText: 'Cidade',
                          ),
                        ),
                        TextFormField(
                          key: ValueKey('uf'),
                          initialValue: this.widget.provider.uf,
                          // controller: _ufController
                          //   ..text = this.widget.provider.uf,
                          // onSubmitted: (_) => null,
                          onChanged: (value) => this.widget.provider.uf = value,
                          decoration: InputDecoration(
                            labelText: 'UF',
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            RaisedButton(
                              child: Text('Atualizar'),
                              color: Theme.of(context).primaryColor,
                              textColor:
                                  Theme.of(context).textTheme.button.color,
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
      ),
    );
  }
}
