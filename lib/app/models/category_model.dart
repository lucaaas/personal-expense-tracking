import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/models/base_model.dart';

class CategoryModel extends BaseModel<CategoryModel> {
  String name;
  String color;
  String? description;

  CategoryModel({super.id, super.createdAt, required this.name, this.color = "0xFFFF9700", this.description});

  CategoryModel.fromMap(Map<String, dynamic> data)
      : name = data["name"],
        color = data["color"].toString(),
        description = data["description"],
        super(id: data["id"], createdAt: DateTime.parse(data["createdAt"]));

  CategoryModel.empty()
      : name = "",
        color = "0xFFFF9700",
        super();

  static Future<List<CategoryModel>> list() async {
    return CategoryModel.empty().getAll();
  }

  Color get colorValue {
    return Color(int.parse(color));
  }

  @override
  String get table => "category";

  @override
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "createdAt": createdAt.toIso8601String(),
      "name": name,
      "color": color,
      "description": description,
    };
  }

  @override
  CategoryModel toObject(Map<String, dynamic> data) {
    return CategoryModel.fromMap(data);
  }
}
