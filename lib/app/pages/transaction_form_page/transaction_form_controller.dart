import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/models/category_model.dart';
import 'package:personal_expense_tracker/app/models/credit_card_model.dart';
import 'package:personal_expense_tracker/app/models/transaction_model.dart';
import 'package:personal_expense_tracker/app/providers/transaction_provider.dart';
import 'package:provider/provider.dart';

enum TransactionType { expense, income }

class TransactionFormController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TransactionModel transaction;

  TransactionType type = TransactionType.expense;

  TransactionFormController({TransactionModel? transaction}) : transaction = transaction ?? TransactionModel.empty();

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
