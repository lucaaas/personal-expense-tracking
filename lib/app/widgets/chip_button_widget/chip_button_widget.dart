import 'package:flutter/cupertino.dart';

class ChipButtonWidget extends StatelessWidget {
  final void Function() onPressed;
  final String label;
  final IconData? icon;

  const ChipButtonWidget({
    required this.onPressed,
    required this.label,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.all(0),
      alignment: Alignment.topRight,
      onPressed: onPressed,
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: CupertinoTheme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(50),
        ),
        child: IntrinsicWidth(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Visibility(
                visible: icon != null,
                child: Icon(
                  icon,
                  color: CupertinoColors.white,
                  size: 16,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
