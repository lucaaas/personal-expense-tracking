import 'package:personal_expense_tracker/app/models/base_model.dart';

class CreditCardModel extends BaseModel<CreditCardModel> {
  String name;
  String color;

  CreditCardModel({super.id, super.createdAt, required this.name, required this.color});

  CreditCardModel.empty()
      : name = "",
        color = "",
        super() {
    populate();
  }

  @override
  String get table => "credit_card";

  @override
  CreditCardModel toObject(Map<String, dynamic> data) {
    return CreditCardModel(
        id: data['id'], createdAt: DateTime.parse(data["createdAt"]), name: data["name"], color: data["color"]);
  }

  Future<void> populate() async {
    final CreditCardModel model = CreditCardModel(name: "My Card", color: "#FF0000");
    await model.save();
  }

  static Future<List<CreditCardModel>> list() async {
    return CreditCardModel.empty().getAll();
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "createdAt": createdAt.toIso8601String(),
      "name": name,
      "color": color,
    };
  }
}
