import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/models/credit_card_model.dart';

class CreditCardFormController {
  final CreditCardModel creditCard;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  CreditCardFormController({CreditCardModel? creditCard}) : creditCard = creditCard ?? CreditCardModel.empty();

  Future<void> save() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      await creditCard.save();
    } else {
      throw Exception("Invalid form");
    }
  }
}
