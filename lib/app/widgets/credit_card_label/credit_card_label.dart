import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/helpers/get_constrasting_text_color.dart';
import 'package:personal_expense_tracker/app/models/credit_card_model.dart';

class CreditCardLabel extends StatelessWidget {
  final CreditCardModel creditCard;

  const CreditCardLabel({super.key, required this.creditCard});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: creditCard.colorValue,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      child: Text(
        creditCard.name,
        style: TextStyle(
          color: getContrastingTextColor(creditCard.colorValue),
        ),
      ),
    );
  }
}
