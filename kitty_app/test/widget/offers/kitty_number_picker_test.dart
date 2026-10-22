import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/features/offers/data/repositories/mock_scheme_repository.dart';
import 'package:kitty_app/features/offers/domain/entities/kitty_slot_entity.dart';
import 'package:kitty_app/features/offers/domain/entities/scheme_entity.dart';
import 'package:kitty_app/features/offers/presentation/widgets/kitty_number_picker_sheet.dart';

void main() {
  group('KittyNumberPickerSheet Widget Tests (Phase 7)', () {
    final MockEngineConfig instantConfig =
        MockEngineConfig(latency: MockLatency.instant);

    final SchemeEntity testScheme = MockSchemeRepository.prototypeSchemes.first;

    Widget buildTestApp({
      required MockSchemeRepository repository,
      required ValueChanged<KittySlotEntity> onNumberSelected,
    }) {
      return ProviderScope(
        overrides: [
          schemeRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: KittyNumberPickerSheet(
              scheme: testScheme,
              onNumberSelected: onNumberSelected,
            ),
          ),
        ),
      );
    }

    testWidgets('1. Renders header, search field, auspicious chips, legend, and 50 slots',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockSchemeRepository repo =
          MockSchemeRepository(engineConfig: instantConfig);

      await tester.pumpWidget(
        buildTestApp(repository: repo, onNumberSelected: (_) {}),
      );
      await tester.pumpAndSettle();

      expect(find.text('CHOOSE LUCKY KITTY NUMBER'), findsOneWidget);
      expect(find.text('Search lucky number (e.g. 7, 21, 51)...'), findsOneWidget);
      expect(find.text('No. 7'), findsOneWidget);
      expect(find.text('No. 21'), findsOneWidget);
      expect(find.text('SELECT A LUCKY NUMBER'), findsOneWidget);

      // Verify numbers rendered in grid
      expect(find.text('01'), findsOneWidget);
      expect(find.text('03'), findsOneWidget);
      expect(find.text('07'), findsOneWidget);
    });

    testWidgets('2. Selecting an available number updates selection and enables CTA',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockSchemeRepository repo =
          MockSchemeRepository(engineConfig: instantConfig);
      KittySlotEntity? selectedResult;

      await tester.pumpWidget(
        buildTestApp(
          repository: repo,
          onNumberSelected: (KittySlotEntity slot) {
            selectedResult = slot;
          },
        ),
      );
      await tester.pumpAndSettle();

      // Tap slot 03 (available)
      await tester.tap(find.text('03'));
      await tester.pumpAndSettle();

      // Check selection state
      expect(find.text('🔒 Held 15 Mins'), findsOneWidget);
      expect(find.text('CONTINUE WITH NUMBER 3 →'), findsOneWidget);

      // Tap continue button
      await tester.tap(find.text('CONTINUE WITH NUMBER 3 →'));
      await tester.pumpAndSettle();

      expect(selectedResult, isNotNull);
      expect(selectedResult!.number, equals(3));
      expect(selectedResult!.tokenString, equals('#SW-003'));
    });

    testWidgets('3. Tapping a booked number shows error snackbar and refuses selection',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockSchemeRepository repo =
          MockSchemeRepository(engineConfig: instantConfig);

      await tester.pumpWidget(
        buildTestApp(repository: repo, onNumberSelected: (_) {}),
      );
      await tester.pumpAndSettle();

      // Slot 02 is booked in mock
      await tester.tap(find.text('02'));
      await tester.pumpAndSettle();

      expect(
        find.text('Kitty Number #02 is already booked by another patron.'),
        findsOneWidget,
      );
      expect(find.text('SELECT A LUCKY NUMBER'), findsOneWidget);
    });

    testWidgets('4. Searching for number filters grid slots in real time',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockSchemeRepository repo =
          MockSchemeRepository(engineConfig: instantConfig);

      await tester.pumpWidget(
        buildTestApp(repository: repo, onNumberSelected: (_) {}),
      );
      await tester.pumpAndSettle();

      // Search for "42"
      await tester.enterText(
        find.byType(TextField),
        '42',
      );
      await tester.pumpAndSettle();

      // Slot 42 and textfield text should both be present, but 01 filtered out
      expect(find.text('42'), findsNWidgets(2));
      expect(find.text('01'), findsNothing);
    });

    testWidgets('5. Tapping auspicious chip filters and selects lucky number',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockSchemeRepository repo =
          MockSchemeRepository(engineConfig: instantConfig);

      await tester.pumpWidget(
        buildTestApp(repository: repo, onNumberSelected: (_) {}),
      );
      await tester.pumpAndSettle();

      // Tap auspicious "No. 9" chip
      await tester.tap(find.text('No. 9'));
      await tester.pumpAndSettle();

      expect(find.text('CONTINUE WITH NUMBER 9 →'), findsOneWidget);
    });

    testWidgets('6. Renders error state and recovers upon tapping Try Again',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockSchemeRepository repo =
          MockSchemeRepository(engineConfig: instantConfig);
      repo.setShouldThrow(true);

      await tester.pumpWidget(
        buildTestApp(repository: repo, onNumberSelected: (_) {}),
      );
      await tester.pumpAndSettle();

      expect(find.text('Unable to Load Kitty Numbers'), findsOneWidget);
      expect(find.text('TRY AGAIN'), findsOneWidget);

      repo.setShouldThrow(false);
      await tester.tap(find.text('TRY AGAIN'));
      await tester.pumpAndSettle();

      expect(find.text('01'), findsOneWidget);
    });
  });
}
