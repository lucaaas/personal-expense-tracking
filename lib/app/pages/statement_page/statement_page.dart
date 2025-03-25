import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:personal_expense_tracker/app/models/transaction_model.dart';
import 'package:personal_expense_tracker/app/pages/statement_page/widgets/transaction_list/transaction_list.dart';
import 'package:personal_expense_tracker/app/providers/transaction_provider.dart';
import 'package:personal_expense_tracker/app/utils/app_routes.dart';
import 'package:personal_expense_tracker/app/widgets/tabbar_widget/tabbar_widget.dart';
import 'package:provider/provider.dart';

class StatementPage extends StatefulWidget {
  const StatementPage({super.key});

  @override
  State<StatementPage> createState() => _StatementPageState();
}

class _StatementPageState extends State<StatementPage> {
  late TransactionProvider provider;
  List<TransactionModel> _transactions = [];

  bool isLoading = true;
  int _index = 0;

  @override
  void initState() {
    super.initState();

    provider = Provider.of<TransactionProvider>(context, listen: false);
    Future.delayed(const Duration(seconds: 2), _loadTransactions);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("Extrato"),
        trailing: CupertinoButton(
          onPressed: _addTransaction,
          padding: EdgeInsets.zero,
          child: Icon(
            CupertinoIcons.add,
            color: CupertinoTheme.of(context).primaryContrastingColor,
          ),
        ),
      ),
      child: !isLoading
          ? CustomScrollView(
              slivers: [
                Consumer(
                  builder: (context, value, child) => SliverPersistentHeader(
                    pinned: true,
                    delegate: _HeaderDelegate(
                      tabBar: TabBarWidget(
                        items: provider.months.map((month) => TabBarItem(title: month)).toList(),
                        selectedIndex: _index,
                        onTabChanged: _changeTab,
                      ),
                    ),
                  ),
                ),
                _transactions.isNotEmpty
                    ? TransactionList(transactions: _transactions)
                    : const SliverToBoxAdapter(child: Center(child: Text("Nenhuma transação encontrada"))),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  void _addTransaction() {
    Navigator.of(context).pushNamed(AppRoutes.TRANSACTION_FORM);
  }

  Future<void> _loadTransactions() async {
    String selectedMonth = provider.months.isEmpty ? '' : provider.months.last;

    if (selectedMonth.isNotEmpty) {
      List<TransactionModel> transactions = await provider.getTransactionsByMonthYear(selectedMonth);

      setState(() {
        _transactions = transactions;
        _index = provider.months.indexOf(selectedMonth);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void _changeTab(int index) async {
    setState(() => isLoading = true);

    final List<TransactionModel> transactions =
        await provider.getTransactionsByMonthYear(provider.months.elementAt(index));

    setState(() {
      _index = index;
      _transactions = transactions;
      isLoading = false;
    });
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final TabBarWidget tabBar;

  _HeaderDelegate({required this.tabBar});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Align(
      child: Container(
        color: CupertinoTheme.of(context).scaffoldBackgroundColor,
        child: tabBar,
      ),
    );
  }

  @override
  double get maxExtent => 50;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
