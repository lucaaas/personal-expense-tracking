import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/helpers/loading_helper.dart';
import 'package:personal_expense_tracker/app/pages/category_form_page/category_form_controller.dart';
import 'package:personal_expense_tracker/app/validators/required_validator.dart';
import 'package:personal_expense_tracker/app/widgets/bottom_modal_scaffold_widget/bottom_modal_scaffold_widget.dart';
import 'package:personal_expense_tracker/app/widgets/color_picker_widget/color_picker_widget.dart';

class CategoryFormPage extends StatefulWidget {
  const CategoryFormPage({super.key});

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final controller = CategoryFormController();

  Future<void> _save() async {
    LoadingHelper.showLoading(context);

    try {
      await controller.save();
      LoadingHelper.hideLoading(context);
      Navigator.of(context).pop(controller.category);
    } catch (e) {
      LoadingHelper.hideLoading(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomModalScaffoldWidget(
      title: "Nova categoria",
      okButtonLabel: "Salvar",
      onOk: _save,
      child: Form(
        key: controller.formKey,
        child: CupertinoFormSection(
          children: [
            SizedBox(
              height: 150,
              child: ColorPickerWidget(
                selectedColor: controller.category.colorValue,
                onSaved: (value) => controller.category.color = value!,
                validator: RequiredValidator().validate,
              ),
            ),
            CupertinoTextFormFieldRow(
              prefix: const Text("Nome"),
              placeholder: "Nome",
              validator: RequiredValidator().validate,
              onSaved: (value) => controller.category.name = value!,
            ),
            CupertinoTextFormFieldRow(
              prefix: const Text("Descrição"),
              placeholder: "Descrição",
              onSaved: (value) => controller.category.description = value,
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
