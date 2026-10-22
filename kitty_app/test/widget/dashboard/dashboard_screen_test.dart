import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/enums/app_enums.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/features/dashboard/data/repositories/mock_dashboard_repository.dart';
import 'package:kitty_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:kitty_app/features/dashboard/presentation/widgets/dashboard_next_emi_card.dart';
import 'package:kitty_app/features/dashboard/presentation/widgets/dashboard_prejoin_banner.dart';
import 'package:kitty_app/features/dashboard/presentation/widgets/dashboard_skeleton_loader.dart';
import 'package:kitty_app/features/dashboard/presentation/widgets/dashboard_stats_grid.dart';
import 'package:kitty_app/features/dashboard/presentation/widgets/dashboard_trust_bar.dart';
import 'package:kitty_app/shared/widgets/feedback/kitty_empty_state.dart';

void main() {
  group('DashboardScreen Widget Tests', () {
    late MockDashboardRepository mockRepository;

    setUp(() {
      final MockEngineConfig immediateEngine = MockEngineConfig(
        latency: MockLatency.instant,
      );
      mockRepository = MockDashboardRepository(engineConfig: immediateEngine);
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          dashboardRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: const MaterialApp(
          home: DashboardScreen(),
        ),
      );
    }

    testWidgets('1. Fully renders loaded Dashboard screen with all sections', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify sections
      expect(find.byType(DashboardStatsGrid), findsNothing);
      expect(find.byType(DashboardNextEmiCard), findsNothing);
      expect(find.byType(DashboardTrustBar), findsNothing);

      // Verify text content
      expect(find.text('Your Active Plan'), findsOneWidget);
      expect(find.text('Swastik Swarna Varsha'), findsOneWidget);
      expect(find.textContaining('mem_994411'), findsOneWidget);
      expect(find.text('Your Plan Details'), findsOneWidget);
      expect(find.text('Your Progress'), findsOneWidget);
      expect(find.text('Upcoming Payment'), findsOneWidget);
    });

    testWidgets('2. Displays Empty State when no active scheme exists', (WidgetTester tester) async {
      mockRepository.setHasActiveScheme(false);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(KittyEmptyState), findsOneWidget);
      expect(find.text('No Active Gold Scheme'), findsOneWidget);
      expect(find.text('EXPLORE GOLD PLANS'), findsOneWidget);
    });

    testWidgets('3. Displays PRE_JOIN banner for pre-join users', (WidgetTester tester) async {
      mockRepository.setStatus(MembershipStatusEnum.preJoin);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(DashboardPrejoinBanner), findsOneWidget);
      expect(find.text('PRE-JOIN SCHEME ENROLLED'), findsOneWidget);
    });

    testWidgets('4. Displays Error view on failure and recovers upon retry', (WidgetTester tester) async {
      mockRepository.setShouldThrow(true);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Unable to Load Scheme Details'), findsOneWidget);
      expect(find.text('TRY AGAIN'), findsOneWidget);

      // Fix failure and tap retry
      mockRepository.setShouldThrow(false);
      await tester.tap(find.text('TRY AGAIN'));
      await tester.pumpAndSettle();

      expect(find.text('Swastik Swarna Varsha'), findsOneWidget);
      expect(find.text('Your Active Plan'), findsOneWidget);
    });

    testWidgets('5. Displays Skeleton Loader during loading state', (WidgetTester tester) async {
      // Use latency to observe loading skeleton
      final MockEngineConfig delayedEngine = MockEngineConfig(
        latency: MockLatency.slow,
      );
      mockRepository = MockDashboardRepository(engineConfig: delayedEngine);

      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Start build

      expect(find.byType(DashboardSkeletonLoader), findsOneWidget);

      await tester.pumpAndSettle(); // Settle async load
      expect(find.text('Swastik Swarna Varsha'), findsOneWidget);
    });
  });
}
