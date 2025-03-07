import 'package:flutter/services.dart';

class MoneyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String cleanText = newValue.text.replaceAll(RegExp(r'\D'), '');
    print(cleanText);
    TextEditingValue formattedValue = TextEditingValue();
    if (cleanText.isEmpty) {
      formattedValue = formattedValue.copyWith(text: '0,00');
    } else if (cleanText.length == 1) {
      formattedValue = formattedValue.copyWith(text: '0,0$cleanText');
    } else if (cleanText.length == 2) {
      formattedValue = formattedValue.copyWith(text: '0,$cleanText');
    } else {
      int centsIndex = cleanText.length - 2;
      String cents = cleanText.substring(centsIndex);
      String value = cleanText.substring(0, centsIndex);

      if (value.startsWith('0')) {
        value = value.substring(1);
      }

      for (int i = value.length - 3; i > 0; i -= 3) {
        value = value.replaceRange(i, i, '.');
      }

      formattedValue = formattedValue.copyWith(text: '$value,$cents');
    }

    return formattedValue;
  }
}
