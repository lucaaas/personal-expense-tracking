import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/helpers/format_to_money_string_helper.dart';
import 'package:personal_expense_tracker/app/helpers/get_constrasting_text_color.dart';
import 'package:personal_expense_tracker/app/models/transaction_model.dart';
import 'package:personal_expense_tracker/app/utils/app_routes.dart';
import 'package:personal_expense_tracker/app/widgets/accordion_widget/accordion_widget.dart';
import 'package:personal_expense_tracker/app/widgets/card_widget/dismissible_card_widget.dart';
import 'package:personal_expense_tracker/app/widgets/chip_widget/chip_widget.dart';
import 'package:personal_expense_tracker/app/widgets/credit_card_label/credit_card_label.dart';

class TransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;
  final List<TransactionModel>? estimatedTransactions;
  final double? totalEstimated;
  final Future<void> Function(TransactionModel) onTransactionDelete;
  final Future<bool> Function(TransactionModel)? confirmModify;

  const TransactionList({
    super.key,
    required this.transactions,
    required this.onTransactionDelete,
    this.estimatedTransactions,
    this.totalEstimated,
    this.confirmModify,
  }) : assert(
          estimatedTransactions != null && totalEstimated != null,
          'If estimated transactions are provided, totalEstimated must also be provided.',
        );

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(8),
      sliver: SliverList.list(
        children: [
          if (estimatedTransactions != null && estimatedTransactions!.isNotEmpty)
            AccordionWidget(
              title: "Transações Estimadas",
              subtitle: formatToMoneyString(totalEstimated!),
              child: ListView(
                shrinkWrap: true,
                children: List.generate(
                  estimatedTransactions!.length,
                  (int index) => _buildItem(context, index, estimatedTransactions!),
                ),
              ),
            ),
          ...List.generate(
            transactions.length,
            (int index) => _buildItem(
              context,
              index,
              transactions,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index, List<TransactionModel> transactions) {
    final transaction = transactions[index];

    String formattedDate = "";
    if (transaction.date != null) {
      final DateTime date = transaction.date!;
      formattedDate = '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    }

    return DismissibleCardWidget(
      icon: _getIcon(transaction.value),
      title: Text(transaction.description),
      subtitle: Text(formattedDate),
      trailing: _getAmountWidget(transaction.value),
      confirmDismiss: (_) => _confirmDismiss(transaction),
      onDismissed: (_) => onTransactionDelete(transaction),
      onTap: () => _editTransaction(context, transaction),
      background: Container(
        color: CupertinoColors.systemRed.withOpacity(0.5),
        padding: const EdgeInsets.only(right: 24),
        alignment: Alignment.centerRight,
        child: const Icon(
          CupertinoIcons.delete,
          color: CupertinoColors.white,
          size: 30,
        ),
      ),
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

  Future<bool> _confirmDismiss(TransactionModel transaction) async {
    if (confirmModify != null) {
      return confirmModify!(transaction);
    } else {
      return true;
    }
  }

  void _editTransaction(BuildContext context, TransactionModel transaction) async {
    if (confirmModify != null && await confirmModify!(transaction)) {
      if (context.mounted) {
        Navigator.pushNamed(context, AppRoutes.TRANSACTION_FORM, arguments: transaction);
      }
    }
  }

  Widget _getAmountWidget(double value) {
    final Color color = value < 0 ? CupertinoColors.systemRed : CupertinoColors.systemGreen;

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
