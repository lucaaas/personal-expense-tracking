import 'package:personal_expense_tracker/app/connectors/base_connector.dart';
import 'package:uuid/uuid.dart';

import '../helpers/firebase_helper.dart';

abstract class BaseModel<T extends BaseModel<dynamic>> with BaseConnector<T>, FirebaseHelper {
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
    await addDataToId(id!, toMap()); // save to firebase

    return id!;
  }

  Future<int> delete() {
    return super.remove(this as T);
  }

  @override
  String get collection => table;
}
