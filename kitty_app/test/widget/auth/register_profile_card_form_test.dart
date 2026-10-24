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
  group('RegisterProfileScreen Unified Card-Form & Placeholder Tests', () {
    testWidgets('Step 1 displays internal placeholders and unified card without separate labels',
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

      // Heading & Step indicator
      expect(find.text('User Details'), findsOneWidget);
      expect(find.text('Step 1 of 3'), findsOneWidget);

      // Verify internal placeholders
      expect(find.text('Enter first name'), findsOneWidget);
      expect(find.text('Enter last name'), findsOneWidget);
      expect(find.text('Enter 10-digit mobile number'), findsOneWidget);
      expect(find.text('Enter email address'), findsOneWidget);

      // Verify CTA button
      expect(find.text('NEXT: ADDRESS & BIRTH DATE'), findsOneWidget);
    });

    testWidgets('Step 2 displays internal placeholders and responsive city/pincode in card',
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

      // Enter Step 1 valid info
      await tester.enterText(find.byKey(const Key('input_profile_name')), 'Ananya');
      await tester.enterText(find.byKey(const Key('input_profile_last_name')), 'Sharma');
      await tester.enterText(find.byKey(const Key('input_profile_phone')), '9812345678');
      await tester.enterText(find.byKey(const Key('input_profile_email')), 'ananya@example.com');
      await tester.pump();

      await tester.ensureVisible(find.byKey(const Key('btn_profile_submit')));
      await tester.tap(find.byKey(const Key('btn_profile_submit')));
      await tester.pumpAndSettle();

      // Step 2 assertions
      expect(find.text('Address & Birth Date'), findsOneWidget);
      expect(find.text('Step 2 of 3'), findsOneWidget);

      // Verify Step 2 placeholders
      expect(find.text('DD/MM/YYYY'), findsOneWidget);
      expect(find.text('Enter house / flat / street address'), findsOneWidget);
      expect(find.text('Enter city'), findsOneWidget);
      expect(find.text('NEXT: NOMINEE DETAILS'), findsOneWidget);
      expect(find.text('Skip this step for now'), findsOneWidget);
    });

    testWidgets('Step 3 displays nominee card, dropdown, and statutory protection note',
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

      // Enter Step 1 valid info and advance
      await tester.enterText(find.byKey(const Key('input_profile_name')), 'Ananya');
      await tester.enterText(find.byKey(const Key('input_profile_last_name')), 'Sharma');
      await tester.enterText(find.byKey(const Key('input_profile_phone')), '9812345678');
      await tester.enterText(find.byKey(const Key('input_profile_email')), 'ananya@example.com');
      await tester.pump();

      await tester.ensureVisible(find.byKey(const Key('btn_profile_submit')));
      await tester.tap(find.byKey(const Key('btn_profile_submit')));
      await tester.pumpAndSettle();

      // Skip Step 2 to reach Step 3
      await tester.tap(find.byKey(const Key('btn_skip_step2')));
      await tester.pumpAndSettle();

      // Step 3 assertions
      expect(find.text('Nominee Details'), findsOneWidget);
      expect(find.text('Step 3 of 3'), findsOneWidget);
      expect(find.text('Enter nominee full name'), findsOneWidget);
      expect(find.text('Enter nominee mobile number'), findsOneWidget);
      expect(find.text('Spouse'), findsOneWidget); // Default selected relationship
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
      expect(find.text('CONFIRM & PROCEED TO KYC'), findsOneWidget);
      expect(find.text('Skip nominee for now'), findsOneWidget);
    });
  });
}
