import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/helpers/loading_helper.dart';
import 'package:personal_expense_tracker/app/pages/credit_card_form_page/credit_card_form_controller.dart';
import 'package:personal_expense_tracker/app/validators/required_validator.dart';
import 'package:personal_expense_tracker/app/widgets/bottom_modal_scaffold_widget/bottom_modal_scaffold_widget.dart';
import 'package:personal_expense_tracker/app/widgets/color_picker_widget/color_picker_widget.dart';

class CreditCardFormPage extends StatefulWidget {
  const CreditCardFormPage({super.key});

  @override
  State<CreditCardFormPage> createState() => _CreditCardFormPageState();
}

class _CreditCardFormPageState extends State<CreditCardFormPage> {
  final controller = CreditCardFormController();

  Future<void> _save() async {
    LoadingHelper.showLoading(context);

    try {
      await controller.save();
      LoadingHelper.hideLoading(context);
      Navigator.of(context).pop(controller.creditCard);
    } catch (e) {
      LoadingHelper.hideLoading(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomModalScaffoldWidget(
      title: "Novo cartão de crédito",
      okButtonLabel: "Salvar",
      onOk: _save,
      child: Form(
        key: controller.formKey,
        child: CupertinoFormSection(
          children: [
            SizedBox(
              height: 150,
              child: ColorPickerWidget(
                selectedColor: controller.creditCard.colorValue,
                onSaved: (value) => controller.creditCard.color = value!,
                validator: RequiredValidator().validate,
              ),
            ),
            CupertinoTextFormFieldRow(
              prefix: const Text("Nome"),
              placeholder: "Nome",
              validator: RequiredValidator().validate,
              onSaved: (value) => controller.creditCard.name = value!,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: CupertinoButton.filled(
                onPressed: _save,
                child: const Text("Salvar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
