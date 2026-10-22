import '../../../../core/config/app_constants.dart';
import '../../../../core/security/mpin_security_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/i_settings_local_repository.dart';

/// Local implementation of [ISettingsLocalRepository] using bank-grade [SecureStorageService].
class SettingsLocalRepositoryImpl implements ISettingsLocalRepository {
  const SettingsLocalRepositoryImpl({
    required SecureStorageService storageService,
  }) : _storage = storageService;

  final SecureStorageService _storage;

  @override
  Future<UserPreferencesEntity> getPreferences() async {
    final String? biometricStr = await _storage.read(key: AppConstants.biometricEnabledKey);
    final String? autoPayStr = await _storage.read(key: AppConstants.autoPayEnabledKey);
    final String? themeModeStr = await _storage.read(key: AppConstants.themeModeKey);
    final String? languageStr = await _storage.read(key: AppConstants.languageKey);

    return UserPreferencesEntity(
      biometricEnabled: biometricStr == null ? true : biometricStr == 'true',
      autoPayEnabled: autoPayStr == null ? true : autoPayStr == 'true',
      themeMode: themeModeStr ?? 'system',
      language: languageStr ?? 'en',
      pushNotifications: true,
      smsNotifications: true,
      whatsappUpdates: true,
    );
  }

  @override
  Future<void> savePreferences(UserPreferencesEntity preferences) async {
    await Future.wait<void>(<Future<void>>[
      setBiometricEnabled(preferences.biometricEnabled),
      setAutoPayEnabled(preferences.autoPayEnabled),
      setThemeMode(preferences.themeMode),
      setLanguage(preferences.language),
    ]);
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(
      key: AppConstants.biometricEnabledKey,
      value: enabled.toString(),
    );
  }

  @override
  Future<void> setAutoPayEnabled(bool enabled) async {
    await _storage.write(
      key: AppConstants.autoPayEnabledKey,
      value: enabled.toString(),
    );
  }

  @override
  Future<void> setThemeMode(String themeMode) async {
    await _storage.write(
      key: AppConstants.themeModeKey,
      value: themeMode,
    );
  }

  @override
  Future<void> setLanguage(String language) async {
    await _storage.write(
      key: AppConstants.languageKey,
      value: language,
    );
  }

  @override
  Future<void> setMpin(String mpin) async {
    final String hashed = MpinSecurityService.hashMpin(mpin);
    await _storage.write(
      key: AppConstants.mpinKey,
      value: hashed,
    );
  }

  @override
  Future<String?> getMpin() async {
    return _storage.read(key: AppConstants.mpinKey);
  }

  @override
  Future<bool> hasMpin() async {
    final String? stored = await _storage.read(key: AppConstants.mpinKey);
    return stored != null && stored.trim().isNotEmpty;
  }

  @override
  Future<bool> verifyMpin(String mpin) async {
    final String? stored = await _storage.read(key: AppConstants.mpinKey);
    if (stored == null || stored.trim().isEmpty) {
      return false;
    }

    final bool isValid = MpinSecurityService.verifyMpin(
      candidateMpin: mpin,
      storedHash: stored,
    );

    // Auto-migrate legacy plaintext MPIN to salted PBKDF2 representation
    if (isValid && MpinSecurityService.isLegacyPlaintext(stored)) {
      await setMpin(mpin);
    }

    return isValid;
  }
}
