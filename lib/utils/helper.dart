class Helper {
  String formatCurrency(double value, String currency) {
    final symbol = currency == 'KHR' ? '៛' : '\$';
    return '$symbol ${value.toStringAsFixed(currency == 'KHR' ? 0 : 2)}';
  }
}
