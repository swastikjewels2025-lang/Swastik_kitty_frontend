import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/core/providers/auth_state_provider.dart';
import 'package:kitty_app/core/providers/core_providers.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/core/storage/secure_storage_service.dart';
import 'package:kitty_app/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:kitty_app/features/settings/data/repositories/settings_local_repository_impl.dart';
import 'package:kitty_app/features/settings/presentation/providers/settings_controller.dart';
import 'package:kitty_app/features/settings/presentation/providers/settings_state.dart';

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

  late ProviderContainer container;
  late MockAuthRepository mockAuthRepo;
  late _FakeSecureStorageService fakeStorage;
  late SettingsLocalRepositoryImpl localSettingsRepo;

  setUp(() {
    fakeStorage = _FakeSecureStorageService();
    mockAuthRepo = MockAuthRepository(
      storageService: fakeStorage,
      engineConfig: MockEngineConfig(latency: MockLatency.instant),
    );
    localSettingsRepo = SettingsLocalRepositoryImpl(storageService: fakeStorage);

    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepo),
        secureStorageServiceProvider.overrideWithValue(fakeStorage),
        settingsLocalRepositoryProvider.overrideWithValue(localSettingsRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('SettingsController Unit Tests', () {
    test('Initial load populates user profile and local preferences', () async {
      // Allow initial async data loading to complete
      await container.read(settingsControllerProvider.notifier).loadInitialData();

      final SettingsState state = container.read(settingsControllerProvider);

      expect(state.isLoading, isFalse);
      expect(state.user, isNotNull);
      expect(state.user?.name, 'Rihan Saifi');
      expect(state.user?.phone, '+919876543210');
      expect(state.user?.kyc.isVerified, isTrue);
      expect(state.user?.nomineeName, 'Amina Saifi');
      expect(state.preferences.biometricEnabled, isTrue);
      expect(state.preferences.autoPayEnabled, isTrue);
    });

    test('toggleBiometric updates state and local storage', () async {
      final SettingsController controller = container.read(settingsControllerProvider.notifier);

      await controller.toggleBiometric(false);

      final SettingsState state = container.read(settingsControllerProvider);
      expect(state.preferences.biometricEnabled, isFalse);

      final storedPrefs = await localSettingsRepo.getPreferences();
      expect(storedPrefs.biometricEnabled, isFalse);
    });

    test('toggleAutoPay updates state and local storage', () async {
      final SettingsController controller = container.read(settingsControllerProvider.notifier);

      await controller.toggleAutoPay(false);

      final SettingsState state = container.read(settingsControllerProvider);
      expect(state.preferences.autoPayEnabled, isFalse);

      final storedPrefs = await localSettingsRepo.getPreferences();
      expect(storedPrefs.autoPayEnabled, isFalse);
    });

    test('setThemeMode updates state and synchronizes themeModeProvider', () async {
      final SettingsController controller = container.read(settingsControllerProvider.notifier);

      expect(container.read(themeModeProvider), ThemeMode.system);

      await controller.setThemeMode('dark');

      expect(container.read(settingsControllerProvider).preferences.themeMode, 'dark');
      expect(container.read(themeModeProvider), ThemeMode.dark);

      await controller.setThemeMode('light');
      expect(container.read(themeModeProvider), ThemeMode.light);
    });

    test('setLanguage updates state and persists choice', () async {
      final SettingsController controller = container.read(settingsControllerProvider.notifier);

      await controller.setLanguage('hi');

      expect(container.read(settingsControllerProvider).preferences.language, 'hi');
      final storedPrefs = await localSettingsRepo.getPreferences();
      expect(storedPrefs.language, 'hi');
    });

    test('setMpin stores MPIN and sets hasMpin to true', () async {
      final SettingsController controller = container.read(settingsControllerProvider.notifier);

      expect(container.read(settingsControllerProvider).hasMpin, isFalse);

      await controller.setMpin('4321');

      expect(container.read(settingsControllerProvider).hasMpin, isTrue);
      expect(await controller.verifyMpin('4321'), isTrue);
      expect(await controller.verifyMpin('0000'), isFalse);
      expect(await localSettingsRepo.verifyMpin('4321'), isTrue);
      expect(await localSettingsRepo.getMpin(), isNot(equals('4321')));
      expect(await localSettingsRepo.getMpin(), startsWith('pbkdf2_sha256\$10000\$'));
    });

    test('logout invokes appAuthStateProvider and clears session', () async {
      final SettingsController controller = container.read(settingsControllerProvider.notifier);

      // Seed an active session
      await container.read(appAuthStateProvider.notifier).setAuthenticated(token: 'token_123');
      expect(container.read(appAuthStateProvider).isAuthenticated, isTrue);

      await controller.logout();

      expect(container.read(appAuthStateProvider).isAuthenticated, isFalse);
    });
  });
}
