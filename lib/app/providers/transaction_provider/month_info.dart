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
