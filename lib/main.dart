import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:personal_expense_tracker/app/helpers/db_helper.dart';
import 'package:personal_expense_tracker/app/models/transaction_model.dart';
import 'package:personal_expense_tracker/app/pages/transaction_form_page/transaction_form_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'Flutter Demo',
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.systemPurple,
        primaryContrastingColor: CupertinoColors.activeOrange,
        barBackgroundColor: CupertinoColors.systemPurple,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool canShowContent = false;

  void _incrementCounter() async {
    print('oi');
    List<TransactionModel> models = await TransactionModel.list();
    print(models.length);

    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter = models.length;
    });
  }

  @override
  void initState() {
    super.initState();
    DBHelper.getInstance();

    Future.delayed(const Duration(seconds: 5)).then(
      (value) => setState(() {
        canShowContent = true;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return canShowContent
        ? const TransactionFormPage()
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
