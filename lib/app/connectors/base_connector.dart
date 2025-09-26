import 'package:personal_expense_tracker/app/helpers/db_helper.dart';
import 'package:personal_expense_tracker/app/models/base_model.dart';
import 'package:uuid/uuid.dart';

abstract mixin class BaseConnector<T extends BaseModel<dynamic>> {
  final DBHelper _helper = DBHelper.getInstance();

  String get table;

  Future<int> remove(T model) async {
    return await _helper.delete(table, 'id=?', [model.byteId]);
  }

  Future<List<T>> filter(
      {String? where, List<Object>? whereArgs, int? limit, String? orderBy}) async {
    List<Map<String, dynamic>> data = await _helper.getData(
      table: table,
      where: where,
      whereArgs: whereArgs,
      limit: limit,
      orderBy: orderBy,
    );

    List<T> models = data.map((Map<String, dynamic> item) => _toObject(item)).toList();
    return models;
  }

  Future<List<T>> getAll() async {
    List<Map<String, dynamic>> data = await _helper.getData(table: table);
    List<T> models = data.map((Map<String, dynamic> item) => _toObject(item)).toList();
    return models;
  }

  Future<T> getById(List<int> id) async {
    Map<String, dynamic> data = await _helper.getDataById(table: table, id: id);
    return _toObject(data);
  }

  Future<int> insertOrUpdate(T model) async {
    if (model.id == null) {
      String id = await _helper.insert(table: table, data: model.toMap());
      model.id = id;
      return 1;
    } else {
      return await _helper
          .update(table: table, data: model.toMap(), where: 'id=?', whereArgs: [model.id]);
    }
  }

  Future<int> updateSyncStatus(T model) async {
    return await _helper.update(
      table: table,
      data: {'synced': model.synced ? 1 : 0},
      where: 'id=?',
      whereArgs: [model.byteId],
    );
  }

  T _toObject(Map<String, dynamic> data) {
    Map<String, dynamic> modifiableData = Map.from(data);

    if (modifiableData.containsKey('id')) {
      modifiableData['id'] = Uuid.unparse(modifiableData['id']);
    }

    return toObject(modifiableData);
  }

  T toObject(Map<String, dynamic> data);
}
