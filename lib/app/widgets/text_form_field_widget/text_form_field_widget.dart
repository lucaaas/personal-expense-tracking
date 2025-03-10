import 'package:flutter/cupertino.dart';

class TextFormFieldWidget extends CupertinoTextFormFieldRow {
  TextFormFieldWidget({
    super.key,
    required String label,
    super.placeholder,
    super.keyboardType,
    super.readOnly,
    super.inputFormatters,
    super.validator,
    super.onSaved,
    super.onChanged,
    super.controller,
  }) : super(
          textAlign: TextAlign.end,
          prefix: Text(label),
        );
}
