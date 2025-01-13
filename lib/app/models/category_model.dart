import 'package:personal_expense_tracker/app/models/base_model.dart';

class CategoryModel extends BaseModel<CategoryModel> {
  String name;
  String color;
  String? description;

  CategoryModel({super.id, super.createdAt, required this.name, this.color = "#ffffff", this.description});

  CategoryModel.empty()
      : name = "",
        color = "#ffffff",
        super();

  static Future<List<CategoryModel>> list() async {
    return CategoryModel.empty().getAll();
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
    return CategoryModel(
      id: data['id'],
      createdAt: DateTime.parse(data["createdAt"]),
      name: data["name"],
      color: data["color"],
      description: data["description"],
    );
  }
}
