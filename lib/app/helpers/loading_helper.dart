import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingHelper {
  static void showLoading(BuildContext context) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  static void hideLoading(BuildContext context) {
    Navigator.of(context).pop();
  }
}
