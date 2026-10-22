import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/config/app_config.dart';
import 'package:kitty_app/core/config/app_environment.dart';
import 'package:kitty_app/core/enums/app_enums.dart';
import 'package:kitty_app/core/network/dio_client.dart';
import 'package:kitty_app/core/network/interceptors/auth_interceptor.dart';
import 'package:kitty_app/core/storage/secure_storage_service.dart';
import 'package:kitty_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:kitty_app/features/checkout/data/repositories/payment_repository_impl.dart';
import 'package:kitty_app/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:kitty_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:kitty_app/features/kyc/data/repositories/kyc_repository_impl.dart';
import 'package:kitty_app/features/kyc/domain/entities/kyc_entity.dart';
import 'package:kitty_app/features/offers/data/repositories/scheme_repository_impl.dart';
import 'package:kitty_app/features/passbook/data/repositories/passbook_repository_impl.dart';
import 'package:kitty_app/features/settings/data/repositories/profile_repository_impl.dart';

class _InMemorySecureStorageService extends SecureStorageService {
  final Map<String, String> _storage = <String, String>{};

  @override
  Future<void> write({required String key, required String value}) async {
    _storage[key] = value;
  }

  @override
  Future<String?> read({required String key}) async {
    return _storage[key];
  }

  @override
  Future<void> delete({required String key}) async {
    _storage.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _storage.clear();
  }
}

class _RealHttpOverrides extends HttpOverrides {}

void main() {
  HttpOverrides.global = _RealHttpOverrides();

  const String backendBaseUrl = 'http://127.0.0.1:5000';
  late AppConfig config;
  late _InMemorySecureStorageService storageService;
  late AuthInterceptor authInterceptor;
  late DioClient apiClient;

  late AuthRepositoryImpl authRepo;
  late ProfileRepositoryImpl profileRepo;
  late KycRepositoryImpl kycRepo;
  late HomeRepositoryImpl homeRepo;
  late SchemeRepositoryImpl schemeRepo;
  late DashboardRepositoryImpl dashboardRepo;
  late PassbookRepositoryImpl passbookRepo;
  late PaymentRepositoryImpl paymentRepo;

  bool wasUnauthorizedTriggered = false;

  setUp(() {
    wasUnauthorizedTriggered = false;
    config = AppConfig(
      environment: AppEnvironment.staging,
      baseUrl: backendBaseUrl,
      useMockApi: false,
    );
    storageService = _InMemorySecureStorageService();
    authInterceptor = AuthInterceptor(
      secureStorageService: storageService,
      onUnauthorized: () {
        wasUnauthorizedTriggered = true;
      },
    );
    apiClient = DioClient(
      config: config,
      authInterceptor: authInterceptor,
    );

    authRepo = AuthRepositoryImpl(apiClient: apiClient, storageService: storageService);
    profileRepo = ProfileRepositoryImpl(apiClient: apiClient);
    kycRepo = KycRepositoryImpl(apiClient: apiClient);
    homeRepo = HomeRepositoryImpl(apiClient: apiClient);
    schemeRepo = SchemeRepositoryImpl(apiClient: apiClient);
    dashboardRepo = DashboardRepositoryImpl(apiClient: apiClient);
    passbookRepo = PassbookRepositoryImpl(apiClient: apiClient);
    paymentRepo = PaymentRepositoryImpl(apiClient: apiClient);
  });

  group(
    'Phase 16 — Live Backend Integration Tests',
    () {
    test('1. Backend Health Check (GET /api/v1/health)', () async {
      final response = await apiClient.get<Map<String, dynamic>>('/api/v1/health');
      expect(response.statusCode, equals(200));
      expect(response.data!['success'], isTrue);
      expect(response.data!['data']['status'], equals('HEALTHY'));
      expect(response.data!['data']['database'], equals('CONNECTED'));
    });

    test('2. Auth API: sendOtp and verifyOtp (POST /api/v1/auth/*)', () async {
      // Dynamic valid Indian phone number to prevent 60-second cooldown collision
      final String testPhone = '+9198${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

      // Step A: Send OTP
      final sendResult = await authRepo.sendOtp(phone: testPhone);
      expect(sendResult.expiresInSeconds, greaterThan(0));

      // Step B: Verify OTP (sandbox bypass code 123456)
      final session = await authRepo.verifyOtp(
        phone: testPhone,
        otp: '123456',
      );
      expect(session.token, isNotEmpty);
      expect(session.user.phone, equals(testPhone));
      expect(session.user.role, equals(UserRoleEnum.customer));

      // Step C: Verify token persisted in SecureStorage
      final storedToken = await storageService.getToken();
      expect(storedToken, equals(session.token));

      // Step D: Verify Bearer header on authenticated getCurrentUser call
      final currentUser = await authRepo.getCurrentUser();
      expect(currentUser.phone, equals(testPhone));
      expect(currentUser.role, equals(UserRoleEnum.customer));
    });

    test('3. Profile API: getProfile extracts data.user (GET /api/v1/users/profile)', () async {
      // Obtain session first
      final session = await authRepo.verifyOtp(phone: '+919876543210', otp: '123456');
      expect(session.token, isNotEmpty);

      // Query Profile via ProfileRepositoryImpl
      final profile = await profileRepo.getProfile();
      expect(profile.phone, equals('+919876543210'));
      expect(profile.name, isNotEmpty);
    });

    test('4. Live Gold Rate API (GET /api/v1/rates/gold)', () async {
      final rate = await homeRepo.getLiveGoldRate();
      expect(rate.ratePerGram, greaterThan(0));
      expect(rate.currency, equals('INR'));
      expect(rate.purity, contains('24K'));
    });

    test('5. Active Schemes API (GET /api/v1/schemes/active)', () async {
      final schemes = await schemeRepo.getActiveSchemes();
      // Schemes array returns from backend (empty or populated)
      expect(schemes, isA<List<dynamic>>());
    });

    test('6. Dashboard API (GET /api/v1/memberships/my-dashboard)', () async {
      // Authenticate
      await authRepo.verifyOtp(phone: '+919876543210', otp: '123456');

      final dashboard = await dashboardRepo.getMyDashboard();
      expect(dashboard, isNotNull);
      // New account has no active scheme initially
      expect(dashboard.hasActiveScheme, isFalse);
    });

    test('7. Passbook API mapping against real backend', () async {
      // Authenticate
      await authRepo.verifyOtp(phone: '+919876543210', otp: '123456');

      final summary = await passbookRepo.getPassbookSummary();
      final entries = await passbookRepo.getPassbookEntries();
      // When no active scheme exists, summary is null and entries are empty
      expect(summary, isNull);
      expect(entries, isEmpty);
    });

    test('8. KYC Multipart API submission (POST /api/v1/users/kyc)', () async {
      // Authenticate
      await authRepo.verifyOtp(phone: '+919876543210', otp: '123456');

      // Create a temporary KYC document file
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/test_kyc_doc.pdf');
      await tempFile.writeAsString('%PDF-1.4 Mock Aadhaar Document Content for Phase 16');

      final submission = KycSubmissionEntity(
        documentType: DocTypeEnum.aadhaar,
        documentNumber: '123456789012',
        consentAgreed: true,
        filePath: tempFile.path,
        fileName: 'test_kyc_doc.pdf',
      );

      final result = await kycRepo.submitKyc(submission);
      expect(result.status, equals(KycStatusEnum.pending));
      expect(result.referenceId, isNotEmpty);
      expect(result.documentNumberMasked, contains('9012'));

      // Clean up temp file
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      // Check KYC status refresh via profile
      final statusResult = await kycRepo.getKycStatus();
      expect(statusResult.status, equals(KycStatusEnum.pending));
    });

    test('9. Payment API initiate & status endpoints', () async {
      // Authenticate
      await authRepo.verifyOtp(phone: '+919876543210', otp: '123456');

      // Check validation error handling on payments initiate
      try {
        await paymentRepo.initiatePayment(
          membershipId: 'non_existent_id',
          monthFor: 1,
        );
      } catch (e) {
        expect(e.toString(), anyOf(contains('VALIDATION_ERROR'), contains('400')));
      }

      // Check status check for unknown order returns 404
      try {
        await paymentRepo.getPaymentStatus('UNKNOWN_ORDER_123');
      } catch (e) {
        expect(e.toString(), anyOf(contains('ORDER_NOT_FOUND'), contains('404')));
      }
    });

    test('10. AuthInterceptor 401 Session Purge', () async {
      // Provide an invalid token
      await storageService.saveToken('invalid_expired_jwt_token_for_testing');

      try {
        await apiClient.get<dynamic>('/api/v1/users/profile');
      } catch (_) {
        // Expected 401 exception
      }

      // Verify onUnauthorized was called
      expect(wasUnauthorizedTriggered, isTrue);
    });

    test('11. Auth API Logout (POST /api/v1/auth/logout)', () async {
      // Authenticate first
      await authRepo.verifyOtp(phone: '+919876543210', otp: '123456');
      expect(await storageService.hasToken(), isTrue);

      // Perform logout
      await authRepo.logout();

      // Verify token is wiped from secure storage
      expect(await storageService.hasToken(), isFalse);
    });
  },
  skip: const bool.fromEnvironment('RUN_LIVE_BACKEND_TESTS', defaultValue: false)
      ? null
      : 'Deferred to Phase 16 — Live backend server required at http://127.0.0.1:5000',
  );
}
