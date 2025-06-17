import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/models/transaction_model.dart';
import 'package:personal_expense_tracker/app/pages/home_page/home_page.dart';
import 'package:personal_expense_tracker/app/pages/loading_page/loading_page.dart';
import 'package:personal_expense_tracker/app/pages/statement_page/statement_page.dart';
import 'package:personal_expense_tracker/app/pages/tab_page/tab_page.dart';
import 'package:personal_expense_tracker/app/pages/transaction_form_page/transaction_form_page.dart';

class AppRoutes {
  static const LOADING = '/';
  static const HOME = '/home';
  static const TRANSACTION_FORM = '/transaction-form';
  static const STATEMENT = '/statement';
  static const TAB = '/tab';

  static Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.HOME:
        return CupertinoPageRoute(builder: (_) => const HomePage());
      case AppRoutes.TRANSACTION_FORM:
        return CupertinoPageRoute(
          builder: (_) => TransactionFormPage(
            transaction: settings.arguments as TransactionModel?,
          ),
        );
      case AppRoutes.STATEMENT:
        return CupertinoPageRoute(builder: (_) => const StatementPage());
      case AppRoutes.LOADING:
        return CupertinoPageRoute(builder: (_) => const LoadingPage());
      case AppRoutes.TAB:
        return CupertinoPageRoute(builder: (_) => const TabPage());
      default:
        return null;
    }
  }
}
