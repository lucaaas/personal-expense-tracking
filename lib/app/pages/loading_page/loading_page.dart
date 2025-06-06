import 'package:flutter/material.dart';
import 'package:personal_expense_tracker/app/helpers/db_helper.dart';
import 'package:personal_expense_tracker/app/providers/transaction_provider/transaction_provider.dart';
import 'package:personal_expense_tracker/app/utils/app_routes.dart';
import 'package:provider/provider.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  void _initApp(BuildContext context) {
    DBHelper.getInstance();

    Future.delayed(const Duration(seconds: 3), () async {
      if (context.mounted) {
        await Provider.of<TransactionProvider>(context, listen: false).init();
        Navigator.of(context).pushReplacementNamed(AppRoutes.TAB);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _initApp(context);

    return const Center(
      child: LinearProgressIndicator(),
    );
  }
}
