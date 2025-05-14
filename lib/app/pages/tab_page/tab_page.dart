import 'package:flutter/cupertino.dart';
import 'package:personal_expense_tracker/app/pages/home_page/home_page.dart';
import 'package:personal_expense_tracker/app/pages/statement_page/statement_page.dart';
import 'package:personal_expense_tracker/app/utils/app_routes.dart';
import 'package:personal_expense_tracker/app/widgets/page_scaffold_widget/page_scaffold_widget.dart';

class TabPage extends StatelessWidget {
  const TabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffoldWidget.withTabBar(
      contentPadding: EdgeInsets.zero,
      tabBarIcons: const [
        TabBarIcon(active: CupertinoIcons.house_fill, inactive: CupertinoIcons.house),
        TabBarIcon(active: CupertinoIcons.square_list_fill, inactive: CupertinoIcons.square_list),
      ],
      floatingActionButton: CupertinoButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.TRANSACTION_FORM),
        color: CupertinoTheme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(50),
        padding: const EdgeInsets.all(14),
        child: Icon(
          CupertinoIcons.add,
          color: CupertinoTheme.of(context).primaryContrastingColor,
          size: 32,
        ),
      ),
      pages: const [HomePage(), StatementPage()],
    );
  }
}
