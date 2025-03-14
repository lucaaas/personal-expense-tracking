import 'package:flutter/cupertino.dart';

class CardWidget extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Icon? icon;
  final Widget? trailing;

  final Widget? child;
  const CardWidget({
    super.key,
    this.child,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(
          color: CupertinoColors.inactiveGray,
          width: 1,
          style: BorderStyle.solid,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        color: CupertinoTheme.of(context).scaffoldBackgroundColor,
        boxShadow: const [
          BoxShadow(
            color: CupertinoColors.inactiveGray,
            spreadRadius: 0,
            blurRadius: 1.5,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          CupertinoListTile(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 15),
            title: title,
            leading: icon,
            subtitle: subtitle,
            trailing: trailing,
          ),
          if (child != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: child,
            )
        ],
      ),
    );
  }
}
