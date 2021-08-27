import 'package:magnum_requisition_app/models/auth_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:magnum_requisition_app/models/requisition.dart';
import 'package:magnum_requisition_app/utils/app_routes.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _paymentDateController = TextEditingController();
  DateTime _selectedPaymentDate;
  bool _isLoading = false;
  // Future<void> _aproveRequisition(
  //     BuildContext context, Requisition requisition, AuthData user) async {
  //   Navigator.of(context).pop();

  //   FirebaseFirestore.instance
  //       .collection('requisitions')
  //       .doc(requisition.id)
  //       .update({
  //     'solvedByName': user.name,
  //     'solvedById': user.id,
  //     'status': 'APROVADO',
  //     'solvedIn': DateTime.now(),
  //   });
  // }

  // Future<void> _disapproveRequisition(
  //     BuildContext context, Requisition requisition, AuthData user) async {
  //   Navigator.of(context).pop();

  //   await FirebaseFirestore.instance
  //       .collection('requisitions')
  //       .doc(requisition.id)
  //       .update({
  //     'solvedByName': user.name,
  //     'solvedById': user.id,
  //     'status': 'NEGADO',
  //     'solvedIn': DateTime.now(),
  //   });
  // }

  Future<void> _submitForm(Requisition requisition) async {
    bool isValid = _formKey.currentState.validate();
    if (isValid) {
      setState(() {
        _isLoading = true;
      });
      await FirebaseFirestore.instance
          .collection('requisitions')
          .doc(requisition.id)
          .update({
        'paidOut': true,
        'paymentDate': _selectedPaymentDate,
      }).then((_) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      });
    }
  }

  _showPaymentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      } else {
        setState(() {
          this._selectedPaymentDate = pickedDate;
          _paymentDateController.text =
              DateFormat('dd/MM/y').format(_selectedPaymentDate);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    final requisition = arguments['requisition'] as Requisition;
    final user = arguments['user'] as AuthData;

    return _isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text('Registrar Pagamento'),
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
            body: ListView.builder(
              itemCount: 1,
              itemBuilder: (ctx, i) {
                return GestureDetector(
                  onTap: () => null,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: requisition.status == 'PENDENTE'
                              ? Colors.amber
                              : requisition.status == 'NEGADO'
                                  ? Colors.red
                                  : Colors.green,
                        ),
                        padding: EdgeInsets.all(6),
                        margin: EdgeInsets.all(2),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      requisition.nameDepartment +
                                          ' - ' +
                                          DateFormat('dd/MM/y - HH:mm:ss')
                                              .format(requisition.createdAt
                                                  .toDate()),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  // if (requisition.status != 'PENDENTE')
                                  Text(
                                    requisition.number != null
                                        ? 'Nº: ${requisition.number.toString()}'
                                        : 'Nº: ---',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                              child: Row(
                                children: [
                                  Text(
                                    'Data da Compra: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      DateFormat('dd/MM/y').format(
                                          requisition.purchaseDate.toDate()),
                                      softWrap: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                              child: Row(
                                children: [
                                  Text(
                                    'Descrição: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      requisition.description,
                                      softWrap: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                              child: Row(
                                children: [
                                  Text(
                                    'Fornecedor: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(requisition.nameProvider),
                                  ),
                                ],
                              ),
                            ),
                            if (requisition.docProvider.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                child: Row(
                                  children: [
                                    Text(
                                      'Documento do Fornecedor: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(requisition.docProvider),
                                    ),
                                  ],
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                              child: Row(
                                children: [
                                  Text(
                                    'Departamento: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(requisition.nameDepartment),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                              child: Row(
                                children: [
                                  Text(
                                    'Centro de Custo: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(requisition.nameSector),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                              child: Row(
                                children: [
                                  Text(
                                    'Categoria: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(requisition.nameCategory),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                              child: Row(
                                children: [
                                  Text(
                                    'Solicitado por: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(requisition.nameUserRequested),
                                  ),
                                ],
                              ),
                            ),
                            if (requisition.status == 'PENDENTE')
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                child: Row(
                                  children: [
                                    Text(
                                      'Status: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(requisition.status),
                                    ),
                                  ],
                                ),
                              )
                            else if (requisition.status == 'NEGADO')
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                child: Row(
                                  children: [
                                    Text(
                                      'Status: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                          'Negado por ${requisition.solvedByName}'),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                child: Row(
                                  children: [
                                    Text(
                                      'Status: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                          'Aprovado por ${requisition.solvedByName}'),
                                    ),
                                  ],
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                              child: Row(
                                children: [
                                  Text(
                                    (requisition.paidOut)
                                        ? 'Data do Pagamento: '
                                        : 'Data Prevista Pagamento: ',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      (requisition.paidOut)
                                          ? DateFormat('dd/MM/y').format(
                                              requisition.paymentDate.toDate())
                                          : DateFormat('dd/MM/y').format(
                                              requisition.paymentForecastDate
                                                  .toDate()),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'R\$ ${requisition.value.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                key: ValueKey('paymentForecastDate'),
                                controller: _paymentDateController,
                                readOnly: true,
                                decoration: InputDecoration(
                                    labelText: 'Data do Pagamento*'),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Selecione uma Data...';
                                  }
                                  return null;
                                },
                                onTap: _showPaymentDatePicker,
                              ),
                              SizedBox(height: 8.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => _submitForm(requisition),
                                    child: Text('Registrar Pagamento'),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
  }
}
