import 'package:personal_expense_tracker/app/helpers/db_helper.dart';
import 'package:personal_expense_tracker/app/models/base_model.dart';

abstract mixin class BaseConnector<T extends BaseModel<dynamic>> {
  final DBHelper _helper = DBHelper.getInstance();

  String get table;

  Future<int> remove(T model) async {
    return await _helper.delete(table, 'id=?', [model.id]);
  }

  Future<List<T>> getAll() async {
    List<Map<String, dynamic>> data = await _helper.getData(table: table);
    List<T> models = data.map((Map<String, dynamic> item) => toObject(item)).toList();
    return models;
  }

  Future<T> getById(int id) async {
    Map<String, dynamic> data = await _helper.getDataById(table: table, id: id);
    return toObject(data);
  }

  Future<int> insertOrUpdate(T model) async {
    if (model.id == null) {
      int id = await _helper.insert(table: table, data: model.toMap());
      model.id = id;
      return id;
    } else {
      return await _helper.update(table: table, data: model.toMap(), where: 'id=?', whereArgs: [model.id]);
    }
  }

  T toObject(Map<String, dynamic> data);
}
