import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/shared/widgets/feedback/kitty_empty_state.dart';
import 'package:kitty_app/shared/widgets/feedback/kitty_error_state.dart';
import 'package:kitty_app/shared/widgets/feedback/kitty_loading_indicator.dart';
import 'package:kitty_app/shared/widgets/feedback/kitty_toast.dart';

void main() {
  group('KittyEmptyState Widget Tests', () {
    testWidgets('renders title, description and triggers action button',
        (WidgetTester tester) async {
      bool actionTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KittyEmptyState(
              title: 'No Active Kitty Schemes',
              description: 'Enroll in our luxury gold savings scheme today.',
              actionLabel: 'Explore Offers',
              onAction: () => actionTriggered = true,
            ),
          ),
        ),
      );

      expect(find.text('No Active Kitty Schemes'), findsOneWidget);
      expect(find.text('Enroll in our luxury gold savings scheme today.'), findsOneWidget);
      expect(find.text('EXPLORE OFFERS'), findsOneWidget);

      await tester.tap(find.text('EXPLORE OFFERS'));
      await tester.pumpAndSettle();

      expect(actionTriggered, isTrue);
    });
  });

  group('KittyErrorState Widget Tests', () {
    testWidgets('renders error message and triggers retry callback',
        (WidgetTester tester) async {
      bool retryTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KittyErrorState(
              message: 'Network connection lost. Please check internet.',
              onRetry: () => retryTriggered = true,
            ),
          ),
        ),
      );

      expect(find.text('Network connection lost. Please check internet.'), findsOneWidget);
      expect(find.text('TRY AGAIN'), findsOneWidget);

      await tester.tap(find.text('TRY AGAIN'));
      await tester.pumpAndSettle();

      expect(retryTriggered, isTrue);
    });
  });

  group('KittyLoadingIndicator Widget Tests', () {
    testWidgets('renders spinner and jewel loaders without crashing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: <Widget>[
                KittyLoadingIndicator(type: KittyLoadingType.spinner),
                KittyLoadingIndicator(type: KittyLoadingType.jewel),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.diamond_outlined), findsOneWidget);
    });
  });

  group('KittyToast Widget Tests', () {
    testWidgets('renders toast message and responds to action callback',
        (WidgetTester tester) async {
      bool actionTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KittyToast(
              message: 'Installment payment completed successfully',
              type: KittyToastType.success,
              actionLabel: 'View Receipt',
              onAction: () => actionTriggered = true,
            ),
          ),
        ),
      );

      expect(find.text('Installment payment completed successfully'), findsOneWidget);
      expect(find.text('VIEW RECEIPT'), findsOneWidget);

      await tester.tap(find.text('VIEW RECEIPT'));
      await tester.pumpAndSettle();

      expect(actionTriggered, isTrue);
    });
  });
}
