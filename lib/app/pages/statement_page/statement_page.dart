import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:personal_expense_tracker/app/helpers/snack_bar_helper.dart';
import 'package:personal_expense_tracker/app/models/transaction_model.dart';
import 'package:personal_expense_tracker/app/pages/statement_page/widgets/month_resume/month_resume.dart';
import 'package:personal_expense_tracker/app/pages/statement_page/widgets/transaction_list/transaction_list.dart';
import 'package:personal_expense_tracker/app/providers/transaction_provider.dart';
import 'package:personal_expense_tracker/app/utils/app_routes.dart';
import 'package:personal_expense_tracker/app/widgets/floating_tabbar_widget/floating_tabbar_widget.dart';
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
    _load();
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
                tabBar: FloatingTabBarWidget(
                  items: provider.months.map((month) => FloatingTabBarItem(title: month)).toList(),
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

  Future<void> _load() async {
    TransactionProvider provider = Provider.of<TransactionProvider>(context, listen: false);

    provider.addListener(
      () async {
        TransactionCache transaction =
            await provider.getTransactionsByMonthYear(provider.months.elementAt(_index));
        setState(() {
          _transaction = transaction;
        });
      },
    );

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
    final TransactionCache transaction =
        await provider.getTransactionsByMonthYear(provider.months.elementAt(index));

    setState(() {
      _transaction = transaction;
      isLoading = false;
    });
  }

  List<Widget> _buildMonthInformation() {
    List<Widget> widgets = [];

    widgets.add(
      SliverPadding(
        padding: const EdgeInsets.all(10),
        sliver: SliverToBoxAdapter(
          child: MonthResume(transaction: _transaction!),
        ),
      ),
    );

    if (_transaction == null || _transaction!.transactions.isEmpty) {
      widgets.add(
          const SliverToBoxAdapter(child: Center(child: Text("Nenhuma transação encontrada"))));
    } else {
      widgets.add(TransactionList(
        transactions: _transaction!.transactions,
        onTransactionDelete: _deleteTransaction,
      ));
    }

    return widgets;
  }

  Future<void> _deleteTransaction(TransactionModel transaction) async {
    TransactionProvider provider = Provider.of<TransactionProvider>(context, listen: false);
    await provider.deleteTransaction(transaction);

    const Duration duration = Duration(seconds: 5);
    SnackBarHelper.show(
      context: context,
      duration: duration,
      message: "Transação excluída",
      leading: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1, end: 0),
        duration: duration,
        builder: (context, value, child) => CircularProgressIndicator(
          value: value,
          strokeWidth: 6,
          color: CupertinoTheme.of(context).primaryContrastingColor,
        ),
      ),
      trailing: CupertinoButton(
        child: Text(
          "Desfazer",
          style: TextStyle(
            fontSize: 16,
            color: CupertinoTheme.of(context).primaryContrastingColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () => provider.undoDeleteTransaction(),
      ),
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final FloatingTabBarWidget tabBar;

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
  double get maxExtent => 75;

  @override
  double get minExtent => 75;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
