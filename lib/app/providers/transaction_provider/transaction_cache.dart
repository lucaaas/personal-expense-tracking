import 'package:personal_expense_tracker/app/models/category_model.dart';
import 'package:personal_expense_tracker/app/models/credit_card_model.dart';
import 'package:personal_expense_tracker/app/models/transaction_model.dart';
import 'package:personal_expense_tracker/app/providers/transaction_provider/month_info.dart';

/// Manages a cache of transactions and related information.
class TransactionCache {
  /// List of transactions stored in the cache.
  late List<TransactionModel> transactions;

  /// List of estimated transactions
  TransactionCache? estimatedTransactions;

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
  })  : transactions = [],
        estimatedTransactions = TransactionCache._withoutEstimatedTransactions(
          previousMonth: previousMonth,
          transactions: [],
          isCached: true,
        ) {
    addAllTransactions(transactions);

    previousMonthBalance = TransactionModel(
      description: "Saldo do mês anterior",
      value: 0,
      date: previousMonth,
    );

    addTransaction(previousMonthBalance);
  }

  /// Creates a [TransactionCache] without estimated transactions.
  TransactionCache._withoutEstimatedTransactions({
    required DateTime previousMonth,
    List<TransactionModel> transactions = const [],
    this.isCached = false,
  }) : transactions = [];

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
    if (transaction.date == null && estimatedTransactions != null) {
      estimatedTransactions!.addTransaction(transaction);
      return;
    }

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
      if (transaction.date == null && estimatedTransactions != null) {
        estimatedTransactions!.removeTransaction(transaction);
      }

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
    transactions.sort((a, b) => b.dateOrCreatedAt.compareTo(a.dateOrCreatedAt));
  }
}
