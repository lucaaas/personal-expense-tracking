import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/models/transaction_model.dart';

class TransactionCache {
  List<TransactionModel> transactions;
  bool isCached;
  double totalIncome = 0;
  double totalExpense = 0;
  double balance = 0;

  TransactionCache({this.transactions = const [], this.isCached = false});
}

class TransactionProvider with ChangeNotifier {
  final Map<String, TransactionCache> _groupedTransactions = {};

  List<String> get months => _groupedTransactions.keys.toList();

  TransactionProvider() {
    _generateGroupedTransactionsKeys();
  }

  Future<TransactionCache> getTransactionsByMonthYear(String monthYear) async {
    if (!_groupedTransactions[monthYear]!.isCached) {
      int month = int.parse(monthYear.split('/')[0]);
      int year = int.parse(monthYear.split('/')[1]);

      _groupedTransactions[monthYear]!.transactions = await TransactionModel.getTransactionsByMonthYear(month, year);
      _groupedTransactions[monthYear]!.isCached = true;
      _sumTotals(_groupedTransactions[monthYear]!);
    }

    return _groupedTransactions[monthYear]!;
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
      _updateTotals(_groupedTransactions[key]!, transaction);
      _groupedTransactions.keys.toList().sort();
    } else {
      List<TransactionModel> transactions = List.from(_groupedTransactions[key]!.transactions);

      if (!transactions.contains(transaction)) {
        transactions.add(transaction);
        transactions.sort((a, b) => b.date!.compareTo(a.date!));
        _groupedTransactions[key]!.transactions = transactions;
        _sumTotals(_groupedTransactions[key]!);
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

  void _sumTotals(TransactionCache cache) {
    for (TransactionModel transaction in cache.transactions) {
      _updateTotals(cache, transaction);
    }
  }

  void _updateTotals(TransactionCache cache, TransactionModel transaction) {
    if (transaction.value > 0) {
      cache.totalIncome += transaction.value;
    } else {
      cache.totalExpense += transaction.value;
    }

    cache.balance = cache.totalIncome + cache.totalExpense;
  }
}
