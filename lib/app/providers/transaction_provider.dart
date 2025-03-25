import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/models/transaction_model.dart';

class TransactionCache {
  List<TransactionModel> transactions;
  bool isCached;

  TransactionCache({this.transactions = const [], this.isCached = false});
}

class TransactionProvider with ChangeNotifier {
  final Map<String, TransactionCache> _groupedTransactions = {};

  List<String> get months => _groupedTransactions.keys.toList();

  TransactionProvider() {
    _generateGroupedTransactionsKeys();
  }

  Future<List<TransactionModel>> getTransactionsByMonthYear(String monthYear) async {
    if (!_groupedTransactions[monthYear]!.isCached) {
      int month = int.parse(monthYear.split('/')[0]);
      int year = int.parse(monthYear.split('/')[1]);

      _groupedTransactions[monthYear]!.transactions = await TransactionModel.getTransactionsByMonthYear(month, year);
      _groupedTransactions[monthYear]!.isCached = true;
    }

    return _groupedTransactions[monthYear]!.transactions;
  }

  Future<void> saveTransaction(TransactionModel transaction) async {
    await transaction.save();
    _addToGroupedTransactions(transaction);
    notifyListeners();
  }

  void _addToGroupedTransactions(TransactionModel transaction) {
    String key = _getKeyFromDate(transaction.date!);

    if (!_groupedTransactions.containsKey(key)) {
      _groupedTransactions[key] = TransactionCache(transactions: [transaction], isCached: true);
      _groupedTransactions.keys.toList().sort();
    } else {
      List<TransactionModel> transactions = List.from(_groupedTransactions[key]!.transactions);

      if (!transactions.contains(transaction)) {
        transactions.add(transaction);
        transactions.sort((a, b) => b.date!.compareTo(a.date!));
        _groupedTransactions[key]!.transactions = transactions;
      }
    }
  }

  Future<void> _generateGroupedTransactionsKeys() async {
    List<DateTime> dateRange = await TransactionModel.getTransactionsDateRange();
    DateTime firstDate = dateRange[0];
    DateTime lastDate = dateRange[1];
    DateTime currentDate = firstDate;

    do {
      String key = _getKeyFromDate(currentDate);
      _groupedTransactions[key] = TransactionCache();
      currentDate = DateTime(currentDate.year, currentDate.month + 1);
    } while (currentDate.isBefore(lastDate));

    getTransactionsByMonthYear(_groupedTransactions.keys.last);
    notifyListeners();
  }

  String _getKeyFromDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
