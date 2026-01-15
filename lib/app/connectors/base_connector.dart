import 'package:personal_expense_tracker/app/helpers/db_helper.dart';
import 'package:personal_expense_tracker/app/models/base_model.dart';

abstract mixin class BaseConnector<T extends BaseModel<dynamic>> {
  final DBHelper _helper = DBHelper.getInstance();

  String get table;

  Future<int> remove(T model) async {
    final int result = await _helper.delete(table, 'id=?', [model.id]);
    model.synced = false;
    updateSyncStatus(model);

    return result;
  }

  Future<List<T>> filter({
    String? where,
    List<Object>? whereArgs,
    int? limit,
    String? orderBy,
  }) async {
    List<Map<String, dynamic>> data = await _helper.getData(
      table: table,
      where: where,
      whereArgs: whereArgs,
      limit: limit,
      orderBy: orderBy,
    );

    List<T> models = data.map((Map<String, dynamic> item) => toObject(item)).toList();
    return models;
  }

  Future<List<T>> getAll() async {
    List<Map<String, dynamic>> data = await _helper.getData(table: table);
    List<T> models = data.map((Map<String, dynamic> item) => toObject(item)).toList();
    return models;
  }

  Future<T> getById(String id) async {
    Map<String, dynamic> data = await _helper.getDataById(table: table, id: id);
    return toObject(data);
  }

  Future<int> insertOrUpdate(T model) async {
    if (model.id == null) {
      return insert(model);
    } else {
      model.updatedAt = DateTime.now();
      Map<String, dynamic> data = model.toMap();

      return await _helper.update(table: table, data: data, where: 'id=?', whereArgs: [model.id]);
    }
  }

  Future<int> insert(T model) async {
    Map<String, dynamic> data = model.toMap();
    data['id'] = model.id;

    String id = await _helper.insert(table: table, data: data);
    model.id = id;
    return 1;
  }

  Future<int> updateSyncStatus(T model) async {
    return await _helper.update(
      table: table,
      data: {'synced': model.synced ? 1 : 0},
      where: 'id=?',
      whereArgs: [model.id],
    );
  }

  T toObject(Map<String, dynamic> data);
}
