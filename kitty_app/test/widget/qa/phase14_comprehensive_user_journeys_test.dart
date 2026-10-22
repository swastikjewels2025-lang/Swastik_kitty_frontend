import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/core/providers/auth_state_provider.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/features/calculator/presentation/screens/calculator_screen.dart';
import 'package:kitty_app/features/coin_rates/presentation/screens/coin_rates_screen.dart';
import 'package:kitty_app/features/dashboard/data/repositories/mock_dashboard_repository.dart';
import 'package:kitty_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:kitty_app/features/dashboard/presentation/widgets/dashboard_multi_scheme_carousel.dart';
import 'package:kitty_app/features/home/presentation/screens/home_screen.dart';
import 'package:kitty_app/features/jewellery/presentation/screens/jewellery_screen.dart';
import 'package:kitty_app/features/live_rates/presentation/screens/live_rates_screen.dart';
import 'package:kitty_app/features/offers/data/repositories/mock_scheme_repository.dart';
import 'package:kitty_app/features/offers/domain/entities/scheme_entity.dart';
import 'package:kitty_app/features/offers/presentation/widgets/start_kitty_flow_sheet.dart';

class _FakeAuthNotifier extends AppAuthNotifier {
  _FakeAuthNotifier(this._initial);
  final AppAuthState _initial;

  @override
  AppAuthState build() => _initial;
}

void main() {
  group('Phase 14: Comprehensive End-to-End User Journeys QA', () {
    // -------------------------------------------------------------------------
    // JOURNEY 1: App Launch -> Home -> Live Rates
    // -------------------------------------------------------------------------
    testWidgets('Journey 1: App Launch -> Home -> Live Rates', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          key: const Key('ps_journey_1_home'),
          overrides: [
            appAuthStateProvider.overrideWith(
              () => _FakeAuthNotifier(
                const AppAuthState.authenticated(
                  token: 'auth_token',
                  userName: 'Rihan Patron',
                  userPhone: '+91 98765 43210',
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: HomeScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Home loaded
      expect(find.byType(HomeScreen), findsOneWidget);

      // Verify Live Rates screen
      await tester.pumpWidget(
        const ProviderScope(
          key: Key('ps_journey_1_live_rates'),
          child: MaterialApp(
            home: LiveRatesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LiveRatesScreen), findsOneWidget);
      expect(find.text('Today\'s Live Rates'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // JOURNEY 2: Kitty Plans -> Plan Details -> Start Kitty -> Kitty Number
    // -------------------------------------------------------------------------
    testWidgets('Journey 2: Kitty Plans -> Plan Details -> Start Kitty Enrollment -> Kitty Number Picker', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockSchemeRepository repo = MockSchemeRepository(
        engineConfig: MockEngineConfig(latency: MockLatency.instant),
      );
      final SchemeEntity scheme = MockSchemeRepository.prototypeSchemes.first;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            schemeRepositoryProvider.overrideWithValue(repo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: StartKittyFlowSheet(scheme: scheme),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Step 1: Customize Your Plan
      expect(find.text('Step 1: Customize Your Plan'), findsOneWidget);
      expect(find.text(scheme.name), findsNWidgets(2));
      expect(find.text('YOUR 11+1 SAVINGS BENEFIT'), findsOneWidget);

      // Advance to Step 2: Number Selection
      await tester.tap(find.text('CONTINUE TO NUMBER SELECTION →'));
      await tester.pumpAndSettle();

      expect(find.text('Step 2: Choose Kitty Number'), findsOneWidget);
      expect(find.text('Search lucky number (e.g. 7, 21, 51)...'), findsOneWidget);
      expect(find.text('Auspicious: '), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // JOURNEY 3: Calculator -> Calculate -> Start Kitty with this Budget -> Start Kitty
    // -------------------------------------------------------------------------
    testWidgets('Journey 3: Calculator -> Calculate -> Start Kitty with Budget -> Wizard Conversion', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockSchemeRepository repo = MockSchemeRepository(
        engineConfig: MockEngineConfig(latency: MockLatency.instant),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            schemeRepositoryProvider.overrideWithValue(repo),
          ],
          child: const MaterialApp(
            home: CalculatorScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Calculate for 5.482 grams
      final weightField = find.byType(TextField).first;
      await tester.enterText(weightField, '5.482');
      await tester.pumpAndSettle();

      // Verify Start Kitty with Budget CTA appears
      final Finder ctaFinder = find.byKey(const Key('btn_calculator_start_kitty'));
      expect(ctaFinder, findsOneWidget);
      expect(find.textContaining('Start Kitty with this Budget'), findsOneWidget);

      // Tap CTA to convert calculation into Start Kitty enrollment flow
      await tester.tap(ctaFinder);
      await tester.pumpAndSettle();

      // Verify Wizard opens with custom budget banner
      expect(find.byKey(const Key('start_kitty_flow_sheet')), findsOneWidget);
      expect(find.textContaining('Budget calculated from Gold Calculator'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // JOURNEY 4: Drawer -> Coins -> Gold -> Silver
    // -------------------------------------------------------------------------
    testWidgets('Journey 4: Coins Showcase -> Gold vs Silver Selector', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CoinRatesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Gold Coins rendered
      expect(find.text('GOLD COIN'), findsOneWidget);
      expect(find.text('SILVER COIN'), findsOneWidget);
      expect(find.text('GOLD COIN 999 5 GM'), findsOneWidget);

      // Switch to Silver Coins
      await tester.tap(find.text('SILVER COIN'));
      await tester.pumpAndSettle();

      expect(find.text('SILVER COIN 999 5 GM'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // JOURNEY 5: Jewellery -> WebView Web Bridge -> Concierge / Refresh
    // -------------------------------------------------------------------------
    testWidgets('Journey 5: Jewellery Screen -> In-App Web Bridge -> Concierge Modal', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: JewelleryScreen(isTestMode: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Luxury Chrome and Official Verified Badge
      expect(find.text('Swastik Showroom'), findsOneWidget);
      expect(find.text('swastikjewel.in · Official Web Catalog'), findsOneWidget);

      // Open Concierge dialog
      await tester.tap(find.byKey(const Key('btn_jewellery_concierge')));
      await tester.pumpAndSettle();

      expect(find.text('Swastik Showroom Concierge'), findsOneWidget);
      expect(find.byKey(const Key('btn_concierge_call_now')), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // JOURNEY 6: My Kitty -> Multiple Kitty Carousel -> Switch Scheme -> Pay Selected
    // -------------------------------------------------------------------------
    testWidgets('Journey 6: My Kitty -> Multiple Kitty Carousel -> Switch Scheme -> Pay Selected', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockDashboardRepository mockRepo = MockDashboardRepository(
        engineConfig: MockEngineConfig(latency: MockLatency.instant),
      );
      mockRepo.setMultipleSchemes(true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Carousel tabs rendered for multi-scheme portfolio
      expect(find.byType(DashboardMultiSchemeCarousel), findsOneWidget);
      expect(find.byKey(const Key('multi_scheme_tab_0')), findsOneWidget);
      expect(find.byKey(const Key('multi_scheme_tab_1')), findsOneWidget);

      // Switch to Scheme #2
      await tester.tap(find.byKey(const Key('multi_scheme_tab_1')));
      await tester.pumpAndSettle();

      // Verify active card updated
      expect(find.text('Kitty #2'), findsOneWidget);
      expect(find.text('#SW-018'), findsOneWidget);
      expect(find.byKey(const Key('dashboard_hero_pay_selected_btn')), findsOneWidget);
    });
  });
}
