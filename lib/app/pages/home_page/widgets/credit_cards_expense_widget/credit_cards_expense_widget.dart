import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/helpers/format_to_money_string_helper.dart';
import 'package:personal_expense_tracker/app/providers/transaction_provider.dart';
import 'package:personal_expense_tracker/app/widgets/card_widget/card_widget.dart';
import 'package:personal_expense_tracker/app/widgets/graph_bar_widget/graph_bar_widget.dart';

class CreditCardsExpenseWidget extends StatelessWidget {
  final List<CreditCardMonthInfo> creditCardInfos;
  final double totalExpense;

  const CreditCardsExpenseWidget(
      {super.key, required this.creditCardInfos, required this.totalExpense});

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      title: const Text("Despesas dos cartões de crédito"),
      child: Column(
        children: _buildChildren(),
      ),
    );
  }

  List<Widget> _buildChildren() {
    List<Widget> children = [];

    for (CreditCardMonthInfo info in creditCardInfos) {
      children.add(
        GraphBarWidget(
          percentage: info.totalExpense / totalExpense,
          color: info.creditCard.colorValue,
          value: formatToMoneyString(info.totalExpense),
          title: info.creditCard.name,
        ),
      );
    }

    return children;
  }
}
