import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/core/utils/currency_formatter.dart';
import 'package:kitty_app/features/offers/data/repositories/mock_scheme_repository.dart';
import 'package:kitty_app/features/offers/domain/entities/scheme_entity.dart';
import 'package:kitty_app/features/offers/presentation/widgets/start_kitty_flow_sheet.dart';

void main() {
  group('StartKittyFlowSheet Guided Enrollment Tests (Phase 8)', () {
    final MockEngineConfig instantConfig =
        MockEngineConfig(latency: MockLatency.instant);

    final SchemeEntity testScheme = MockSchemeRepository.prototypeSchemes.first;

    Widget buildTestApp({
      required MockSchemeRepository repository,
      ValueChanged<Map<String, dynamic>>? onCompleted,
    }) {
      return ProviderScope(
        overrides: [
          schemeRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: StartKittyFlowSheet(
              scheme: testScheme,
              onCompleted: onCompleted,
            ),
          ),
        ),
      );
    }

    testWidgets('1. Step 1: Renders plan summary, amount pills, and 11+1 math preview',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockSchemeRepository repo =
          MockSchemeRepository(engineConfig: instantConfig);

      await tester.pumpWidget(
        buildTestApp(repository: repo),
      );
      await tester.pumpAndSettle();

      expect(find.text('Step 1: Customize Your Plan'), findsOneWidget);
      expect(find.text(testScheme.name), findsNWidgets(2));
      expect(find.text('Select Monthly Contribution'), findsOneWidget);
      expect(find.text('YOUR 11+1 SAVINGS BENEFIT'), findsOneWidget);
      expect(find.text('CONTINUE TO NUMBER SELECTION →'), findsOneWidget);
    });

    testWidgets('2. Step 1: Selecting amount preset updates 11+1 math calculations',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockSchemeRepository repo =
          MockSchemeRepository(engineConfig: instantConfig);

      await tester.pumpWidget(
        buildTestApp(repository: repo),
      );
      await tester.pumpAndSettle();

      // Tap ₹2,000 preset pill
      await tester.tap(find.text('₹2,000'));
      await tester.pumpAndSettle();

      // For 12 months with 2,000:
      // Customer: 11 x 2,000 = 22,000
      // Bonus: 1 x 2,000 = 2,000
      // Maturity: 24,000
      expect(find.text('₹22,000'), findsOneWidget);
      expect(find.text('+ ₹2,000'), findsOneWidget);
      expect(find.text('₹24,000'), findsOneWidget);
    });

    testWidgets('3. Step 1 -> Step 2: Next button advances to 50-slot Kitty Number selection',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockSchemeRepository repo =
          MockSchemeRepository(engineConfig: instantConfig);

      await tester.pumpWidget(
        buildTestApp(repository: repo),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('CONTINUE TO NUMBER SELECTION →'));
      await tester.pumpAndSettle();

      expect(find.text('Step 2: Choose Kitty Number'), findsOneWidget);
      expect(find.text('Search lucky number (e.g. 7, 21, 51)...'), findsOneWidget);
      expect(find.text('01'), findsOneWidget);
      expect(find.text('SELECT A LUCKY NUMBER'), findsOneWidget);
    });

    testWidgets('4. Step 2 -> Back button returns to Step 1 preserving customized amount',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockSchemeRepository repo =
          MockSchemeRepository(engineConfig: instantConfig);

      await tester.pumpWidget(
        buildTestApp(repository: repo),
      );
      await tester.pumpAndSettle();

      // Select ₹3,000
      await tester.tap(find.text('₹3,000'));
      await tester.pumpAndSettle();

      // Go to Step 2
      await tester.tap(find.text('CONTINUE TO NUMBER SELECTION →'));
      await tester.pumpAndSettle();
      expect(find.text('Step 2: Choose Kitty Number'), findsOneWidget);

      // Tap Back button
      await tester.tap(find.byTooltip('Go Back'));
      await tester.pumpAndSettle();

      // Back on Step 1, amount is preserved
      expect(find.text('Step 1: Customize Your Plan'), findsOneWidget);
      expect(find.text('₹33,000'), findsOneWidget);
      expect(find.text('₹36,000'), findsOneWidget);
    });

    testWidgets('5. Step 2 -> Step 3: Selecting slot enables Review & Confirm button and moves to Step 3',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockSchemeRepository repo =
          MockSchemeRepository(engineConfig: instantConfig);

      await tester.pumpWidget(
        buildTestApp(repository: repo),
      );
      await tester.pumpAndSettle();

      // Advance to Step 2
      await tester.tap(find.text('CONTINUE TO NUMBER SELECTION →'));
      await tester.pumpAndSettle();

      // Tap slot 03
      await tester.tap(find.text('03'));
      await tester.pumpAndSettle();

      expect(find.text('REVIEW & CONFIRM (NUMBER 3) →'), findsOneWidget);

      // Advance to Step 3
      await tester.tap(find.text('REVIEW & CONFIRM (NUMBER 3) →'));
      await tester.pumpAndSettle();

      expect(find.text('Step 3: Review & Confirm'), findsOneWidget);
      expect(find.text('First Installment (Month 1)'), findsOneWidget);
      expect(find.text('PROCEED TO PAY MONTH 1 (${CurrencyFormatter.formatRupees(testScheme.monthlyInstallment)}) →'), findsOneWidget);
    });

    testWidgets('6. Step 3 -> Back button returns to Step 2 preserving selected slot',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockSchemeRepository repo =
          MockSchemeRepository(engineConfig: instantConfig);

      await tester.pumpWidget(
        buildTestApp(repository: repo),
      );
      await tester.pumpAndSettle();

      // Step 1 -> Step 2
      await tester.tap(find.text('CONTINUE TO NUMBER SELECTION →'));
      await tester.pumpAndSettle();

      // Select slot 03
      await tester.tap(find.text('03'));
      await tester.pumpAndSettle();

      // Step 2 -> Step 3
      await tester.tap(find.text('REVIEW & CONFIRM (NUMBER 3) →'));
      await tester.pumpAndSettle();
      expect(find.text('Step 3: Review & Confirm'), findsOneWidget);

      // Tap Back to Step 2
      await tester.tap(find.byTooltip('Go Back'));
      await tester.pumpAndSettle();

      expect(find.text('Step 2: Choose Kitty Number'), findsOneWidget);
      expect(find.text('REVIEW & CONFIRM (NUMBER 3) →'), findsOneWidget);
    });

    testWidgets('7. Step 3: Submitting enrollment triggers repository and executes completion callback',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockSchemeRepository repo =
          MockSchemeRepository(engineConfig: instantConfig);
      Map<String, dynamic>? completionResult;

      await tester.pumpWidget(
        buildTestApp(
          repository: repo,
          onCompleted: (res) {
            completionResult = res;
          },
        ),
      );
      await tester.pumpAndSettle();

      // Step 1 -> Step 2
      await tester.tap(find.text('CONTINUE TO NUMBER SELECTION →'));
      await tester.pumpAndSettle();

      // Select slot 03
      await tester.tap(find.text('03'));
      await tester.pumpAndSettle();

      // Step 2 -> Step 3
      await tester.tap(find.text('REVIEW & CONFIRM (NUMBER 3) →'));
      await tester.pumpAndSettle();

      // Submit enrollment
      final Finder submitFinder = find.text('PROCEED TO PAY MONTH 1 (${CurrencyFormatter.formatRupees(testScheme.monthlyInstallment)}) →');
      expect(submitFinder, findsOneWidget);
      await tester.tap(submitFinder);
      await tester.pumpAndSettle();

      expect(completionResult, isNotNull);
      expect(completionResult!['success'], isTrue);
      expect(completionResult!['slotNumber'], equals(3));
      expect(completionResult!['monthlyAmount'], equals(testScheme.monthlyInstallment));
    });
  });
}
