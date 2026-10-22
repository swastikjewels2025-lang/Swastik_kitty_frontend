import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/providers/core_providers.dart';
import 'package:kitty_app/shared/widgets/feedback/connectivity_banner_wrapper.dart';

void main() {
  group('Phase 15 - ConnectivityBannerWrapper Widget Suite', () {
    testWidgets('1. Renders child content normally when online', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectivityStatusProvider.overrideWith((ref) => Stream.value(true)),
          ],
          child: const MaterialApp(
            home: ConnectivityBannerWrapper(
              child: Scaffold(
                body: Center(child: Text('Protected Vault Screen')),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Protected Vault Screen'), findsOneWidget);
      expect(find.byKey(const Key('connectivity_offline_banner')), findsNothing);
    });

    testWidgets('2. Displays offline banner without destroying child screen when disconnected',
        (WidgetTester tester) async {
      final controller = StreamController<bool>();
      addTearDown(controller.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectivityStatusProvider.overrideWith((ref) => controller.stream),
          ],
          child: const MaterialApp(
            home: ConnectivityBannerWrapper(
              child: Scaffold(
                body: Center(child: Text('Active Form Screen')),
              ),
            ),
          ),
        ),
      );

      // Initially online
      controller.add(true);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('connectivity_offline_banner')), findsNothing);
      expect(find.text('Active Form Screen'), findsOneWidget);

      // Network lost
      controller.add(false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byKey(const Key('connectivity_offline_banner')), findsOneWidget);
      expect(find.text('No internet connection'), findsOneWidget);
      // Screen is still preserved!
      expect(find.text('Active Form Screen'), findsOneWidget);

      // Network restored
      controller.add(true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byKey(const Key('connectivity_online_banner')), findsOneWidget);
      expect(find.text('Back online'), findsOneWidget);
      expect(find.text('Active Form Screen'), findsOneWidget);
    });
  });
}
