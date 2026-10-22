import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/features/dashboard/data/repositories/mock_dashboard_repository.dart';
import 'package:kitty_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:kitty_app/features/dashboard/presentation/widgets/dashboard_hero_card.dart';
import 'package:kitty_app/features/dashboard/presentation/widgets/dashboard_multi_scheme_carousel.dart';
import 'package:kitty_app/shared/widgets/feedback/kitty_empty_state.dart';
import 'package:kitty_app/shared/widgets/feedback/kitty_error_state.dart';

void main() {
  group('Multi-Scheme Dashboard Management Tests (Phase 10)', () {
    late MockDashboardRepository mockRepo;

    setUp(() {
      mockRepo = MockDashboardRepository(
        engineConfig: MockEngineConfig(latency: MockLatency.instant),
      );
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          dashboardRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const MaterialApp(
          home: DashboardScreen(),
        ),
      );
    }

    testWidgets('1. Single scheme portfolio: Renders single hero card without carousel tabs',
        (WidgetTester tester) async {
      mockRepo.setMultipleSchemes(false);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(DashboardHeroCard), findsOneWidget);
      expect(find.text('Swastik Swarna Varsha'), findsOneWidget);
      expect(find.text('#SW-042'), findsOneWidget);
      expect(find.byKey(const Key('multi_scheme_tab_0')), findsNothing);
      expect(find.byKey(const Key('multi_scheme_tab_1')), findsNothing);
    });

    testWidgets('2. Multi-scheme portfolio: Renders carousel with tab switcher and dots',
        (WidgetTester tester) async {
      mockRepo.setMultipleSchemes(true);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(DashboardMultiSchemeCarousel), findsOneWidget);
      expect(find.text('ACTIVE SCHEMES (3)'), findsOneWidget);

      // Verify all 3 scheme tabs are displayed with monthly amounts
      expect(find.byKey(const Key('multi_scheme_tab_0')), findsOneWidget);
      expect(find.byKey(const Key('multi_scheme_tab_1')), findsOneWidget);
      expect(find.byKey(const Key('multi_scheme_tab_2')), findsOneWidget);

      expect(find.text('Kitty #1'), findsOneWidget);
      expect(find.text('₹5,000'), findsWidgets);

      expect(find.text('Kitty #2'), findsOneWidget);
      expect(find.text('₹2,000'), findsWidgets);

      expect(find.text('Kitty #3'), findsOneWidget);
      expect(find.text('₹3,000'), findsWidgets);
    });

    testWidgets('3. Switching schemes via tab pill updates active card to Kitty #2',
        (WidgetTester tester) async {
      mockRepo.setMultipleSchemes(true);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initially Kitty #1 is active
      expect(find.text('Swastik Swarna Varsha'), findsOneWidget);
      expect(find.text('#SW-042'), findsOneWidget);

      // Tap Kitty #2 tab pill
      await tester.tap(find.byKey(const Key('multi_scheme_tab_1')));
      await tester.pumpAndSettle();

      // Kitty #2 details are now visible on active card
      expect(find.text('Dhanvantari Wealth Plan'), findsOneWidget);
      expect(find.text('#SW-018'), findsOneWidget);
      expect(find.text('4 EMIs Completed'), findsOneWidget);
    });

    testWidgets('4. Scheme isolation: Switching to Kitty #3 displays independent metrics',
        (WidgetTester tester) async {
      mockRepo.setMultipleSchemes(true);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap Kitty #3 tab pill
      await tester.tap(find.byKey(const Key('multi_scheme_tab_2')));
      await tester.pumpAndSettle();

      // Kitty #3 details
      expect(find.text('Akshaya Gold Reserve'), findsOneWidget);
      expect(find.text('#SW-031'), findsOneWidget);
      expect(find.text('11 EMIs Completed'), findsOneWidget);

      // Switch back to Kitty #1
      await tester.tap(find.byKey(const Key('multi_scheme_tab_0')));
      await tester.pumpAndSettle();

      expect(find.text('Swastik Swarna Varsha'), findsOneWidget);
      expect(find.text('#SW-042'), findsOneWidget);
      expect(find.text('8 EMIs Completed'), findsOneWidget);
    });

    testWidgets('5. Pay Selected button is rendered on active scheme card',
        (WidgetTester tester) async {
      mockRepo.setMultipleSchemes(true);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Primary Pay Selected button exists with amount
      expect(find.byKey(const Key('dashboard_hero_pay_selected_btn')), findsOneWidget);
      expect(find.text('PAY SELECTED (₹5,000)'), findsOneWidget);

      // Switch to Kitty #2
      await tester.tap(find.byKey(const Key('multi_scheme_tab_1')));
      await tester.pumpAndSettle();

      // Button amount updates to Kitty #2's due amount (₹2,000)
      expect(find.text('PAY SELECTED (₹2,000)'), findsOneWidget);
    });

    testWidgets('6. Empty state: Renders No Active Gold Scheme when hasActiveScheme is false',
        (WidgetTester tester) async {
      mockRepo.setHasActiveScheme(false);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(KittyEmptyState), findsOneWidget);
      expect(find.text('No Active Gold Scheme'), findsOneWidget);
      expect(find.text('EXPLORE SCHEMES'), findsOneWidget);
    });

    testWidgets('7. Error state: Renders error state and recovers upon tapping Try Again',
        (WidgetTester tester) async {
      mockRepo.setShouldThrow(true);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(KittyErrorState), findsOneWidget);
      expect(find.text('Unable to Load Scheme Details'), findsOneWidget);

      // Recover
      mockRepo.setShouldThrow(false);
      await tester.tap(find.text('TRY AGAIN'));
      await tester.pumpAndSettle();

      expect(find.byType(DashboardMultiSchemeCarousel), findsOneWidget);
    });
  });
}
