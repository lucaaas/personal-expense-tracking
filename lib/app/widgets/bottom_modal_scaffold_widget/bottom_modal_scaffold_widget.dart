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
              showCancelButton
                  ? CupertinoButton.filled(
                      onPressed: () => {},
                      padding: EdgeInsets.zero,
                      child: Text(
                        "Cancelar",
                        style: TextStyle(color: CupertinoColors.destructiveRed.darkHighContrastElevatedColor),
                      ),
                    )
                  : const SizedBox(),
              Container(
                height: double.infinity,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: CupertinoColors.systemGrey, width: 10, style: BorderStyle.solid),
                  ),
                ),
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              showOkButton
                  ? CupertinoButton.filled(
                      onPressed: () => onOk?.call(),
                      padding: EdgeInsets.zero,
                      child: Text(okButtonLabel),
                    )
                  : const SizedBox(),
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

void showBottomModalWidget({required BuildContext context, required Widget child}) {
  showCupertinoModalPopup(
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
