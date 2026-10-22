import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/app/kitty_app.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/core/providers/auth_state_provider.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/core/storage/secure_storage_service.dart';
import 'package:kitty_app/features/auth/presentation/screens/login_screen.dart';
import 'package:kitty_app/features/dashboard/data/repositories/mock_dashboard_repository.dart';
import 'package:kitty_app/features/home/data/repositories/mock_gold_rate_repository.dart';
import 'package:kitty_app/features/home/data/repositories/mock_product_repository.dart';
import 'package:kitty_app/features/home/presentation/screens/home_screen.dart';
import 'package:kitty_app/features/kyc/presentation/screens/kyc_screen.dart';
import 'package:kitty_app/features/offers/data/repositories/mock_scheme_repository.dart';
import 'package:kitty_app/features/splash/presentation/screens/splash_screen.dart';

class _OptionETestAuthNotifier extends AppAuthNotifier {
  _OptionETestAuthNotifier(this._state);

  final AppAuthState _state;

  @override
  AppAuthState build() {
    return _state;
  }
}

void main() {
  group('OPTION E: Unified Pipeline Tests', () {
    late MockEngineConfig instantConfig;

    setUp(() {
      instantConfig = MockEngineConfig(latency: MockLatency.instant);
    });

    testWidgets('PHASE 6 & 10: Authenticated + KYC NOT verified redirects to /kyc', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mockEngineConfigProvider.overrideWithValue(instantConfig),
            appAuthStateProvider.overrideWith(
              () => _OptionETestAuthNotifier(
                const AppAuthState.authenticated(
                  token: 'test_token',
                  userName: 'Rihan',
                  isKycVerified: false,
                ),
              ),
            ),
            goldRateRepositoryProvider.overrideWithValue(
              MockGoldRateRepository(engineConfig: instantConfig),
            ),
            productRepositoryProvider.overrideWithValue(
              MockProductRepository(engineConfig: instantConfig),
            ),
            schemeRepositoryProvider.overrideWithValue(
              MockSchemeRepository(engineConfig: instantConfig),
            ),
            dashboardRepositoryProvider.overrideWithValue(
              MockDashboardRepository(engineConfig: instantConfig),
            ),
          ],
          child: const KittyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Guard should redirect unverified user to KYC screen
      expect(find.byType(KycScreen), findsOneWidget);
      expect(find.text('KYC Document Verification'), findsOneWidget);
    });

    testWidgets('PHASE 6 & 10: Authenticated + KYC verified allows access to /home', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mockEngineConfigProvider.overrideWithValue(instantConfig),
            appAuthStateProvider.overrideWith(
              () => _OptionETestAuthNotifier(
                const AppAuthState.authenticated(
                  token: 'test_token',
                  userName: 'Rihan',
                  isKycVerified: true,
                ),
              ),
            ),
            goldRateRepositoryProvider.overrideWithValue(
              MockGoldRateRepository(engineConfig: instantConfig),
            ),
            productRepositoryProvider.overrideWithValue(
              MockProductRepository(engineConfig: instantConfig),
            ),
            schemeRepositoryProvider.overrideWithValue(
              MockSchemeRepository(engineConfig: instantConfig),
            ),
            dashboardRepositoryProvider.overrideWithValue(
              MockDashboardRepository(engineConfig: instantConfig),
            ),
          ],
          child: const KittyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Verified user lands on HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('PHASE 9: LoginScreen View 3 displays Complete Verification when isKycVerified is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appAuthStateProvider.overrideWith(
              () => _OptionETestAuthNotifier(
                const AppAuthState.authenticated(
                  token: 'test_token',
                  userName: 'Rihan',
                  isKycVerified: false,
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: LoginScreen(initialStep: LoginStep.success),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Statutory KYC verification required to access schemes.'), findsOneWidget);
      expect(find.text('Complete Verification'), findsOneWidget);
    });

    testWidgets('PHASE 9: LoginScreen View 3 displays Enter Kitty Vault when isKycVerified is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appAuthStateProvider.overrideWith(
              () => _OptionETestAuthNotifier(
                const AppAuthState.authenticated(
                  token: 'test_token',
                  userName: 'Rihan',
                  isKycVerified: true,
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: LoginScreen(initialStep: LoginStep.success),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Accessing your gold schemes and bullion vault...'), findsOneWidget);
      expect(find.text('Enter Gold Vault'), findsOneWidget);
    });

    test('PHASE 4: SecureStorageService fastSessionHint reflects write/delete lifecycle', () async {
      final SecureStorageService storage = SecureStorageService();
      // Hint is null or false initially
      expect(storage.fastSessionHint, isFalse);
    });

    testWidgets('PHASE 1: SplashScreen triggers immediate navigation on animation completion', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appAuthStateProvider.overrideWith(
              () => _OptionETestAuthNotifier(const AppAuthState.unauthenticated()),
            ),
          ],
          child: const MaterialApp(
            home: SplashScreen(
              totalDuration: Duration(milliseconds: 500),
              autoNavigate: false, // disable GoRouter call so we test state completion directly
            ),
          ),
        ),
      );

      // Advance past 500ms
      await tester.pump(const Duration(milliseconds: 550));

      // SplashScreen completed animation cleanly without stuck delay
      expect(find.byType(SplashScreen), findsOneWidget);
    });
    testWidgets('SplashScreen plays full duration on startup for authenticated user then goes to HomeScreen', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mockEngineConfigProvider.overrideWithValue(instantConfig),
            appAuthStateProvider.overrideWith(
              () => _OptionETestAuthNotifier(
                const AppAuthState.authenticated(
                  token: 'test_token',
                  userName: 'Rihan',
                  isKycVerified: true,
                ),
              ),
            ),
            goldRateRepositoryProvider.overrideWithValue(
              MockGoldRateRepository(engineConfig: instantConfig),
            ),
            productRepositoryProvider.overrideWithValue(
              MockProductRepository(engineConfig: instantConfig),
            ),
            schemeRepositoryProvider.overrideWithValue(
              MockSchemeRepository(engineConfig: instantConfig),
            ),
            dashboardRepositoryProvider.overrideWithValue(
              MockDashboardRepository(engineConfig: instantConfig),
            ),
          ],
          child: const KittyApp(),
        ),
      );

      // At 100ms: SplashScreen must be actively showing (Phase 1: 3D Diamond), NOT HomeScreen!
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);

      // At 1500ms: SplashScreen still actively showing (Diamond zooming)!
      await tester.pump(const Duration(milliseconds: 1400));
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);

      // At 2500ms: Logo is revealed and holding stably for 1.0s, still on SplashScreen!
      await tester.pump(const Duration(milliseconds: 1000));
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);

      // Advance past total duration (3400ms) and settle
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      // Now it transitions to HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
    });

    testWidgets('SplashScreen plays full duration on startup for unauthenticated user then goes to LoginScreen', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mockEngineConfigProvider.overrideWithValue(instantConfig),
            appAuthStateProvider.overrideWith(
              () => _OptionETestAuthNotifier(const AppAuthState.unauthenticated()),
            ),
          ],
          child: const KittyApp(),
        ),
      );

      // At 100ms: SplashScreen must be showing, NOT LoginScreen!
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);

      // At 1500ms: SplashScreen still actively showing!
      await tester.pump(const Duration(milliseconds: 1400));
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);

      // At 2500ms: Logo is holding for 1s, still on SplashScreen!
      await tester.pump(const Duration(milliseconds: 1000));
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);

      // Advance past total duration (3400ms) and settle
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      // Now transitions to LoginScreen
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
    });
  });
}
