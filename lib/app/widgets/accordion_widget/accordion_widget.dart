import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/widgets/card_widget/card_widget.dart';

class AccordionWidget extends StatefulWidget {
  final Widget child;
  final bool isExpanded;
  final String title;
  final String subtitle;
  final double maxHeight;

  const AccordionWidget({
    super.key,
    required this.child,
    this.isExpanded = false,
    this.title = "",
    this.subtitle = "",
    this.maxHeight = 200,
  });

  @override
  State<AccordionWidget> createState() => _AccordionWidgetState();
}

class _AccordionWidgetState extends State<AccordionWidget> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      title: Text(widget.title),
      subtitle: Text(widget.subtitle),
      trailing: Icon(
        _isExpanded ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
        size: 32,
      ),
      onTap: _toggleExpansion,
      childPadding: EdgeInsets.zero,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        height: _isExpanded ? null : 0,
        constraints: BoxConstraints(maxHeight: widget.maxHeight),
        child: widget.child,
      ),
    );
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }
}
