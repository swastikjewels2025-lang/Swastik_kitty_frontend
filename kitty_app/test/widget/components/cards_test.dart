import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/shared/widgets/cards/kitty_card.dart';
import 'package:kitty_app/shared/widgets/cards/kitty_luxury_emerald_card.dart';
import 'package:kitty_app/shared/widgets/cards/kitty_stat_card.dart';

void main() {
  group('KittyCard Widget Tests', () {
    testWidgets('renders child content and responds to onTap',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KittyCard(
              onTap: () => tapped = true,
              child: const Text('Sample Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Sample Card Content'), findsOneWidget);
      await tester.tap(find.text('Sample Card Content'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('renders luxury emerald variant', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KittyCard(
              variant: KittyCardVariant.emeraldDark,
              child: Text('Emerald Card'),
            ),
          ),
        ),
      );

      expect(find.text('Emerald Card'), findsOneWidget);
    });
  });

  group('KittyLuxuryEmeraldCard Widget Tests', () {
    testWidgets('renders hero child content with gradient surface',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KittyLuxuryEmeraldCard(
              child: Text('Active Suvarna Scheme'),
            ),
          ),
        ),
      );

      expect(find.text('Active Suvarna Scheme'), findsOneWidget);
    });
  });

  group('KittyStatCard Widget Tests', () {
    testWidgets('renders label, value, delta and responds to tap',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KittyStatCard(
              icon: const Icon(Icons.wallet),
              label: 'Scheme Target',
              value: '₹60,000',
              deltaText: '+2.59%',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('SCHEME TARGET'), findsOneWidget);
      expect(find.text('₹60,000'), findsOneWidget);
      expect(find.text('+2.59%'), findsOneWidget);
      expect(find.byIcon(Icons.wallet), findsOneWidget);

      await tester.tap(find.byType(KittyStatCard));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });
}
