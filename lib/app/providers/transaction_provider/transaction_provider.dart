import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/models/transaction_model.dart';
import 'package:personal_expense_tracker/app/providers/transaction_provider/transaction_cache.dart';

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

    String key = _getKeyFromDate(transaction.dateOrCreatedAt);
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
    String key = _getKeyFromDate(transaction.dateOrCreatedAt);
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
      String key = _getKeyFromDate(_lastDeletedTransaction!.dateOrCreatedAt);
      _groupedTransactions[key]!.addTransaction(_lastDeletedTransaction!);
      await _lastDeletedTransaction!.save();
      _lastDeletedTransaction = null;

      _updateBalance();
      notifyListeners();
    }
  }

  /// Adds a transaction to the grouped transactions.
  void _addToGroupedTransactions(TransactionModel transaction) {
    DateTime date = transaction.dateOrCreatedAt;
    String key = _getKeyFromDate(date);

    if (!_groupedTransactions.containsKey(key)) {
      _groupedTransactions[key] = TransactionCache(
        transactions: [transaction],
        isCached: true,
        previousMonth: DateTime(date.year, date.month),
      );
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
