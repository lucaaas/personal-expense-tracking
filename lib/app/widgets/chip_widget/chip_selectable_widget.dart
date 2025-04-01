import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/helpers/get_constrasting_text_color.dart';
import 'package:personal_expense_tracker/app/widgets/chip_widget/chip_widget.dart';

class ChipSelectableWidget extends StatefulWidget {
  final Color color;
  final String label;
  final IconData? icon;
  final bool isSelected;
  final void Function(bool) onChange;

  const ChipSelectableWidget({
    super.key,
    required this.color,
    required this.label,
    required this.onChange,
    this.icon,
    this.isSelected = false,
  });

  @override
  State<ChipSelectableWidget> createState() => _ChipSelectableWidgetState();
}

class _ChipSelectableWidgetState extends State<ChipSelectableWidget> {
  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.isSelected;
  }

  @override
  void didUpdateWidget(covariant ChipSelectableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    setState(() {
      _isSelected = widget.isSelected;
    });
  }

  void _onTap() {
    setState(() {
      _isSelected = !_isSelected;
      widget.onChange(_isSelected);
    });
  }

  Color _getContrastingTextColor() {
    if (_isSelected) {
      return getContrastingTextColor(widget.color);
    } else {
      return widget.color;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: ChipWidget(
        color: widget.color,
        label: widget.label,
        icon: widget.icon,
        isColorFilled: _isSelected,
        textColor: _getContrastingTextColor(),
      ),
    );
  }
}
