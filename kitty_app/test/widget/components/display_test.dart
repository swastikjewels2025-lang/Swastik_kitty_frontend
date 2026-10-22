import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/shared/widgets/display/kitty_avatar.dart';
import 'package:kitty_app/shared/widgets/display/kitty_divider.dart';
import 'package:kitty_app/shared/widgets/display/kitty_dropzone.dart';
import 'package:kitty_app/shared/widgets/display/kitty_label_value_row.dart';
import 'package:kitty_app/shared/widgets/display/kitty_section_header.dart';

void main() {
  group('KittyAvatar Widget Tests', () {
    testWidgets('renders fallback initials when no image is provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KittyAvatar(initials: 'RS'),
          ),
        ),
      );

      expect(find.text('RS'), findsOneWidget);
    });
  });

  group('KittySectionHeader Widget Tests', () {
    testWidgets('renders title, eyebrow, and responds to action link',
        (WidgetTester tester) async {
      bool actionTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KittySectionHeader(
              title: 'Passbook Ledger',
              eyebrow: 'Installments',
              actionLabel: 'View All',
              onAction: () => actionTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Passbook Ledger'), findsOneWidget);
      expect(find.text('INSTALLMENTS'), findsOneWidget);
      expect(find.text('View All'), findsOneWidget);

      await tester.tap(find.text('View All'));
      await tester.pumpAndSettle();

      expect(actionTapped, isTrue);
    });
  });

  group('KittyLabelValueRow Widget Tests', () {
    testWidgets('renders label and value strings',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KittyLabelValueRow(
              label: 'Monthly EMI',
              value: '₹5,000',
            ),
          ),
        ),
      );

      expect(find.text('Monthly EMI'), findsOneWidget);
      expect(find.text('₹5,000'), findsOneWidget);
    });
  });

  group('KittyDivider Widget Tests', () {
    testWidgets('renders divider with optional center label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KittyDivider(label: 'OR'),
          ),
        ),
      );

      expect(find.text('OR'), findsOneWidget);
    });
  });

  group('KittyDropzone Widget Tests', () {
    testWidgets('renders empty dropzone with action triggers',
        (WidgetTester tester) async {
      bool photoTapped = false;
      bool fileTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KittyDropzone(
              onTakePhoto: () => photoTapped = true,
              onChooseFile: () => fileTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Upload Document'), findsOneWidget);
      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Choose File'), findsOneWidget);

      await tester.tap(find.text('Take Photo'));
      await tester.pumpAndSettle();
      expect(photoTapped, isTrue);

      await tester.tap(find.text('Choose File'));
      await tester.pumpAndSettle();
      expect(fileTapped, isTrue);
    });

    testWidgets('renders selected file preview state with remove button',
        (WidgetTester tester) async {
      bool removeTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KittyDropzone(
              selectedFileName: 'aadhaar_front.jpg',
              selectedFileSize: '2.4 MB',
              onRemoveFile: () => removeTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('aadhaar_front.jpg'), findsOneWidget);
      expect(find.text('2.4 MB'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(removeTapped, isTrue);
    });
  });
}
