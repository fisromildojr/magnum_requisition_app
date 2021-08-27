import 'package:cloud_firestore/cloud_firestore.dart';

class Requisition {
  String id;
  Timestamp solvedIn;
  Timestamp createdAt;
  String description;
  String idCategory;
  String idDepartment;
  String idProvider;
  String idSector;
  String idUserRequested;
  String nameCategory;
  String nameDepartment;
  String nameProvider;
  String emailProvider;
  int number;
  String docProvider;
  String nameSector;
  String nameUserRequested;
  Timestamp paymentForecastDate;
  Timestamp purchaseDate;
  String solvedByName;
  String solvedById;
  String status;
  double value;
  Timestamp paymentDate;
  String proofPayment;
  bool paidOut;

  Requisition({
    this.id,
    this.solvedIn,
    this.createdAt,
    this.description,
    this.idCategory,
    this.idDepartment,
    this.idProvider,
    this.idSector,
    this.idUserRequested,
    this.nameCategory,
    this.nameDepartment,
    this.nameProvider,
    this.emailProvider,
    this.number,
    this.docProvider,
    this.nameSector,
    this.nameUserRequested,
    this.paymentForecastDate,
    this.purchaseDate,
    this.solvedByName,
    this.solvedById,
    this.status,
    this.value,
    this.paymentDate,
    this.proofPayment,
    this.paidOut,
  });
}
