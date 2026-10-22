import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/features/coin_rates/presentation/screens/coin_rates_screen.dart';
import 'package:kitty_app/shared/widgets/navigation/kitty_hamburger_button.dart';

void main() {
  group('CoinRatesScreen Widget Tests (coins.html Approved Design)', () {
    late MockEngineConfig instantConfig;

    setUp(() {
      instantConfig = MockEngineConfig(latency: MockLatency.instant);
    });

    testWidgets('Renders header with hamburger, Available Coins (4g, 5g), and Custom Coin builder', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mockEngineConfigProvider.overrideWithValue(instantConfig),
          ],
          child: const MaterialApp(
            home: CoinRatesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Header with title and Hamburger button
      expect(find.text('Gold Coins'), findsWidgets);
      expect(find.byType(KittyHamburgerButton), findsOneWidget);

      // 2. Predefined Available Gold Coins section
      expect(find.text('Available Gold Coins'), findsOneWidget);
      expect(find.text('4g Gold Coin'), findsOneWidget);
      expect(find.text('5g Gold Coin'), findsOneWidget);
      expect(find.text('Book Now'), findsNWidgets(2));

      // 3. Custom Gold Coin Section
      expect(find.text('Custom Gold Coin'), findsOneWidget);
      expect(find.text('24K (99.9%)'), findsOneWidget);
      expect(find.text('22K (91.6%)'), findsOneWidget);
      expect(find.text('18K (75.0%)'), findsOneWidget);

      // 4. Quick weight chips
      expect(find.text('1g'), findsOneWidget);
      expect(find.text('2g'), findsOneWidget);
      expect(find.text('8g'), findsOneWidget);
      expect(find.text('10g'), findsWidgets);
      expect(find.text('20g'), findsOneWidget);

      // 5. Book Custom Coin CTA
      expect(find.text('Book Custom Coin'), findsOneWidget);
    });

    testWidgets('Interacting with weight chips updates custom calculation', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mockEngineConfigProvider.overrideWithValue(instantConfig),
          ],
          child: const MaterialApp(
            home: CoinRatesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 20g chip
      await tester.tap(find.text('20g'));
      await tester.pumpAndSettle();

      // Verify custom grams input displays 20
      expect(find.text('20'), findsWidgets);
    });
  });
}
