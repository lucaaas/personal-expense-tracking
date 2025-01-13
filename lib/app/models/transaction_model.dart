import 'package:personal_expense_tracker/app/connectors/transaction_connector.dart';
import 'package:personal_expense_tracker/app/models/base_model.dart';
import 'package:personal_expense_tracker/app/models/category_model.dart';
import 'package:personal_expense_tracker/app/models/credit_card_model.dart';

class TransactionModel extends BaseModel<TransactionModel> with TransactionConnector {
  String description;
  double value;
  DateTime? date;
  CreditCardModel? creditCard;
  List<CategoryModel> categories;

  TransactionModel({
    super.id,
    super.createdAt,
    required this.description,
    required this.value,
    this.date,
    this.creditCard,
    this.categories = const [],
  });

  TransactionModel.fromMap(Map<String, dynamic> data)
      : description = data['description'],
        value = data['value'],
        categories = [],
        creditCard = data['credit_card'].keys.length > 0 ? CreditCardModel.fromMap(data['credit_card']) : null,
        date = DateTime.tryParse(data['date']),
        super(id: data['id'], createdAt: DateTime.parse(data['createdAt'])) {
    for (Map<String, dynamic> category in data['categories']) {
      categories.add(CategoryModel.fromMap(category));
    }
  }

  TransactionModel.empty()
      : description = '',
        value = 0,
        categories = [] {
    populate();
  }

  static Future<List<TransactionModel>> list() async {
    List<TransactionModel> transactions = await TransactionModel.empty().getAll();

    return transactions;
  }

  populate() async {
    final CreditCardModel creditCard = await CreditCardModel.empty().getById(1);
    final CategoryModel category = await CategoryModel.empty().getById(1);
    final TransactionModel transaction = TransactionModel(
      description: "My Transaction",
      value: 100.0,
      date: DateTime.now(),
      creditCard: creditCard,
      categories: [category],
    );
    await transaction.save();
  }

  @override
  Future<int> save() {
    for (CategoryModel category in categories) {
      category.save();
    }
    creditCard?.save();
    return insertOrUpdate(this);
  }

  @override
  String get table => "transactions";

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'value': value,
      'date': date?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'credit_card': creditCard?.id,
    };
  }

  @override
  TransactionModel toObject(Map<String, dynamic> data) {
    return TransactionModel.fromMap(data);
  }
}
