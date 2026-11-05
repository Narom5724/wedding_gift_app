import 'package:intl/intl.dart';

class CurrencyHelper {
  static const String usd = 'USD';
  static const String khr = 'KHR';

  static String normalize(String currency) {
    final normalized = currency.trim().toUpperCase();
    return normalized == 'KH' ? khr : normalized;
  }

  static String symbol(String currency) {
    return normalize(currency) == khr ? '៛' : '\$';
  }

  static String formatAmount(num amount, String currency) {
    final isKhr = normalize(currency) == khr;
    final pattern = isKhr ? '#,##0' : '#,##0.00';
    return '${symbol(currency)}${NumberFormat(pattern).format(amount)}';
  }
}
