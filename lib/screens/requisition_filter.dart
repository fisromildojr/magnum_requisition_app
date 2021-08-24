import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class RequisitionFilter extends StatefulWidget {
  final Function callback;
  const RequisitionFilter({Key key, this.callback}) : super(key: key);
  @override
  _RequisitionFilterViewState createState() => _RequisitionFilterViewState();
}

class _RequisitionFilterViewState extends State<RequisitionFilter> {
  final _txtValor = MoneyMaskedTextController();
  final _txtNumDoc = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
            child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _txtValor,
                      key: ValueKey('valor'),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Valor',
                      ),
                    ),
                    TextFormField(
                      controller: _txtNumDoc,
                      key: ValueKey('numforn'),
                      decoration: InputDecoration(
                        labelText: 'Doc Fornecedor',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              widget.callback(
                                  _txtValor.numberValue == 0.0
                                      ? ""
                                      : _txtValor.numberValue.toString(),
                                  _txtNumDoc.text);
                            });
                          },
                          icon: Icon(Icons.filter_alt),
                          label: Text('Filtrar'),
                        ),
                      ),
                    )
                  ],
                ))),
      ),
    );
  }
}
