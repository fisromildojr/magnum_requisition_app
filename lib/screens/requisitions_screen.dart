import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:magnum_requisition_app/models/auth_data.dart';
import 'package:magnum_requisition_app/models/requisition.dart';
import 'package:magnum_requisition_app/utils/app_routes.dart';

class RequisitionsScreen extends StatefulWidget {
  @override
  _RequisitionsScreenState createState() => _RequisitionsScreenState();
}

class _RequisitionsScreenState extends State<RequisitionsScreen> {
  String filter = '';

  void _selectRequisition(
      BuildContext context, Requisition requisition, AuthData user) {
    Navigator.of(context).pushNamed(
      AppRoutes.REQUISITION_DETAILS,
      arguments: {
        'requisition': requisition,
        'user': user,
      },
    );
  }

  Future<void> _deleteRequisition(requisition) async {
    Navigator.of(context).pop();

    FirebaseFirestore.instance
        .collection('requisitions')
        .doc(requisition.id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context).settings.arguments as AuthData;
    return Scaffold(
      appBar: AppBar(
        title: Text('Requisições'),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                icon: Icon(
                  Icons.filter_alt,
                  color: Theme.of(context).primaryIconTheme.color,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'aprovado',
                    child: Container(
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            color: Colors.green,
                          ),
                          SizedBox(width: 8),
                          Text('Aprovados'),
                        ],
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'negado',
                    child: Container(
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            color: Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text('Negados'),
                        ],
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'pendente',
                    child: Container(
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            color: Colors.amber,
                          ),
                          SizedBox(width: 8),
                          Text('Pendentes'),
                        ],
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'limpar',
                    child: Container(
                      child: Row(
                        children: [
                          Icon(
                            Icons.close,
                            color: Colors.black,
                          ),
                          SizedBox(width: 8),
                          Text('Limpar Filtro'),
                        ],
                      ),
                    ),
                  ),
                ],
                onChanged: (filtro) {
                  if (filtro == 'aprovado') {
                    setState(() {
                      filter = 'APROVADO';
                    });
                  } else if (filtro == 'negado') {
                    setState(() {
                      filter = 'NEGADO';
                    });
                  } else if (filtro == 'pendente') {
                    setState(() {
                      filter = 'PENDENTE';
                    });
                  } else
                    setState(() {
                      filter = '';
                    });
                },
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: user.isAdmin
            ? filter == ''
                ? FirebaseFirestore.instance
                    .collection('requisitions')
                    .orderBy('createdAt', descending: true)
                    .snapshots()
                : FirebaseFirestore.instance
                    .collection('requisitions')
                    .where('status', isEqualTo: filter)
                    .orderBy('createdAt', descending: true)
                    .snapshots()
            : filter == ''
                ? FirebaseFirestore.instance
                    .collection('requisitions')
                    .where('idUserRequested', isEqualTo: user.id)
                    .orderBy('createdAt', descending: true)
                    .snapshots()
                : FirebaseFirestore.instance
                    .collection('requisitions')
                    .where('idUserRequested', isEqualTo: user.id)
                    .where('status', isEqualTo: filter)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Text('ERRO: ' + snapshot.error.toString());
          }

          final documents = snapshot.data.documents;

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (ctx, i) {
              final requisition = Requisition(
                id: documents[i].id,
                solvedIn: documents[i]['solvedIn'],
                createdAt: documents[i]['createdAt'],
                description: documents[i]['description'],
                idCategory: documents[i]['idCategory'],
                idDepartment: documents[i]['idDepartment'],
                idProvider: documents[i]['idProvider'],
                idSector: documents[i]['idSector'],
                idUserRequested: documents[i]['idUserRequested'],
                nameCategory: documents[i]['nameCategory'],
                nameDepartment: documents[i]['nameDepartment'],
                nameProvider: documents[i]['nameProvider'],
                emailProvider: documents[i]['emailProvider'],
                number: documents[i]['number'],
                docProvider: documents[i]['docProvider'],
                nameSector: documents[i]['nameSector'],
                nameUserRequested: documents[i]['nameUserRequested'],
                paymentForecastDate: documents[i]['paymentForecastDate'],
                purchaseDate: documents[i]['purchaseDate'],
                solvedByName: documents[i]['solvedByName'],
                solvedById: documents[i]['solvedById'],
                status: documents[i]['status'],
                value: documents[i]['value'],
              );
              return GestureDetector(
                // onTap: user.isAdmin
                //     ? () => _selectRequisition(context, requisition, user)
                //     : null,
                onTap: () => _selectRequisition(context, requisition, user),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: documents[i]['status'] == 'PENDENTE'
                        ? Colors.amber
                        : documents[i]['status'] == 'NEGADO'
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
                                documents[i]['nameDepartment'] +
                                    ' - ' +
                                    DateFormat('dd/MM/y - HH:mm:ss').format(
                                        documents[i]['createdAt'].toDate()),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (documents[i]['status'] == 'PENDENTE' &&
                                documents[i]['idUserRequested'] == user.id)
                              IconButton(
                                icon: Icon(Icons.delete),
                                color: Theme.of(context).errorColor,
                                onPressed: () {
                                  return showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text("Confirmação"),
                                          content: Text(
                                              "Você deseja excluir essa requisição?"),
                                          actions: [
                                            FlatButton(
                                              child: Text('Cancel'),
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                            ),
                                            FlatButton(
                                              child: Text('Continuar'),
                                              onPressed: () =>
                                                  _deleteRequisition(
                                                      requisition),
                                            ),
                                          ],
                                        );
                                      });
                                },
                              ),
                            if (documents[i]['status'] != 'PENDENTE')
                              Text(
                                documents[i]['number'] != null
                                    ? 'Nº: ${documents[i]['number'].toString()}'
                                    : 'Nº: ---',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Data da Compra: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              DateFormat('dd/MM/y').format(
                                  documents[i]['purchaseDate'].toDate()),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Descrição: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              documents[i]['description'],
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Fornecedor: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              documents[i]['nameProvider'],
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Departamento: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              documents[i]['nameDepartment'],
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Centro de Custo: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              documents[i]['nameSector'],
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Categoria: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              documents[i]['nameCategory'],
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (user.isAdmin)
                        Row(
                          children: [
                            Text(
                              'Solicitado por: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                documents[i]['nameUserRequested'],
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      if (documents[i]['status'] == 'PENDENTE')
                        Row(
                          children: [
                            Text(
                              'Status: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                documents[i]['status'],
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      else if (documents[i]['status'] == 'NEGADO')
                        Row(
                          children: [
                            Text(
                              'Status: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                'Negado por ${documents[i]['solvedByName']}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Text(
                              'Status: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                'Aprovado por ${documents[i]['solvedByName']}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'R\$ ${documents[i]['value'].toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
          // return Text('Chegou');
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          Navigator.of(context).pushNamed(
            AppRoutes.REQUISITION_FORM_SCREEN,
            arguments: user,
          );
        },
      ),
    );
  }
}
