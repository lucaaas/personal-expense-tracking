import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:personal_expense_tracker/app/providers/transaction_provider/transaction_provider.dart';
import 'package:personal_expense_tracker/app/utils/app_routes.dart';
import 'package:provider/provider.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(
      systemNavigationBarColor: Color.fromARGB(255, 249, 139, 95),
      statusBarColor: Color.fromARGB(255, 249, 139, 95),
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => TransactionProvider())],
      child: const CupertinoApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: CupertinoThemeData(
          primaryColor: Color.fromARGB(255, 58, 0, 1),
          primaryContrastingColor: Color.fromRGBO(234, 161, 135, 0.8),
          barBackgroundColor: Color.fromARGB(255, 58, 0, 1),
          scaffoldBackgroundColor: Color.fromRGBO(234, 161, 135, 0.8),
          textTheme: CupertinoTextThemeData(
            textStyle: TextStyle(
              fontFamily: "Inter",
              color: Color.fromARGB(255, 58, 0, 1),
              fontSize: 18,
              inherit: false,
            ),
            navTitleTextStyle: TextStyle(
              inherit: false,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color.fromRGBO(234, 161, 135, 0.8),
            ),
            primaryColor: Color.fromRGBO(234, 161, 135, 0.8),
          ),
        ),
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
