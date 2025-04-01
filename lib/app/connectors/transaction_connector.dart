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

    Map<int, Map<String, dynamic>> transactions = _groupTransactionsQueryResult(resultQuery);
    return transactions.values.map((Map<String, dynamic> data) => toObject(data)).toList();
  }

  @override
  Future<List<TransactionModel>> filter({String? where, List<Object>? whereArgs, int? limit, String? orderBy}) async {
    List<Map<String, dynamic>> resultQuery = await _helper.getData(
      table: joinTable,
      columns: joinColumns,
      where: where,
      whereArgs: whereArgs,
      limit: limit,
      orderBy: orderBy,
    );

    Map<int, Map<String, dynamic>> transactions = _groupTransactionsQueryResult(resultQuery);
    return transactions.values.map((Map<String, dynamic> data) => toObject(data)).toList();
  }

  @override
  Future<int> insertOrUpdate(TransactionModel model) async {
    int transactionId = model.id ?? await super.insertOrUpdate(model);

    if (model.categories.isNotEmpty) {
      for (CategoryModel category in model.categories) {
        Map<String, dynamic> data = {
          'transaction_id': transactionId,
          'category_id': category.id,
          'createdAt': DateTime.now().toIso8601String(),
        };

        _helper.insert(table: 'transaction_has_category', data: data);
      }
    }

    return transactionId;
  }

  Map<int, Map<String, dynamic>> _groupTransactionsQueryResult(List<Map<String, dynamic>> resultQuery) {
    Map<int, Map<String, dynamic>> transactions = {};
    for (Map<String, dynamic> result in resultQuery) {
      if (!transactions.containsKey(result['id'])) {
        transactions[result['id']] = {
          'id': result['id'],
          'description': result['description'],
          'value': result['value'],
          'date': result['date'],
          'createdAt': result['createdAt'],
          'credit_card': {},
          'categories': [],
        };
      }

      if (result['category_id'] != null) {
        transactions[result['id']]!['categories'].add({
          'id': result['category_id'],
          'name': result['category_name'],
          'description': result['category_description'],
          'color': result['category_color'],
          'createdAt': result['category_createdAt'],
        });
      }

      if (result['credit_card_id'] != null) {
        transactions[result['id']]!['credit_card'] = {
          'id': result['credit_card_id'],
          'name': result['credit_card_name'],
          'color': result['credit_card_color'],
          'createdAt': result['credit_card_createdAt'],
        };
      }
    }

    return transactions;
  }

  String get joinTable => 'transactions '
      'LEFT JOIN transaction_has_category ON transactions.id = transaction_has_category.transaction_id '
      'LEFT JOIN category ON transaction_has_category.category_id = category.id '
      'LEFT JOIN credit_card ON transactions.credit_card = credit_card.id ';

  List<String> get joinColumns => [
        'transactions.*',
        'category.id as category_id',
        'category.name as category_name',
        'category.description as category_description',
        'category.createdAt as category_createdAt',
        'category.color as category_color',
        'credit_card.id as credit_card_id',
        'credit_card.name as credit_card_name',
        'credit_card.color as credit_card_color',
        'credit_card.createdAt as credit_card_createdAt',
      ];
}
