import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/shared/widgets/dialogs/kitty_confirm_dialog.dart';
import 'package:kitty_app/shared/widgets/dialogs/kitty_dialog.dart';
import 'package:kitty_app/shared/widgets/sheets/kitty_bottom_sheet.dart';

void main() {
  group('KittyDialog Widget Tests', () {
    testWidgets('renders modal dialog content and responds to close button',
        (WidgetTester tester) async {
      bool closed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KittyDialog(
              title: 'Digital Receipt',
              subtitle: 'Tax Invoice',
              onClose: () => closed = true,
              child: const Text('Receipt Details Body'),
            ),
          ),
        ),
      );

      expect(find.text('Digital Receipt'), findsOneWidget);
      expect(find.text('Tax Invoice'), findsOneWidget);
      expect(find.text('Receipt Details Body'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(closed, isTrue);
    });
  });

  group('KittyConfirmDialog Widget Tests', () {
    testWidgets('triggers confirm callback on Confirm tap',
        (WidgetTester tester) async {
      bool confirmed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KittyConfirmDialog(
              title: 'Discard Changes?',
              message: 'Are you sure you want to discard unsaved edits?',
              confirmLabel: 'Discard',
              onConfirm: () => confirmed = true,
            ),
          ),
        ),
      );

      expect(find.text('Discard Changes?'), findsOneWidget);
      expect(find.text('Are you sure you want to discard unsaved edits?'), findsOneWidget);
      expect(find.text('DISCARD'), findsOneWidget);

      await tester.tap(find.text('DISCARD'));
      await tester.pumpAndSettle();

      expect(confirmed, isTrue);
    });
  });

  group('KittyBottomSheet Widget Tests', () {
    testWidgets('renders bottom sheet container with title and child',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KittyBottomSheet(
              title: 'Payment Method',
              subtitle: 'Select UPI or Card',
              child: Text('Sheet Child Content'),
            ),
          ),
        ),
      );

      expect(find.text('Payment Method'), findsOneWidget);
      expect(find.text('Select UPI or Card'), findsOneWidget);
      expect(find.text('Sheet Child Content'), findsOneWidget);
    });
  });
}
