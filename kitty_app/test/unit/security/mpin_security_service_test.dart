import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/security/mpin_security_service.dart';

void main() {
  group('MpinSecurityService Cryptographic Suite', () {
    test('1. hashMpin generates salted PBKDF2-HMAC-SHA256 representation', () {
      final String hash = MpinSecurityService.hashMpin('1234');

      expect(hash, startsWith('pbkdf2_sha256\$10000\$'));
      final List<String> parts = hash.split('\$');
      expect(parts.length, equals(4));
      expect(parts[0], equals('pbkdf2_sha256'));
      expect(parts[1], equals('10000'));
      // Salt: 16 bytes = 32 hex chars
      expect(parts[2].length, equals(32));
      // Hash: 32 bytes (256 bits) = 64 hex chars
      expect(parts[3].length, equals(64));
    });

    test('2. Two hashes of the same MPIN produce different outputs due to unique random salt', () {
      final String hashA = MpinSecurityService.hashMpin('4321');
      final String hashB = MpinSecurityService.hashMpin('4321');

      expect(hashA, isNot(equals(hashB)));
      final String saltA = hashA.split('\$')[2];
      final String saltB = hashB.split('\$')[2];
      expect(saltA, isNot(equals(saltB)));
    });

    test('3. verifyMpin succeeds with correct candidate MPIN', () {
      final String storedHash = MpinSecurityService.hashMpin('9876');

      expect(
        MpinSecurityService.verifyMpin(
          candidateMpin: '9876',
          storedHash: storedHash,
        ),
        isTrue,
      );
    });

    test('4. verifyMpin rejects incorrect candidate MPINs', () {
      final String storedHash = MpinSecurityService.hashMpin('9876');

      expect(
        MpinSecurityService.verifyMpin(
          candidateMpin: '0000',
          storedHash: storedHash,
        ),
        isFalse,
      );
      expect(
        MpinSecurityService.verifyMpin(
          candidateMpin: '9875',
          storedHash: storedHash,
        ),
        isFalse,
      );
      expect(
        MpinSecurityService.verifyMpin(
          candidateMpin: '',
          storedHash: storedHash,
        ),
        isFalse,
      );
    });

    test('5. verifyMpin supports backwards-compatible legacy plaintext verification', () {
      const String legacyPlaintext = '7788';

      expect(MpinSecurityService.isLegacyPlaintext(legacyPlaintext), isTrue);
      expect(
        MpinSecurityService.verifyMpin(
          candidateMpin: '7788',
          storedHash: legacyPlaintext,
        ),
        isTrue,
      );
      expect(
        MpinSecurityService.verifyMpin(
          candidateMpin: '1234',
          storedHash: legacyPlaintext,
        ),
        isFalse,
      );
    });

    test('6. isLegacyPlaintext accurately identifies 4-digit plaintext vs hashed representations', () {
      expect(MpinSecurityService.isLegacyPlaintext('1234'), isTrue);
      expect(MpinSecurityService.isLegacyPlaintext('0000'), isTrue);
      expect(MpinSecurityService.isLegacyPlaintext('9999'), isTrue);

      expect(MpinSecurityService.isLegacyPlaintext('12345'), isFalse);
      expect(MpinSecurityService.isLegacyPlaintext('12a4'), isFalse);
      expect(MpinSecurityService.isLegacyPlaintext(''), isFalse);

      final String hashed = MpinSecurityService.hashMpin('1234');
      expect(MpinSecurityService.isLegacyPlaintext(hashed), isFalse);
    });

    test('7. Deterministic hashing with fixed salt matches reproducible output', () {
      final Uint8List fixedSalt = Uint8List.fromList(List<int>.filled(16, 7));
      final String hash1 = MpinSecurityService.hashMpin('1122', salt: fixedSalt);
      final String hash2 = MpinSecurityService.hashMpin('1122', salt: fixedSalt);

      expect(hash1, equals(hash2));
      expect(
        MpinSecurityService.verifyMpin(
          candidateMpin: '1122',
          storedHash: hash1,
        ),
        isTrue,
      );
    });
  });
}
