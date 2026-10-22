import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/features/home/data/repositories/mock_gold_rate_repository.dart';
import 'package:kitty_app/features/home/domain/entities/gold_rate_entity.dart';
import 'package:kitty_app/features/home/domain/repositories/i_gold_rate_repository.dart';
import 'package:kitty_app/features/live_rates/presentation/providers/live_rate_controller.dart';
import 'package:kitty_app/features/live_rates/presentation/providers/live_rate_state.dart';
import 'package:kitty_app/features/live_rates/presentation/screens/live_rates_screen.dart';
import 'package:kitty_app/features/live_rates/presentation/widgets/live_rate_karat_card.dart';
import 'package:kitty_app/features/live_rates/presentation/widgets/live_rate_silver_card.dart';
import 'package:kitty_app/features/live_rates/presentation/widgets/live_rates_skeleton_loader.dart';
import 'package:kitty_app/shared/widgets/feedback/kitty_error_state.dart';

void main() {
  late MockEngineConfig instantConfig;

  setUp(() {
    instantConfig = MockEngineConfig(latency: MockLatency.instant);
  });

  Widget createSubject({
    IGoldRateRepository? goldRateRepo,
  }) {
    return ProviderScope(
      overrides: [
        mockEngineConfigProvider.overrideWithValue(instantConfig),
        goldRateRepositoryProvider.overrideWithValue(
          goldRateRepo ?? MockGoldRateRepository(engineConfig: instantConfig),
        ),
      ],
      child: const MaterialApp(
        home: LiveRatesScreen(),
      ),
    );
  }

  group('LiveRatesScreen (Phase 4) Widget Tests', () {
    testWidgets('1. Fully renders Live Rates board for 24K, 22K, 18K, 14K Gold and 999 Silver', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Title & Live badge
      expect(find.text("Today's Live Rates"), findsWidgets);
      expect(find.text('LIVE'), findsOneWidget);
      expect(find.textContaining('Updated:'), findsOneWidget);

      // Gold Karat Cards
      expect(find.byType(LiveRateKaratCard), findsNWidgets(4));
      expect(find.text('24K'), findsOneWidget);
      expect(find.text('22K'), findsOneWidget);
      expect(find.text('18K'), findsOneWidget);
      expect(find.text('14K'), findsOneWidget);

      // Purity labels
      expect(find.text('99.9% Pure Gold • Standard Bullion'), findsOneWidget);
      expect(find.text('91.6% Pure Gold • Traditional Jewellery'), findsOneWidget);
      expect(find.text('75.0% Fine Gold • Diamond Jewellery'), findsOneWidget);
      expect(find.text('58.5% Fine Gold • Modern Everyday Wear'), findsOneWidget);

      // Hallmark badges
      expect(find.text('BIS 999'), findsOneWidget);
      expect(find.text('BIS 916'), findsOneWidget);
      expect(find.text('BIS 750'), findsOneWidget);
      expect(find.text('BIS 585'), findsOneWidget);

      // Silver Card (separate and without gold karat selector)
      expect(find.byType(LiveRateSilverCard), findsOneWidget);
      expect(find.text('SILVER 999'), findsOneWidget);
      expect(find.text('99.9% Fine Bullion Silver'), findsOneWidget);
      expect(find.text('PER 10 GRAMS'), findsOneWidget);
      expect(find.text('PER 1 GRAM'), findsOneWidget);

      // Utility CTAs
      expect(find.text('CALCULATE GOLD VALUE'), findsOneWidget);
      expect(find.text('EXPLORE KITTY PLANS'), findsOneWidget);

      // Notice
      expect(find.textContaining('IBJA'), findsOneWidget);
    });

    testWidgets('2. Gracefully handles missing silver rate (partial data) without crashing', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mockEngineConfigProvider.overrideWithValue(instantConfig),
            goldRateRepositoryProvider.overrideWithValue(
              _FakePartialGoldRateRepo(),
            ),
          ],
          child: const MaterialApp(
            home: LiveRatesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Gold rates still render
      expect(find.byType(LiveRateKaratCard), findsNWidgets(4));
      expect(find.text('24K'), findsOneWidget);

      // Silver displays unavailable message
      expect(find.text('Silver market rate temporarily unavailable'), findsOneWidget);
    });

    testWidgets('3. Renders Error state and retry button when rate retrieval fails', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mockEngineConfigProvider.overrideWithValue(instantConfig),
            liveRateControllerProvider.overrideWith(
              () => _FakeErrorLiveRateController(),
            ),
          ],
          child: const MaterialApp(
            home: LiveRatesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(KittyErrorState), findsOneWidget);
      expect(find.text('Unable to Load Live Rates'), findsOneWidget);
      expect(find.text('TRY AGAIN'), findsOneWidget);
    });

    testWidgets('4. Renders Skeleton loader during loading state', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mockEngineConfigProvider.overrideWithValue(instantConfig),
            liveRateControllerProvider.overrideWith(
              () => _FakeLoadingLiveRateController(),
            ),
          ],
          child: const MaterialApp(
            home: LiveRatesScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(LiveRatesSkeletonLoader), findsOneWidget);
    });
  });
}

class _FakePartialGoldRateRepo implements IGoldRateRepository {
  @override
  Future<LiveGoldRateEntity> getLiveGoldRate() async {
    return LiveGoldRateEntity(
      ratePerGram: 15268.0,
      purity: '24K (999)',
      purityFraction: 0.999,
      currency: 'INR',
      change24h: 0.0,
      changePct: 0.0,
      isUp: true,
      updatedAt: DateTime.parse('2026-09-29T10:30:00.000Z'),
      silverRatePerGram: null, // Partial data: silver unavailable
    );
  }
}

class _FakeErrorLiveRateController extends LiveRateController {
  @override
  LiveRateState build() {
    return const LiveRateState(
      status: LiveRateStatus.error,
      errorMessage: 'Network timeout.',
    );
  }
}

class _FakeLoadingLiveRateController extends LiveRateController {
  @override
  LiveRateState build() {
    return const LiveRateState(status: LiveRateStatus.loading);
  }
}
