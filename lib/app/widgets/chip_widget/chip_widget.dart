import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/helpers/get_constrasting_text_color.dart';

class ChipWidget extends StatefulWidget {
  final Color color;
  final String label;
  final IconData? icon;
  final bool isSelected;
  final void Function(bool) onChange;

  const ChipWidget({
    super.key,
    required this.color,
    required this.label,
    required this.onChange,
    this.icon,
    this.isSelected = false,
  });

  @override
  State<ChipWidget> createState() => _ChipWidgetState();
}

class _ChipWidgetState extends State<ChipWidget> {
  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.isSelected;
  }

  @override
  void didUpdateWidget(covariant ChipWidget oldWidget) {
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

  Color _getContrastingTextColor(Color backgroundColor) {
    if (_isSelected) {
      return getContrastingTextColor(backgroundColor);
    } else {
      return backgroundColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: EdgeInsets.symmetric(horizontal: widget.icon != null ? 5 : 10, vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(color: widget.color, width: 2),
          color: _isSelected ? widget.color : CupertinoColors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: GestureDetector(
          onTap: _onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widget.icon != null
                  ? Icon(
                      widget.icon,
                      color: _getContrastingTextColor(widget.color),
                      size: 16,
                    )
                  : Container(),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 16,
                  color: _getContrastingTextColor(widget.color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
