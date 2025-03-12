import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/models/category_model.dart';
import 'package:personal_expense_tracker/app/pages/category_form_page/category_form_page.dart';
import 'package:personal_expense_tracker/app/widgets/bottom_modal_scaffold_widget/bottom_modal_scaffold_widget.dart';
import 'package:personal_expense_tracker/app/widgets/chip_button_widget/chip_button_widget.dart';
import 'package:personal_expense_tracker/app/widgets/chip_widget/chip_widget.dart';

class CategorySelectorWidget extends StatefulWidget {
  final List<CategoryModel> categories;
  final List<CategoryModel> selectedCategories;

  const CategorySelectorWidget({super.key, required this.selectedCategories, this.categories = const []});

  @override
  State<CategorySelectorWidget> createState() => _CategorySelectorWidgetState();
}

class _CategorySelectorWidgetState extends State<CategorySelectorWidget> {
  List<CategoryModel> _shownCategories = [];

  @override
  void initState() {
    _shownCategories = List.from(widget.categories);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CategorySelectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _shownCategories = List.from(widget.categories);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CupertinoTextFormFieldRow(
          placeholder: 'filtrar...',
          onChanged: _filterCategories,
          prefix: const Text('categorias'),
        ),
        Wrap(
          alignment: WrapAlignment.spaceAround,
          children: [
            ..._shownCategories.map(
              (category) => ChipWidget(
                color: category.colorValue,
                label: category.name,
                isSelected: widget.selectedCategories.contains(category),
                onChange: (bool value) => _changeSelectedCategory(category, value),
              ),
            ),
            ChipButtonWidget(
              onPressed: _goToCategoryFormPage,
              label: "Criar",
              icon: CupertinoIcons.add,
            ),
          ],
        )
      ],
    );
  }

  void _goToCategoryFormPage() async {
    CategoryModel? category = await showBottomModalWidget<CategoryModel>(
      context: context,
      child: const CategoryFormPage(),
    );

    if (category != null) {
      setState(() {
        widget.selectedCategories.add(category);
        _shownCategories.insert(0, category);
      });
    }
  }

  void _changeSelectedCategory(CategoryModel category, bool isSelected) {
    setState(() {
      if (isSelected) {
        widget.selectedCategories.add(category);
        widget.categories.remove(category);
      } else {
        widget.selectedCategories.remove(category);
        widget.categories.add(category);
      }
    });
  }

  void _filterCategories(String value) {
    List<CategoryModel> filteredCategories = [];
    if (value.trim().isNotEmpty) {
      filteredCategories =
          widget.categories.where((category) => category.name.toLowerCase().startsWith(value.toLowerCase())).toList();
    } else {
      filteredCategories = List.from(widget.categories);
    }

    _shownCategories.clear();
    setState(() {
      _shownCategories.addAll(widget.selectedCategories);
      _shownCategories.addAll(filteredCategories);
    });
  }
}
