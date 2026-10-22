import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/features/auth/presentation/screens/onboarding_choice_screen.dart';
import 'package:kitty_app/shared/widgets/dialogs/edit_profile_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('OnboardingChoiceScreen renders top-left logo and top-right profile icon, no Welcome heading', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: OnboardingChoiceScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Welcome heading is REMOVED
    expect(find.text('Welcome to Swastik Jewels'), findsNothing);

    // Verify Swastik logo SVG is present
    expect(find.byType(SvgPicture), findsWidgets);

    // Verify Profile Icon button is present
    expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);

    // Verify the 3 destination cards
    expect(find.text('View Gold Schemes'), findsOneWidget);
    expect(find.text('Shop Jewellery'), findsOneWidget);
    expect(find.text('View Our Instagram'), findsOneWidget);

    // Tap Profile Icon and verify EditProfileDialog opens
    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(EditProfileDialog), findsOneWidget);
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('First Name'), findsOneWidget);
    expect(find.text('Surname'), findsOneWidget);
    expect(find.text('Mobile Number'), findsOneWidget);

    // Verify inputs have no visible borders
    final Finder textFieldFinder = find.byType(TextField);
    expect(textFieldFinder, findsWidgets);

    final TextField firstField = tester.widget<TextField>(textFieldFinder.first);
    expect(firstField.decoration?.border, equals(InputBorder.none));
    expect(firstField.decoration?.enabledBorder, equals(InputBorder.none));
    expect(firstField.decoration?.focusedBorder, equals(InputBorder.none));
  });
}
