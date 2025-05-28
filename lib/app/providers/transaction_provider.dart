import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/models/category_model.dart';
import 'package:personal_expense_tracker/app/models/credit_card_model.dart';
import 'package:personal_expense_tracker/app/models/transaction_model.dart';

/// Represents monthly information for a generic type [T].
class MonthInfo<T> {
  /// Total expenses for the month (always <= 0).
  double totalExpense = 0;

  /// Total income for the month.
  double totalIncome = 0;

  /// Data associated with the month (e.g., category or credit card).
  final T data;

  /// Creates a [MonthInfo] instance with the provided [data].
  MonthInfo({required this.data});

  /// Returns the total balance (income + expenses).
  double get balance => totalIncome + totalExpense;

  /// Adds a value to the total income or expenses.
  ///
  /// If the [value] is positive, it is added to the income.
  /// If the [value] is negative, it is added to the expenses.
  void addToTotal(double value) {
    if (value > 0) {
      totalIncome += value;
    } else {
      totalExpense += value;
    }
  }

  /// Subtracts a value from the total income or expenses.
  ///
  /// If the [value] is positive, it is subtracted from the income.
  /// If the [value] is negative, it is subtracted from the expenses.
  void subtractFromTotal(double value) {
    if (value > 0) {
      totalIncome -= value;
    } else {
      totalExpense -= value;
    }
  }
}

/// Manages a cache of transactions and related information.
class TransactionCache {
  /// List of transactions stored in the cache.
  late List<TransactionModel> transactions;

  /// Represents the balance from the previous month.
  late TransactionModel previousMonthBalance;

  /// List of monthly information related to credit cards.
  final List<MonthInfo<CreditCardModel>> _creditCardInfos = [];

  /// Indicates whether the cache is loaded.
  bool isCached;

  /// Total income in the cache.
  double totalIncome = 0;

  /// Total expenses in the cache.
  double totalExpense = 0;

  /// Creates a [TransactionCache] with the provided [previousMonth] and [transactions].
  ///
  /// The [previousMonth] is the date of the previous month.
  /// The [transactions] is the list of transactions to be added to the cache.
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

  /// Returns the total balance (income + expenses).
  double get balance => totalIncome + totalExpense;

  /// Returns a copy of the list of credit card information.
  List<MonthInfo<CreditCardModel>> get creditCardInfos => List.from(_creditCardInfos);

  /// Returns a list of monthly information related to categories.
  List<MonthInfo<CategoryModel>> get categoriesInfo {
    List<MonthInfo<CategoryModel>> categoryInfos = [];

    for (TransactionModel transaction in transactions) {
      if (transaction.categories.isNotEmpty) {
        for (CategoryModel category in transaction.categories) {
          MonthInfo<CategoryModel> categoryInfo;
          try {
            categoryInfo = categoryInfos.firstWhere((info) => info.data == category);
          } on StateError catch (_) {
            categoryInfo = MonthInfo(data: category);
            categoryInfos.add(categoryInfo);
          }

          categoryInfo.addToTotal(transaction.value);
        }
      }
    }

    return categoryInfos;
  }

  /// Calculates the total expenses related to credit cards.
  double get totalCreditCardExpense {
    double total = 0;
    for (MonthInfo info in _creditCardInfos) {
      total += info.totalExpense;
    }
    return total;
  }

  /// Adds a transaction to the cache.
  ///
  /// Updates income, expenses, and credit card information.
  void addTransaction(TransactionModel transaction) {
    transactions.add(transaction);
    _sortTransactions();
    _sumTotals(transaction);

    if (transaction.creditCard != null) {
      MonthInfo<CreditCardModel> creditCardInfo;
      try {
        creditCardInfo = _creditCardInfos.firstWhere((info) => info.data == transaction.creditCard);
      } on StateError catch (_) {
        creditCardInfo = MonthInfo(data: transaction.creditCard!);
        _creditCardInfos.add(creditCardInfo);
      }

      creditCardInfo.addToTotal(transaction.value);
    }
  }

  /// Removes a transaction from the cache.
  ///
  /// Throws an exception if the transaction is the previous month's balance.
  void removeTransaction(TransactionModel transaction) {
    if (transaction != previousMonthBalance) {
      transactions.remove(transaction);

      if (transaction.value > 0) {
        totalIncome -= transaction.value;
      } else {
        totalExpense -= transaction.value;
      }

      if (transaction.creditCard != null) {
        MonthInfo<CreditCardModel> creditCardInfo =
            _creditCardInfos.firstWhere((info) => info.data == transaction.creditCard);

        creditCardInfo.subtractFromTotal(transaction.value);
      }
    } else {
      throw ("Cannot remove previous month balance");
    }
  }

  /// Recalculates the totals for expenses, income, and credit card information.
  ///
  /// Clears the current lists of transactions and credit card infos, then
  /// re-adds all transactions to ensure the totals are accurate.
  void recalculateTotals() {
    totalExpense = 0;
    totalIncome = 0;

    List<TransactionModel> transactions = List.from(this.transactions);
    this.transactions.clear();
    _creditCardInfos.clear();

    addAllTransactions(transactions);
  }

  /// Adds a list of transactions to the cache.
  void addAllTransactions(List<TransactionModel> transactions) {
    for (TransactionModel transaction in transactions) {
      addTransaction(transaction);
    }
  }

  /// Updates the previous month's balance with the provided [newValue].
  void updatePreviousMonthBalance(double newValue) {
    transactions.remove(previousMonthBalance);

    if (previousMonthBalance.value > 0) {
      totalIncome -= previousMonthBalance.value;
    } else {
      totalExpense -= previousMonthBalance.value;
    }

    previousMonthBalance.value = newValue;

    addTransaction(previousMonthBalance);
  }

  /// Updates income, expenses, and balance based on the provided [transaction].
  void _sumTotals(TransactionModel transaction) {
    if (transaction.value > 0) {
      totalIncome += transaction.value;
    } else {
      totalExpense += transaction.value;
    }
  }

  /// Sorts transactions in descending order by date.
  void _sortTransactions() {
    transactions.sort((a, b) => b.date!.compareTo(a.date!));
  }
}

/// Provides transaction-related operations and state management.
class TransactionProvider with ChangeNotifier {
  /// Stores transactions grouped by month and year.
  late SplayTreeMap<String, TransactionCache> _groupedTransactions;

  /// Stores the last deleted transaction for undo purposes.
  TransactionModel? _lastDeletedTransaction;

  /// Returns a list of months (keys) in the grouped transactions.
  List<String> get months => _groupedTransactions.keys.toList();

  /// Creates a [TransactionProvider] instance.
  TransactionProvider() {
    _groupedTransactions = SplayTreeMap(_compareKeys);
  }

  /// Initializes the provider by grouping transactions.
  Future<void> init() async {
    await _groupTransactions();
  }

  /// Deletes a transaction and updates the balance.
  ///
  /// The [transaction] is removed from the grouped transactions and deleted from storage.
  Future<void> deleteTransaction(TransactionModel transaction) async {
    _lastDeletedTransaction = transaction;

    String key = _getKeyFromDate(transaction.date!);
    _groupedTransactions[key]!.removeTransaction(transaction);
    _updateBalance();

    await transaction.delete();
    _lastDeletedTransaction!.id = null;
    notifyListeners();
  }

  /// Checks if a transaction can be deleted or updated.
  ///
  /// Returns `false` if the transaction is the previous month's balance.
  bool canModifyTransaction(TransactionModel transaction) {
    String key = _getKeyFromDate(transaction.date!);
    return transaction != _groupedTransactions[key]!.previousMonthBalance;
  }

  /// Retrieves transactions for a specific month and year.
  ///
  /// If the transactions are not cached, they are loaded from storage.
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

  /// Saves a transaction and updates the grouped transactions.
  Future<void> saveTransaction(TransactionModel transaction) async {
    await transaction.save();
    _addToGroupedTransactions(transaction);
    notifyListeners();
  }

  /// Restores the last deleted transaction.
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

  /// Adds a transaction to the grouped transactions.
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
      } else {
        _groupedTransactions[key]!.recalculateTotals();
      }
    }

    _updateBalance();
  }

  /// Groups transactions by month and year.
  Future<void> _groupTransactions() async {
    final List<TransactionModel> transactions = await TransactionModel.list();

    if (transactions.isNotEmpty) {
      for (TransactionModel transaction in transactions) {
        _addToGroupedTransactions(transaction);
      }
    }

    DateTime now = DateTime.now();
    String key = _getKeyFromDate(now);
    if (transactions.isEmpty || !_groupedTransactions.keys.contains(key)) {
      _groupedTransactions[key] = TransactionCache(previousMonth: DateTime(now.year, now.month));
    }

    notifyListeners();
  }

  /// Generates a key in the format `MM/YYYY` from a [date].
  String _getKeyFromDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Updates the balance for all grouped transactions.
  void _updateBalance() {
    for (int i = 1; i < _groupedTransactions.keys.length; i++) {
      String key = _groupedTransactions.keys.elementAt(i);
      TransactionCache cache = _groupedTransactions[key]!;
      cache.updatePreviousMonthBalance(_groupedTransactions.values.elementAt(i - 1).balance);
    }
  }

  /// Compares two keys in the format `MM/YYYY`.
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
