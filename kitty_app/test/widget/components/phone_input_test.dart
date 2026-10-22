import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/shared/widgets/inputs/kitty_phone_input_field.dart';

void main() {
  group('KittyPhoneInputField Widget Tests', () {
    testWidgets('renders country code and allows phone number entry',
        (WidgetTester tester) async {
      String phone = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KittyPhoneInputField(
              countryCode: '+91',
              countryFlag: '🇮🇳',
              onChanged: (String val) => phone = val,
            ),
          ),
        ),
      );

      expect(find.text('+91'), findsOneWidget);
      expect(find.text('🇮🇳'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '9876543210');
      await tester.pumpAndSettle();

      expect(phone, equals('9876543210'));
    });

    testWidgets('limits phone input to 10 digits and numbers only',
        (WidgetTester tester) async {
      String phone = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KittyPhoneInputField(
              onChanged: (String val) => phone = val,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '9876543210999abc');
      await tester.pumpAndSettle();

      expect(phone, equals('9876543210'));
    });

    testWidgets('triggers onCountryCodeTap when country pill is tapped',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KittyPhoneInputField(
              onCountryCodeTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('+91'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('displays errorText when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KittyPhoneInputField(
              errorText: 'Enter a valid 10-digit mobile number',
            ),
          ),
        ),
      );

      expect(find.text('Enter a valid 10-digit mobile number'), findsOneWidget);
    });
  });
}
