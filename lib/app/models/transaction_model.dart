import 'package:personal_expense_tracker/app/connectors/transaction_connector.dart';
import 'package:personal_expense_tracker/app/helpers/shared_preferences_helper.dart';
import 'package:personal_expense_tracker/app/models/base_model.dart';
import 'package:personal_expense_tracker/app/models/category_model.dart';
import 'package:personal_expense_tracker/app/models/credit_card_model.dart';

class TransactionModel extends BaseModel<TransactionModel> with TransactionConnector {
  String description;
  double value;
  DateTime? date;
  CreditCardModel? creditCard;
  List<CategoryModel> categories;

  TransactionModel({
    super.id,
    super.createdAt,
    required this.description,
    required this.value,
    this.date,
    this.creditCard,
    this.categories = const [],
  });

  TransactionModel.fromMap(Map<String, dynamic> data)
    : description = data['description'],
      value = data['value'],
      categories = [],
      creditCard = data['credit_card'] != null
          ? CreditCardModel.fromMap(data['credit_card'])
          : null,
      date = DateTime.tryParse(data['date']),
      super(
        id: data['id'],
        createdAt: DateTime.parse(data['createdAt']),
        updatedAt: DateTime.parse(data['updatedAt']),
        isDeleted: data['isDeleted'] == 1,
        synced: data['synced'] == 1,
      ) {
    for (Map<String, dynamic> category in data['categories']) {
      categories.add(CategoryModel.fromMap(category));
    }
  }

  TransactionModel.empty() : description = '', value = 0, categories = [];

  static Future<List<TransactionModel>> list() async {
    List<TransactionModel> transactions = await TransactionModel.empty().getAll();

    return transactions;
  }

  static Future<List<DateTime>> getTransactionsDateRange() async {
    List<DateTime> dates = [];

    List<TransactionModel> firstTransaction = await TransactionModel.empty().filter(
      limit: 1,
      orderBy: 'date ASC',
    );

    if (firstTransaction.isNotEmpty) {
      dates.add(firstTransaction.first.date!);
    }

    List<TransactionModel> lastTransaction = await TransactionModel.empty().filter(
      limit: 1,
      orderBy: 'date DESC',
    );

    if (lastTransaction.isNotEmpty) {
      dates.add(lastTransaction.first.date!);
    }

    return dates;
  }

  static Future<List<TransactionModel>> getTransactionsByMonthYear(int month, int year) async {
    List<TransactionModel> transactions = await TransactionModel.empty().filter(
      where: 'strftime("%m", date) = ? AND strftime("%Y", date) = ?',
      whereArgs: [month.toString().padLeft(2, '0'), year.toString()],
      orderBy: 'date DESC',
    );

    return transactions;
  }

  DateTime get dateOrCreatedAt {
    return date ?? createdAt;
  }

  @override
  Future<String> save() {
    for (CategoryModel category in categories) {
      category.save();
    }
    creditCard?.save();
    return super.save();
  }

  @override
  Future<void> saveFromServer() async {
    final SharedPreferencesHelper sharedPrefs = await SharedPreferencesHelper.getInstance();

    DateTime? lastSync = sharedPrefs.getLastSyncTime(table);
    List<Map<String, dynamic>> transactionsData = await getAllSinceDate(lastSync);

    for (Map<String, dynamic> transactionData in transactionsData) {
      final categoriesTransactions = await getDocsEqualTo(
        'transaction_id',
        transactionData['id'],
        transactionHasCategoryTable,
      );

      transactionData['categories'] = [];
      if (categoriesTransactions.isNotEmpty) {
        for (Map<String, dynamic> categoryTransaction in categoriesTransactions) {
          final Map<String, dynamic> category = await CategoryModel.empty().getDocById(
            categoryTransaction['category_id'],
          );

          if (category.isNotEmpty) {
            transactionData['categories'].add(category);
          }
        }
      }

      if (transactionData['credit_card'] != null) {
        CreditCardModel creditCard = await CreditCardModel.empty().getById(
          transactionData['credit_card'],
        );

        transactionData['credit_card'] = creditCard.toMap();
      }

      TransactionModel model = toObject(transactionData);
      model.synced = true;
      await super.insert(model);
    }

    sharedPrefs.setLastSyncTime(table, DateTime.now());
  }

  @override
  Future<void> sendUnsyncedToServer() async {
    List<TransactionModel> unsyncedData = await filter(where: '$table.synced=0');
    for (TransactionModel model in unsyncedData) {
      await model.sendToServer();
      await _sendTransactionHasCategoryToServer();
    }
  }

  @override
  Future<void> addDataToId(String id, Map<String, dynamic> data, [String? col]) async {
    await _sendTransactionHasCategoryToServer();
    return super.addDataToId(id, data, col);
  }

  Future<void> _sendTransactionHasCategoryToServer() async {
    if (categories.isNotEmpty) {
      for (CategoryModel category in categories) {
        Map<String, dynamic> map = transactionHasCategoryToMap(category);
        await super.addDataToId("$id.${category.id}", map, transactionHasCategoryTable);
        await updateTransactionHasCategorySyncStatus(this, category, true);
      }
    }
  }

  Map<String, dynamic> transactionHasCategoryToMap(CategoryModel category) {
    Map<String, dynamic> data = {
      'transaction_id': id,
      'category_id': category.id,
      'createdAt': createdAt.toIso8601String(),
    };

    return data;
  }

  @override
  String get table => "transactions";

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'description': description,
      'value': value,
      'date': date?.toIso8601String() ?? '',
      'credit_card': creditCard?.id,
    };
  }

  @override
  TransactionModel toObject(Map<String, dynamic> data) {
    return TransactionModel.fromMap(data);
  }
}
