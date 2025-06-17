import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/providers/transaction_provider/transaction_cache.dart';
import 'package:personal_expense_tracker/app/widgets/card_widget/card_widget.dart';

class MonthResume extends StatelessWidget {
  final TransactionCache transaction;

  const MonthResume({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Saldo atual",
            style: TextStyle(
              color: CupertinoTheme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Text(
            'R\$ ${transaction.balance.toStringAsFixed(2).replaceAll('.', ',')}',
            style: _getTextStyle(transaction.balance),
          ),
        ],
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Saldo estimado",
            style: TextStyle(
              color: CupertinoTheme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            'R\$ ${transaction.totalEstimated.toStringAsFixed(2).replaceAll('.', ',')}',
            style: _getTextStyle(transaction.totalEstimated, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Entradas",
                style: _getTextStyle(transaction.totalIncome),
              ),
              Text(
                'R\$ ${transaction.totalIncome.toStringAsFixed(2).replaceAll('.', ',')}',
                style: _getTextStyle(transaction.totalIncome),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Saídas",
                style: _getTextStyle(transaction.totalExpense),
              ),
              Text(
                'R\$ ${transaction.totalExpense.toStringAsFixed(2).replaceAll('.', ',')}',
                style: _getTextStyle(transaction.totalExpense),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _getTextStyle(double value, [double fontSize = 20]) {
    return TextStyle(
      color: value < 0 ? CupertinoColors.systemRed : CupertinoColors.systemGreen,
      fontWeight: FontWeight.bold,
      fontSize: fontSize,
    );
  }
}
