import 'package:magnum_requisition_app/components/category_list.dart';
import 'package:magnum_requisition_app/models/category.dart';
import 'package:magnum_requisition_app/utils/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter/material.dart';

import 'package:magnum_requisition_app/components/departments_list_requisition.dart';
import 'package:magnum_requisition_app/components/provider_list.dart';
import 'package:magnum_requisition_app/components/sector_list_requisition.dart';
import 'package:magnum_requisition_app/models/auth_data.dart';
import 'package:magnum_requisition_app/models/department.dart';
import 'package:magnum_requisition_app/models/provider.dart';
import 'package:magnum_requisition_app/models/sector.dart';

import 'package:intl/intl.dart';

class RequisitionFormScreen extends StatefulWidget {
  @override
  _RequisitionFormScreenState createState() => _RequisitionFormScreenState();
}

class _RequisitionFormScreenState extends State<RequisitionFormScreen> {
  bool loaded = false;

  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _fantasyNameProviderController = TextEditingController();
  final _purchaseDateController = TextEditingController();
  final _paymentForecastDateController = TextEditingController();
  final _nameDepartmentController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _nameSectorController = TextEditingController();
  final _nameCategoryController = TextEditingController();
  final _valueController = MoneyMaskedTextController();
  final _docProviderController = TextEditingController();

  DateTime _selectedPurchaseDate;
  DateTime _selectedPaymentForecastDate;

  Provider selectedProvider;
  Department selectedDepartment;
  Sector selectedSector;
  Category selectedCategory;

  _showPurchaseDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        this._selectedPurchaseDate = pickedDate;
        _purchaseDateController.text =
            DateFormat('dd/MM/y').format(_selectedPurchaseDate);
      });
    });
  }

  _showPaymentForecastDatePicker() {
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
          this._selectedPaymentForecastDate = pickedDate;
          _paymentForecastDateController.text =
              DateFormat('dd/MM/y').format(_selectedPaymentForecastDate);
        });
      }
    });
  }

  _openProviderListModal(context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ProviderList(_selectedProvider);
      },
    );
  }

  _openDepartmentListModal(context, user) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return DepartmentListRequisition(_selectedDepartment, user);
      },
    );
  }

  _openSectorListModal(context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SectorListRequisition(_selectedSector, this.selectedDepartment);
      },
    );
  }

  _openCategoryListModal(context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return CategoryList(_selectedCategory);
      },
    );
  }

  _selectedProvider(Provider provider) {
    Navigator.of(context).pop();
    setState(() {
      this.selectedProvider = provider;
      _fantasyNameProviderController.text = provider.fantasyName;
    });
  }

  _selectedDepartment(Department department) {
    Navigator.of(context).pop();
    setState(() {
      this.selectedDepartment = department;
      _nameDepartmentController.text = department.name;
      _nameSectorController.clear();
    });
  }

  _selectedSector(Sector sector) {
    Navigator.of(context).pop();
    setState(() {
      this.selectedSector = sector;
      _nameSectorController.text = sector.name;
    });
  }

  _selectedCategory(Category category) {
    Navigator.of(context).pop();
    setState(() {
      this.selectedCategory = category;
      _nameCategoryController.text = category.name;
    });
  }

  Future<void> _addRequisition() async {
    bool isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    final user = ModalRoute.of(context).settings.arguments as AuthData;

    if (isValid) {
      Navigator.of(context).popAndPushNamed(
        AppRoutes.REQUISITIONS,
        arguments: user,
      );
      await FirebaseFirestore.instance.collection('requisitions').add({
        'solvedIn': null,
        'createdAt': DateTime.now(),
        'description': _descriptionController.text,
        'idCategory': selectedCategory.id,
        'idDepartment': selectedDepartment.id,
        'idProvider': selectedProvider.id,
        'idSector': selectedSector.id,
        'idUserRequested': user.id,
        'nameCategory': selectedCategory.name,
        'nameDepartment': selectedDepartment.name,
        'nameProvider': selectedProvider.fantasyName,
        'emailProvider': selectedProvider.email,
        'number': null,
        'docProvider': _docProviderController.text.toUpperCase(),
        'nameSector': selectedSector.name,
        'nameUserRequested': user.name,
        'paymentForecastDate': _selectedPaymentForecastDate,
        'purchaseDate': _selectedPurchaseDate,
        'solvedByName': null,
        'solvedById': null,
        'status': 'PENDENTE',
        'value': _valueController.numberValue,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context).settings.arguments as AuthData;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Solicitar Requisição"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  key: ValueKey('purchaseDate'),
                  controller: _purchaseDateController,
                  readOnly: true,
                  decoration: InputDecoration(labelText: 'Data da Compra*'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Selecione uma Data...';
                    }
                    return null;
                  },
                  onTap: _showPurchaseDatePicker,
                ),
                TextFormField(
                  key: ValueKey('department'),
                  controller: _nameDepartmentController,
                  readOnly: true,
                  decoration: InputDecoration(labelText: 'Departamento*'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Selecione um Departamento...';
                    }
                    return null;
                  },
                  onTap: () => _openDepartmentListModal(context, user),
                ),
                TextFormField(
                  key: ValueKey('sector'),
                  controller: _nameSectorController,
                  readOnly: true,
                  decoration: InputDecoration(labelText: 'Centro de Custo*'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Selecione um Centro de Custo...';
                    }
                    return null;
                  },
                  onTap: () => selectedDepartment != null
                      ? _openSectorListModal(context)
                      : _scaffoldKey.currentState.showSnackBar(SnackBar(
                          content: Text('Selecione um Departamento...'),
                          backgroundColor: Colors.red,
                        )),
                ),
                TextFormField(
                  key: ValueKey('provider'),
                  controller: _fantasyNameProviderController,
                  readOnly: true,
                  decoration: InputDecoration(labelText: 'Fornecedor*'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Selecione um Fornecedor...';
                    }
                    return null;
                  },
                  onTap: () => _openProviderListModal(context),
                ),
                TextFormField(
                  key: ValueKey('category'),
                  controller: _nameCategoryController,
                  readOnly: true,
                  decoration:
                      InputDecoration(labelText: 'Categoria da Compra*'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Selecione uma Categoria...';
                    }
                    return null;
                  },
                  onTap: () => _openCategoryListModal(context),
                ),
                TextFormField(
                  key: ValueKey('value'),
                  controller: _valueController,
                  decoration: InputDecoration(labelText: 'Valor*'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (_valueController.numberValue <= 0.00) {
                      return 'Informe um valor válido...';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  key: ValueKey('paymentForecastDate'),
                  controller: _paymentForecastDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                      labelText: 'Data Prevista para Pagamento*'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Selecione uma Data...';
                    }
                    return null;
                  },
                  onTap: _showPaymentForecastDatePicker,
                ),
                TextFormField(
                  key: ValueKey('docProvider'),
                  controller: _docProviderController,
                  decoration:
                      InputDecoration(labelText: 'Nr Documento do Fornecedor'),
                  // validator: (value) {
                  // if (value.isEmpty || value.length < 3) {
                  //   return 'Descrição da compra...';
                  // }
                  // return null;
                  // },
                ),
                TextFormField(
                  key: ValueKey('description'),
                  controller: _descriptionController,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(labelText: 'Descrição*'),
                  validator: (value) {
                    if (value.isEmpty || value.length < 3) {
                      return 'Descrição da compra...';
                    }
                    return null;
                  },
                ),
                Divider(),
                Row(
                  children: [
                    Expanded(
                      child: ButtonTheme(
                        splashColor: Theme.of(context).primaryColor,
                        height: 40.0,
                        child: RaisedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          color: Colors.grey,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0)),
                          child: Text("Cancelar"),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: ButtonTheme(
                        splashColor: Theme.of(context).primaryColor,
                        height: 40.0,
                        child: RaisedButton(
                          onPressed: _addRequisition,
                          color: Theme.of(context).primaryColor,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0)),
                          child: Text("Solicitar"),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
