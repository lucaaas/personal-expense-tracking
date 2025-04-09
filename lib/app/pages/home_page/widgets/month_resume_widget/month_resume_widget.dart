import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/helpers/format_to_money_string_helper.dart';
import 'package:personal_expense_tracker/app/providers/transaction_provider.dart';
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
    final double total = currentMonthInfo.totalIncome + (currentMonthInfo.totalExpense * -1);
    final double incomePercentage = (currentMonthInfo.totalIncome / total);
    final double expensePercentage = (currentMonthInfo.totalExpense * -1 / total);

    Color color = CupertinoColors.systemGreen;
    String title = "Entrada";

    return CardWidget(
      title: const Text("Resumo do mês"),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GraphBarWidget(
            percentage: incomePercentage,
            color: CupertinoColors.systemGreen,
            value: formatToMoneyString(currentMonthInfo.totalIncome),
            title: "Entrada",
          ),
          const SizedBox(height: 8),
          GraphBarWidget(
            percentage: expensePercentage,
            color: CupertinoColors.systemRed,
            value: formatToMoneyString(currentMonthInfo.totalExpense),
            title: "Saída",
          ),
        ],
      ),
    );
  }
}
