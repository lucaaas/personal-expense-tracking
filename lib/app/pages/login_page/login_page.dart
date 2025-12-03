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
        children: [
          CupertinoButton(
            onPressed: _signInWithGoogle,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Container(
              decoration: BoxDecoration(
                border: BoxBorder.all(color: CupertinoTheme.of(context).primaryColor, width: 2),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Row(
                spacing: 10,
                children: [
                  SvgPicture.asset('assets/logos/google.svg', semanticsLabel: 'google'),
                  const Text('Entrar com Google'),
                ],
              ),
            ),
          ),
          CupertinoButton(onPressed: _goToNextPage, child: const Text('Continuar como convidado')),
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
