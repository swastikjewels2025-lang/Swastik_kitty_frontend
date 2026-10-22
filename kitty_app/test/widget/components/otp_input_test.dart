import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/shared/widgets/inputs/kitty_otp_input.dart';

void main() {
  group('KittyOtpInput Widget Tests', () {
    testWidgets('renders 6 segmented digit boxes by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KittyOtpInput(),
          ),
        ),
      );

      expect(find.byType(TextField), findsNWidgets(6));
    });

    testWidgets('triggers onCompleted when all 6 digits are entered',
        (WidgetTester tester) async {
      String completedPin = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KittyOtpInput(
              onCompleted: (String pin) => completedPin = pin,
            ),
          ),
        ),
      );

      final Finder textFields = find.byType(TextField);
      for (int i = 0; i < 6; i++) {
        await tester.enterText(textFields.at(i), '${i + 1}');
      }
      await tester.pumpAndSettle();

      expect(completedPin, equals('123456'));
    });

    testWidgets('programmatically sets full OTP code via GlobalKey / state',
        (WidgetTester tester) async {
      final GlobalKey<KittyOtpInputState> key = GlobalKey<KittyOtpInputState>();
      String currentCode = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KittyOtpInput(
              key: key,
              onChanged: (String code) => currentCode = code,
            ),
          ),
        ),
      );

      key.currentState?.setOtp('984210');
      await tester.pumpAndSettle();

      expect(currentCode, equals('984210'));
      expect(key.currentState?.currentCode, equals('984210'));
    });

    testWidgets('clears all digits on clear() call',
        (WidgetTester tester) async {
      final GlobalKey<KittyOtpInputState> key = GlobalKey<KittyOtpInputState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KittyOtpInput(key: key),
          ),
        ),
      );

      key.currentState?.setOtp('123456');
      await tester.pumpAndSettle();
      expect(key.currentState?.currentCode, equals('123456'));

      key.currentState?.clear();
      await tester.pumpAndSettle();
      expect(key.currentState?.currentCode, equals(''));
    });
  });
}
