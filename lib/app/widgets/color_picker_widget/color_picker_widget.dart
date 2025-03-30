import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../helpers/get_constrasting_text_color.dart';

class ColorPickerWidget extends StatefulWidget {
  final Color selectedColor;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;

  const ColorPickerWidget({this.selectedColor = CupertinoColors.systemOrange, this.onSaved, this.validator, super.key});

  @override
  State<ColorPickerWidget> createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  final TextEditingController _textEditingController = TextEditingController();
  late Color _pickedColor;
  late Color _textColor;
  double _brightness = 1;

  @override
  void initState() {
    super.initState();
    _pickedColor = widget.selectedColor;
    _textEditingController.text = '#${_pickedColor.value.toRadixString(16).toUpperCase()}';
    _updateTextColor();
  }

  void _onColorChanged(Color color) {
    setState(() {
      _pickedColor = color.withOpacity(_brightness);
      _textEditingController.text = '#${color.value.toRadixString(16).toUpperCase()}';
      _updateTextColor();
    });
  }

  void _onBrightnessChanged(double value) {
    setState(() {
      _brightness = value;
      _pickedColor = _pickedColor.withOpacity(value);
      _textEditingController.text = '#${_pickedColor.value.toRadixString(16).toUpperCase()}';
    });
    _updateTextColor();
  }

  void _updateTextColor() {
    setState(() {
      _textColor = getContrastingTextColor(_pickedColor);
    });
  }

  void _onSaved(_) {
    if (widget.onSaved != null) {
      widget.onSaved!(_pickedColor.value.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: _ColorWheel(onColorChanged: _onColorChanged),
          ),
          Flexible(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [CupertinoColors.white, _pickedColor.withOpacity(1)],
                    ),
                  ),
                  child: CupertinoSlider(value: _brightness, onChanged: _onBrightnessChanged),
                ),
                CupertinoTextFormFieldRow(
                  padding: const EdgeInsets.all(0),
                  readOnly: true,
                  decoration: BoxDecoration(color: _pickedColor),
                  style: TextStyle(color: _textColor),
                  onSaved: _onSaved,
                  validator: widget.validator,
                  controller: _textEditingController,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ColorWheel extends StatefulWidget {
  final void Function(Color) onColorChanged;

  const _ColorWheel({
    required this.onColorChanged,
  });

  @override
  State<_ColorWheel> createState() => _ColorWheelState();
}

class _ColorWheelState extends State<_ColorWheel> {
  final GlobalKey _key = GlobalKey();

  Future<void> _getColorAtTap(Offset position) async {
    RenderRepaintBoundary boundary = _key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    int pixelOffset = (position.dy.toInt() * image.width + position.dx.toInt()) * 4;
    int red = byteData!.getUint8(pixelOffset);
    int green = byteData.getUint8(pixelOffset + 1);
    int blue = byteData.getUint8(pixelOffset + 2);
    int alpha = byteData.getUint8(pixelOffset + 3);

    setState(() {
      widget.onColorChanged(Color.fromARGB(alpha, red, green, blue));
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _key,
      child: GestureDetector(
        onPanUpdate: (details) => _getColorAtTap(details.localPosition),
        child: Container(
          height: 100,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: [
                CupertinoColors.systemIndigo,
                CupertinoColors.systemPurple,
                CupertinoColors.systemPink,
                CupertinoColors.systemRed,
                CupertinoColors.systemOrange,
                CupertinoColors.systemYellow,
                CupertinoColors.systemGreen,
                CupertinoColors.systemTeal,
                CupertinoColors.systemBlue,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
