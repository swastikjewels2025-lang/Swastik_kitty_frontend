import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/features/settings/presentation/providers/settings_controller.dart';
import 'package:kitty_app/features/settings/presentation/providers/settings_state.dart';
import 'package:kitty_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:kitty_app/features/settings/presentation/widgets/settings_skeleton_loader.dart';
import 'package:kitty_app/shared/widgets/feedback/kitty_error_state.dart';

void main() {
  group('Phase 15 - Settings Screen Production States Suite', () {
    testWidgets('1. Displays SettingsSkeletonLoader while initial profile is loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsControllerProvider.overrideWith(
              () => _MockSettingsLoadingNotifier(),
            ),
          ],
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(SettingsSkeletonLoader), findsOneWidget);
    });

    testWidgets('2. Displays KittyErrorState on profile load failure',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsControllerProvider.overrideWith(
              () => _MockSettingsErrorNotifier(),
            ),
          ],
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(KittyErrorState), findsOneWidget);
      expect(find.text('Unable to Load Profile'), findsOneWidget);
      expect(find.text('TRY AGAIN'), findsOneWidget);
    });
  });
}

class _MockSettingsLoadingNotifier extends SettingsController {
  @override
  SettingsState build() {
    return const SettingsState(isLoading: true, user: null);
  }
}

class _MockSettingsErrorNotifier extends SettingsController {
  @override
  SettingsState build() {
    return const SettingsState(
      isLoading: false,
      user: null,
      errorMessage: 'Network timeout loading profile.',
    );
  }
}
