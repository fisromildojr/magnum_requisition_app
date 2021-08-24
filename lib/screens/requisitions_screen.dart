import 'package:magnum_requisition_app/screens/requisition_filter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  String filterVal = '';
  String filterNumForn = '';
  AuthData user;

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

  void setFilter(String fv, String fnf) {
    Navigator.of(context).pop();
    setState(() {
      this.filterVal = fv;
      this.filterNumForn = fnf;
    });
  }

  Future<void> _deleteRequisition(requisition) async {
    Navigator.of(context).pop();

    FirebaseFirestore.instance
        .collection('requisitions')
        .doc(requisition.id)
        .delete();
  }

  void showModalFilter() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return RequisitionFilter(callback: this.setFilter);
        });
  }

  GestureDetector listRequisition(Requisition rq, user) {
    return GestureDetector(
      // onTap: user.isAdmin
      //     ? () => _selectRequisition(context, requisition, user)
      //     : null,
      onTap: () => _selectRequisition(context, rq, user),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: rq.status == 'PENDENTE'
              ? Colors.amber
              : rq.status == 'NEGADO'
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
                      rq.nameDepartment +
                          ' - ' +
                          DateFormat('dd/MM/y - HH:mm:ss')
                              .format(rq.createdAt.toDate()),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (rq.status == 'PENDENTE' && rq.idUserRequested == user.id)
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
                                  TextButton(
                                    child: Text('Cancel'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                  TextButton(
                                    child: Text('Continuar'),
                                    onPressed: () => _deleteRequisition(rq),
                                  ),
                                ],
                              );
                            });
                      },
                    ),
                  // if (documents[i]['status'] != 'PENDENTE')
                  Text(
                    rq.number != null
                        ? 'Nº: ${rq.number.toString()}'
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
                    DateFormat('dd/MM/y').format(rq.purchaseDate.toDate()),
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
                    rq.description,
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
                    rq.nameProvider,
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
                    rq.nameDepartment,
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
                    rq.nameSector,
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
                    rq.nameCategory,
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
                      rq.nameUserRequested,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            if (rq.status == 'PENDENTE')
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
                      rq.status,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            else if (rq.status == 'NEGADO')
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
                      'Negado por ${rq.solvedByName}',
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
                      'Aprovado por ${rq.solvedByName}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'R\$ ${rq.value.toStringAsFixed(2)}',
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
  }

  Stream getReqFirebase(bool adm, String filters) {
    //Pega os itens do filtro
    var p = filters.split(":");
    //Campos usados o filtro
    List<String> campos = ['status', 'value', 'docProvider'];
    //Armazena as posições dos campos que serão filtrados
    List<int> pos = [];
    //Preenche as posiçoes
    for (int i = 0; i <= p.length - 1; i++) {
      if (p[i] != '') {
        pos.add(i);
      }
    }
    if (adm) {
      if (pos.length == 0) {
        return FirebaseFirestore.instance
            .collection('requisitions')
            .orderBy('createdAt', descending: true)
            .snapshots();
      } else {
        if (pos.length == 1) {
          return FirebaseFirestore.instance
              .collection('requisitions')
              .where(campos[pos[0]],
                  isEqualTo: (campos[pos[0]] == 'value'
                      ? double.parse(p[pos[0]])
                      : p[pos[0]]))
              .orderBy('createdAt', descending: true)
              .snapshots();
        } else {
          if (pos.length == 2) {
            return FirebaseFirestore.instance
                .collection('requisitions')
                .where(campos[pos[0]],
                    isEqualTo: (campos[pos[0]] == 'value'
                        ? double.parse(p[pos[0]])
                        : p[pos[0]]))
                .where(campos[pos[1]],
                    isEqualTo: (campos[pos[1]] == 'value'
                        ? double.parse(p[pos[1]])
                        : p[pos[1]]))
                .orderBy('createdAt', descending: true)
                .snapshots();
          } else {
            if (pos.length == 3) {
              return FirebaseFirestore.instance
                  .collection('requisitions')
                  .where(campos[pos[0]],
                      isEqualTo: (campos[pos[0]] == 'value'
                          ? double.parse(p[pos[0]])
                          : p[pos[0]]))
                  .where(campos[pos[1]],
                      isEqualTo: (campos[pos[1]] == 'value'
                          ? double.parse(p[pos[1]])
                          : p[pos[1]]))
                  .where(campos[pos[2]], isEqualTo: p[pos[2]])
                  .orderBy('createdAt', descending: true)
                  .snapshots();
            }
          }
        }
      }
    } else {
      if (pos.length == 0) {
        return FirebaseFirestore.instance
            .collection('requisitions')
            .where('idUserRequested', isEqualTo: user.id)
            .orderBy('createdAt', descending: true)
            .snapshots();
      } else {
        if (pos.length == 1) {
          return FirebaseFirestore.instance
              .collection('requisitions')
              .where('idUserRequested', isEqualTo: user.id)
              .where(campos[pos[0]],
                  isEqualTo: (campos[pos[0]] == 'value'
                      ? double.parse(p[pos[0]])
                      : p[pos[0]]))
              .orderBy('createdAt', descending: true)
              .snapshots();
        } else {
          if (pos.length == 2) {
            return FirebaseFirestore.instance
                .collection('requisitions')
                .where('idUserRequested', isEqualTo: user.id)
                .where(campos[pos[0]],
                    isEqualTo: (campos[pos[0]] == 'value'
                        ? double.parse(p[pos[0]])
                        : p[pos[0]]))
                .where(campos[pos[1]],
                    isEqualTo: (campos[pos[1]] == 'value'
                        ? double.parse(p[pos[1]])
                        : p[pos[1]]))
                .orderBy('createdAt', descending: true)
                .snapshots();
          } else {
            if (pos.length == 3) {
              return FirebaseFirestore.instance
                  .collection('requisitions')
                  .where('idUserRequested', isEqualTo: user.id)
                  .where(campos[pos[0]],
                      isEqualTo: (campos[pos[0]] == 'value'
                          ? double.parse(p[pos[0]])
                          : p[pos[0]]))
                  .where(campos[pos[1]],
                      isEqualTo: (campos[pos[1]] == 'value'
                          ? double.parse(p[pos[1]])
                          : p[pos[1]]))
                  .where(campos[pos[2]], isEqualTo: p[pos[2]])
                  .orderBy('createdAt', descending: true)
                  .snapshots();
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context).settings.arguments as AuthData;
    this.user = user;
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
                    value: 'mais',
                    child: Container(
                      child: Row(
                        children: [
                          Icon(
                            Icons.add,
                            //color: Colors.amber,
                          ),
                          SizedBox(width: 8),
                          Text('Mais Filtros'),
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
                  } else if (filtro == 'mais') {
                    showModalFilter();
                  } else {
                    setState(() {
                      filter = '';
                      filterVal = '';
                      filterNumForn = '';
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: getReqFirebase(
            user.isAdmin, filter + ":" + filterVal + ":" + filterNumForn),
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
              return listRequisition(requisition, user);
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
