import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/theme/app_theme.dart';
import 'package:kitty_app/shared/widgets/navigation/app_bottom_nav_bar.dart';

void main() {
  group('AppBottomNavBar Widget Tests (Approved 4-Tab Navigation)', () {
    testWidgets('Renders all 4 approved tabs and responds to tap', (WidgetTester tester) async {
      int tappedIndex = -1;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            bottomNavigationBar: AppBottomNavBar(
              currentIndex: 0, // 'Gold Plans' selected
              onTap: (int index) {
                tappedIndex = index;
              },
            ),
            body: const Center(child: Text('Tab Body')),
          ),
        ),
      );

      // Verify all 4 approved canonical destinations are present
      expect(find.text('Gold Plans'), findsOneWidget);
      expect(find.text('My Plan'), findsOneWidget);
      expect(find.text('Instagram'), findsOneWidget);
      expect(find.text('Jewellery'), findsOneWidget);

      // Verify Live Rate and Calculator do NOT appear in bottom navigation
      expect(find.text('Live Rate'), findsNothing);
      expect(find.text('Calculator'), findsNothing);
      expect(find.text('Home'), findsNothing);
      expect(find.text('Coins'), findsNothing);
      expect(find.text('Menu'), findsNothing);
      expect(find.text('KYC'), findsNothing);

      // Tap on Tab 1 ('My Plan')
      await tester.tap(find.text('My Plan'));
      await tester.pump();
      expect(tappedIndex, equals(1));

      // Tap on Tab 2 ('Instagram')
      await tester.tap(find.text('Instagram'));
      await tester.pump();
      expect(tappedIndex, equals(2));

      // Tap on Tab 3 ('Jewellery')
      await tester.tap(find.text('Jewellery'));
      await tester.pump();
      expect(tappedIndex, equals(3));

      // Tap on Tab 0 ('Gold Plans')
      await tester.tap(find.text('Gold Plans'));
      await tester.pump();
      expect(tappedIndex, equals(0));
    });

    testWidgets('Renders luxury icons and SVGs for 4 canonical tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            bottomNavigationBar: AppBottomNavBar(
              currentIndex: 0, // Gold Plans active
              onTap: (_) {},
            ),
            body: const Center(child: Text('Tab Body')),
          ),
        ),
      );

      // Verify SVG icons exist for plans, my plan, instagram, jewellery
      expect(find.byType(SvgPicture), findsWidgets);
    });

    testWidgets('Handles off-dock currentIndex -1 cleanly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            bottomNavigationBar: AppBottomNavBar(
              currentIndex: -1, // Off-dock route (Settings/Passbook/Coins/Orders)
              onTap: (_) {},
            ),
            body: const Center(child: Text('Tab Body')),
          ),
        ),
      );
      await tester.pump();

      // All 4 tabs rendered
      expect(find.text('Gold Plans'), findsOneWidget);
      expect(find.text('My Plan'), findsOneWidget);
      expect(find.text('Instagram'), findsOneWidget);
      expect(find.text('Jewellery'), findsOneWidget);
    });
  });
}
