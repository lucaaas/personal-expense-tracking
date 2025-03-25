import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/helpers/get_constrasting_text_color.dart';
import 'package:personal_expense_tracker/app/models/transaction_model.dart';
import 'package:personal_expense_tracker/app/widgets/card_widget/card_widget.dart';
import 'package:personal_expense_tracker/app/widgets/chip_widget/chip_widget.dart';
import 'package:personal_expense_tracker/app/widgets/credit_card_label/credit_card_label.dart';

class TransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;

  const TransactionList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(8),
      sliver: SliverList.builder(
        itemCount: transactions.length,
        itemBuilder: _buildItem,
      ),
    );
  }

  Widget _buildItem(_, index) {
    final transaction = transactions[index];
    return CardWidget(
      icon: _getIcon(transaction.value),
      title: Text(transaction.description),
      subtitle: Text(transaction.date.toString()),
      trailing: _getAmountWidget(transaction.value),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (transaction.creditCard != null) CreditCardLabel(creditCard: transaction.creditCard!),
          Wrap(
            children: transaction.categories
                .map(
                  (category) => ChipWidget(
                    label: category.name,
                    color: category.colorValue,
                    isColorFilled: true,
                    textColor: getContrastingTextColor(category.colorValue),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _getAmountWidget(double value) {
    final Color color = value < 0 ? CupertinoColors.systemRed : CupertinoColors.systemGreen;

    if (value < 0) {
      value *= -1;
    }

    return Text(
      'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}',
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Icon _getIcon(double value) {
    if (value < 0) {
      return const Icon(CupertinoIcons.arrow_up, color: CupertinoColors.systemRed);
    } else {
      return const Icon(CupertinoIcons.arrow_down_to_line, color: CupertinoColors.systemGreen);
    }
  }
}
