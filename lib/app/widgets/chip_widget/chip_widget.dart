import 'package:flutter/cupertino.dart';

class ChipWidget extends StatefulWidget {
  final Color color;
  final String label;
  final bool isSelected;
  final void Function(bool) onChange;

  const ChipWidget({
    super.key,
    required this.color,
    required this.label,
    required this.onChange,
    this.isSelected = false,
  });

  @override
  State<ChipWidget> createState() => _ChipWidgetState();
}

class _ChipWidgetState extends State<ChipWidget> {
  late bool _isSelected;

  @override
  void initState() {
    _isSelected = widget.isSelected;
    super.initState();
  }

  void _onTap() {
    setState(() {
      _isSelected = !_isSelected;
      widget.onChange(_isSelected);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: widget.color, width: 2),
        color: _isSelected ? widget.color : CupertinoColors.transparent,
        borderRadius: BorderRadius.circular(50),
      ),
      child: GestureDetector(
        onTap: _onTap,
        child: Text(widget.label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
