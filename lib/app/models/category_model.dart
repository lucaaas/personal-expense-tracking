import 'dart:ui';

import 'package:personal_expense_tracker/app/models/base_model.dart';

class CategoryModel extends BaseModel<CategoryModel> {
  String name;
  String color;
  String? description;

  CategoryModel({super.id, super.createdAt, required this.name, this.color = "#ffffff", this.description});

  CategoryModel.fromMap(Map<String, dynamic> data)
      : name = data["name"],
        color = data["color"],
        description = data["description"],
        super(id: data["id"], createdAt: DateTime.parse(data["createdAt"]));

  CategoryModel.empty()
      : name = "",
        color = "#ffffff",
        super() {
    populate();
  }

  static Future<List<CategoryModel>> list() async {
    return CategoryModel.empty().getAll();
  }

  populate() async {
    final CategoryModel model = CategoryModel(name: "My Category", color: "#FF0000");
    await model.save();
  }

  Color get colorValue {
    String hexColor = color.replaceAll('#', '');
    return Color(int.parse(hexColor, radix: 16));
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
