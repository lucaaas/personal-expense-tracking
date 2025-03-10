import 'package:flutter/cupertino.dart';

class DatePickerFormFieldWidget extends StatefulWidget {
  final String label;
  final DateTime initialValue;
  final void Function(DateTime)? onSaved;
  final String? Function(String?)? validator;

  DatePickerFormFieldWidget({super.key, required this.label, DateTime? initialValue, this.onSaved, this.validator})
      : initialValue = initialValue ?? DateTime.now();

  @override
  State<DatePickerFormFieldWidget> createState() => _DatePickerFormFieldWidgetState();
}

class _DatePickerFormFieldWidgetState extends State<DatePickerFormFieldWidget> {
  late DateTime _selectedDate;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialValue;
    _controller.text = '${_selectedDate.day.toString().padLeft(2, '0')}/'
        '${_selectedDate.month.toString().padLeft(2, '0')}/'
        '${_selectedDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTextFormFieldRow(
      prefix: Text(widget.label),
      onTap: _openDatePicker,
      onSaved: _onSaved,
      readOnly: true,
      textAlign: TextAlign.end,
      validator: widget.validator,
      controller: _controller,
    );
  }

  void _onSaved(_) {
    if (widget.onSaved != null) {
      widget.onSaved!(_selectedDate);
    }
  }

  void _openDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 0),
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          dateOrder: DatePickerDateOrder.dmy,
          onDateTimeChanged: (value) {
            setState(() {
              _selectedDate = value;
              _controller.text = '${_selectedDate.day.toString().padLeft(2, '0')}/'
                  '${_selectedDate.month.toString().padLeft(2, '0')}/'
                  '${_selectedDate.year}';
            });
          },
        ),
      ),
    );
  }
}
