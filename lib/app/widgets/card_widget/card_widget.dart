import 'package:flutter/cupertino.dart';

class CardWidget extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Icon? icon;
  final Widget? trailing;
  final void Function()? onTap;

  final Widget? child;

  const CardWidget({
    super.key,
    this.child,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(
            color: CupertinoColors.inactiveGray,
            width: 1,
            style: BorderStyle.solid,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          color: CupertinoColors.white,
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                child: child,
              )
          ],
        ),
      ),
    );
  }
}
