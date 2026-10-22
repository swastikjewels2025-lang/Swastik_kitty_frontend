import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/features/auth/presentation/screens/auth_success_screen.dart';

void main() {
  testWidgets('AuthSuccessScreen renders welcome greeting, tier chip, and Enter button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AuthSuccessScreen(),
        ),
      ),
    );

    expect(find.textContaining('Welcome Back'), findsOneWidget);
    expect(find.text('Tier 1 Verified Member'), findsOneWidget);
    expect(find.text('Accessing your gold schemes and bullion vault...'), findsOneWidget);
    expect(find.text('Enter Gold Vault'), findsOneWidget);
  });
}
