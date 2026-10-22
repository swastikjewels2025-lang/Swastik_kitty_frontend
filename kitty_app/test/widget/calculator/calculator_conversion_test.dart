import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/features/calculator/presentation/screens/calculator_screen.dart';
import 'package:kitty_app/shared/widgets/navigation/kitty_hamburger_button.dart';

void main() {
  group('Dedicated Calculator Screen Tests (Requirement 11 - Live Rate Calculator parity)', () {
    late MockEngineConfig instantConfig;

    setUp(() {
      instantConfig = MockEngineConfig(latency: MockLatency.instant);
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          mockEngineConfigProvider.overrideWithValue(instantConfig),
        ],
        child: const MaterialApp(
          home: CalculatorScreen(),
        ),
      );
    }

    testWidgets('1. Renders title, hamburger, metal switcher, purity, and input fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify title & hamburger button
      expect(find.text('Calculator'), findsWidgets);
      expect(find.byType(KittyHamburgerButton), findsOneWidget);

      // Verify metal switcher (Gold / Silver)
      expect(find.text('Gold'), findsOneWidget);
      expect(find.text('Silver'), findsOneWidget);

      // Verify purity and unit selectors
      expect(find.text('24K (999)'), findsOneWidget);
      expect(find.text('g'), findsWidgets);
      expect(find.text('kg'), findsOneWidget);

      // Verify Calculate button
      expect(find.text('Calculate'), findsOneWidget);
    });

    testWidgets('2. Entering weight with 3-decimal precision recalculates estimated value',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter 5.482 grams
      final Finder weightField = find.byType(TextField).first;
      await tester.enterText(weightField, '5.482');
      await tester.pumpAndSettle();

      // Verify estimated value card updates
      expect(find.text('Estimated Value'), findsOneWidget);
      expect(find.textContaining('5.482 g'), findsOneWidget);
    });

    testWidgets('3. Tapping Calculate triggers confirmation feedback',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final Finder calcBtn = find.text('Calculate');
      await tester.tap(calcBtn);
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Calculated Value:'), findsOneWidget);
    });
  });
}
