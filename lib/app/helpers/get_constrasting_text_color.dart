import 'package:flutter/cupertino.dart';

Color getContrastingTextColor(Color backgroundColor) {
  double brightness =
      (backgroundColor.red * 0.299 + backgroundColor.green * 0.587 + backgroundColor.blue * 0.114) / 255;

  return brightness > 0.5 ? CupertinoColors.black : CupertinoColors.white;
}
