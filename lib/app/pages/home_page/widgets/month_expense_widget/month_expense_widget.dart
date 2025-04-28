import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/providers/transaction_provider.dart';
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
        children: _buildChildren(),
      ),
    );
  }

  List<Widget> _buildChildren() {
    List<Widget> children = [];
    List<BarInfo> bars = [];

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

    if (bars.isNotEmpty) {
      children.add(GraphBarWidget(bars: bars, prefixValue: "R\$", value: totalExpense * -1));
    }

    return children;
  }
}
