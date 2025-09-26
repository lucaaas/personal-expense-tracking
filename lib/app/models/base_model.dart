import 'package:personal_expense_tracker/app/connectors/base_connector.dart';
import 'package:personal_expense_tracker/app/helpers/api_helper.dart';
import 'package:uuid/uuid.dart';

abstract class BaseModel<T extends BaseModel<dynamic>> with BaseConnector<T>, ApiHelper {
  String? id;
  DateTime createdAt;
  bool synced;

  BaseModel({
    this.id,
    DateTime? createdAt,
    this.synced = false,
  }) : createdAt = createdAt ?? DateTime.now();

  List<int>? get byteId => id != null ? Uuid.parse(id!) : null;

  Map<String, dynamic> toMap();

  Future<String> save() async {
    await super.insertOrUpdate(this as T); // save to local database and get id

    return id!;
  }

  Future<int> delete() {
    return super.remove(this as T);
  }

  Map<String, dynamic> toApiMap() {
    return {
      id.toString(): toMap(),
    };
  }

  @override
  String get entity => table;
}
