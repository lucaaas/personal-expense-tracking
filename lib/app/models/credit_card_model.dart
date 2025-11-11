import 'dart:ui';

import 'package:personal_expense_tracker/app/models/base_model.dart';

class CreditCardModel extends BaseModel<CreditCardModel> {
  String name;
  String color;

  CreditCardModel({super.id, super.createdAt, required this.name, required this.color});

  CreditCardModel.fromMap(Map<String, dynamic> data)
    : name = data["name"],
      color = data["color"].toString(),
      super(
        id: data["id"],
        createdAt: DateTime.parse(data["createdAt"]),
        updatedAt: DateTime.parse(data['updatedAt']),
        isDeleted: data['isDeleted'] == 1,
        synced: data['synced'] == 1,
      );

  CreditCardModel.empty() : name = "", color = "0xFFFF9700", super();

  @override
  String get table => "credit_card";

  get colorValue => Color(int.parse(color));

  @override
  CreditCardModel toObject(Map<String, dynamic> data) {
    return CreditCardModel.fromMap(data);
  }

  static Future<List<CreditCardModel>> list() async {
    return CreditCardModel.empty().getAll();
  }

  static Future<CreditCardModel> get(String id) async {
    return CreditCardModel.empty().getById(id);
  }

  @override
  bool operator ==(Object other) {
    return other is CreditCardModel && other.id == id;
  }

  @override
  Map<String, dynamic> toMap() {
    return {...super.toMap(), "name": name, "color": color};
  }
}
