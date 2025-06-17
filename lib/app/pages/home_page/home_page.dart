import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/helpers/format_to_money_string_helper.dart';
import 'package:personal_expense_tracker/app/pages/home_page/widgets/month_expense_widget/month_expense_widget.dart';
import 'package:personal_expense_tracker/app/pages/home_page/widgets/month_resume_widget/month_resume_widget.dart';
import 'package:personal_expense_tracker/app/providers/transaction_provider/transaction_cache.dart';
import 'package:personal_expense_tracker/app/providers/transaction_provider/transaction_provider.dart';
import 'package:personal_expense_tracker/app/widgets/page_scaffold_widget/page_scaffold_widget.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TransactionCache? _currentMonthInfo;
  late TransactionProvider _transactionProvider;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  void _init() async {
    // final TransactionProvider transactionProvider =
    //     Provider.of<TransactionProvider>(context, listen: false);

    DateTime today = DateTime.now();
    String monthYear = "${today.month}/${today.year}";
    TransactionCache monthInfo = await _transactionProvider.getTransactionsByMonthYear(monthYear);

    setState(() {
      _currentMonthInfo = monthInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    _transactionProvider = Provider.of<TransactionProvider>(context);

    return PageScaffoldWidget(
      navigationBar: const CupertinoNavigationBar(),
      child: _currentMonthInfo != null
          ? Consumer<TransactionProvider>(
              builder: (context, value, child) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Saldo", style: TextStyle(fontSize: 24)),
                  Text(
                    formatToMoneyString(_currentMonthInfo!.balance),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
                  ),
                  MonthResumeWidget(currentMonthInfo: _currentMonthInfo!),
                  MonthExpenseWidget(
                    info: _currentMonthInfo!.creditCardInfos,
                    totalExpense: _currentMonthInfo!.totalCreditCardExpense,
                    title: "Despesas por cartão de crédito",
                  ),
                  MonthExpenseWidget(
                    info: _currentMonthInfo!.categoriesInfo,
                    totalExpense: _currentMonthInfo!.totalExpense,
                    title: "Despesas por categoria",
                  ),
                ],
              ),
            )
          : const Center(child: CupertinoActivityIndicator()),
    );
  }
}
