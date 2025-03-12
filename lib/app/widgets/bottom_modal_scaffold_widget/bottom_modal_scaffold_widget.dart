import 'package:flutter/cupertino.dart';

class BottomModalScaffoldWidget extends StatelessWidget {
  final String title;
  final Widget child;
  final bool showCancelButton;
  final bool showOkButton;
  final String okButtonLabel;
  final void Function()? onOk;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          width: double.infinity,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: CupertinoTheme.of(context).barBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Visibility(
                visible: showCancelButton,
                child: CupertinoButton.filled(
                  onPressed: () => {},
                  padding: EdgeInsets.zero,
                  child: Text(
                    "Cancelar",
                    style: TextStyle(color: CupertinoColors.destructiveRed.darkHighContrastElevatedColor),
                  ),
                ),
              ),
              Container(
                height: double.infinity,
                alignment: Alignment.center,
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Visibility(
                visible: showOkButton,
                child: CupertinoButton.filled(
                  onPressed: () => onOk?.call(),
                  padding: EdgeInsets.zero,
                  child: Text(okButtonLabel),
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }

  const BottomModalScaffoldWidget({
    super.key,
    required this.title,
    required this.child,
    this.okButtonLabel = "Ok",
    this.showCancelButton = true,
    this.showOkButton = true,
    this.onOk,
  });
}

Future<T?> showBottomModalWidget<T>({required BuildContext context, required Widget child}) {
  return showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: child,
      );
    },
  );
}
