import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/models/category_model.dart';

class CategoryFormController {
  final CategoryModel category;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  CategoryFormController({CategoryModel? category}) : category = category ?? CategoryModel.empty();

  Future<void> save() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      await category.save();
    } else {
      throw Exception("Invalid form");
    }
  }
}
