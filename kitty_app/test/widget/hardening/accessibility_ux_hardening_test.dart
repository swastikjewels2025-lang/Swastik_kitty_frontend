import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kitty_app/core/constants/app_dimensions.dart';
import 'package:kitty_app/core/errors/app_exception.dart';
import 'package:kitty_app/core/errors/error_handler.dart';
import 'package:kitty_app/core/errors/failure.dart';
import 'package:kitty_app/core/providers/auth_state_provider.dart';
import 'package:kitty_app/core/theme/app_theme.dart';
import 'package:kitty_app/features/orders/presentation/screens/orders_screen.dart';
import 'package:kitty_app/shared/widgets/buttons/kitty_primary_button.dart';
import 'package:kitty_app/shared/widgets/feedback/kitty_empty_state.dart';
import 'package:kitty_app/shared/widgets/feedback/kitty_error_state.dart';
import 'package:kitty_app/shared/widgets/navigation/app_bottom_nav_bar.dart';
import 'package:kitty_app/shared/widgets/navigation/luxury_nav_drawer.dart';

class _FakeAuthNotifier extends AppAuthNotifier {
  _FakeAuthNotifier(this._initial);
  final AppAuthState _initial;

  @override
  AppAuthState build() => _initial;
}

void main() {
  group('Phase 13: Accessibility & UX Hardening Tests', () {
    testWidgets('1. KittyPrimaryButton meets minimum 52px accessible touch target and uppercase label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KittyPrimaryButton(
              label: 'Proceed Securely',
              onPressed: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Size buttonSize = tester.getSize(find.byType(KittyPrimaryButton));
      expect(buttonSize.height, greaterThanOrEqualTo(52.0));
      expect(find.text('PROCEED SECURELY'), findsOneWidget);
    });

    testWidgets('2. KittyEmptyState action button achieves >=52px touch target', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KittyEmptyState(
              title: 'No Active Schemes',
              description: 'You do not have any active gold kitty schemes at this moment.',
              actionLabel: 'Explore Plans',
              onAction: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Size buttonSize = tester.getSize(find.byType(KittyPrimaryButton));
      expect(buttonSize.height, greaterThanOrEqualTo(52.0));
      expect(find.text('No Active Schemes'), findsOneWidget);
      expect(find.text('EXPLORE PLANS'), findsOneWidget);
    });

    testWidgets('3. KittyErrorState provides human-readable message and >=52px retry button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KittyErrorState(
              title: 'Connection Issue',
              message: 'Unable to reach the server. Please verify your connection.',
              retryLabel: 'Retry Now',
              onRetry: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Size buttonSize = tester.getSize(find.byType(KittyPrimaryButton));
      expect(buttonSize.height, greaterThanOrEqualTo(52.0));
      expect(find.text('Connection Issue'), findsOneWidget);
      expect(find.text('RETRY NOW'), findsOneWidget);
    });

    testWidgets('4. AppBottomNavBar items render luxury labels and respond to touch', (WidgetTester tester) async {
      int tappedIndex = -1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavBar(
              currentIndex: 0,
              onTap: (idx) => tappedIndex = idx,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Home tab and other tabs visible
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('My Kitty'), findsOneWidget);
      expect(find.text('Kitty Plans'), findsOneWidget);
      expect(find.text('Calculator'), findsOneWidget);
      expect(find.text('Jewellery'), findsOneWidget);

      await tester.tap(find.text('Calculator'));
      await tester.pumpAndSettle();
      expect(tappedIndex, 3);
    });

    testWidgets('5. LuxuryNavDrawer items enforce accessible layout and navigation links', (WidgetTester tester) async {
      final GoRouter dummyRouter = GoRouter(
        initialLocation: '/test',
        routes: <RouteBase>[
          GoRoute(
            path: '/test',
            builder: (BuildContext context, GoRouterState state) => Scaffold(
              drawer: const LuxuryNavDrawer(),
              body: Builder(
                builder: (BuildContext ctx) => ElevatedButton(
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ],
      );

      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appAuthStateProvider.overrideWith(
              () => _FakeAuthNotifier(
                const AppAuthState.authenticated(
                  token: 'test_token',
                  userName: 'Rihan Patron',
                  userPhone: '+91 98765 43210',
                ),
              ),
            ),
          ],
          child: MaterialApp.router(
            theme: AppTheme.darkTheme,
            routerConfig: dummyRouter,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open the drawer
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Verify Drawer content
      expect(find.text('Rihan Patron'), findsOneWidget);
      expect(find.text('My Kitty'), findsOneWidget);
      expect(find.text('Kitty Plans'), findsOneWidget);
      expect(find.text('Savings Passbook'), findsOneWidget);
      expect(find.text('Gold Coins'), findsOneWidget);
    });

    testWidgets('6. OrdersScreen empty state has >=52px touch target and clear CTA', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OrdersScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('You haven’t booked or ordered anything yet.'), findsOneWidget);
      final Finder ctaFinder = find.byKey(const Key('orders_continue_shopping_btn'));
      expect(ctaFinder, findsOneWidget);
      final Size ctaSize = tester.getSize(ctaFinder);
      expect(ctaSize.height, greaterThanOrEqualTo(AppDimensions.primaryButtonHeight));
      expect(find.text('Continue Shopping'), findsOneWidget);
    });

    test('7. ErrorHandler converts raw exceptions to non-technical, user-friendly messages', () {
      final Failure networkFailure = ErrorHandler.handle(const NetworkException());
      expect(networkFailure.message, contains('Unable to connect to the server'));
      expect(networkFailure.message, isNot(contains('DioException')));

      final Failure serverFailure = ErrorHandler.handle(const ServerException());
      expect(serverFailure.message, contains('undergoing maintenance'));
      expect(serverFailure.message, isNot(contains('500 Internal Server Error')));

      final Failure fallbackFailure = ErrorHandler.handle(Exception('Raw DB connection error 0x8291'));
      expect(fallbackFailure.message, 'Something went wrong. Please try again.');
    });
  });
}
