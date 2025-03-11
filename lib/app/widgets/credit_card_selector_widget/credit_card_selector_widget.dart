import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:personal_expense_tracker/app/models/credit_card_model.dart';
import 'package:personal_expense_tracker/app/pages/credit_card_form_page/credit_card_form_page.dart';

import '../../helpers/get_constrasting_text_color.dart';
import '../bottom_modal_scaffold_widget/bottom_modal_scaffold_widget.dart';

class CreditCardSelectorWidget extends StatefulWidget {
  final List<CreditCardModel> creditCards;
  final CreditCardModel? selectedCreditCard;
  final void Function(CreditCardModel?)? onSaved;

  const CreditCardSelectorWidget({super.key, required this.creditCards, this.selectedCreditCard, this.onSaved});

  @override
  State<CreditCardSelectorWidget> createState() => _CreditCardSelectorWidgetState();
}

class _CreditCardSelectorWidgetState extends State<CreditCardSelectorWidget> {
  CreditCardModel? _selectedCreditCard;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCreditCard = widget.selectedCreditCard;
    if (_selectedCreditCard != null) {
      _controller.text = _selectedCreditCard!.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTextFormFieldRow(
      prefix: const Text('cartão de crédito'),
      placeholder: 'Selecione o cartão de crédito',
      readOnly: true,
      onTap: _openSelector,
      onSaved: _onSaved,
      style: _getTextStyle(),
      controller: _controller,
      decoration: _getDecoration(),
      textAlign: TextAlign.center,
    );
  }

  TextStyle _getTextStyle() {
    if (_selectedCreditCard != null) {
      return TextStyle(
        color: getContrastingTextColor(_selectedCreditCard!.colorValue),
        backgroundColor: _selectedCreditCard!.colorValue,
      );
    } else {
      return const TextStyle(color: CupertinoColors.placeholderText);
    }
  }

  BoxDecoration _getDecoration() {
    if (_selectedCreditCard != null) {
      return BoxDecoration(
        color: _selectedCreditCard!.colorValue,
        borderRadius: BorderRadius.circular(50),
      );
    } else {
      return const BoxDecoration();
    }
  }

  void _openSelector() async {
    CreditCardModel? creditCard = await showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: const Text('Selecione o cartão de crédito'),
          actions: [
            ...widget.creditCards.map(
              (creditCard) => CupertinoActionSheetAction(
                onPressed: () => Navigator.of(context).pop(creditCard),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: creditCard.colorValue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    creditCard.name,
                    style: TextStyle(
                      color: getContrastingTextColor(creditCard.colorValue),
                    ),
                  ),
                ),
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: _goToCreditCardFormPage,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Novo cartão de crédito",
                  style: TextStyle(
                    color: getContrastingTextColor(Theme.of(context).primaryColor),
                  ),
                ),
              ),
            )
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        );
      },
    );

    if (creditCard != null) {
      setState(() {
        _selectedCreditCard = creditCard;
        _controller.text = creditCard.name;
      });
    }
  }

  void _onSaved(_) {
    if (widget.onSaved != null) {
      widget.onSaved!(_selectedCreditCard);
    }
  }

  void _goToCreditCardFormPage() async {
    CreditCardModel? creditCard = await showBottomModalWidget<CreditCardModel>(
      context: context,
      child: const CreditCardFormPage(),
    );

    if (creditCard != null) {
      setState(() {
        _selectedCreditCard = creditCard;
        _controller.text = creditCard.name;
      });
    }

    Navigator.of(context).pop();
  }
}
