import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/widgets/card_widget/card_widget.dart';

class DismissibleCardWidget extends CardWidget {
  final Widget? background;
  final Future<bool> Function(DismissDirection)? confirmDismiss;
  final void Function(DismissDirection)? onDismissed;

  const DismissibleCardWidget({
    required super.title,
    super.subtitle,
    super.icon,
    super.trailing,
    super.child,
    super.onTap,
    super.key,
    this.background,
    this.confirmDismiss,
    this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(title),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          child: background,
        ),
      ),
      confirmDismiss: confirmDismiss,
      direction: DismissDirection.endToStart,
      onDismissed: onDismissed,
      child: super.build(context),
    );
  }
}
