import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/config/app_constants.dart';
import 'package:kitty_app/core/storage/secure_storage_service.dart';
import 'package:kitty_app/features/settings/data/repositories/settings_local_repository_impl.dart';
import 'package:kitty_app/features/settings/domain/entities/profile_entity.dart';

class _FakeSecureStorageService extends SecureStorageService {
  final Map<String, String> _map = <String, String>{};

  @override
  Future<void> write({required String key, required String value}) async {
    _map[key] = value;
  }

  @override
  Future<String?> read({required String key}) async {
    return _map[key];
  }

  @override
  Future<void> delete({required String key}) async {
    _map.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _map.clear();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeSecureStorageService fakeStorage;
  late SettingsLocalRepositoryImpl repository;

  setUp(() {
    fakeStorage = _FakeSecureStorageService();
    repository = SettingsLocalRepositoryImpl(storageService: fakeStorage);
  });

  group('SettingsLocalRepositoryImpl Unit Tests', () {
    test('getPreferences returns default values when storage is empty', () async {
      final UserPreferencesEntity prefs = await repository.getPreferences();

      expect(prefs.biometricEnabled, isTrue);
      expect(prefs.autoPayEnabled, isTrue);
      expect(prefs.themeMode, 'system');
      expect(prefs.language, 'en');
    });

    test('setBiometricEnabled stores value and reflects in getPreferences', () async {
      await repository.setBiometricEnabled(false);

      final String? stored = await fakeStorage.read(key: AppConstants.biometricEnabledKey);
      expect(stored, 'false');

      final UserPreferencesEntity prefs = await repository.getPreferences();
      expect(prefs.biometricEnabled, isFalse);
    });

    test('setAutoPayEnabled stores value and reflects in getPreferences', () async {
      await repository.setAutoPayEnabled(false);

      final String? stored = await fakeStorage.read(key: AppConstants.autoPayEnabledKey);
      expect(stored, 'false');

      final UserPreferencesEntity prefs = await repository.getPreferences();
      expect(prefs.autoPayEnabled, isFalse);
    });

    test('setThemeMode persists dark theme choice', () async {
      await repository.setThemeMode('dark');

      final String? stored = await fakeStorage.read(key: AppConstants.themeModeKey);
      expect(stored, 'dark');

      final UserPreferencesEntity prefs = await repository.getPreferences();
      expect(prefs.themeMode, 'dark');
    });

    test('setLanguage persists hindi choice', () async {
      await repository.setLanguage('hi');

      final String? stored = await fakeStorage.read(key: AppConstants.languageKey);
      expect(stored, 'hi');

      final UserPreferencesEntity prefs = await repository.getPreferences();
      expect(prefs.language, 'hi');
    });

    test('setMpin stores PBKDF2 hashed MPIN without leaking plaintext', () async {
      expect(await repository.getMpin(), isNull);
      expect(await repository.hasMpin(), isFalse);

      await repository.setMpin('1234');

      expect(await repository.hasMpin(), isTrue);
      final String? stored = await repository.getMpin();
      expect(stored, isNotNull);
      expect(stored, isNot(equals('1234')));
      expect(stored, startsWith('pbkdf2_sha256\$10000\$'));

      expect(await repository.verifyMpin('1234'), isTrue);
      expect(await repository.verifyMpin('9999'), isFalse);
    });

    test('verifyMpin automatically migrates legacy plaintext MPIN to PBKDF2 hash', () async {
      // Seed legacy unhashed 4-digit plaintext PIN
      await fakeStorage.write(key: AppConstants.mpinKey, value: '5678');
      expect(await repository.hasMpin(), isTrue);
      expect(await repository.getMpin(), equals('5678'));

      // Verification succeeds and triggers auto-migration
      final bool verified = await repository.verifyMpin('5678');
      expect(verified, isTrue);

      final String? migrated = await repository.getMpin();
      expect(migrated, isNot(equals('5678')));
      expect(migrated, startsWith('pbkdf2_sha256\$10000\$'));

      // Subsequent verification succeeds against PBKDF2 hash
      expect(await repository.verifyMpin('5678'), isTrue);
      expect(await repository.verifyMpin('0000'), isFalse);
    });

    test('savePreferences persists multiple fields in one call', () async {
      const UserPreferencesEntity custom = UserPreferencesEntity(
        biometricEnabled: false,
        autoPayEnabled: false,
        themeMode: 'light',
        language: 'hi',
      );

      await repository.savePreferences(custom);

      final UserPreferencesEntity loaded = await repository.getPreferences();
      expect(loaded.biometricEnabled, isFalse);
      expect(loaded.autoPayEnabled, isFalse);
      expect(loaded.themeMode, 'light');
      expect(loaded.language, 'hi');
    });
  });
}
