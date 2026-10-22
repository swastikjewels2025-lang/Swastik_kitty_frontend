import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kitty_app/app/kitty_app.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/core/providers/auth_state_provider.dart';
import 'package:kitty_app/core/providers/core_providers.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/core/storage/secure_storage_service.dart';
import 'package:kitty_app/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:kitty_app/features/dashboard/data/repositories/mock_dashboard_repository.dart';
import 'package:kitty_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:kitty_app/features/home/data/repositories/mock_gold_rate_repository.dart';
import 'package:kitty_app/features/home/data/repositories/mock_product_repository.dart';
import 'package:kitty_app/features/home/presentation/screens/home_screen.dart';
import 'package:kitty_app/features/notifications/data/repositories/mock_notification_repository.dart';
import 'package:kitty_app/features/offers/data/repositories/mock_scheme_repository.dart';
import 'package:kitty_app/features/calculator/presentation/screens/calculator_screen.dart';
import 'package:kitty_app/features/jewellery/presentation/screens/jewellery_screen.dart';
import 'package:kitty_app/features/offers/presentation/screens/offers_screen.dart';
import 'package:kitty_app/shared/widgets/inputs/kitty_otp_input.dart';

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
  group('Comprehensive Route & Link Verification Test Suite', () {
    late MockEngineConfig instantConfig;

    setUp(() {
      instantConfig = MockEngineConfig(latency: MockLatency.instant);
    });

    testWidgets('1. Auth Flow: Login -> Phone -> OTP -> Success -> Dashboard', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final _FakeSecureStorageService fakeStorage = _FakeSecureStorageService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mockEngineConfigProvider.overrideWithValue(instantConfig),
            secureStorageServiceProvider.overrideWithValue(fakeStorage),
            authRepositoryProvider.overrideWithValue(
              MockAuthRepository(storageService: fakeStorage, engineConfig: instantConfig),
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

      // 1a. Start on Login Screen
      expect(find.text('Sign in to continue'), findsOneWidget);

      // 1b. Tap 'Continue with Mobile' -> /auth/phone
      await tester.tap(find.text('Continue with Mobile'));
      await tester.pumpAndSettle();
      expect(find.text('Enter your mobile number'), findsOneWidget);

      // 1c. Enter phone and tap 'Continue' -> /auth/otp
      await tester.enterText(find.byType(TextField), '9876543210');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Verify your number'), findsOneWidget);

      // 1d. Enter OTP '123456' -> Navigates to /auth/profile
      final Finder otpFinder = find.byType(KittyOtpInput);
      expect(otpFinder, findsOneWidget);
      final KittyOtpInputState otpState = tester.state(otpFinder);
      otpState.setOtp('123456');
      await tester.pumpAndSettle();
      expect(find.text('Complete Your Profile'), findsOneWidget);

      // 1e. Complete Profile Form -> Pushes /auth/success
      await tester.enterText(find.byKey(const Key('input_profile_name')), 'Rihan Saifi');
      await tester.enterText(find.byKey(const Key('input_profile_email')), 'rihan@swastikjewel.com');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Complete Profile & Enter Vault'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Welcome Back'), findsOneWidget);

      // 1f. Tap 'Enter Gold Vault' -> Navigates to /home
      await tester.tap(find.text('Enter Gold Vault'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('2. 5 Shell Bottom Tabs switch smoothly and preserve state', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mockEngineConfigProvider.overrideWithValue(instantConfig),
            appAuthStateProvider.overrideWith(
              () => _TestAuthNotifier(
                const AppAuthState.authenticated(
                  token: 'test_token',
                  userName: 'Rihan',
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

      // Tab 0: Home Tab
      expect(find.byType(HomeScreen), findsOneWidget);

      // Tab 1: Switch to My Kitty Tab via Bottom Nav
      await tester.tap(find.text('My Kitty'));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsOneWidget);

      // Tab 2: Switch to Kitty Plans Tab via Bottom Nav
      await tester.tap(find.text('Kitty Plans'));
      await tester.pumpAndSettle();
      expect(find.byType(OffersScreen), findsOneWidget);

      // Tab 3: Switch to Calculator Tab via Bottom Nav
      await tester.tap(find.text('Calculator'));
      await tester.pumpAndSettle();
      expect(find.byType(CalculatorScreen), findsOneWidget);

      // Tab 4: Switch to Jewellery Tab via Bottom Nav
      await tester.tap(find.text('Jewellery'));
      await tester.pumpAndSettle();
      expect(find.byType(JewelleryScreen), findsOneWidget);

      // Return to Home Tab via Bottom Nav
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('3. In-screen Navigation Links: Home -> Dashboard -> Checkout -> Gokwik', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mockEngineConfigProvider.overrideWithValue(instantConfig),
            appAuthStateProvider.overrideWith(
              () => _TestAuthNotifier(
                const AppAuthState.authenticated(
                  token: 'test_token',
                  userName: 'Rihan',
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

      // Home: Open Drawer -> Tap 'My Kitty' -> Dashboard
      await tester.tap(find.byTooltip('Open Menu'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(Drawer),
          matching: find.text('My Kitty'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsOneWidget);

      // Dashboard: Tap upcoming installment tile -> Checkout modal
      await tester.tap(find.byKey(const Key('dashboard_hero_pay_upcoming_emi')));
      await tester.pumpAndSettle();
      expect(find.text('Pay Kitty Installment'), findsOneWidget);
      expect(find.text('Confirm & Pay ₹5,000'), findsOneWidget);

      // Checkout: Tap 'Confirm & Pay ₹5,000' -> Launches Gokwik Gateway
      await tester.tap(find.text('Confirm & Pay ₹5,000'));
      await tester.pumpAndSettle();
      expect(find.text('GoKwik Sandbox'), findsOneWidget);

      // Gokwik: Tap 'Simulate User Payment Complete'
      await tester.tap(find.text('Simulate User Payment Complete'));
      await tester.pumpAndSettle();

      // Verified Success screen in Checkout
      expect(find.text('PAYMENT CONFIRMED'), findsOneWidget);

      // Tap 'Back to Kitty Dashboard'
      await tester.tap(find.text('Back to Kitty Dashboard'));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets('4. Header Navigation: Bell Icon opens Notifications', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mockEngineConfigProvider.overrideWithValue(instantConfig),
            appAuthStateProvider.overrideWith(
              () => _TestAuthNotifier(
                const AppAuthState.authenticated(
                  token: 'test_token',
                  userName: 'Rihan',
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
            secureStorageServiceProvider.overrideWithValue(_FakeSecureStorageService()),
            notificationRepositoryProvider.overrideWithValue(
              MockNotificationRepository(engineConfig: instantConfig),
            ),
          ],
          child: const KittyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Notification Bell in Header
      await tester.tap(find.byTooltip('Notifications'));
      await tester.pumpAndSettle();

      // Verify Notifications Screen
      expect(find.text('Notifications'), findsOneWidget);

      // Back navigation returns to Home
      await tester.tap(find.byKey(const Key('btn_notifications_back')));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('5. Luxury Drawer Links: KYC and Logout', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mockEngineConfigProvider.overrideWithValue(instantConfig),
            appAuthStateProvider.overrideWith(
              () => _TestAuthNotifier(
                const AppAuthState.authenticated(
                  token: 'test_token',
                  userName: 'Rihan',
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

      // Open Drawer via Menu Button
      await tester.tap(find.byTooltip('Open Menu'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('drawer_swastik_logo')), findsOneWidget);

      // Tap 'KYC Compliance' link
      await tester.tap(find.text('KYC Compliance'));
      await tester.pumpAndSettle();
      expect(find.text('KYC Document Verification'), findsOneWidget);

      // Tap 'Back' on KYC screen
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      // Open Drawer again to test Logout
      await tester.tap(find.byTooltip('Open Menu'));
      await tester.pumpAndSettle();

      // Tap 'Log Out of Account'
      await tester.tap(find.text('Log Out of Account'));
      await tester.pumpAndSettle();

      // Confirm Logout Dialog
      expect(find.text('Log Out of Account?'), findsOneWidget);
      await tester.tap(find.text('Log Out'));
      await tester.pumpAndSettle();

      // Successfully redirected to Login
      expect(find.text('Sign in to continue'), findsOneWidget);
    });

    testWidgets('6. Unknown Route renders 404 and recovers back to Home', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mockEngineConfigProvider.overrideWithValue(instantConfig),
            appAuthStateProvider.overrideWith(
              () => _TestAuthNotifier(
                const AppAuthState.authenticated(
                  token: 'test_token',
                  userName: 'Rihan',
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

      // Navigate to an invalid unregistered path
      final BuildContext ctx = tester.element(find.byType(Scaffold).first);
      GoRouter.of(ctx).go('/unregistered/invalid/path');
      await tester.pumpAndSettle();

      // Verify 404 Screen
      expect(find.text('404 — Page Not Found'), findsOneWidget);

      // Tap 'Return to Safety' button
      await tester.tap(find.text('Return to Safety'));
      await tester.pumpAndSettle();

      // Successfully recovered to Home Screen
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}

class _TestAuthNotifier extends AppAuthNotifier {
  _TestAuthNotifier(this._initialState);

  final AppAuthState _initialState;

  @override
  AppAuthState build() {
    return _initialState;
  }

  @override
  Future<void> setAuthenticated({
    required String token,
    String userName = 'Rihan',
    String userPhone = '+91 98765 43210',
    String userEmail = 'rihan@swastikjewel.com',
    String userDob = '',
    String address = '',
    String city = '',
    String pincode = '',
    String nomineeName = '',
    String nomineeRelation = '',
    String nomineePhone = '',
    String tier = 'Tier 1 Verified Member',
    bool isKycVerified = true,
    bool isOnboarded = true,
  }) async {
    state = AppAuthState.authenticated(
      token: token,
      userName: userName,
      userPhone: userPhone,
      userEmail: userEmail,
      userDob: userDob,
      address: address,
      city: city,
      pincode: pincode,
      nomineeName: nomineeName,
      nomineeRelation: nomineeRelation,
      nomineePhone: nomineePhone,
      tier: tier,
      isKycVerified: isKycVerified,
      isOnboarded: isOnboarded,
    );
  }

  @override
  Future<void> logout() async {
    state = const AppAuthState.unauthenticated();
  }
}
