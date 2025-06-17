import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/helpers/format_to_money_string_helper.dart';
import 'package:personal_expense_tracker/app/providers/transaction_provider/month_info.dart';
import 'package:personal_expense_tracker/app/widgets/card_widget/card_widget.dart';
import 'package:personal_expense_tracker/app/widgets/graph_bar_widget/graph_bar_widget.dart';

class MonthExpenseWidget extends StatelessWidget {
  final List<MonthInfo> info;
  final double totalExpense;
  final String title;

  const MonthExpenseWidget({
    super.key,
    required this.info,
    required this.totalExpense,
    this.title = "Despesas",
  });

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      title: Text(title),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildChildren(),
      ),
    );
  }

  List<Widget> _buildChildren() {
    List<Widget> children = [];
    List<BarInfo> bars = [];

    if (info.isNotEmpty) {
      for (MonthInfo info in info) {
        if (info.totalExpense != 0) {
          bars.add(
            BarInfo(
              color: info.data.colorValue,
              value: info.totalExpense * -1,
              label: info.data.name,
            ),
          );
        }
      }

      children.add(GraphBarWidget(bars: bars, prefixValue: "R\$", value: totalExpense * -1));
    } else {
      children.addAll([
        Text(
          formatToMoneyString(0.00),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Text(
          "Nenhuma despesa registrada",
          style: TextStyle(fontSize: 16),
        ),
      ]);
    }

    return children;
  }
}
