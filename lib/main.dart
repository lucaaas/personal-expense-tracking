import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/helpers/db_helper.dart';
import 'package:personal_expense_tracker/app/pages/statement_page/statement_page.dart';
import 'package:personal_expense_tracker/app/providers/transaction_provider.dart';
import 'package:personal_expense_tracker/app/utils/app_routes.dart';
import 'package:provider/provider.dart';

import 'app/pages/transaction_form_page/transaction_form_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    DBHelper.getInstance();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: CupertinoApp(
        title: 'Flutter Demo',
        theme: const CupertinoThemeData(
          primaryColor: CupertinoColors.systemPurple,
          primaryContrastingColor: CupertinoColors.activeOrange,
          barBackgroundColor: CupertinoColors.systemPurple,
        ),
        routes: {
          AppRoutes.HOME: (context) => const StatementPage(),
          AppRoutes.TRANSACTION_FORM: (context) => const TransactionFormPage(),
          AppRoutes.STATEMENT: (context) => const StatementPage(),
        },
      ),
    );
  }
}
