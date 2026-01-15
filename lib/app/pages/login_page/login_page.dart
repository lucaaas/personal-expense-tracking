import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:personal_expense_tracker/app/helpers/snack_bar_helper.dart';
import 'package:personal_expense_tracker/app/pages/login_page/login_page_controller.dart';
import 'package:personal_expense_tracker/app/utils/app_routes.dart';
import 'package:personal_expense_tracker/app/widgets/page_scaffold_widget/page_scaffold_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final controller = LoginPageController();

  @override
  void initState() {
    super.initState();

    controller.init().then((_) {
      if (FirebaseAuth.instance.currentUser != null) {
        if (mounted) {
          _goToNextPage();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffoldWidget(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 32,
        children: [
          SvgPicture.asset('assets/logos/app_logo.svg', semanticsLabel: 'app_logo'),
          Text("bem vindo", style: TextStyle(fontSize: 36), textAlign: TextAlign.center),
          CupertinoButton(
            onPressed: _signInWithGoogle,

            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Container(
              height: 52,
              width: double.infinity,

              decoration: BoxDecoration(
                color: CupertinoTheme.of(context).primaryColor,
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
              child: Row(
                spacing: 32,
                children: [
                  SvgPicture.asset('assets/logos/google.svg', semanticsLabel: 'google'),
                  Text(
                    'Continuar com Google',
                    style: TextStyle(
                      color: CupertinoTheme.of(context).primaryContrastingColor,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          CupertinoButton(
            onPressed: _goToNextPage,
            child: const Text(
              'Continuar como convidado',
              style: TextStyle(fontSize: 16, decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    try {
      await controller.signInWithGoogle();

      if (mounted) {
        _goToNextPage();
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.show(
          context: context,
          message: "Não foi possível autenticá-lo. Por favor, tente novamente",
          duration: Duration(seconds: 5),
        );
      }
    }
  }

  void _goToNextPage() {
    Navigator.pushReplacementNamed(context, AppRoutes.LOADING);
  }
}
