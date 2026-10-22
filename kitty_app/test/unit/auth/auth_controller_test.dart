import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/providers/auth_state_provider.dart';
import 'package:kitty_app/core/providers/core_providers.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/core/storage/secure_storage_service.dart';
import 'package:kitty_app/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:kitty_app/features/auth/presentation/providers/auth_controller.dart';

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
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late MockAuthRepository mockAuthRepo;
  late _FakeSecureStorageService fakeStorage;

  setUp(() {
    fakeStorage = _FakeSecureStorageService();
    mockAuthRepo = MockAuthRepository(storageService: fakeStorage);
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepo),
        secureStorageServiceProvider.overrideWithValue(fakeStorage),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthController Unit Tests', () {
    test('Initial state has default country code +91 and empty inputs', () {
      final AuthFlowState state = container.read(authControllerProvider);
      expect(state.countryCode, '+91');
      expect(state.countryFlag, '🇮🇳');
      expect(state.phone, '');
      expect(state.phoneError, isNull);
      expect(state.otpError, isNull);
      expect(state.isSubmitting, isFalse);
      expect(state.isVerifying, isFalse);
      expect(state.canResend, isTrue);
    });

    test('setPhone updates phone string and clears existing phone error', () {
      final AuthController controller = container.read(authControllerProvider.notifier);
      controller.setPhone('9876543210');

      final AuthFlowState state = container.read(authControllerProvider);
      expect(state.phone, '9876543210');
      expect(state.cleanPhone, '9876543210');
      expect(state.fullFormattedPhone, '+91 9876543210');
    });

    test('setCountry updates country code and flag', () {
      final AuthController controller = container.read(authControllerProvider.notifier);
      controller.setCountry('+971', '🇦🇪');

      final AuthFlowState state = container.read(authControllerProvider);
      expect(state.countryCode, '+971');
      expect(state.countryFlag, '🇦🇪');
    });

    test('sendOtp fails on phone number shorter than 10 digits', () async {
      final AuthController controller = container.read(authControllerProvider.notifier);
      controller.setPhone('12345');

      final bool success = await controller.sendOtp();
      expect(success, isFalse);

      final AuthFlowState state = container.read(authControllerProvider);
      expect(state.phoneError, isNotNull);
    });

    test('sendOtp fails on invalid non-Indian starting digit', () async {
      final AuthController controller = container.read(authControllerProvider.notifier);
      controller.setPhone('1234567890');

      final bool success = await controller.sendOtp();
      expect(success, isFalse);

      final AuthFlowState state = container.read(authControllerProvider);
      expect(state.phoneError, isNotNull);
    });

    test('sendOtp succeeds with valid 10-digit phone and sets 30s resend / 300s TTL timers', () async {
      final AuthController controller = container.read(authControllerProvider.notifier);
      controller.setPhone('9876543210');

      final bool success = await controller.sendOtp();
      expect(success, isTrue);

      final AuthFlowState state = container.read(authControllerProvider);
      expect(state.sessionId, isNotNull);
      expect(state.resendCountdownSeconds, 30);
      expect(state.otpTtlSeconds, 300);
      expect(state.canResend, isFalse);
    });

    test('verifyOtp fails if OTP length is not 6 digits', () async {
      final AuthController controller = container.read(authControllerProvider.notifier);
      controller.setPhone('9876543210');
      await controller.sendOtp();

      final bool success = await controller.verifyOtp('123');
      expect(success, isFalse);

      final AuthFlowState state = container.read(authControllerProvider);
      expect(state.otpError, isNotNull);
    });

    test('verifyOtp fails with wrong OTP code (not 123456 or 984210)', () async {
      final AuthController controller = container.read(authControllerProvider.notifier);
      controller.setPhone('9876543210');
      await controller.sendOtp();

      final bool success = await controller.verifyOtp('999999');
      expect(success, isFalse);

      final AuthFlowState state = container.read(authControllerProvider);
      expect(state.otpError, contains('Incorrect OTP'));
    });

    test('verifyOtp succeeds with mock sandbox code 123456 and transitions global AppAuthState', () async {
      final AuthController controller = container.read(authControllerProvider.notifier);
      controller.setPhone('9876543210');
      await controller.sendOtp();

      final bool success = await controller.verifyOtp('123456');
      expect(success, isTrue);

      final AuthFlowState state = container.read(authControllerProvider);
      expect(state.authSession, isNotNull);
      expect(state.authSession!.token, isNotEmpty);

      // Check global AppAuthState updated
      final AppAuthState globalAuth = container.read(appAuthStateProvider);
      expect(globalAuth.isAuthenticated, isTrue);
      expect(globalAuth.token, isNotEmpty);
    });

    test('loginWithGoogle succeeds and authenticates user', () async {
      final AuthController controller = container.read(authControllerProvider.notifier);
      final bool success = await controller.loginWithGoogle();
      expect(success, isTrue);

      final AppAuthState globalAuth = container.read(appAuthStateProvider);
      expect(globalAuth.isAuthenticated, isTrue);
    });

    test('loginWithInstagram succeeds and authenticates user via abstraction', () async {
      final AuthController controller = container.read(authControllerProvider.notifier);
      final bool success = await controller.loginWithInstagram();
      expect(success, isTrue);

      final AppAuthState globalAuth = container.read(appAuthStateProvider);
      expect(globalAuth.isAuthenticated, isTrue);
    });
  });
}
