import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/features/auth/presentation/screens/onboarding_choice_screen.dart';
import 'package:kitty_app/app/kitty_app.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/core/providers/auth_state_provider.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/core/routing/app_router.dart';
import 'package:kitty_app/core/routing/route_paths.dart';
import 'package:kitty_app/features/coin_rates/presentation/screens/coin_rates_screen.dart';
import 'package:kitty_app/features/dashboard/data/repositories/mock_dashboard_repository.dart';
import 'package:kitty_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:kitty_app/features/home/data/repositories/mock_gold_rate_repository.dart';
import 'package:kitty_app/features/home/data/repositories/mock_product_repository.dart';
import 'package:kitty_app/features/jewellery/presentation/screens/jewellery_screen.dart';
import 'package:kitty_app/features/kyc/presentation/screens/kyc_screen.dart';
import 'package:kitty_app/features/offers/data/repositories/mock_scheme_repository.dart';
import 'package:kitty_app/features/offers/presentation/screens/offers_screen.dart';
import 'package:kitty_app/features/orders/presentation/screens/orders_screen.dart';
import 'package:kitty_app/shared/widgets/navigation/app_bottom_nav_bar.dart';

void main() {
  group('AppRouter Declarative Navigation & Auth Guards Tests', () {
    late MockEngineConfig instantConfig;

    setUp(() {
      instantConfig = MockEngineConfig(latency: MockLatency.instant);
    });

    testWidgets('Unauthenticated user is redirected to Login screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mockEngineConfigProvider.overrideWithValue(instantConfig),
            appAuthStateProvider.overrideWith(
              () => _TestAuthNotifier(const AppAuthState.unauthenticated()),
            ),
          ],
          child: const KittyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Login Screen is displayed
      expect(find.text('Sign in to continue'), findsOneWidget);
    });

    testWidgets('Authenticated user accessing root navigates to Gold Plans landing page', (WidgetTester tester) async {
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
                  token: 'valid_jwt_token',
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

      // Authenticated user arrives at OnboardingChoiceScreen from splash
      expect(find.byType(OnboardingChoiceScreen), findsOneWidget);
      await tester.tap(find.text('View Gold Schemes'));
      await tester.pumpAndSettle();

      // Verify Gold Plans Screen is rendered as landing page
      expect(find.byType(OffersScreen), findsOneWidget);
    });

    testWidgets('Authenticated user with skipped KYC navigates freely to Gold Plans landing page', (WidgetTester tester) async {
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
                  token: 'valid_jwt_token',
                  userName: 'Rihan',
                  isKycVerified: false,
                  hasSkippedKyc: true,
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

      // Skipped KYC user also arrives at choice screen and navigates to Gold Schemes without KYC lock
      expect(find.byType(OnboardingChoiceScreen), findsOneWidget);
      await tester.tap(find.text('View Gold Schemes'));
      await tester.pumpAndSettle();

      // Verify Gold Plans Screen is rendered as landing page even though KYC is not verified
      expect(find.byType(OffersScreen), findsOneWidget);
    });

    testWidgets('4-Destination Primary Shell switches branches and preserves navigation state', (WidgetTester tester) async {
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
                  token: 'valid_jwt_token',
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

      // Tap through choice screen into Gold Plans
      expect(find.byType(OnboardingChoiceScreen), findsOneWidget);
      await tester.tap(find.text('View Gold Schemes'));
      await tester.pumpAndSettle();

      // Initially on Branch 0: Gold Plans
      expect(find.byType(OffersScreen), findsOneWidget);

      // Verify bottom nav items
      final Finder bottomNavBarFinder = find.byType(AppBottomNavBar);
      expect(find.descendant(of: bottomNavBarFinder, matching: find.text('Gold Plans')), findsOneWidget);
      expect(find.descendant(of: bottomNavBarFinder, matching: find.text('My Plan')), findsOneWidget);
      expect(find.descendant(of: bottomNavBarFinder, matching: find.text('Instagram')), findsOneWidget);
      expect(find.descendant(of: bottomNavBarFinder, matching: find.text('Jewellery')), findsOneWidget);

      // Switch to Branch 1: My Plan
      await tester.tap(find.descendant(of: bottomNavBarFinder, matching: find.text('My Plan')));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsOneWidget);

      // Tap Tab 2: Instagram (external action, maintains current tab)
      await tester.tap(find.descendant(of: bottomNavBarFinder, matching: find.text('Instagram')));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsOneWidget);

      // Tap Tab 3: Jewellery (external action, opens website externally, does not navigate internally)
      await tester.tap(find.descendant(of: bottomNavBarFinder, matching: find.text('Jewellery')));
      await tester.pumpAndSettle();
      expect(find.byType(JewelleryScreen), findsNothing);
      expect(find.byType(DashboardScreen), findsOneWidget);

      // Return to Branch 0: Gold Plans
      await tester.tap(find.descendant(of: bottomNavBarFinder, matching: find.text('Gold Plans')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(OffersScreen), findsOneWidget);
    });

    testWidgets('Secondary routes: Gold Coins, Bookings, and KYC remain accessible', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final ProviderContainer container = ProviderContainer(
        overrides: [
          mockEngineConfigProvider.overrideWithValue(instantConfig),
          appAuthStateProvider.overrideWith(
            () => _TestAuthNotifier(
              const AppAuthState.authenticated(
                token: 'valid_jwt_token',
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
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const KittyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to Gold Coins
      container.read(routerProvider).go(RoutePaths.coinRates);
      await tester.pumpAndSettle();
      expect(find.byType(CoinRatesScreen), findsOneWidget);

      // Navigate to Orders / Bookings
      container.read(routerProvider).go(RoutePaths.orders);
      await tester.pumpAndSettle();
      expect(find.byType(OrdersScreen), findsOneWidget);

      // Navigate to KYC
      container.read(routerProvider).go(RoutePaths.kyc);
      await tester.pumpAndSettle();
      expect(find.byType(KycScreen), findsOneWidget);

      // Return to Gold Plans
      container.read(routerProvider).go(RoutePaths.offers);
      await tester.pumpAndSettle();
      expect(find.byType(OffersScreen), findsOneWidget);
    });

    testWidgets('Unrecognized route renders 404 NotFoundScreen without crashing', (WidgetTester tester) async {
      final ProviderContainer container = ProviderContainer(
        overrides: [
          mockEngineConfigProvider.overrideWithValue(instantConfig),
          appAuthStateProvider.overrideWith(
            () => _TestAuthNotifier(
              const AppAuthState.authenticated(
                token: 'valid_jwt_token',
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
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const KittyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to nonexistent route
      container.read(routerProvider).go('/nonexistent-404-test-path');
      await tester.pumpAndSettle();

      // Verify 404 Not Found Screen is displayed
      expect(find.text('404 — Page Not Found'), findsOneWidget);
      expect(find.text('Return to Safety'), findsOneWidget);
    });
  });
}

class _TestAuthNotifier extends AppAuthNotifier {
  _TestAuthNotifier(this._state);

  final AppAuthState _state;

  @override
  AppAuthState build() {
    return _state;
  }
}
