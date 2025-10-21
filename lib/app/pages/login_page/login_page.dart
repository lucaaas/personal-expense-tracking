import 'package:flutter/cupertino.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: CupertinoButton.filled(
          child: const Text('Login with Google'),
          onPressed: () {
            // Implement Google Sign-In logic here
          },
        ),
      ),
    );
  }
}
