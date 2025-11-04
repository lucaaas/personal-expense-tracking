import 'package:personal_expense_tracker/app/connectors/base_connector.dart';
import 'package:personal_expense_tracker/app/helpers/db_helper.dart';
import 'package:personal_expense_tracker/app/models/category_model.dart';
import 'package:personal_expense_tracker/app/models/transaction_model.dart';

mixin TransactionConnector on BaseConnector<TransactionModel> {
  final DBHelper _helper = DBHelper.getInstance();

  @override
  Future<List<TransactionModel>> getAll() async {
    List<Map<String, dynamic>> resultQuery = await _helper.getData(
      table: joinTable,
      columns: joinColumns,
    );

    Map<String, Map<String, dynamic>> transactions = _groupTransactionsQueryResult(resultQuery);
    return transactions.values.map((Map<String, dynamic> data) => toObject(data)).toList();
  }

  @override
  Future<List<TransactionModel>> filter({
    String? where,
    List<Object>? whereArgs,
    int? limit,
    String? orderBy,
  }) async {
    List<Map<String, dynamic>> resultQuery = await _helper.getData(
      table: joinTable,
      columns: joinColumns,
      where: where,
      whereArgs: whereArgs,
      limit: limit,
      orderBy: orderBy,
    );

    Map<String, Map<String, dynamic>> transactions = _groupTransactionsQueryResult(resultQuery);
    return transactions.values.map((Map<String, dynamic> data) => toObject(data)).toList();
  }

  @override
  Future<int> insertOrUpdate(TransactionModel model) async {
    int transactionId = await super.insertOrUpdate(model);
    await insertTransactionHasCategory(model);

    return transactionId;
  }

  @override
  Future<int> insert(TransactionModel model) async {
    int transactionId = await super.insert(model);
    await insertTransactionHasCategory(model);

    return transactionId;
  }

  Future<void> insertTransactionHasCategory(TransactionModel transaction) async {
    for (CategoryModel category in transaction.categories) {
      Map<String, dynamic> data = {
        'transaction_id': transaction.id,
        'category_id': category.id,
        'createdAt': transaction.createdAt.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      _helper.insert(table: transactionHasCategoryTable, data: data);
    }
  }

  Future<int> updateTransactionHasCategorySyncStatus(
    TransactionModel transaction,
    CategoryModel category,
    bool synced,
  ) async {
    return await _helper.update(
      table: transactionHasCategoryTable,
      data: {'synced': synced ? 1 : 0},
      where: 'transaction_id=? AND category_id=?',
      whereArgs: [transaction.id, category.id],
    );
  }

  Map<String, Map<String, dynamic>> _groupTransactionsQueryResult(
    List<Map<String, dynamic>> resultQuery,
  ) {
    Map<String, Map<String, dynamic>> transactions = {};
    for (Map<String, dynamic> result in resultQuery) {
      final String transactionId = result['id'];

      if (!transactions.containsKey(result['id'])) {
        transactions[transactionId] = {
          'id': transactionId,
          'synced': result['synced'],
          'description': result['description'],
          'value': result['value'],
          'date': result['date'],
          'createdAt': result['createdAt'],
          'updatedAt': result['updatedAt'],
          'credit_card': null,
          'categories': [],
        };
      }

      if (result['category_id'] != null) {
        transactions[transactionId]!['categories'].add({
          'id': result['category_id'],
          'name': result['category_name'],
          'description': result['category_description'],
          'color': result['category_color'],
          'synced': result['category_synced'],
          'updatedAt': result['category_updatedAt'],
          'createdAt': result['category_createdAt'],
        });
      }

      if (result['credit_card_id'] != null) {
        transactions[transactionId]!['credit_card'] = {
          'id': result['credit_card_id'],
          'name': result['credit_card_name'],
          'color': result['credit_card_color'],
          'synced': result['credit_card_synced'],
          'createdAt': result['credit_card_createdAt'],
          'updatedAt': result['credit_card_updatedAt'],
        };
      }
    }

    return transactions;
  }

  String get joinTable =>
      'transactions '
      'LEFT JOIN transaction_has_category ON transactions.id = transaction_has_category.transaction_id '
      'LEFT JOIN category ON transaction_has_category.category_id = category.id '
      'LEFT JOIN credit_card ON transactions.credit_card = credit_card.id ';

  List<String> get joinColumns => [
    'transactions.*',
    'category.id as category_id',
    'category.name as category_name',
    'category.description as category_description',
    'category.createdAt as category_createdAt',
    'category.updatedAt as category_updatedAt',
    'category.color as category_color',
    'category.synced as category_synced',
    'credit_card.id as credit_card_id',
    'credit_card.name as credit_card_name',
    'credit_card.color as credit_card_color',
    'credit_card.createdAt as credit_card_createdAt',
    'credit_card.updatedAt as credit_card_updatedAt',
    'credit_card.synced as credit_card_synced',
  ];

  String get transactionHasCategoryTable => 'transaction_has_category';
}
