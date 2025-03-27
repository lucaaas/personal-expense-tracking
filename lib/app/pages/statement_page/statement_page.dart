import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:personal_expense_tracker/app/pages/statement_page/widgets/month_resume/month_resume.dart';
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
  TransactionCache? _transaction;

  bool isLoading = true;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
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
      child: CustomScrollView(
        slivers: [
          Consumer<TransactionProvider>(
            builder: (context, provider, child) => SliverPersistentHeader(
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
          if (!isLoading)
            ...(_buildMonthInformation())
          else
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  void _addTransaction() {
    Navigator.of(context).pushNamed(AppRoutes.TRANSACTION_FORM);
  }

  Future<void> _loadTransactions() async {
    TransactionProvider provider = Provider.of<TransactionProvider>(context, listen: false);

    String selectedMonth = provider.months.isEmpty ? '' : provider.months.last;

    if (selectedMonth.isNotEmpty) {
      TransactionCache transaction = await provider.getTransactionsByMonthYear(selectedMonth);

      setState(() {
        _transaction = transaction;
        _index = provider.months.indexOf(selectedMonth);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void _changeTab(int index) async {
    setState(() {
      _index = index;
      isLoading = true;
    });

    TransactionProvider provider = Provider.of<TransactionProvider>(context, listen: false);
    final TransactionCache transaction = await provider.getTransactionsByMonthYear(provider.months.elementAt(index));

    setState(() {
      _transaction = transaction;
      isLoading = false;
    });
  }

  List<Widget> _buildMonthInformation() {
    if (_transaction == null || _transaction!.transactions.isEmpty) {
      return [const SliverToBoxAdapter(child: Center(child: Text("Nenhuma transação encontrada")))];
    } else {
      return [
        SliverPadding(
          padding: const EdgeInsets.all(10),
          sliver: SliverToBoxAdapter(
            child: MonthResume(transaction: _transaction!),
          ),
        ),
        TransactionList(transactions: _transaction!.transactions)
      ];
    }
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
