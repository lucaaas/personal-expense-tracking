import 'package:flutter/cupertino.dart';
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
    List<BarInfo> bars = [];

    for (CreditCardMonthInfo info in creditCardInfos) {
      if (info.totalExpense != 0) {
        bars.add(BarInfo(
          color: info.creditCard.colorValue,
          value: info.totalExpense * -1,
          label: info.creditCard.name,
        ));
      }
    }

    if (bars.isNotEmpty) {
      children.add(GraphBarWidget(bars: bars, prefixValue: "R\$", value: totalExpense * -1));
    }

    return children;
  }
}
