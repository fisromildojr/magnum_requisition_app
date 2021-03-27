import 'package:magnum_requisition_app/models/auth_data.dart';
import 'package:magnum_requisition_app/models/category.dart';
import 'package:magnum_requisition_app/models/department.dart';
import 'package:magnum_requisition_app/models/provider.dart';
import 'package:magnum_requisition_app/models/sector.dart';

class FilterReports {
  DateTime initialDate;
  DateTime finalDate;
  Category category;
  Department department;
  Provider provider;
  Sector sector;
  AuthData userRequested;

  FilterReports({
    this.initialDate,
    this.finalDate,
    this.category,
    this.department,
    this.provider,
    this.sector,
    this.userRequested,
  });
}
