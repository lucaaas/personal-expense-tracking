import 'package:flutter/foundation.dart';
import 'package:personal_expense_tracker/app/connectors/base_connector.dart';
import 'package:personal_expense_tracker/app/helpers/shared_preferences_helper.dart';

import '../helpers/firebase_helper.dart';

abstract class BaseModel<T extends BaseModel<dynamic>> with BaseConnector<T>, FirebaseHelper {
  String? id;
  DateTime createdAt;
  DateTime updatedAt;
  bool synced;

  BaseModel({this.id, DateTime? createdAt, DateTime? updatedAt, this.synced = false})
    : createdAt = createdAt ?? DateTime.now(),
      updatedAt = updatedAt ?? DateTime.now();

  @mustCallSuper
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'synced': synced ? 1 : 0,
    };
  }

  Future<String> save() async {
    await super.insertOrUpdate(this as T); // save to local database and get id
    await sendToServer();

    return id!;
  }

  @protected
  Future<void> sendToServer() async {
    await addDataToId(id!, toMap());
    synced = true;
    await super.updateSyncStatus(this as T);
  }

  Future<int> delete() {
    return super.remove(this as T);
  }

  Future<void> sync() async {
    await saveFromServer();
    await sendUnsyncedToServer();
  }

  @protected
  Future<void> sendUnsyncedToServer() async {
    List<T> unsyncedData = await filter(where: 'synced=0');
    for (T model in unsyncedData) {
      model.sendToServer();
    }
  }

  @protected
  Future<void> saveFromServer() async {
    final SharedPreferencesHelper sharedPrefs = await SharedPreferencesHelper.getInstance();

    DateTime? lastSync = sharedPrefs.getLastSyncTime(table);

    try {
      List<Map<String, dynamic>> entities = await getAllSinceDate(lastSync);

      for (Map<String, dynamic> entity in entities) {
        T model = toObject(entity);
        model.synced = true;
        await super.insert(model);
      }

      sharedPrefs.setLastSyncTime(table, DateTime.now());
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing $table: $e');
      }
    }
  }

  @override
  String get collection => table;
}
