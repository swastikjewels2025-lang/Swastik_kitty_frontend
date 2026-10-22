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
import 'package:kitty_app/features/settings/presentation/screens/settings_screen.dart';

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
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepo),
        secureStorageServiceProvider.overrideWithValue(fakeStorage),
        settingsLocalRepositoryProvider.overrideWithValue(localSettingsRepo),
        appAuthStateProvider.overrideWith(
          () => AppAuthNotifier(),
        ),
      ],
      child: const MaterialApp(
        home: SettingsScreen(),
      ),
    );
  }

  group('SettingsScreen Widget Tests', () {
    testWidgets('1. Renders header, patron profile card, and 4 settings sections', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Header title removed per specification
      expect(find.text('Patron Settings'), findsNothing);

      // Patron Profile Card
      expect(find.text('Rihan Saifi'), findsOneWidget);
      expect(find.text('+919876543210'), findsOneWidget);
      expect(find.text('Tier 1 Verified Member'), findsOneWidget);

      // Section titles
      expect(find.text('GOLD SCHEME & SAVINGS SETTINGS'), findsOneWidget);
      expect(find.text('SECURITY & PIN'), findsOneWidget);
      expect(find.text('KYC VERIFICATION'), findsOneWidget);
      expect(find.text('APP & LEGAL'), findsOneWidget);

      // Setting labels
      expect(find.text('UPI AutoPay / e-Mandate'), findsOneWidget);
      expect(find.text('Nominee Registration'), findsOneWidget);
      expect(find.text('Biometric App Lock'), findsOneWidget);
      expect(find.text('Change 4-Digit MPIN'), findsOneWidget);
      expect(find.text('Gold Scheme Terms & BIS 24K Hallmarking'), findsOneWidget);
      expect(find.text('Theme Appearance'), findsNothing);
      expect(find.text('Language'), findsNothing);

      // Destructive button and footer
      expect(find.text('Log Out of Account'), findsOneWidget);
      expect(find.textContaining('Active Gold Vault • v2.4.0'), findsOneWidget);
    });

    testWidgets('2. Toggling AutoPay and Biometric switches updates state', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final Finder switches = find.byType(Switch);
      expect(switches, findsNWidgets(2));

      // AutoPay switch is first
      await tester.tap(switches.first);
      await tester.pumpAndSettle();

      // Biometric switch is second
      await tester.tap(switches.last);
      await tester.pumpAndSettle();

      expect(await fakeStorage.read(key: 'kitty_autopay_enabled'), 'false');
      expect(await fakeStorage.read(key: 'kitty_biometric_enabled'), 'false');
    });

    testWidgets('3. Tapping Nominee Registration opens details modal', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Nominee Registration'));
      await tester.pumpAndSettle();

      expect(find.text('Statutory Beneficiary Details'), findsOneWidget);
      expect(find.text('Beneficiary Name'), findsOneWidget);
      expect(find.text('Amina Saifi'), findsOneWidget);
      expect(find.text('100% Share'), findsOneWidget);

      // Close modal
      await tester.tap(find.text('CLOSE'));
      await tester.pumpAndSettle();
      expect(find.text('Statutory Beneficiary Details'), findsNothing);
    });

    testWidgets('4. Tapping Change MPIN opens dialog and allows entering pin', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Change 4-Digit MPIN'));
      await tester.pumpAndSettle();

      expect(find.text('Change MPIN'), findsOneWidget);
      expect(find.text('Enter a new 4-digit MPIN for payment and passbook authorization.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '9876');
      await tester.tap(find.text('Save PIN'));
      await tester.pumpAndSettle();

      expect(find.text('Change MPIN'), findsNothing);
      final String? storedMpin = await fakeStorage.read(key: 'kitty_mpin');
      expect(storedMpin, isNotNull);
      expect(storedMpin, startsWith('pbkdf2_sha256\$10000\$'));
      expect(storedMpin, isNot(equals('9876')));
    });

    testWidgets('5. Verifies Theme Appearance and Language are absent from settings', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Theme Appearance'), findsNothing);
      expect(find.text('Language'), findsNothing);
      expect(find.text('Gold Scheme Terms & BIS 24K Hallmarking'), findsOneWidget);
    });

    testWidgets('6. Tapping Log Out shows confirmation dialog', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Log Out of Account'));
      await tester.tap(find.text('Log Out of Account'));
      await tester.pumpAndSettle();

      expect(find.text('Log Out of Account?'), findsOneWidget);
      expect(find.text('Are you sure you want to end your current session?'), findsOneWidget);

      // Cancel button dismisses
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Log Out of Account?'), findsNothing);
    });
  });
}
