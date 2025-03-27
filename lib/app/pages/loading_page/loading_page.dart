import 'package:flutter/material.dart';
import 'package:personal_expense_tracker/app/helpers/db_helper.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  void _initApp(BuildContext context) {
    DBHelper.getInstance();

    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
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
