import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/providers/transaction_provider.dart';
import 'package:personal_expense_tracker/app/widgets/card_widget/card_widget.dart';
import 'package:personal_expense_tracker/app/widgets/graph_bar_widget/graph_bar_widget.dart';

class CategoryExpenseWidget extends StatelessWidget {
  final List<CategoryMonthInfo> categoriesInfo;
  final double totalExpense;

  const CategoryExpenseWidget(
      {super.key, required this.categoriesInfo, required this.totalExpense});

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      title: const Text("Despesas por categoria"),
      child: Column(
        children: _buildChildren(),
      ),
    );
  }

  List<Widget> _buildChildren() {
    List<Widget> children = [];
    List<BarInfo> bars = [];

    for (CategoryMonthInfo info in categoriesInfo) {
      if (info.totalExpense != 0) {
        bars.add(
          BarInfo(
            color: info.category.colorValue,
            value: info.totalExpense * -1,
            label: info.category.name,
          ),
        );
      }
    }

    if (bars.isNotEmpty) {
      children.add(GraphBarWidget(bars: bars));
    }

    return children;
  }
}
