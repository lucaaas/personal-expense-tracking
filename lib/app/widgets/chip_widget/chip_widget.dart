import 'package:flutter/cupertino.dart';

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
    _isSelected = widget.isSelected;
    super.initState();
  }

  void _onTap() {
    setState(() {
      _isSelected = !_isSelected;
      widget.onChange(_isSelected);
    });
  }

  Color _getContrastingTextColor(Color backgroundColor) {
    if (_isSelected) {
      double brightness =
          (backgroundColor.red * 0.299 + backgroundColor.green * 0.587 + backgroundColor.blue * 0.114) / 255;

      return brightness > 0.5 ? CupertinoColors.black : CupertinoColors.white;
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
