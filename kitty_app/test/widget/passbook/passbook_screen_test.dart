import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/features/passbook/data/repositories/mock_passbook_repository.dart';
import 'package:kitty_app/features/passbook/presentation/screens/passbook_screen.dart';
import 'package:kitty_app/features/passbook/presentation/widgets/passbook_cards_list.dart';
import 'package:kitty_app/features/passbook/presentation/widgets/passbook_perks_dialog.dart';
import 'package:kitty_app/features/passbook/presentation/widgets/passbook_timeline_table.dart';
import 'package:kitty_app/shared/widgets/feedback/kitty_empty_state.dart';

void main() {
  final MockEngineConfig instantConfig = MockEngineConfig(latency: MockLatency.instant);

  Widget buildTestApp({
    required MockPassbookRepository repository,
  }) {
    return ProviderScope(
      overrides: [
        passbookRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(
        home: PassbookScreen(),
      ),
    );
  }

  group('PassbookScreen Widget Tests', () {
    testWidgets('1. Fully renders loaded Passbook screen with Table View and Summary Strip', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockPassbookRepository repository =
          MockPassbookRepository(engineConfig: instantConfig);

      await tester.pumpWidget(buildTestApp(repository: repository));
      await tester.pumpAndSettle();

      // Section Title
      expect(find.text('Passbook Ledger'), findsOneWidget);
      expect(find.text('12-Month Timeline'), findsOneWidget);

      // Chit Token
      expect(find.text('#SW-042'), findsOneWidget);

      // View Switcher
      expect(find.text('Table View'), findsOneWidget);
      expect(find.text('Card View'), findsOneWidget);

      // Summary Strip Pillars
      expect(find.byKey(const Key('summary_paid_count')), findsOneWidget);
      expect(find.text('8 / 12'), findsOneWidget);
      expect(find.byKey(const Key('summary_total_paid')), findsOneWidget);
      expect(find.text('₹40,000'), findsOneWidget);
      expect(find.byKey(const Key('summary_gold_acc')), findsOneWidget);
      expect(find.text('5.482 g'), findsOneWidget);

      // Table View rendered
      expect(find.byType(PassbookTimelineTable), findsOneWidget);
      expect(find.text('INSTALLMENT'), findsOneWidget);
      expect(find.text('AMOUNT'), findsOneWidget);
      expect(find.text('24K GOLD'), findsNWidgets(2));
      expect(find.text('Month 1'), findsOneWidget);
      expect(find.text('Month 9'), findsOneWidget);
      expect(find.text('Month 12'), findsOneWidget);
    });

    testWidgets('2. Tapping view switcher toggles between Table View and Card View', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockPassbookRepository repository =
          MockPassbookRepository(engineConfig: instantConfig);

      await tester.pumpWidget(buildTestApp(repository: repository));
      await tester.pumpAndSettle();

      // Initially in Table View
      expect(find.byType(PassbookTimelineTable), findsOneWidget);
      expect(find.byType(PassbookCardsList), findsNothing);

      // Switch to Card View
      await tester.tap(find.text('Card View'));
      await tester.pumpAndSettle();

      expect(find.byType(PassbookCardsList), findsOneWidget);
      expect(find.byType(PassbookTimelineTable), findsNothing);

      // Switch back to Table View
      await tester.tap(find.text('Table View'));
      await tester.pumpAndSettle();

      expect(find.byType(PassbookTimelineTable), findsOneWidget);
      expect(find.byType(PassbookCardsList), findsNothing);
    });

    testWidgets('3. Tapping Perks Info opens PassbookPerksDialog', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockPassbookRepository repository =
          MockPassbookRepository(engineConfig: instantConfig);

      await tester.pumpWidget(buildTestApp(repository: repository));
      await tester.pumpAndSettle();

      // Switch to Card View so Perks Info button is present
      await tester.tap(find.text('Card View'));
      await tester.pumpAndSettle();

      final Finder perksButtonFinder = find.text('Perks Info');
      expect(perksButtonFinder, findsOneWidget);

      await tester.ensureVisible(perksButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(perksButtonFinder);
      await tester.pumpAndSettle();

      // Dialog opens
      expect(find.byType(PassbookPerksDialog), findsOneWidget);
      expect(find.text('100% Jeweler Bonus Deposit'), findsOneWidget);
      expect(find.text('UNDERSTOOD'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('UNDERSTOOD'));
      await tester.pumpAndSettle();
      expect(find.byType(PassbookPerksDialog), findsNothing);
    });

    testWidgets('4. In Card View, transaction ID tap copies to clipboard with SnackBar', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockPassbookRepository repository =
          MockPassbookRepository(engineConfig: instantConfig);

      await tester.pumpWidget(buildTestApp(repository: repository));
      await tester.pumpAndSettle();

      // Switch to Card View
      await tester.tap(find.text('Card View'));
      await tester.pumpAndSettle();

      final Finder txnFinder = find.text('Txn: TXN-SW-10821');
      expect(txnFinder, findsOneWidget);

      await tester.tap(txnFinder);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('TXN-SW-10821 copied'), findsOneWidget);
    });

    testWidgets('5. Renders Empty State when no active scheme exists', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockPassbookRepository repository =
          MockPassbookRepository(engineConfig: instantConfig);
      repository.setHasActiveScheme(false);

      await tester.pumpWidget(buildTestApp(repository: repository));
      await tester.pumpAndSettle();

      expect(find.byType(KittyEmptyState), findsOneWidget);
      expect(find.text('No Active Passbook Ledger'), findsOneWidget);
      expect(find.text('EXPLORE SCHEMES'), findsOneWidget);
    });

    testWidgets('6. Renders Error State and recovers upon tapping Try Again', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockPassbookRepository repository =
          MockPassbookRepository(engineConfig: instantConfig);
      repository.setShouldThrow(true);

      await tester.pumpWidget(buildTestApp(repository: repository));
      await tester.pumpAndSettle();

      expect(find.text('Unable to Load Passbook'), findsOneWidget);
      expect(find.text('TRY AGAIN'), findsOneWidget);

      // Now resolve failure and tap Try Again
      repository.setShouldThrow(false);
      await tester.tap(find.text('TRY AGAIN'));
      await tester.pumpAndSettle();

      expect(find.text('Passbook Ledger'), findsOneWidget);
      expect(find.byType(PassbookTimelineTable), findsOneWidget);
    });
  });
}
