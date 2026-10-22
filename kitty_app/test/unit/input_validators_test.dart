import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/utils/input_validators.dart';

void main() {
  group('InputValidators', () {
    test('validates 10-digit Indian phone numbers', () {
      expect(InputValidators.validatePhone('9876543210'), isNull);
      expect(InputValidators.validatePhone('8876543210'), isNull);
      expect(InputValidators.validatePhone('7876543210'), isNull);
      expect(InputValidators.validatePhone('6876543210'), isNull);

      expect(InputValidators.validatePhone('1234567890'), isNotNull);
      expect(InputValidators.validatePhone('98765'), isNotNull);
      expect(InputValidators.validatePhone(''), isNotNull);
      expect(InputValidators.validatePhone(null), isNotNull);
    });

    test('validates 6-digit OTP code', () {
      expect(InputValidators.validateOtp('123456'), isNull);
      expect(InputValidators.validateOtp('000000'), isNull);

      expect(InputValidators.validateOtp('12345'), isNotNull);
      expect(InputValidators.validateOtp('1234567'), isNotNull);
      expect(InputValidators.validateOtp('12345A'), isNotNull);
      expect(InputValidators.validateOtp(''), isNotNull);
      expect(InputValidators.validateOtp(null), isNotNull);
    });

    test('validates 12-digit UIDAI Aadhaar number', () {
      expect(InputValidators.validateAadhaar('123456789012'), isNull);
      expect(InputValidators.validateAadhaar('1234 5678 9012'), isNull);

      expect(InputValidators.validateAadhaar('12345678901'), isNotNull);
      expect(InputValidators.validateAadhaar(''), isNotNull);
      expect(InputValidators.validateAadhaar(null), isNotNull);
    });

    test('validates 10-character PAN number', () {
      expect(InputValidators.validatePan('ABCDE1234F'), isNull);
      expect(InputValidators.validatePan('abcde1234f'), isNull);

      expect(InputValidators.validatePan('ABCDE12345'), isNotNull);
      expect(InputValidators.validatePan('12345ABCDE'), isNotNull);
      expect(InputValidators.validatePan(''), isNotNull);
      expect(InputValidators.validatePan(null), isNotNull);
    });
  });
}
