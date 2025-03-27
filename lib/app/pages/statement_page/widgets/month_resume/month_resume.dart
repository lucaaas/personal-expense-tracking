import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/providers/transaction_provider.dart';
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
            "Saldo",
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

  _getTextStyle(double value) {
    return TextStyle(
      color: value < 0 ? CupertinoColors.systemRed : CupertinoColors.systemGreen,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    );
  }
}
