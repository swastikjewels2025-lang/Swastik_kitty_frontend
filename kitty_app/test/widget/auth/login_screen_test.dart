import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/features/auth/presentation/screens/login_screen.dart';

void main() {
  testWidgets('LoginScreen renders brand header, Google button, OR divider, and Mobile trigger matching login.html', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Initial View 0 elements
    await tester.pump(const Duration(milliseconds: 850)); // let entrance animation complete

    expect(find.text('Sign in to continue'), findsOneWidget);
    expect(find.text('Continue with Instagram'), findsOneWidget);
    expect(find.text('OR'), findsOneWidget);
    expect(find.text('Continue with Mobile'), findsOneWidget);
    expect(find.textContaining('Protected by bank-grade 256-bit encryption'), findsOneWidget);

    // Tap "Continue with mobile number" -> navigates to View 1
    await tester.tap(find.text('Continue with Mobile'));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Enter your mobile number'), findsOneWidget);
    expect(find.text('We will send a 6-digit OTP to verify your identity'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);

    // Tap "Back" -> navigates back to View 0
    await tester.tap(find.text('Back'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Continue with Instagram'), findsOneWidget);
  });

  testWidgets('LoginScreen View 2 renders OTP step with 6 boxes and change number', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(initialStep: LoginStep.otp),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 850));

    expect(find.text('Verify your number'), findsOneWidget);
    expect(find.text('Enter the OTP sent to '), findsOneWidget);
    expect(find.text('Change Number'), findsOneWidget);
    expect(find.text('Verify & Continue'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(6)); // 6 OTP digit boxes

    // Tap Change Number -> goes to phone view
    await tester.tap(find.text('Change Number'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Enter your mobile number'), findsOneWidget);
  });

  testWidgets('LoginScreen View 3 renders success state with patron greeting and enter button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(initialStep: LoginStep.success),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 850));

    expect(find.textContaining('Welcome Back'), findsOneWidget);
    expect(find.text('Tier 1 Verified Member'), findsOneWidget);
    expect(find.text('Accessing your gold schemes and bullion vault...'), findsOneWidget);
    expect(find.text('Enter Gold Vault'), findsOneWidget);
  });

  testWidgets('LoginScreen renders cleanly without overflow on small screen (320x568)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 850));

    expect(find.text('Sign in to continue'), findsOneWidget);
    expect(find.text('Continue with Instagram'), findsOneWidget);
    expect(find.text('Continue with Mobile'), findsOneWidget);

    // Navigate to phone view on small screen
    await tester.tap(find.text('Continue with Mobile'));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Enter your mobile number'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}
