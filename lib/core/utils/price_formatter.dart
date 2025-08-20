// lib/core/utils/price_formatter.dart
String formatPrice(double price, {String currencySymbol = '₪'}) {
  final isInt = price == price.roundToDouble();
  return isInt
      ? '$currencySymbol${price.toStringAsFixed(0)}'
      : '$currencySymbol${price.toStringAsFixed(2)}';
}