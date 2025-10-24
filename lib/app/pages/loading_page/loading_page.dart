import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:personal_expense_tracker/app/helpers/db_helper.dart';
import 'package:personal_expense_tracker/app/models/category_model.dart';
import 'package:personal_expense_tracker/app/models/credit_card_model.dart';
import 'package:personal_expense_tracker/app/models/transaction_model.dart';
import 'package:personal_expense_tracker/app/providers/transaction_provider/transaction_provider.dart';
import 'package:personal_expense_tracker/app/utils/app_routes.dart';
import 'package:provider/provider.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  void _initApp() async {
    // try {
    DBHelper.getInstance();

    if (FirebaseAuth.instance.currentUser != null) {
      await _sync();
    }

    if (mounted) {
      await Provider.of<TransactionProvider>(context, listen: false).init();
      Navigator.of(context).pushReplacementNamed(AppRoutes.TAB);
    }
    // } catch (e) {
    //   print("Erro durante a inicialização: $e");
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('Falha ao carregar dados: $e')),
    //     );
    //   }
    // }
  }

  Future<void> _sync() async {
    await CategoryModel.empty().sync();
    await CreditCardModel.empty().sync();
    await TransactionModel.empty().sync();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: LinearProgressIndicator()));
  }
}
