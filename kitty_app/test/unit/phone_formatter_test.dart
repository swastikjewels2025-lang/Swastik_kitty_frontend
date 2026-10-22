import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/utils/phone_formatter.dart';

void main() {
  group('PhoneFormatter', () {
    test('cleans Indian mobile numbers correctly', () {
      expect(PhoneFormatter.clean('+91 98765 43210'), equals('9876543210'));
      expect(PhoneFormatter.clean('+91-98765-43210'), equals('9876543210'));
      expect(PhoneFormatter.clean('09876543210'), equals('9876543210'));
      expect(PhoneFormatter.clean('9876543210'), equals('9876543210'));
      expect(PhoneFormatter.clean(''), equals(''));
      expect(PhoneFormatter.clean(null), equals(''));
    });

    test('formats phone with country code', () {
      expect(
        PhoneFormatter.formatWithCountryCode('9876543210'),
        equals('+91 98765 43210'),
      );
    });

    test('masks phone number middle digits', () {
      expect(
        PhoneFormatter.maskMiddle('9876543210'),
        equals('98••••••10'),
      );
    });
  });
}
