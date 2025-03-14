import 'package:flutter/cupertino.dart';

class ChipWidget extends StatelessWidget {
  final IconData? icon;
  final Color color;
  final Color? textColor;
  final bool isColorFilled;
  final String label;

  const ChipWidget({
    super.key,
    required this.color,
    required this.label,
    this.icon,
    this.isColorFilled = false,
    Color? textColor,
  }) : textColor = textColor ?? color;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: EdgeInsets.symmetric(horizontal: icon != null ? 5 : 10, vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          color: isColorFilled ? color : CupertinoColors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Visibility(
              visible: icon != null,
              child: Icon(
                icon,
                color: textColor,
                size: 16,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
    ;
  }
}
