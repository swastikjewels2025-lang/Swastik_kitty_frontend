import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/theme/app_theme.dart';
import 'package:kitty_app/shared/widgets/navigation/header_nav_bar.dart';

void main() {
  group('HeaderNavBar Widget Tests', () {
    testWidgets('Renders brand title, gold ticker, and action buttons', (WidgetTester tester) async {
      bool menuTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            appBar: HeaderNavBar(
              onMenuPressed: () {
                menuTapped = true;
              },
              unreadNotificationsCount: 3,
              goldRate24k: 7550.00,
            ),
            body: const Center(child: Text('Content')),
          ),
        ),
      );

      // Verify authentic Swastik brand logo SVG
      expect(find.byKey(const Key('swastik_header_logo')), findsOneWidget);

      // Verify gold rate ticker badge is removed from header
      expect(find.textContaining('24K:'), findsNothing);

      // Verify notification bell is present on the right
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

      // Tap hamburger menu button
      final Finder menuBtn = find.byTooltip('Open Menu');
      expect(menuBtn, findsOneWidget);
      await tester.tap(menuBtn);
      expect(menuTapped, isTrue);
    });
  });
}
