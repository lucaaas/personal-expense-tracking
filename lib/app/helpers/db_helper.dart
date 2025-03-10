import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static DBHelper? _instance;
  late Database _database;

  DBHelper._() {
    _initDatabase();
  }

  static getInstance() {
    _instance ??= DBHelper._();
    return _instance;
  }

  /// This deletes rows from a table that satisfies the [where] condition.
  ///
  /// Returns the number of rows deleted.
  Future<int> delete(String table, String where, List whereArgs) async {
    final db = await _database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  /// This queries a table and return the rows found.
  ///
  /// Returns a [List<Map<String, dynamic>>]
  ///
  /// If no filters is provided, it returns a list containing all rows of [table].
  Future<List<Map<String, dynamic>>> getData({
    required String table,
    List<String>? columns,
    String? where,
    List<Object>? whereArgs,
    bool? distinct,
    String? groupBy,
    int? limit,
    String? orderBy,
  }) async {
    final db = await _database;
    return db.query(
      table,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      distinct: distinct,
      groupBy: groupBy,
      orderBy: orderBy,
      limit: limit,
    );
  }

  /// This queries a [table] and return a row containing the [id].
  ///
  /// Return a Map<String, dynamic>.
  /// ```dart
  ///  Map<String, dynamic> data = await database.getDataById(tableModel, model.id);
  ///  ```
  Future<Map<String, dynamic>> getDataById({required String table, required int id}) async {
    final db = await _database;
    List<Map<String, dynamic>> data = await db.query(table, where: 'id=?', whereArgs: [id]);
    return data.first;
  }

  /// Creates a new row on [table]
  ///
  /// Returns the new id.
  /// ```dart
  /// int idInserted = await database.insert(tableModel, model.toMap());
  /// ```
  Future<int> insert({required String table, required Map<String, dynamic> data}) async {
    final db = await _database;
    return await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Updates the [table] with [data] values that satisfies the [where] condition.
  ///
  /// Returns the number of affected rows.
  /// ```dart
  /// int rowsAffected = await database.update(tableModel, model.toMap(), 'id = ?', [model.id]);
  /// ```
  Future<int> update({
    required String table,
    required Map<String, dynamic> data,
    required String where,
    required List whereArgs,
  }) async {
    final db = await _database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  /// Opens and initializes the database connection.
  ///
  /// This method retrieves the database path and opens a connection to the
  /// 'finances.db' database. If the database doesn't exist, it creates the
  /// database and sets up the necessary tables: 'credit_card', 'category',
  /// 'transaction', and 'transaction_has_category'.
  ///
  /// **Returns:** A [Future] that resolves to the opened [Database] object.
  Future<void> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    _database = await openDatabase(path.join(dbPath, 'finances.db'), onCreate: (db, version) {
      db.execute('PRAGMA foreign_keys = ON');
      db.execute(
          'CREATE TABLE credit_card(id INTEGER PRIMARY KEY, name TEXT NOT NULL, color INTEGER, createdAt TEXT NOT NULL);');
      db.execute(
          'CREATE TABLE category(id INTEGER PRIMARY KEY NOT NULL, name TEXT NOT NULL, color INTEGER, description TEXT, createdAt TEXT NOT NULL);');
      db.execute(
          'CREATE TABLE transactions(id INTEGER PRIMARY KEY NOT NULL, description TEXT NOT NULL, value FLOAT NOT NULL, date TEXT, createdAt TEXT NOT NULL, credit_card INTEGER, FOREIGN KEY(credit_card) REFERENCES credit_card(id));');
      db.execute(
          'CREATE TABLE transaction_has_category(transaction_id INTEGER NOT NULL, category_id INTEGER NOT NULL, createdAt TEXT NOT NULL, PRIMARY KEY(transaction_id, category_id), FOREIGN KEY(transaction_id) REFERENCES transactions(id), FOREIGN KEY(category_id) REFERENCES category(id));');
    }, version: 1);
  }
}
