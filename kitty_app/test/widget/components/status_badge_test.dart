import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/shared/widgets/badges/kitty_chit_token_pill.dart';
import 'package:kitty_app/shared/widgets/badges/kitty_status_badge.dart';

void main() {
  group('KittyStatusBadge Widget Tests', () {
    testWidgets('renders PAID status badge with uppercase text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KittyStatusBadge(status: KittyInstallmentStatus.paid),
          ),
        ),
      );

      expect(find.text('PAID'), findsOneWidget);
    });

    testWidgets('renders CURRENT, BONUS, and ACTIVE statuses',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: <Widget>[
                KittyStatusBadge(status: KittyInstallmentStatus.current),
                KittyStatusBadge(status: KittyInstallmentStatus.bonus),
                KittyStatusBadge(status: KittyInstallmentStatus.active),
              ],
            ),
          ),
        ),
      );

      expect(find.text('CURRENT'), findsOneWidget);
      expect(find.text('100% BONUS'), findsOneWidget);
      expect(find.text('ACTIVE KITTY'), findsOneWidget);
    });

    testWidgets('renders semantic slot statuses: AVAILABLE, SELECTED, BOOKED, RESERVED',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: <Widget>[
                KittyStatusBadge(status: KittyInstallmentStatus.available),
                KittyStatusBadge(status: KittyInstallmentStatus.selected),
                KittyStatusBadge(status: KittyInstallmentStatus.booked),
                KittyStatusBadge(status: KittyInstallmentStatus.reserved),
              ],
            ),
          ),
        ),
      );

      expect(find.text('AVAILABLE'), findsOneWidget);
      expect(find.text('SELECTED'), findsOneWidget);
      expect(find.text('BOOKED'), findsOneWidget);
      expect(find.text('RESERVED'), findsOneWidget);
    });

    testWidgets('renders custom status badge with custom label and icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KittyStatusBadge(
              status: KittyInstallmentStatus.custom,
              customLabel: 'SPECIAL VIP',
              customIcon: Icon(Icons.star, size: 12),
            ),
          ),
        ),
      );

      expect(find.text('SPECIAL VIP'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });

  group('KittyChitTokenPill Widget Tests', () {
    testWidgets('renders chit token string correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KittyChitTokenPill(token: '#SW-042'),
          ),
        ),
      );

      expect(find.text('#SW-042'), findsOneWidget);
      expect(find.byIcon(Icons.tag), findsOneWidget);
    });
  });
}
