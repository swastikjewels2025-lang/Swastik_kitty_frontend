import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/network/interceptors/logging_interceptor.dart';

void main() {
  group('LoggingInterceptor Security & Sanitization Suite', () {
    test('1. Redacts sensitive credentials (password, otp, token, jwt, mpin, secrets)', () {
      final Map<String, dynamic> rawPayload = <String, dynamic>{
        'password': 'super_secret_password_123',
        'otp': '123456',
        'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummy',
        'jwt': 'jwt_secret_token_val',
        'mpin': '1234',
        'pin': '4321',
        'passcode': '9999',
        'secret': 'very_secret_key',
        'merchantKey': 'swastik_sandbox_key',
        'appSecret': 'gokwik_secret',
        'webhookSecret': 'webhook_secret_key',
        'authorization': 'Bearer confidential_token',
        'publicField': 'public_value',
      };

      final dynamic sanitized = LoggingInterceptor.sanitizePayload(rawPayload);
      expect(sanitized, isA<Map<String, dynamic>>());
      final Map<String, dynamic> map = sanitized as Map<String, dynamic>;

      expect(map['password'], equals('[REDACTED]'));
      expect(map['otp'], equals('[REDACTED]'));
      expect(map['token'], equals('[REDACTED]'));
      expect(map['jwt'], equals('[REDACTED]'));
      expect(map['mpin'], equals('[REDACTED]'));
      expect(map['pin'], equals('[REDACTED]'));
      expect(map['passcode'], equals('[REDACTED]'));
      expect(map['secret'], equals('[REDACTED]'));
      expect(map['merchantKey'], equals('[REDACTED]'));
      expect(map['appSecret'], equals('[REDACTED]'));
      expect(map['webhookSecret'], equals('[REDACTED]'));
      expect(map['authorization'], equals('[REDACTED]'));
      expect(map['publicField'], equals('public_value'));
    });

    test('2. Redacts sensitive KYC and payment card data', () {
      final Map<String, dynamic> kycPayload = <String, dynamic>{
        'documentNumber': '123456789012',
        'aadhaarNumber': '987654321098',
        'panNumber': 'ABCDE1234F',
        'documentBase64': 'JVBERi0xLjQK...',
        'cardNumber': '4111111111111111',
        'cvv': '123',
        'file': 'some_file_reference',
        'documentType': 'AADHAAR',
      };

      final Map<String, dynamic> map =
          LoggingInterceptor.sanitizePayload(kycPayload) as Map<String, dynamic>;

      expect(map['documentNumber'], equals('[REDACTED]'));
      expect(map['aadhaarNumber'], equals('[REDACTED]'));
      expect(map['panNumber'], equals('[REDACTED]'));
      expect(map['documentBase64'], equals('[REDACTED]'));
      expect(map['cardNumber'], equals('[REDACTED]'));
      expect(map['cvv'], equals('[REDACTED]'));
      expect(map['file'], equals('[REDACTED]'));
      expect(map['documentType'], equals('AADHAAR'));
    });

    test('3. Masks phone numbers safely to +91******XXXX', () {
      final Map<String, dynamic> phonePayload = <String, dynamic>{
        'phone': '+919876543210',
        'customerPhone': '+919988776655',
      };

      final Map<String, dynamic> map =
          LoggingInterceptor.sanitizePayload(phonePayload) as Map<String, dynamic>;

      expect(map['phone'], equals('+91******3210'));
      expect(map['customerPhone'], equals('+91******6655'));
    });

    test('4. Redacts binary Multipart FormData payloads entirely', () {
      final FormData formData = FormData.fromMap(<String, dynamic>{
        'file': MultipartFile.fromString('dummy binary content', filename: 'kyc.pdf'),
        'docNumber': '1234',
      });

      final dynamic sanitized = LoggingInterceptor.sanitizePayload(formData);
      expect(sanitized, contains('[Multipart FormData - Binary/File Content Redacted]'));
    });

    test('5. Recursively sanitizes nested maps and lists', () {
      final Map<String, dynamic> nested = <String, dynamic>{
        'user': <String, dynamic>{
          'name': 'Patron',
          'phone': '+919876541234',
          'kyc': <String, dynamic>{
            'documentNumber': '111122223333',
            'status': 'VERIFIED',
          },
        },
        'payments': <dynamic>[
          <String, dynamic>{
            'id': 'pay_1',
            'token': 'tok_abc',
            'amount': 5000,
          },
        ],
      };

      final Map<String, dynamic> map =
          LoggingInterceptor.sanitizePayload(nested) as Map<String, dynamic>;

      final Map<String, dynamic> user = map['user'] as Map<String, dynamic>;
      expect(user['name'], equals('Patron'));
      expect(user['phone'], equals('+91******1234'));

      final Map<String, dynamic> kyc = user['kyc'] as Map<String, dynamic>;
      expect(kyc['documentNumber'], equals('[REDACTED]'));
      expect(kyc['status'], equals('VERIFIED'));

      final List<dynamic> payments = map['payments'] as List<dynamic>;
      final Map<String, dynamic> pay1 = payments[0] as Map<String, dynamic>;
      expect(pay1['id'], equals('pay_1'));
      expect(pay1['token'], equals('[REDACTED]'));
      expect(pay1['amount'], equals(5000));
    });
  });
}
