import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/pages/loading_page/loading_page.dart';
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
          scaffoldBackgroundColor: Color.fromARGB(255, 245, 245, 245),
          textTheme: CupertinoTextThemeData(
            textStyle: TextStyle(fontFamily: "Inter"),
            navTitleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.white,
            ),
          ),
        ),
        routes: {
          AppRoutes.HOME: (context) => const StatementPage(),
          AppRoutes.TRANSACTION_FORM: (context) => const TransactionFormPage(),
          AppRoutes.STATEMENT: (context) => const StatementPage(),
          AppRoutes.LOADING: (context) => const LoadingPage(),
        },
      ),
    );
  }
}
