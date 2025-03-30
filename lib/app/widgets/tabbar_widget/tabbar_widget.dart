import 'package:flutter/cupertino.dart';

class TabBarWidget extends StatefulWidget {
  final List<TabBarItem> items;
  final int selectedIndex;
  final void Function(int)? onTabChanged;

  const TabBarWidget({
    super.key,
    required this.items,
    this.selectedIndex = 0,
    this.onTabChanged,
  });

  @override
  State<TabBarWidget> createState() => _TabBarWidgetState();
}

class _TabBarWidgetState extends State<TabBarWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant TabBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scrollController.animateTo(_scrollOffset, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(_scrollOffset, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(
            color: CupertinoTheme.of(context).primaryColor,
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: widget.items
              .map<Widget>(
                (item) => GestureDetector(
                  onTap: () => widget.onTabChanged?.call(widget.items.indexOf(item)),
                  child: _TabBarItemWidget(
                    item: item,
                    isSelected: widget.items.indexOf(item) == widget.selectedIndex,
                    itemWidth: _itemWidth,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  double get _scrollOffset {
    double offset = 0;

    if (widget.selectedIndex == widget.items.length - 1) {
      offset = _scrollController.position.maxScrollExtent;
    } else if (widget.selectedIndex > 1) {
      offset = _itemWidth * (widget.selectedIndex - 1);
    }

    return offset;
  }

  double get _itemWidth {
    if (widget.items.length > 3) {
      return MediaQuery.of(context).size.width / 3;
    } else {
      return MediaQuery.of(context).size.width / widget.items.length;
    }
  }
}

class TabBarItem {
  final String? title;
  final IconData? icon;

  const TabBarItem({this.title, this.icon}) : assert(title != null || icon != null);
}

class _TabBarItemWidget extends StatelessWidget {
  final TabBarItem item;
  final bool isSelected;
  final double? itemWidth;
  late final EdgeInsets _padding;

  _TabBarItemWidget({super.key, required this.item, this.isSelected = false, this.itemWidth}) {
    if (item.title != null && item.icon != null) {
      _padding = const EdgeInsets.symmetric(vertical: 2.5);
    } else {
      _padding = const EdgeInsets.symmetric(vertical: 10);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: itemWidth ?? MediaQuery.of(context).size.width / 3,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.symmetric(
          vertical: BorderSide(
            color: CupertinoTheme.of(context).primaryColor,
            width: 0.5,
          ),
        ),
      ),
      padding: _padding,
      child: _buildItemsBar(context, item),
    );
  }

  Widget _buildItemsBar(BuildContext context, TabBarItem item) {
    Color color =
        isSelected ? CupertinoTheme.of(context).primaryContrastingColor : CupertinoTheme.of(context).primaryColor;

    if (item.title != null && item.icon != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(item.icon, color: color),
          Text(
            item.title!,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      );
    } else if (item.title != null) {
      return Text(item.title!, style: TextStyle(color: color));
    } else {
      return Icon(item.icon, color: color);
    }
  }
}
