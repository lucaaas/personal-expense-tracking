String formatToMoneyString(double value) {
  String formattedValue = value.toStringAsFixed(2).replaceAll('.', ',');

  return "R\$ $formattedValue";
}
