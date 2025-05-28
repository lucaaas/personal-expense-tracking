import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/formatters/money_formatter.dart';
import 'package:personal_expense_tracker/app/models/category_model.dart';
import 'package:personal_expense_tracker/app/models/credit_card_model.dart';
import 'package:personal_expense_tracker/app/models/transaction_model.dart';
import 'package:personal_expense_tracker/app/providers/transaction_provider.dart';
import 'package:provider/provider.dart';

enum TransactionType { expense, income }

class TransactionFormController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TransactionModel transaction;
  final bool _isEditing;

  TransactionType type;

  TransactionFormController({TransactionModel? transaction})
      : _isEditing = transaction != null,
        transaction = transaction ?? TransactionModel.empty(),
        type = transaction != null && transaction.value >= 0
            ? TransactionType.income
            : TransactionType.expense;

  String get titlePage => _isEditing ? "Editar transação" : "Nova transação";

  String get initialFormattedValue {
    MoneyFormatter formatter = MoneyFormatter();
    TextEditingValue value = TextEditingValue(text: transaction.value.toStringAsFixed(2));
    TextEditingValue formattedValue = formatter.formatEditUpdate(value, value);
    return formattedValue.text;
  }

  Future<void> save(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      if (type == TransactionType.expense) {
        transaction.value = -transaction.value;
      }

      await Provider.of<TransactionProvider>(context, listen: false).saveTransaction(transaction);
      Navigator.of(context).pop();
    } else {
      throw Exception("Invalid form");
    }
  }

  Future<List<CategoryModel>> getCategories() {
    return CategoryModel.list();
  }

  Future<List<CreditCardModel>> getCredicards() async {
    return CreditCardModel.list();
  }
}
