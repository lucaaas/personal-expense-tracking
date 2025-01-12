import 'package:personal_expense_tracker/app/connectors/base_connector.dart';

abstract class BaseModel<T extends BaseModel<dynamic>> with BaseConnector<T> {
  int? id;
  DateTime createdAt;

  BaseModel({
    this.id,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap();

  Future<int> save() {
    return super.insertOrUpdate(this as T);
  }
}
