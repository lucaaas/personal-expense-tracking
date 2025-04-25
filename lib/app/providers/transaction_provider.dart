import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/models/category_model.dart';
import 'package:personal_expense_tracker/app/models/credit_card_model.dart';
import 'package:personal_expense_tracker/app/models/transaction_model.dart';

abstract class MonthInfo {
  double totalExpense = 0;
  double totalIncome = 0;
  double balance = 0;

  void addToTotal(double value) {
    if (value > 0) {
      totalIncome += value;
    } else {
      totalExpense += value;
    }

    balance = totalIncome + totalExpense;
  }

  void subtractFromTotal(double value) {
    if (value > 0) {
      totalIncome -= value;
    } else {
      totalExpense -= value;
    }

    balance = totalIncome + totalExpense;
  }
}

class CategoryMonthInfo extends MonthInfo {
  final CategoryModel category;

  CategoryMonthInfo({required this.category});
}

class CreditCardMonthInfo extends MonthInfo {
  final CreditCardModel creditCard;

  CreditCardMonthInfo({required this.creditCard});
}

class TransactionCache {
  late List<TransactionModel> transactions;
  late TransactionModel previousMonthBalance;
  final List<CreditCardMonthInfo> _creditCardInfos = [];
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

  List<CreditCardMonthInfo> get creditCardInfos => List.from(_creditCardInfos);

  List<CategoryMonthInfo> get categoriesInfo {
    List<CategoryMonthInfo> categoryInfos = [];

    for (TransactionModel transaction in transactions) {
      if (transaction.categories.isNotEmpty) {
        for (CategoryModel category in transaction.categories) {
          CategoryMonthInfo categoryInfo;
          try {
            categoryInfo = categoryInfos.firstWhere((info) => info.category == category);
          } on StateError catch (_) {
            categoryInfo = CategoryMonthInfo(category: category);
            categoryInfos.add(categoryInfo);
          }

          categoryInfo.addToTotal(transaction.value);
        }
      }
    }

    return categoryInfos;
  }

  double get totalCreditCardExpense {
    double total = 0;
    for (CreditCardMonthInfo info in _creditCardInfos) {
      total += info.totalExpense;
    }
    return total;
  }

  void addTransaction(TransactionModel transaction) {
    transactions.add(transaction);
    _sortTransactions();
    _sumTotals(transaction);

    if (transaction.creditCard != null) {
      CreditCardMonthInfo creditCardInfo;
      try {
        creditCardInfo =
            _creditCardInfos.firstWhere((info) => info.creditCard == transaction.creditCard);
      } on StateError catch (_) {
        creditCardInfo = CreditCardMonthInfo(creditCard: transaction.creditCard!);
        _creditCardInfos.add(creditCardInfo);
      }

      creditCardInfo.addToTotal(transaction.value);
    }
  }

  void removeTransaction(TransactionModel transaction) {
    transactions.remove(transaction);

    if (transaction.value > 0) {
      totalIncome -= transaction.value;
    } else {
      totalExpense -= transaction.value;
    }

    if (transaction.creditCard != null) {
      CreditCardMonthInfo creditCardInfo =
          _creditCardInfos.firstWhere((info) => info.creditCard == transaction.creditCard);

      creditCardInfo.subtractFromTotal(transaction.value);
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
  TransactionModel? _lastDeletedTransaction;

  List<String> get months => _groupedTransactions.keys.toList();

  TransactionProvider() {
    _groupedTransactions = SplayTreeMap(_compareKeys);
  }

  Future<void> init() async {
    await _groupTransactions();
  }

  Future<void> deleteTransaction(TransactionModel transaction) async {
    _lastDeletedTransaction = transaction;

    String key = _getKeyFromDate(transaction.date!);
    _groupedTransactions[key]!.removeTransaction(transaction);
    _updateBalance();

    await transaction.delete();
    notifyListeners();
  }

  Future<TransactionCache> getTransactionsByMonthYear(String monthYear) async {
    if (!_groupedTransactions[monthYear]!.isCached) {
      int month = int.parse(monthYear.split('/')[0]);
      int year = int.parse(monthYear.split('/')[1]);

      _groupedTransactions[monthYear]!
          .addAllTransactions(await TransactionModel.getTransactionsByMonthYear(month, year));
      _groupedTransactions[monthYear]!.isCached = true;
      _updateBalance();
    }

    return _groupedTransactions[monthYear]!;
  }

  Future<void> saveTransaction(TransactionModel transaction) async {
    await transaction.save();
    _addToGroupedTransactions(transaction);
    notifyListeners();
  }

  Future<void> undoDeleteTransaction() async {
    if (_lastDeletedTransaction != null) {
      String key = _getKeyFromDate(_lastDeletedTransaction!.date!);
      _groupedTransactions[key]!.addTransaction(_lastDeletedTransaction!);
      await _lastDeletedTransaction!.save();
      _lastDeletedTransaction = null;

      _updateBalance();
      notifyListeners();
    }
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

    _updateBalance();
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

  void _updateBalance() {
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
