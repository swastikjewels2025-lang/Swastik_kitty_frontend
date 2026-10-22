import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Bank-grade cryptographic service providing one-way PBKDF2-HMAC-SHA256 hashing
/// and verification for transaction MPINs with unique random salting and constant-time checks.
abstract final class MpinSecurityService {
  /// Number of PBKDF2 iterations (balanced for client security and low latency).
  static const int iterations = 10000;

  /// Salt length in bytes (128-bit entropy).
  static const int saltLength = 16;

  /// Algorithm identifier prefix.
  static const String prefix = 'pbkdf2_sha256';

  /// Generates a cryptographically secure 128-bit random salt.
  static Uint8List generateSalt() {
    final Random random = Random.secure();
    final Uint8List salt = Uint8List(saltLength);
    for (int i = 0; i < saltLength; i++) {
      salt[i] = random.nextInt(256);
    }
    return salt;
  }

  /// Hashes a 4-digit MPIN using PBKDF2-HMAC-SHA256 with an optional or generated salt.
  ///
  /// Output format: `pbkdf2_sha256$10000$<saltHex>$<hashHex>`
  static String hashMpin(String mpin, {Uint8List? salt}) {
    final Uint8List effectiveSalt = salt ?? generateSalt();
    final List<int> key = utf8.encode(mpin);

    final Hmac hmac = Hmac(sha256, key);

    // Initial block: U_1 = PRF(Password, Salt || INT(1))
    final List<int> block1 = <int>[...effectiveSalt, 0, 0, 0, 1];
    List<int> u = hmac.convert(block1).bytes;
    final List<int> result = List<int>.from(u);

    for (int i = 1; i < iterations; i++) {
      u = hmac.convert(u).bytes;
      for (int k = 0; k < result.length; k++) {
        result[k] ^= u[k];
      }
    }

    final String saltHex =
        effectiveSalt.map((int b) => b.toRadixString(16).padLeft(2, '0')).join();
    final String hashHex =
        result.map((int b) => b.toRadixString(16).padLeft(2, '0')).join();

    return '$prefix\$$iterations\$$saltHex\$$hashHex';
  }

  /// Verifies candidate MPIN against a stored value using constant-time comparison.
  ///
  /// Supports:
  /// 1. PBKDF2 hashed format (`pbkdf2_sha256$10000$<salt>$<hash>`)
  /// 2. Legacy plaintext 4-digit PINs (for seamless backwards-compatible auto-migration).
  static bool verifyMpin({
    required String candidateMpin,
    required String storedHash,
  }) {
    if (storedHash.isEmpty || candidateMpin.isEmpty) {
      return false;
    }

    // 1. PBKDF2 Hashed Format
    if (storedHash.startsWith('$prefix\$')) {
      final List<String> parts = storedHash.split('\$');
      if (parts.length != 4) return false;

      final String saltHex = parts[2];
      if (saltHex.length != saltLength * 2) return false;

      // Decode salt hex bytes
      final Uint8List salt = Uint8List(saltLength);
      try {
        for (int i = 0; i < saltLength; i++) {
          salt[i] = int.parse(saltHex.substring(i * 2, i * 2 + 2), radix: 16);
        }
      } catch (_) {
        return false;
      }

      final String computedHash = hashMpin(candidateMpin, salt: salt);
      return _constantTimeEquals(computedHash, storedHash);
    }

    // 2. Legacy Plaintext Format (e.g. exactly 4 digits)
    if (isLegacyPlaintext(storedHash)) {
      return _constantTimeEquals(storedHash, candidateMpin);
    }

    return false;
  }

  /// Detects whether stored data represents an unhashed legacy 4-digit plaintext PIN.
  static bool isLegacyPlaintext(String storedValue) {
    return RegExp(r'^\d{4}$').hasMatch(storedValue);
  }

  /// Constant-time string comparison to prevent timing attacks.
  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}
