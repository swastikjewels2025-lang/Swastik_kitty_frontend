import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/core/providers/auth_state_provider.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/features/dashboard/data/repositories/mock_dashboard_repository.dart';
import 'package:kitty_app/features/home/data/repositories/mock_gold_rate_repository.dart';
import 'package:kitty_app/features/home/data/repositories/mock_product_repository.dart';
import 'package:kitty_app/features/home/presentation/providers/home_controller.dart';
import 'package:kitty_app/features/home/presentation/providers/home_state.dart';
import 'package:kitty_app/features/home/presentation/screens/home_screen.dart';
import 'package:kitty_app/features/home/presentation/widgets/home_active_kitty_card.dart';
import 'package:kitty_app/features/home/presentation/widgets/home_footer.dart';
import 'package:kitty_app/features/home/presentation/widgets/home_gold_price_last_3_days.dart';
import 'package:kitty_app/features/home/presentation/widgets/home_jewellery_collections.dart';
import 'package:kitty_app/features/home/presentation/widgets/home_no_active_kitty_card.dart';
import 'package:kitty_app/features/home/presentation/widgets/home_offers_carousel.dart';
import 'package:kitty_app/features/home/presentation/widgets/home_quick_actions.dart';
import 'package:kitty_app/features/home/presentation/widgets/home_store_video_section.dart';
import 'package:kitty_app/features/home/presentation/widgets/home_today_gold_rates.dart';
import 'package:kitty_app/features/offers/data/repositories/mock_scheme_repository.dart';
import 'package:kitty_app/shared/widgets/feedback/kitty_error_state.dart';

void main() {
  late MockEngineConfig instantConfig;

  setUp(() {
    instantConfig = MockEngineConfig(latency: MockLatency.instant);
  });

  Widget createSubject({
    MockDashboardRepository? dashboardRepo,
    AppAuthState authState = const AppAuthState.authenticated(
      token: 'mock_jwt_token',
      userName: 'Rihan Saifi',
      isKycVerified: true,
    ),
  }) {
    return ProviderScope(
      overrides: [
        mockEngineConfigProvider.overrideWithValue(instantConfig),
        appAuthStateProvider.overrideWith(
          () => FakeAppAuthNotifier(authState),
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
          dashboardRepo ?? MockDashboardRepository(engineConfig: instantConfig),
        ),
      ],
      child: const MaterialApp(
        home: HomeScreen(),
      ),
    );
  }

  group('HomeScreen Redesign (Phase 3) Widget Tests', () {
    testWidgets('1. Fully renders Kitty-First Home Dashboard when Active Kitty exists', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 4800);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // 1. Today's Gold Rates (24K, 22K, 18K, 14K with live badge)
      expect(find.byType(HomeTodayGoldRates), findsOneWidget);
      expect(find.text("TODAY'S GOLD RATES"), findsOneWidget);
      expect(find.text('LIVE'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(HomeTodayGoldRates),
          matching: find.text('24K'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(HomeTodayGoldRates),
          matching: find.text('22K'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(HomeTodayGoldRates),
          matching: find.text('18K'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(HomeTodayGoldRates),
          matching: find.text('14K'),
        ),
        findsOneWidget,
      );

      // 2. Active Kitty Card (Prominent Next Payment & PAY NOW CTA)
      expect(find.byType(HomeActiveKittyCard), findsOneWidget);
      expect(find.byType(HomeNoActiveKittyCard), findsNothing);
      expect(find.text('Swastik Suvarna Varsha'), findsWidgets);
      expect(find.text('PAYMENT DUE'), findsOneWidget);
      expect(find.text('NEXT PAYMENT'), findsOneWidget);
      expect(find.textContaining('NOW'), findsOneWidget);
      expect(find.text('View Savings History'), findsOneWidget);

      // 3. Quick Actions (Start Kitty, Calculator, Jewellery)
      expect(find.byType(HomeQuickActions), findsOneWidget);
      expect(find.text('Start Kitty'), findsOneWidget);
      expect(find.text('Calculator'), findsOneWidget);
      expect(find.text('Jewellery'), findsOneWidget);

      // 4. Special Kitty Privileges Carousel
      expect(find.byType(HomeOffersCarousel), findsOneWidget);

      // 5. Curated Masterpieces / Explore Our Jewellery
      expect(find.byType(HomeJewelleryCollections), findsOneWidget);
      expect(find.text('Explore Our Jewellery'), findsOneWidget);
      expect(find.text('Rings'), findsOneWidget);
      expect(find.text('Earrings'), findsOneWidget);

      // 6. Gold Price — Last 3 Days
      expect(find.byType(HomeGoldPriceLast3Days), findsOneWidget);
      expect(find.text('GOLD PRICE — LAST 3 DAYS'), findsOneWidget);

      // 7. Luxury Footer
      expect(find.byType(HomeFooter), findsOneWidget);
      expect(find.text('About Us'), findsOneWidget);
      expect(find.text('Contact Us'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);

      // 8. Verify legacy deprecated items are absent
      expect(find.byType(HomeStoreVideoSection), findsNothing);
      expect(find.text('EXPERIENCE SWASTIK'), findsNothing);
      expect(find.text('ROYAL CLUB'), findsNothing);
    });

    testWidgets('2. Renders HomeNoActiveKittyCard onboarding state when user has no active scheme', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 4800);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final MockDashboardRepository emptyDashboardRepo =
          MockDashboardRepository(engineConfig: instantConfig);
      emptyDashboardRepo.setHasActiveScheme(false);

      await tester.pumpWidget(createSubject(dashboardRepo: emptyDashboardRepo));
      await tester.pumpAndSettle();

      // Active Kitty Card should not be present
      expect(find.byType(HomeActiveKittyCard), findsNothing);

      // No Active Kitty Onboarding Card should be present
      expect(find.byType(HomeNoActiveKittyCard), findsOneWidget);
      expect(find.text('READY TO START'), findsOneWidget);
      expect(find.text('Start Your Gold Savings Today'), findsOneWidget);
      expect(find.text('11+1 Bonus Month'), findsOneWidget);
      expect(find.text('START A KITTY'), findsOneWidget);
      expect(find.text('Calculate Gold Value & Plan'), findsOneWidget);

      // Gold rates, quick actions, offers, collections, and footer remain visible
      expect(find.byType(HomeTodayGoldRates), findsOneWidget);
      expect(find.byType(HomeQuickActions), findsOneWidget);
      expect(find.byType(HomeOffersCarousel), findsOneWidget);
      expect(find.byType(HomeJewelleryCollections), findsOneWidget);
      expect(find.byType(HomeGoldPriceLast3Days), findsOneWidget);
      expect(find.byType(HomeFooter), findsOneWidget);
    });

    testWidgets('3. Displays Error state and retry button when error occurs', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mockEngineConfigProvider.overrideWithValue(instantConfig),
            appAuthStateProvider.overrideWith(
              () => FakeAppAuthNotifier(const AppAuthState.authenticated(token: 'jwt')),
            ),
            homeControllerProvider.overrideWith(
              () => FakeErrorHomeController(),
            ),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(KittyErrorState), findsOneWidget);
      expect(find.text('Unable to Load Home'), findsOneWidget);
      expect(find.text('TRY AGAIN'), findsOneWidget);
    });
  });
}

class FakeAppAuthNotifier extends AppAuthNotifier {
  FakeAppAuthNotifier(this.initialState);
  final AppAuthState initialState;

  @override
  AppAuthState build() => initialState;
}

class FakeErrorHomeController extends HomeController {
  @override
  HomeState build() {
    return const HomeState(
      status: HomeStatus.error,
      errorMessage: 'Network connection error.',
    );
  }
}
