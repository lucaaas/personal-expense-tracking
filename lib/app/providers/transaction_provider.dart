import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/models/transaction_model.dart';

class TransactionCache {
  late List<TransactionModel> transactions;
  late TransactionModel previousMonthBalance;
  bool isCached;
  double totalIncome = 0;
  double totalExpense = 0;
  double balance = 0;

  TransactionCache({
    required DateTime previousMonth,
    List<TransactionModel> transactions = const [],
    this.isCached = false,
  }) : transactions = [] {
    addAllTransactions(transactions);

    previousMonthBalance = TransactionModel(
      description: "Saldo do mês anterior",
      value: 0,
      date: previousMonth,
    );

    addTransaction(previousMonthBalance);
  }

  void addTransaction(TransactionModel transaction) {
    transactions.add(transaction);
    _sortTransactions();
    _sumTotals(transaction);
  }

  void removeTransaction(TransactionModel transaction) {
    transactions.remove(transaction);

    if (transaction.value > 0) {
      totalIncome -= transaction.value;
    } else {
      totalExpense -= transaction.value;
    }

    balance = totalIncome + totalExpense;
  }

  void addAllTransactions(List<TransactionModel> transactions) {
    this.transactions.addAll(transactions);
    _sortTransactions();

    for (TransactionModel transaction in transactions) {
      _sumTotals(transaction);
    }
  }

  void updatePreviousMonthBalance(double value) {
    removeTransaction(previousMonthBalance);
    previousMonthBalance.value = value;
    addTransaction(previousMonthBalance);
  }

  void _sumTotals(TransactionModel transaction) {
    if (transaction.value > 0) {
      totalIncome += transaction.value;
    } else {
      totalExpense += transaction.value;
    }

    balance = totalIncome + totalExpense;
  }

  void _sortTransactions() {
    transactions.sort((a, b) => b.date!.compareTo(a.date!));
  }
}

class TransactionProvider with ChangeNotifier {
  late SplayTreeMap<String, TransactionCache> _groupedTransactions;

  List<String> get months => _groupedTransactions.keys.toList();

  TransactionProvider() {
    _groupedTransactions = SplayTreeMap(_compareKeys);
  }

  Future<void> init() async {
    await _groupTransactions();
  }

  Future<TransactionCache> getTransactionsByMonthYear(String monthYear) async {
    if (!_groupedTransactions[monthYear]!.isCached) {
      int month = int.parse(monthYear.split('/')[0]);
      int year = int.parse(monthYear.split('/')[1]);

      _groupedTransactions[monthYear]!
          .addAllTransactions(await TransactionModel.getTransactionsByMonthYear(month, year));
      _groupedTransactions[monthYear]!.isCached = true;
      _updateBalance(_groupedTransactions[monthYear]!);
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
      _groupedTransactions[key] = TransactionCache(
          transactions: [transaction],
          isCached: true,
          previousMonth: DateTime(transaction.date!.year, transaction.date!.month));
    } else {
      List<TransactionModel> transactions = List.from(_groupedTransactions[key]!.transactions);

      if (!transactions.contains(transaction)) {
        _groupedTransactions[key]!.addTransaction(transaction);
      }
    }

    _updateBalance(_groupedTransactions[key]!);
  }

  Future<void> _groupTransactions() async {
    final List<TransactionModel> transactions = await TransactionModel.list();

    if (transactions.isNotEmpty) {
      for (TransactionModel transaction in transactions) {
        _addToGroupedTransactions(transaction);
      }
    } else {
      DateTime now = DateTime.now();
      String key = _getKeyFromDate(now);
      _groupedTransactions[key] = TransactionCache(previousMonth: DateTime(now.year, now.month));
    }

    notifyListeners();
  }

  String _getKeyFromDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _updateBalance(TransactionCache cache) {
    for (int i = 1; i < _groupedTransactions.keys.length; i++) {
      String key = _groupedTransactions.keys.elementAt(i);
      TransactionCache cache = _groupedTransactions[key]!;
      cache.updatePreviousMonthBalance(_groupedTransactions.values.elementAt(i - 1).balance);
    }
  }

  int _compareKeys(String a, String b) {
    List<String> aParts = a.split('/');
    List<String> bParts = b.split('/');

    int aMonth = int.parse(aParts[0]);
    int aYear = int.parse(aParts[1]);

    int bMonth = int.parse(bParts[0]);
    int bYear = int.parse(bParts[1]);

    DateTime aDate = DateTime(aYear, aMonth);
    DateTime bDate = DateTime(bYear, bMonth);

    return aDate.compareTo(bDate);
  }
}
