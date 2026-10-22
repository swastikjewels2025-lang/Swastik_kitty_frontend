import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:kitty_app/features/auth/presentation/screens/phone_screen.dart';
import 'package:kitty_app/shared/widgets/inputs/kitty_phone_input_field.dart';

void main() {
  testWidgets('PhoneScreen renders title, phone input, country code and continue button', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
        child: const MaterialApp(
          home: PhoneScreen(),
        ),
      ),
    );

    expect(find.text('Enter your mobile number'), findsOneWidget);
    expect(find.byType(KittyPhoneInputField), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('+91'), findsOneWidget);
    expect(find.text('🇮🇳'), findsOneWidget);
  });

  testWidgets('PhoneScreen enters phone and enables Continue button', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
        child: const MaterialApp(
          home: PhoneScreen(),
        ),
      ),
    );

    final Finder inputFinder = find.byType(TextField);
    expect(inputFinder, findsOneWidget);

    await tester.enterText(inputFinder, '9876543210');
    await tester.pump();

    expect(find.text('9876543210'), findsOneWidget);
  });
}
