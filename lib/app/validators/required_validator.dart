import 'package:personal_expense_tracker/app/validators/validator.dart';

class RequiredValidator implements Validator {
  final String message;

  RequiredValidator({this.message = "Campo obrigatório"});

  @override
  String? validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }
}
