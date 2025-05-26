import 'package:flutter/cupertino.dart';

const double TAB_BAR_SIZE = 48.0;

class PageScaffoldWidget extends StatefulWidget {
  final List<TabBarIcon>? tabBarIcons;
  final Widget? floatingActionButton;
  final CupertinoNavigationBar? navigationBar;
  final EdgeInsets contentPadding;
  final List<Widget> pages;
  final bool _hasTabBar;

  PageScaffoldWidget({
    super.key,
    required Widget child,
    this.navigationBar,
    this.floatingActionButton,
    this.contentPadding = const EdgeInsets.all(16),
  })  : _hasTabBar = false,
        tabBarIcons = null,
        pages = [] {
    pages.add(child);
  }

  const PageScaffoldWidget.withTabBar({
    super.key,
    required this.pages,
    required this.tabBarIcons,
    this.navigationBar,
    this.floatingActionButton,
    this.contentPadding = const EdgeInsets.all(16),
  })  : assert(pages.length == tabBarIcons?.length),
        _hasTabBar = true;

  @override
  State<PageScaffoldWidget> createState() => _PageScaffoldWidgetState();
}

class _PageScaffoldWidgetState extends State<PageScaffoldWidget> {
  int _selectedPage = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: widget.navigationBar,
      child: Stack(
        children: [
          Padding(
            padding: widget.contentPadding,
            child: SafeArea(
              minimum: _minimumSafeArea,
              top: false,
              left: false,
              right: false,
              child: _buildContent(),
            ),
          ),
          if (widget._hasTabBar)
            Positioned(
              bottom: 0,
              height: TAB_BAR_SIZE,
              child: _TabBar(
                tabBarItems: List.generate(
                  widget.tabBarIcons!.length,
                  (index) => TabBarItem(
                    icon: widget.tabBarIcons![index],
                    onTap: () => changeTab(index),
                    isSelected: _selectedPage == index,
                  ),
                ),
              ),
            ),
          if (widget.floatingActionButton != null)
            Positioned(
              bottom: widget._hasTabBar ? (TAB_BAR_SIZE + 24) : 8,
              right: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  widget.floatingActionButton!,
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (widget._hasTabBar) {
      return Column(
        children: [
          Expanded(
            child: widget.pages[_selectedPage],
          ),
        ],
      );
    } else {
      return widget.pages[0];
    }
  }

  void changeTab(int index) {
    setState(() {
      _selectedPage = index;
    });
  }

  EdgeInsets get _minimumSafeArea {
    return widget._hasTabBar ? const EdgeInsets.only(bottom: TAB_BAR_SIZE) : EdgeInsets.zero;
  }
}

class _TabBar extends StatelessWidget {
  final List<TabBarItem> tabBarItems;

  const _TabBar({required this.tabBarItems});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: CupertinoTheme.of(context).primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: tabBarItems,
      ),
    );
  }
}

class TabBarIcon {
  final IconData active;
  final IconData inactive;

  const TabBarIcon({
    required this.active,
    required this.inactive,
  });
}

class TabBarItem extends StatelessWidget {
  final TabBarIcon icon;
  final bool isSelected;
  final void Function() onTap;

  const TabBarItem({
    super.key,
    required this.icon,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CupertinoButton(
        alignment: Alignment.center,
        onPressed: onTap,
        child: Icon(
          isSelected ? icon.active : icon.inactive,
          color: CupertinoTheme.of(context).primaryContrastingColor,
        ),
      ),
    );
  }
}
