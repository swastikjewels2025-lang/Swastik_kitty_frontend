import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kitty_app/core/providers/auth_state_provider.dart';
import 'package:kitty_app/core/theme/app_theme.dart';
import 'package:kitty_app/shared/widgets/navigation/luxury_nav_drawer.dart';

void main() {
  group('LuxuryNavDrawer / KittyMenuSheet Widget Tests (menu.html Approved Design)', () {
    testWidgets('Renders patron profile and all 7 approved menu items plus logout', (WidgetTester tester) async {
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
          GoRoute(
            path: '/home',
            builder: (BuildContext context, GoRouterState state) => const Text('Home Screen'),
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

      // Open the drawer
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // 1. Verify Patron Profile
      expect(find.text('Rihan Patron'), findsOneWidget);
      expect(find.text('+91 98765 43210'), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);

      // 2. Verify all menu items from menu.html
      expect(find.text('My Gold Plans'), findsOneWidget);
      expect(find.text('My Bookings'), findsOneWidget);
      expect(find.text('Live Gold Rate'), findsOneWidget);
      expect(find.text('Gold Coins'), findsOneWidget);
      expect(find.text('Gold Calculator'), findsOneWidget);
      expect(find.text('KYC Details'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });
  });
}

class _FakeAuthNotifier extends AppAuthNotifier {
  _FakeAuthNotifier(this._initialState);

  final AppAuthState _initialState;

  @override
  AppAuthState build() {
    return _initialState;
  }
}
