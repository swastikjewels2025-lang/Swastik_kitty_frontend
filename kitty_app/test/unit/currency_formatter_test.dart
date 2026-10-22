import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter (Integer Rupees)', () {
    test('formats integer rupees with Indian comma grouping and symbol', () {
      expect(CurrencyFormatter.formatRupees(0), equals('₹0'));
      expect(CurrencyFormatter.formatRupees(500), equals('₹500'));
      expect(CurrencyFormatter.formatRupees(5000), equals('₹5,000'));
      expect(CurrencyFormatter.formatRupees(60000), equals('₹60,000'));
      expect(CurrencyFormatter.formatRupees(105000), equals('₹1,05,000'));
      expect(CurrencyFormatter.formatRupees(10000000), equals('₹1,00,00,000'));
      expect(CurrencyFormatter.formatRupees(null), equals('₹0'));
    });

    test('formats integer rupees without currency symbol', () {
      expect(CurrencyFormatter.formatWithoutSymbol(0), equals('0'));
      expect(CurrencyFormatter.formatWithoutSymbol(5000), equals('5,000'));
      expect(CurrencyFormatter.formatWithoutSymbol(105000), equals('1,05,000'));
      expect(CurrencyFormatter.formatWithoutSymbol(null), equals('0'));
    });

    test('parses rupee strings safely to integer', () {
      expect(CurrencyFormatter.parseRupees('₹5,000'), equals(5000));
      expect(CurrencyFormatter.parseRupees('₹1,05,000'), equals(105000));
      expect(CurrencyFormatter.parseRupees('60000'), equals(60000));
      expect(CurrencyFormatter.parseRupees(''), equals(0));
      expect(CurrencyFormatter.parseRupees(null), equals(0));
    });
  });
}
