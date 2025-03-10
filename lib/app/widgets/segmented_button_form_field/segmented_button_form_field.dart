import 'package:flutter/cupertino.dart';

class SegmentedButtonFormField<T extends Enum> extends FormField<T> {
  final Map<String, T> options;

  SegmentedButtonFormField({
    super.key,
    required this.options,
    super.onSaved,
    super.validator,
    super.autovalidateMode,
    super.enabled,
    super.initialValue,
  }) : super(
          builder: (field) {
            return CupertinoSegmentedControl<T>(
              groupValue: field.value,
              onValueChanged: (value) {
                field.didChange(value);
              },
              children: options.map<T, Widget>(
                (key, value) {
                  return MapEntry(
                    value,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(key),
                    ),
                  );
                },
              ),
            );
          },
        );
}
