import 'package:flutter/cupertino.dart';

class PageScaffoldWidget extends StatelessWidget {
  final Widget child;
  final CupertinoNavigationBar? navigationBar;
  final Widget? floatingActionButton;

  const PageScaffoldWidget({
    super.key,
    required this.child,
    this.navigationBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: navigationBar,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
          if (floatingActionButton != null)
            Positioned(
              bottom: 16,
              right: 16,
              child: floatingActionButton!,
            ),
        ],
      ),
    );
  }
}
