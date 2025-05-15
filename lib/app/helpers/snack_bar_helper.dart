import 'package:flutter/cupertino.dart';

class SnackBarHelper {
  static OverlayEntry? _overlay;
  static SnackBarHelper? _instance;

  SnackBarHelper._();

  factory SnackBarHelper() {
    _instance ??= SnackBarHelper._();
    return _instance!;
  }

  static void show({
    required BuildContext context,
    required String message,
    required Duration duration,
    Widget? leading,
    Widget? trailing,
  }) {
    _overlay = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 0,
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: CupertinoTheme.of(context).primaryColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (leading != null) leading,
              Text(message, style: const TextStyle(fontSize: 16)),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlay!);
    Future.delayed(duration, () => _overlay!.remove());
  }

  static void remove() {
    if (_overlay != null) {
      _overlay!.remove();
      _overlay = null;
    }
  }
}
