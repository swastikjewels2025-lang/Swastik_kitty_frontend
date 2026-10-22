import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/providers/core_providers.dart';
import 'package:kitty_app/core/storage/secure_storage_service.dart';
import 'package:kitty_app/features/auth/presentation/screens/register_profile_screen.dart';

class _FakeSecureStorageService extends SecureStorageService {
  final Map<String, String> _map = <String, String>{};

  @override
  Future<void> write({required String key, required String value}) async {
    _map[key] = value;
  }

  @override
  Future<String?> read({required String key}) async {
    return _map[key];
  }

  @override
  Future<void> delete({required String key}) async {
    _map.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _map.clear();
  }
}

void main() {
  group('RegisterProfileScreen Progressive Multi-Step Tests', () {
    testWidgets('Step 1 renders First Name, Last Name, Phone, Email, and Next button',
        (WidgetTester tester) async {
      final fakeStorage = _FakeSecureStorageService();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageServiceProvider.overrideWithValue(fakeStorage),
          ],
          child: const MaterialApp(
            home: RegisterProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('User Details'), findsOneWidget);
      expect(find.text('Step 1 of 3'), findsOneWidget);
      expect(find.byKey(const Key('input_profile_name')), findsOneWidget);
      expect(find.byKey(const Key('input_profile_last_name')), findsOneWidget);
      expect(find.byKey(const Key('input_profile_phone')), findsOneWidget);
      expect(find.byKey(const Key('input_profile_email')), findsOneWidget);
      expect(find.byKey(const Key('btn_profile_submit')), findsOneWidget);
      expect(find.text('NEXT: ADDRESS & BIRTH DATE'), findsOneWidget);
    });

    testWidgets('Step 1 validates empty first name and invalid email',
        (WidgetTester tester) async {
      final fakeStorage = _FakeSecureStorageService();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageServiceProvider.overrideWithValue(fakeStorage),
          ],
          child: const MaterialApp(
            home: RegisterProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Clear the name input and set invalid email
      await tester.enterText(find.byKey(const Key('input_profile_name')), '');
      await tester.enterText(find.byKey(const Key('input_profile_email')), 'invalid-email');
      await tester.pump();

      // Scroll and tap submit
      await tester.ensureVisible(find.byKey(const Key('btn_profile_submit')));
      await tester.tap(find.byKey(const Key('btn_profile_submit')));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your first name'), findsOneWidget);
      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('Step 1 advances to Step 2 (Address & DOB) which is skippable',
        (WidgetTester tester) async {
      final fakeStorage = _FakeSecureStorageService();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageServiceProvider.overrideWithValue(fakeStorage),
          ],
          child: const MaterialApp(
            home: RegisterProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Fill valid Step 1 details
      await tester.enterText(find.byKey(const Key('input_profile_name')), 'Rihan');
      await tester.enterText(find.byKey(const Key('input_profile_last_name')), 'Saifi');
      await tester.enterText(find.byKey(const Key('input_profile_phone')), '9876543210');
      await tester.enterText(find.byKey(const Key('input_profile_email')), 'rihan@example.com');
      await tester.pump();

      // Tap Next to Step 2
      await tester.ensureVisible(find.byKey(const Key('btn_profile_submit')));
      await tester.tap(find.byKey(const Key('btn_profile_submit')));
      await tester.pumpAndSettle();

      // Now on Step 2 of 3
      expect(find.text('Address & Birth Date'), findsOneWidget);
      expect(find.text('Step 2 of 3'), findsOneWidget);
      expect(find.byKey(const Key('input_profile_city')), findsOneWidget);
      expect(find.byKey(const Key('input_profile_pincode')), findsOneWidget);
      expect(find.byKey(const Key('btn_skip_step2')), findsOneWidget);
      expect(find.text('Skip this step for now'), findsOneWidget);

      // Tap Skip on Step 2
      await tester.tap(find.byKey(const Key('btn_skip_step2')));
      await tester.pumpAndSettle();

      // Should now be on Step 3 of 3 (Nominee Details)
      expect(find.text('Nominee Details'), findsOneWidget);
      expect(find.text('Step 3 of 3'), findsOneWidget);
      expect(find.byKey(const Key('input_nominee_name')), findsOneWidget);
    });
  });
}
