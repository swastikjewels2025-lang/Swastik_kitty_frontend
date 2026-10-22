import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/providers/core_providers.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/core/storage/secure_storage_service.dart';
import 'package:kitty_app/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:kitty_app/features/auth/presentation/screens/otp_screen.dart';
import 'package:kitty_app/shared/widgets/inputs/kitty_otp_input.dart';

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
  testWidgets('OtpScreen renders heading, 6-digit OTP boxes, and Resend OTP bar', (WidgetTester tester) async {
    final _FakeSecureStorageService fakeStorage = _FakeSecureStorageService();
    final MockAuthRepository mockAuth = MockAuthRepository(storageService: fakeStorage);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuth),
          secureStorageServiceProvider.overrideWithValue(fakeStorage),
        ],
        child: const MaterialApp(
          home: OtpScreen(),
        ),
      ),
    );

    expect(find.text('Verify your number'), findsOneWidget);
    expect(find.byType(KittyOtpInput), findsOneWidget);
    expect(find.text('Verify & Continue'), findsOneWidget);
    expect(find.text('Resend OTP'), findsOneWidget);
  });

  testWidgets('OtpScreen shows error message on invalid OTP submission', (WidgetTester tester) async {
    final _FakeSecureStorageService fakeStorage = _FakeSecureStorageService();
    final MockAuthRepository mockAuth = MockAuthRepository(storageService: fakeStorage);

    final ProviderContainer container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuth),
        secureStorageServiceProvider.overrideWithValue(fakeStorage),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: OtpScreen(),
        ),
      ),
    );

    // Enter wrong OTP 999999
    final Finder otpFinder = find.byType(KittyOtpInput);
    expect(otpFinder, findsOneWidget);

    final KittyOtpInputState state = tester.state(otpFinder);
    state.setOtp('999999');
    await tester.pumpAndSettle();

    expect(find.textContaining('Incorrect OTP'), findsOneWidget);
  });
}
