import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/formatters/money_formatter.dart';
import 'package:personal_expense_tracker/app/models/category_model.dart';
import 'package:personal_expense_tracker/app/models/credit_card_model.dart';
import 'package:personal_expense_tracker/app/pages/transaction_form_page/transaction_form_controller.dart';
import 'package:personal_expense_tracker/app/validators/required_validator.dart';
import 'package:personal_expense_tracker/app/widgets/category_selector_widget/category_selector_widget.dart';
import 'package:personal_expense_tracker/app/widgets/credit_card_selector_widget/credit_card_selector_widget.dart';
import 'package:personal_expense_tracker/app/widgets/datepicker_form_field_widget/datepicker_form_field_widget.dart';
import 'package:personal_expense_tracker/app/widgets/segmented_button_form_field/segmented_button_form_field.dart';
import 'package:personal_expense_tracker/app/widgets/text_form_field_widget/text_form_field_widget.dart';

class TransactionFormPage extends StatefulWidget {
  const TransactionFormPage({super.key});

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  final TransactionFormController _controller = TransactionFormController();
  List<CategoryModel> categories = [];
  List<CreditCardModel> creditCards = [];

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() async {
    List<CategoryModel> categories = await _controller.getCategories();
    List<CreditCardModel> creditCards = await _controller.getCredicards();

    setState(() {
      this.categories = categories;
      this.creditCards = creditCards;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Nova transação'),
      ),
      child: Form(
        key: _controller.formKey,
        child: CupertinoFormSection.insetGrouped(
          children: [
            SegmentedButtonFormField<TransactionType>(
              onSaved: (newValue) => _controller.type = newValue!,
              initialValue: _controller.type,
              options: const {
                "Saída": TransactionType.expense,
                "Entrada": TransactionType.income,
              },
            ),
            TextFormFieldWidget(
              label: "Descrição",
              placeholder: "Descrição",
              validator: RequiredValidator().validate,
              onSaved: (newValue) => _controller.transaction.description = newValue!,
            ),
            TextFormFieldWidget(
              label: 'Valor',
              placeholder: "R\$ 0,00",
              keyboardType: TextInputType.number,
              validator: RequiredValidator().validate,
              inputFormatters: [MoneyFormatter()],
              onSaved: (newValue) {
                newValue = newValue!.replaceAll('.', '');
                newValue = newValue.replaceAll(',', '.');
                _controller.transaction.value = double.parse(newValue);
              },
            ),
            DatePickerFormFieldWidget(
              label: "data",
              validator: RequiredValidator().validate,
              initialValue: DateTime.now(),
              onSaved: (date) => _controller.transaction.date = date,
            ),
            CreditCardSelectorWidget(
              selectedCreditCard: _controller.transaction.creditCard,
              creditCards: creditCards,
            ),
            CategorySelectorWidget(
              selectedCategories: _controller.transaction.categories,
              categories: categories,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: CupertinoButton.filled(
                onPressed: _controller.save,
                child: const Text("Salvar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
