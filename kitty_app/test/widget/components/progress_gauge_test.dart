import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/shared/widgets/progress/kitty_circular_progress_gauge.dart';

void main() {
  group('KittyCircularProgressGauge Widget Tests', () {
    testWidgets('renders fraction and percentage text for partial progress',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KittyCircularProgressGauge(
              currentValue: 8,
              totalValue: 12,
              subtitle: '4 to Pay • 1 Bonus Free',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('8 / 12'), findsOneWidget);
      expect(find.text('67%'), findsOneWidget);
      expect(find.text('4 to Pay • 1 Bonus Free'), findsOneWidget);
    });

    testWidgets('handles zero progress gracefully without crashing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KittyCircularProgressGauge(
              currentValue: 0,
              totalValue: 12,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('0 / 12'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('handles completed 100% progress boundary',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KittyCircularProgressGauge(
              currentValue: 12,
              totalValue: 12,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('12 / 12'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('handles invalid/zero total boundary safely',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KittyCircularProgressGauge(
              currentValue: 0,
              totalValue: 0,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('0 / 0'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
    });
  });
}
