import 'package:flutter/cupertino.dart';

class SnackBarHelper {
  static void show({
    required BuildContext context,
    required String message,
    required Duration duration,
    Widget? leading,
    Widget? trailing,
  }) {
    final overlay = OverlayEntry(
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

    Overlay.of(context).insert(overlay);
    Future.delayed(duration, () => overlay.remove());
  }
}

// class _SnackbarWidget extends StatefulWidget {
//   final Widget? leading;
//   final String message;
//   final Widget? trailing;
//   final Duration duration;
//   final bool showCircularProgress;
//
//   const _SnackbarWidget({
//     super.key,
//     this.leading,
//     required this.message,
//     this.trailing,
//     required this.duration,
//     this.showCircularProgress = false,
//   }) : assert((showCircularProgress || leading == null),
//             'showCircularProgress can only be true if leading is null');
//
//   @override
//   State<_SnackbarWidget> createState() => _SnackbarWidgetState();
// }
//
// class _SnackbarWidgetState extends State<_SnackbarWidget> {
//   int _timerToDelete = 0;
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   void _updateTimer() {
//     _timerToDelete = widget.duration.inSeconds;
//
//     Future.doWhile(() {
//       Future.delayed(const Duration(seconds: 1), () => setState(() => _timerToDelete--));
//       return _timerToDelete > 0;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (widget.showCircularProgress) {
//       _updateTimer();
//     }
//
//     return Positioned(
//       bottom: 0,
//       child: Container(
//         width: MediaQuery.of(context).size.width,
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: CupertinoTheme.of(context).primaryColor,
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             if (widget.showCircularProgress)
//               CircularProgressIndicator(
//                 color: CupertinoTheme.of(context).primaryContrastingColor,
//                 value: 1 / _timerToDelete,
//               ),
//             if (widget.leading != null) widget.leading!,
//             Text(widget.message, style: const TextStyle(fontSize: 16)),
//             if (widget.trailing != null) widget.trailing!,
//           ],
//         ),
//       ),
//     );
//   }
// }
