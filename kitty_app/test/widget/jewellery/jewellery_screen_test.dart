import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/features/jewellery/presentation/screens/jewellery_screen.dart';

void main() {
  group('JewelleryScreen Web Bridge Tests (Phase 12)', () {
    testWidgets('Renders luxury app bar, official verification badge, and web preview chrome', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: JewelleryScreen(isTestMode: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Screen Title
      expect(find.text('Swastik Showroom'), findsOneWidget);

      // Verify Verified Official Catalog Badge
      expect(find.text('swastikjewel.in · Official Web Catalog'), findsOneWidget);
      expect(find.byIcon(Icons.verified_rounded), findsOneWidget);

      // Verify Header Action Buttons
      expect(find.byKey(const Key('btn_jewellery_refresh')), findsOneWidget);
      expect(find.byKey(const Key('btn_jewellery_concierge')), findsOneWidget);
      expect(find.byKey(const Key('btn_jewellery_share')), findsOneWidget);

      // Verify Fallback Preview Card (in test mode)
      expect(find.byKey(const Key('jewellery_fallback_preview')), findsOneWidget);
      expect(find.text('Swastik Jewellers Official Catalog'), findsOneWidget);
      expect(find.byKey(const Key('btn_open_external_catalog')), findsOneWidget);
    });

    testWidgets('Tapping Concierge button opens Showroom Concierge modal with helpline', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: JewelleryScreen(isTestMode: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Concierge Action
      await tester.tap(find.byKey(const Key('btn_jewellery_concierge')));
      await tester.pumpAndSettle();

      // Verify Modal Content
      expect(find.text('Swastik Showroom Concierge'), findsOneWidget);
      expect(find.textContaining('Helpline:'), findsOneWidget);
      expect(find.byKey(const Key('btn_concierge_call_now')), findsOneWidget);
    });

    testWidgets('Tapping Share action triggers snackbar confirmation', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: JewelleryScreen(isTestMode: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Share
      await tester.tap(find.byKey(const Key('btn_jewellery_share')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Snackbar
      expect(find.byKey(const Key('snackbar_jewellery_share')), findsOneWidget);
      expect(find.text('Showroom catalog URL copied to clipboard!'), findsOneWidget);
    });

    testWidgets('Tapping Refresh triggers loading indicator and reloads successfully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: JewelleryScreen(isTestMode: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Refresh
      await tester.tap(find.byKey(const Key('btn_jewellery_refresh')));
      await tester.pump(); // Triggers loading

      // Progress bar should appear
      expect(find.byKey(const Key('jewellery_loading_progress_bar')), findsOneWidget);

      // Wait for simulated reload to finish
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // Progress bar dismissed
      expect(find.byKey(const Key('jewellery_loading_progress_bar')), findsNothing);
    });

    testWidgets('Error state renders offline card with retry and concierge call actions', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: JewelleryScreen(simulateError: true, isTestMode: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Offline Fallback Title & Message
      expect(find.text('Showroom Catalog Offline'), findsOneWidget);
      expect(find.textContaining('Network connection timed out'), findsOneWidget);

      // Verify Actions
      expect(find.byKey(const Key('btn_jewellery_retry')), findsOneWidget);
      expect(find.byKey(const Key('btn_jewellery_call_concierge_offline')), findsOneWidget);

      // Tap Retry to reload
      await tester.tap(find.byKey(const Key('btn_jewellery_retry')));
      await tester.pump();

      // Error view dismissed and loading started
      expect(find.text('Showroom Catalog Offline'), findsNothing);
      expect(find.byKey(const Key('jewellery_loading_progress_bar')), findsOneWidget);

      // Wait for reload to complete
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // Restores preview card
      expect(find.byKey(const Key('jewellery_fallback_preview')), findsOneWidget);
    });
  });
}
