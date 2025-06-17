import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/providers/transaction_provider/transaction_cache.dart';
import 'package:personal_expense_tracker/app/widgets/card_widget/card_widget.dart';
import 'package:personal_expense_tracker/app/widgets/graph_bar_widget/graph_bar_widget.dart';

class MonthResumeWidget extends StatelessWidget {
  final TransactionCache currentMonthInfo;

  const MonthResumeWidget({
    super.key,
    required this.currentMonthInfo,
  });

  @override
  Widget build(BuildContext context) {
    final double total = currentMonthInfo.totalIncome + currentMonthInfo.totalExpense;

    return CardWidget(
      title: const Text("Resumo do mês"),
      child: GraphBarWidget(
        prefixValue: "R\$",
        value: total,
        bars: [
          BarInfo(
            color: CupertinoColors.systemGreen,
            value: currentMonthInfo.totalIncome,
            label: "Entrada",
          ),
          BarInfo(
            color: CupertinoColors.systemRed,
            value: currentMonthInfo.totalExpense * -1,
            label: "Saída",
          ),
        ],
      ),
    );
  }
}
