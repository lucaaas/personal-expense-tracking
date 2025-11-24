import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class DBHelper {
  static DBHelper? _instance;
  late Database _database;

  DBHelper._();

  static DBHelper getInstance() {
    if (_instance == null) {
      _instance = DBHelper._();
      _instance!._initDatabase();
    }

    return _instance!;
  }

  /// This deletes rows from a table that satisfies the [where] condition.
  ///
  /// Returns the number of rows deleted.
  Future<int> delete(String table, String where, List whereArgs) async {
    final db = _database;
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
    String? where = '',
    List<Object>? whereArgs,
    bool? distinct,
    String? groupBy,
    int? limit,
    String? orderBy,
  }) async {
    if (where != null && where.isNotEmpty) {
      where = 'isDeleted = 0 AND ($where)';
    } else {
      where = 'isDeleted = 0';
    }

    return _database.query(
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
  Future<Map<String, dynamic>> getDataById({required String table, required String id}) async {
    final db = _database;
    List<Map<String, dynamic>> data = await db.query(table, where: 'id=?', whereArgs: [id]);
    return data.first;
  }

  /// Creates a new row on [table]
  ///
  /// Returns the new id.
  /// ```dart
  /// int idInserted = await database.insert(tableModel, model.toMap());
  /// ```
  Future<String> insert({required String table, required Map<String, dynamic> data}) async {
    String id = data['id'] ?? "";

    if (data.containsKey('id') && data['id'] == null) {
      id = const Uuid().v4obj().uuid;
      data['id'] = id;
    }
    await _database.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);

    return id;
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
    return _database.update(table, data, where: where, whereArgs: whereArgs);
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
    _database = await openDatabase(
      path.join(dbPath, 'finances.db'),
      onCreate: (db, version) async {
        db.execute('PRAGMA foreign_keys = ON');
        await _createTables(db);
        await _createTriggers(db);
        await _createViews(db);
      },
      version: 1,
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute(
      'CREATE TABLE credit_card('
      ' id TEXT PRIMARY KEY, name TEXT NOT NULL, color INTEGER, synced INTEGER DEFAULT 0,'
      ' createdAt TEXT NOT NULL, updatedAt TEXT NOT NULL, isDeleted INTEGER NOT NULL DEFAULT 0);',
    );

    await db.execute(
      'CREATE TABLE category('
      ' id TEXT PRIMARY KEY NOT NULL, name TEXT NOT NULL, color INTEGER, description TEXT,'
      ' synced INTEGER DEFAULT 0, createdAt TEXT NOT NULL, updatedAt TEXT NOT NULL,'
      ' isDeleted INTEGER NOT NULL DEFAULT 0);',
    );

    await db.execute(
      'CREATE TABLE transactions('
      ' id TEXT PRIMARY KEY NOT NULL, description TEXT NOT NULL, value FLOAT NOT NULL,'
      ' date TEXT, synced INTEGER DEFAULT 0, createdAt TEXT NOT NULL, updatedAt TEXT NOT NULL,'
      ' isDeleted INTEGER NOT NULL DEFAULT 0,'
      ' credit_card TEXT, FOREIGN KEY(credit_card) REFERENCES credit_card(id));',
    );

    await db.execute(
      'CREATE TABLE transaction_has_category('
      ' transaction_id TEXT NOT NULL, category_id BLOB NOT NULL, synced INTEGER DEFAULT 0,'
      ' createdAt TEXT NOT NULL, updatedAt TEXT NOT NULL, isDeleted INTEGER NOT NULL DEFAULT 0,'
      ' PRIMARY KEY(transaction_id, category_id),'
      ' FOREIGN KEY(transaction_id) REFERENCES transactions(id), FOREIGN KEY(category_id) REFERENCES category(id));',
    );
  }

  Future<void> _createTriggers(Database db) async {
    final List<String> tablesName = [
      'credit_card',
      'category',
      'transactions',
      'transaction_has_category',
    ];

    for (final tableName in tablesName) {
      await db.execute(
        'CREATE TRIGGER soft_delete_$tableName BEFORE DELETE ON $tableName'
        ' FOR EACH ROW BEGIN'
        ' UPDATE $tableName SET isDeleted = 1 WHERE id = OLD.id;'
        ' SELECT RAISE(IGNORE);'
        ' END;',
      );
    }

    await db.execute(
      ' CREATE TRIGGER soft_delete_cascade_transaction_has_category '
      ' AFTER UPDATE OF isDeleted ON transactions FOR EACH ROW '
      ' WHEN OLD.isDeleted = 1 AND NEW.isDeleted = 0 BEGIN'
      ' UPDATE transaction_has_category SET isDeleted = 1 WHERE transaction_id = OLD.id;'
      ' END;',
    );

    await db.execute(
      'CREATE TRIGGER soft_delete_cascade_category_belongs_transaction '
      ' AFTER UPDATE OF isDeleted ON category FOR EACH ROW '
      ' WHEN OLD.isDeleted = 1 AND NEW.isDeleted = 0 BEGIN'
      ' UPDATE transaction_has_category SET isDeleted = 1 WHERE category_id = OLD.id;'
      ' END;',
    );
  }

  Future<void> _createViews(Database db) async {
    await db.execute(
      'CREATE VIEW view_transactions AS'
      ' SELECT transactions.*,'
      ' category.id as category_id, category.name as category_name,'
      ' category.description as category_description, category.createdAt as category_createdAt,'
      ' category.updatedAt as category_updatedAt, category.color as category_color,'
      ' category.synced as category_synced, credit_card.id as credit_card_id,'
      ' credit_card.name as credit_card_name, credit_card.color as credit_card_color,'
      ' credit_card.createdAt as credit_card_createdAt,'
      ' credit_card.updatedAt as credit_card_updatedAt, credit_card.synced as credit_card_synced'
      ' FROM transactions'
      ' LEFT JOIN transaction_has_category ON transactions.id = transaction_has_category.transaction_id'
      ' LEFT JOIN category ON transaction_has_category.category_id = category.id'
      ' LEFT JOIN credit_card ON transactions.credit_card = credit_card.id'
      ' WHERE transactions.isDeleted = 0;',
    );
  }
}
