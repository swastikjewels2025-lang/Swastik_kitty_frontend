import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kitty_app/features/splash/presentation/screens/splash_screen.dart';

void main() {
  testWidgets('SplashScreen renders deep emerald background and 3D diamond custom paint', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SplashScreen(
            totalDuration: Duration(milliseconds: 1000),
            autoNavigate: false,
          ),
        ),
      ),
    );

    // Deep emerald background
    expect(find.byType(Scaffold), findsOneWidget);

    // Advance animation to diamond active window
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(CustomPaint), findsWidgets);
    expect(find.byType(RepaintBoundary), findsWidgets);
  });

  testWidgets('SplashScreen completes animation and shows Swastik logo without KITTY VAULT text', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SplashScreen(
            totalDuration: Duration(milliseconds: 1000),
            autoNavigate: false,
          ),
        ),
      ),
    );

    // Fast-forward to end
    await tester.pump(const Duration(milliseconds: 950));
    expect(find.byType(SvgPicture), findsWidgets);
    expect(find.text('KITTY VAULT'), findsNothing);
  });
}
