import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/app/kitty_app.dart';
import 'package:kitty_app/core/providers/auth_state_provider.dart';

void main() {
  testWidgets('KittyApp root launch smoke test', (WidgetTester tester) async {
    // Build app with unauthenticated state
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appAuthStateProvider.overrideWith(
            () => _FakeAuthNotifier(const AppAuthState.unauthenticated()),
          ),
        ],
        child: const KittyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify that the declarative router mounts and routes to Login
    expect(find.text('Sign in to continue'), findsOneWidget);
  });
}

class _FakeAuthNotifier extends AppAuthNotifier {
  _FakeAuthNotifier(this._state);

  final AppAuthState _state;

  @override
  AppAuthState build() {
    return _state;
  }
}
