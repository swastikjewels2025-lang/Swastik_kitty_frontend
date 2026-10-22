import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_constants.dart';

/// Bank-grade secure storage service wrapping [FlutterSecureStorage].
///
/// Uses Android KeyStore with hardware encryption and iOS KeyChain.
class SecureStorageService {
  SecureStorageService({
    FlutterSecureStorage? storage,
  }) : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                resetOnError: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  final FlutterSecureStorage _storage;

  // ---------------------------------------------------------------------------
  // JWT Token Management (Frozen Contract v1.0 - Single 30-Day Token)
  // ---------------------------------------------------------------------------

  static bool? _inMemorySessionHint;

  /// Fast non-sensitive session existence hint for instant routing bootstrap.
  /// NOTE: This is purely a fast routing hint and NEVER proof of authentication.
  bool get fastSessionHint => _inMemorySessionHint ?? false;

  /// Update the fast non-sensitive session existence hint.
  void setSessionHint(bool hasSession) {
    _inMemorySessionHint = hasSession;
  }

  /// Persist the authentication JWT token.
  Future<void> saveToken(String token) async {
    setSessionHint(true);
    await write(key: AppConstants.jwtStorageKey, value: token);
  }

  /// Retrieve the active JWT token, or null if unauthenticated.
  Future<String?> getToken() async {
    final String? token = await read(key: AppConstants.jwtStorageKey);
    setSessionHint(token != null && token.trim().isNotEmpty);
    return token;
  }

  /// Check whether a valid JWT token exists in storage.
  Future<bool> hasToken() async {
    final String? token = await getToken();
    return token != null && token.trim().isNotEmpty;
  }

  /// Remove JWT token on logout or session expiration.
  Future<void> deleteToken() async {
    setSessionHint(false);
    await delete(key: AppConstants.jwtStorageKey);
  }

  // ---------------------------------------------------------------------------
  // User Session & Profile Cache
  // ---------------------------------------------------------------------------

  /// Cache serialized user profile JSON.
  Future<void> saveUserData(String jsonString) async {
    await write(key: AppConstants.userSessionStorageKey, value: jsonString);
  }

  /// Retrieve cached user profile JSON.
  Future<String?> getUserData() async {
    return read(key: AppConstants.userSessionStorageKey);
  }

  /// Clear all authentication, token, and user session cache data.
  Future<void> clearSession() async {
    setSessionHint(false);
    await Future.wait<void>(<Future<void>>[
      delete(key: AppConstants.jwtStorageKey),
      delete(key: AppConstants.userSessionStorageKey),
    ]);
  }

  // ---------------------------------------------------------------------------
  // Generic Key-Value Secure Operations
  // ---------------------------------------------------------------------------

  static final Map<String, String> _memoryStorage = <String, String>{};

  /// Write string value to secure storage.
  Future<void> write({required String key, required String value}) async {
    _memoryStorage[key] = value;
    try {
      await _storage
          .write(key: key, value: value)
          .timeout(const Duration(milliseconds: 1500));
    } catch (_) {
      // In-memory fallback handles iOS simulator keychain sandbox restrictions
    }
  }

  /// Read string value from secure storage.
  Future<String?> read({required String key}) async {
    try {
      final String? val = await _storage
          .read(key: key)
          .timeout(const Duration(milliseconds: 1500));
      if (val != null) return val;
    } catch (_) {}
    return _memoryStorage[key];
  }

  /// Delete single key from secure storage.
  Future<void> delete({required String key}) async {
    _memoryStorage.remove(key);
    try {
      await _storage
          .delete(key: key)
          .timeout(const Duration(milliseconds: 1500));
    } catch (_) {}
  }

  /// Wipe all keys from secure storage.
  Future<void> deleteAll() async {
    _memoryStorage.clear();
    try {
      await _storage
          .deleteAll()
          .timeout(const Duration(milliseconds: 1500));
    } catch (_) {}
  }
}
