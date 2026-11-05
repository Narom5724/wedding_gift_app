import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_gift_app/utils/currency_helper.dart';

void main() {
  test('normalizes KH records to KHR', () {
    expect(CurrencyHelper.normalize('kh'), CurrencyHelper.khr);
    expect(CurrencyHelper.normalize(' khr '), CurrencyHelper.khr);
  });

  test('formats USD and Khmer riel with currency-appropriate precision', () {
    expect(CurrencyHelper.formatAmount(200, CurrencyHelper.usd), '\$200.00');
    expect(CurrencyHelper.formatAmount(200000, 'KH'), '៛200,000');
    expect(
      CurrencyHelper.formatAmount(200000.75, CurrencyHelper.khr),
      '៛200,001',
    );
  });
}
