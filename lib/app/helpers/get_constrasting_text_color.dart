import 'package:flutter/cupertino.dart';

Color getContrastingTextColor(Color backgroundColor) {
  if (backgroundColor.opacity < 0.5) {
    return CupertinoColors.black;
  }

  double brightness =
      ((backgroundColor.red * 0.299 + backgroundColor.green * 0.587 + backgroundColor.blue * 0.114) / 255) *
          backgroundColor.opacity;

  return brightness * backgroundColor.opacity > 0.5 ? CupertinoColors.black : CupertinoColors.white;
}
