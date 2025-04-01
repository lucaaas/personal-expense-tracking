import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/widgets/chip_widget/chip_widget.dart';

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
    return GestureDetector(
      onTap: onPressed,
      child: ChipWidget(
        label: label,
        icon: icon,
        isColorFilled: false,
        color: CupertinoTheme.of(context).primaryColor,
      ),
    );
  }
}
