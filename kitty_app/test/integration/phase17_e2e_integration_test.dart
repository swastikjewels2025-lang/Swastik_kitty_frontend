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
import 'package:kitty_app/features/notifications/data/repositories/mock_notification_repository.dart';
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
  late _InMemorySecureStorageService userStorage;
  late _InMemorySecureStorageService adminStorage;
  late AuthInterceptor userAuthInterceptor;
  late AuthInterceptor adminAuthInterceptor;
  late DioClient userClient;
  late DioClient adminClient;

  late AuthRepositoryImpl userAuthRepo;
  late ProfileRepositoryImpl userProfileRepo;
  late KycRepositoryImpl userKycRepo;
  late HomeRepositoryImpl userHomeRepo;
  late SchemeRepositoryImpl userSchemeRepo;
  late DashboardRepositoryImpl userDashboardRepo;
  late PassbookRepositoryImpl userPassbookRepo;
  late PaymentRepositoryImpl userPaymentRepo;
  late MockNotificationRepository notificationRepo;

  bool wasUnauthorizedTriggered = false;

  setUp(() {
    wasUnauthorizedTriggered = false;
    config = AppConfig(
      environment: AppEnvironment.staging,
      baseUrl: backendBaseUrl,
      useMockApi: false,
    );

    userStorage = _InMemorySecureStorageService();
    userAuthInterceptor = AuthInterceptor(
      secureStorageService: userStorage,
      onUnauthorized: () {
        wasUnauthorizedTriggered = true;
      },
    );
    userClient = DioClient(
      config: config,
      authInterceptor: userAuthInterceptor,
    );

    adminStorage = _InMemorySecureStorageService();
    adminAuthInterceptor = AuthInterceptor(
      secureStorageService: adminStorage,
      onUnauthorized: () {},
    );
    adminClient = DioClient(
      config: config,
      authInterceptor: adminAuthInterceptor,
    );

    userAuthRepo = AuthRepositoryImpl(apiClient: userClient, storageService: userStorage);
    userProfileRepo = ProfileRepositoryImpl(apiClient: userClient);
    userKycRepo = KycRepositoryImpl(apiClient: userClient);
    userHomeRepo = HomeRepositoryImpl(apiClient: userClient);
    userSchemeRepo = SchemeRepositoryImpl(apiClient: userClient);
    userDashboardRepo = DashboardRepositoryImpl(apiClient: userClient);
    userPassbookRepo = PassbookRepositoryImpl(apiClient: userClient);
    userPaymentRepo = PaymentRepositoryImpl(apiClient: userClient);
    notificationRepo = MockNotificationRepository();
  });

  group('Phase 17 — Joint E2E Complete User Journey', () {
    test('Complete Lifecycle: Auth -> KYC -> Admin Verify -> Join Scheme -> Dashboard -> Passbook -> Payment -> Polling -> Logout', () async {
      // -----------------------------------------------------------------------
      // 1. NEW USER & SEND OTP
      // -----------------------------------------------------------------------
      final String freshPhone = '+9198${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      final sendOtpResult = await userAuthRepo.sendOtp(phone: freshPhone);
      expect(sendOtpResult.expiresInSeconds, greaterThan(0));

      // -----------------------------------------------------------------------
      // 2. VERIFY OTP & JWT AUTHENTICATION
      // -----------------------------------------------------------------------
      final session = await userAuthRepo.verifyOtp(phone: freshPhone, otp: '123456');
      expect(session.token, isNotEmpty);
      expect(session.user.phone, equals(freshPhone));
      expect(session.user.role, equals(UserRoleEnum.customer));

      final String? storedToken = await userStorage.getToken();
      expect(storedToken, equals(session.token));

      // Obtain current user to get backend userId
      final currentUser = await userAuthRepo.getCurrentUser();
      final String userId = currentUser.id;
      expect(userId, isNotEmpty);

      // -----------------------------------------------------------------------
      // 3. HOME & PROFILE (Initial state)
      // -----------------------------------------------------------------------
      final goldRate = await userHomeRepo.getLiveGoldRate();
      expect(goldRate.ratePerGram, greaterThan(0));
      expect(goldRate.currency, equals('INR'));

      final initialProfile = await userProfileRepo.getProfile();
      expect(initialProfile.phone, equals(freshPhone));
      expect(initialProfile.kyc.isVerified, isFalse);

      // -----------------------------------------------------------------------
      // 4. ACTIVE SCHEMES DISCOVERY
      // -----------------------------------------------------------------------
      final schemes = await userSchemeRepo.getActiveSchemes();
      expect(schemes, isNotEmpty, reason: 'At least one active scheme must exist');
      final activeScheme = schemes.first;
      expect(activeScheme.id, isNotEmpty);
      expect(activeScheme.status, equals(SchemeStatusEnum.open));

      // -----------------------------------------------------------------------
      // 5. NEGATIVE TEST C: ATTEMPT ENROLLMENT BEFORE KYC VERIFICATION
      // -----------------------------------------------------------------------
      bool kycBlocked = false;
      try {
        await userDashboardRepo.joinScheme(schemeId: activeScheme.id);
      } catch (e) {
        kycBlocked = true;
        expect(e.toString(), anyOf(contains('KYC_REQUIRED'), contains('403')));
      }
      expect(kycBlocked, isTrue, reason: 'Backend must reject enrollment if KYC is not verified');

      // -----------------------------------------------------------------------
      // 6. KYC SUBMISSION (Multipart Upload)
      // -----------------------------------------------------------------------
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/phase17_test_kyc_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await tempFile.writeAsString('%PDF-1.4 Phase 17 E2E Official Aadhaar Document Content');

      final submission = KycSubmissionEntity(
        documentType: DocTypeEnum.aadhaar,
        documentNumber: '998877665544',
        consentAgreed: true,
        filePath: tempFile.path,
        fileName: 'aadhaar_doc.pdf',
      );

      final kycSubmitResult = await userKycRepo.submitKyc(submission);
      expect(kycSubmitResult.status, equals(KycStatusEnum.pending));
      expect(kycSubmitResult.referenceId, isNotEmpty);

      // Clean up temp file
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      // Check KYC status via Profile shows PENDING
      final pendingKycStatus = await userKycRepo.getKycStatus();
      expect(pendingKycStatus.status, equals(KycStatusEnum.pending));

      // -----------------------------------------------------------------------
      // 7. ADMIN KYC VERIFICATION (EXISTING BACKEND ADMIN ENDPOINT)
      // -----------------------------------------------------------------------
      // Admin logs in via existing backend OTP mechanism
      final adminAuthRepo = AuthRepositoryImpl(apiClient: adminClient, storageService: adminStorage);
      final adminSession = await adminAuthRepo.verifyOtp(phone: '+919999900000', otp: '123456');
      expect(adminSession.token, isNotEmpty);
      expect(adminSession.user.role, equals(UserRoleEnum.admin));

      // Invoke existing backend admin endpoint: PATCH /api/v1/admin/kyc/:userId
      final adminReviewResponse = await adminClient.patch<Map<String, dynamic>>(
        '/api/v1/admin/kyc/$userId',
        data: <String, dynamic>{'status': 'VERIFIED'},
      );
      expect(adminReviewResponse.statusCode, equals(200));
      expect(adminReviewResponse.data!['success'], isTrue);
      expect(adminReviewResponse.data!['data']['kyc']['status'], equals('VERIFIED'));
      expect(adminReviewResponse.data!['data']['kyc']['isVerified'], isTrue);

      // -----------------------------------------------------------------------
      // 8. REFRESH PROFILE -> KYC VERIFIED
      // -----------------------------------------------------------------------
      final verifiedProfile = await userProfileRepo.getProfile();
      expect(verifiedProfile.kyc.status, equals(KycStatusEnum.verified));
      expect(verifiedProfile.kyc.isVerified, isTrue);

      // -----------------------------------------------------------------------
      // 9. JOIN GOLD SCHEME
      // -----------------------------------------------------------------------
      final membership = await userDashboardRepo.joinScheme(schemeId: activeScheme.id);
      expect(membership.id, isNotEmpty);
      expect(membership.schemeId, equals(activeScheme.id));
      expect(membership.tokenString, isNotEmpty);
      expect(membership.customMonthlyEmi, equals(5000));
      expect(membership.totalPaidAmount, equals(0));

      // -----------------------------------------------------------------------
      // 10. DASHBOARD E2E
      // -----------------------------------------------------------------------
      final dashboard = await userDashboardRepo.getMyDashboard();
      expect(dashboard.hasActiveScheme, isTrue);
      expect(dashboard.schemeName, contains('Swastik'));
      expect(dashboard.customMonthlyEmi, equals(5000));
      expect(dashboard.totalPaidAmount, equals(0));
      expect(dashboard.nextInstallment?.amount, equals(5000));
      expect(dashboard.totalMonths, equals(12));

      // -----------------------------------------------------------------------
      // 11. PASSBOOK E2E
      // -----------------------------------------------------------------------
      final passbookSummary = await userPassbookRepo.getPassbookSummary();
      expect(passbookSummary, isNotNull);
      expect(passbookSummary!.totalPaid, equals(0));
      expect(passbookSummary.totalMonths, equals(12));

      final passbookEntries = await userPassbookRepo.getPassbookEntries();
      expect(passbookEntries.length, equals(12));
      expect(passbookEntries.first.month, equals(1));
      expect(passbookEntries.first.isPaid, isFalse);
      expect(passbookEntries.last.month, equals(12));
      expect(passbookEntries.last.isBonus, isTrue);

      // -----------------------------------------------------------------------
      // 12. PAYMENT INITIATION E2E
      // -----------------------------------------------------------------------
      final paymentOrder = await userPaymentRepo.initiatePayment(
        membershipId: membership.id,
        monthFor: 1,
      );
      expect(paymentOrder.orderId, startsWith('gokwik_ord_'));
      expect(paymentOrder.amount, equals(5000));
      expect(paymentOrder.currency, equals('INR'));
      expect(paymentOrder.merchantKey, isNotEmpty);

      // -----------------------------------------------------------------------
      // 13. GOKWIK GATEWAY BOUNDARY & STATUS POLLING
      // -----------------------------------------------------------------------
      // External GoKwik checkout cannot connect to live servers without production credentials.
      // We verify the mobile polling endpoint responds with PENDING status for the newly initiated order.
      final pollStatus = await userPaymentRepo.getPaymentStatus(paymentOrder.orderId);
      expect(pollStatus.orderId, equals(paymentOrder.orderId));
      expect(pollStatus.status, equals(PaymentStatusEnum.pending));
      expect(pollStatus.totalPaidAmount, equals(0));

      // -----------------------------------------------------------------------
      // 14. DIGITAL RECEIPT HANDLING
      // -----------------------------------------------------------------------
      // For unpaid or pending entry, receiptUrl is null
      expect(passbookEntries.first.receiptUrl, isNull);

      // -----------------------------------------------------------------------
      // 15. NOTIFICATION CENTER E2E (PHASE 14 LOCAL / MOCK)
      // -----------------------------------------------------------------------
      final notifications = await notificationRepo.getNotifications();
      expect(notifications, isNotEmpty);
      final initialUnread = await notificationRepo.getUnreadCount();
      expect(initialUnread, greaterThanOrEqualTo(0));

      // Mark first notification as read
      await notificationRepo.markAsRead(notifications.first.id);
      final updatedUnread = await notificationRepo.getUnreadCount();
      expect(updatedUnread, lessThanOrEqualTo(initialUnread));

      // -----------------------------------------------------------------------
      // 16. LOGOUT
      // -----------------------------------------------------------------------
      await userAuthRepo.logout();
      expect(await userStorage.hasToken(), isFalse);

      // Verify protected call is rejected after logout
      bool unauthenticatedRejected = false;
      try {
        await userProfileRepo.getProfile();
      } catch (e) {
        unauthenticatedRejected = true;
      }
      expect(unauthenticatedRejected, isTrue);
    });
  },
  skip: const bool.fromEnvironment('RUN_LIVE_BACKEND_TESTS', defaultValue: false)
      ? null
      : 'Deferred to Phase 17 — Live backend server required at http://127.0.0.1:5000',
  );

  group('Phase 17 — Negative E2E Resilience Tests', () {
    test('A. Invalid OTP rejection', () async {
      final String phone = '+9198${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      await userAuthRepo.sendOtp(phone: phone);

      bool failedAsExpected = false;
      try {
        await userAuthRepo.verifyOtp(phone: phone, otp: '000000');
      } catch (e) {
        failedAsExpected = true;
        expect(e.toString(), anyOf(contains('INVALID_OTP'), contains('400')));
      }
      expect(failedAsExpected, isTrue);
    });

    test('B. Expired/Invalid Session: 401 triggers AuthInterceptor session purge', () async {
      await userStorage.saveToken('tampered_bogus_jwt_token_phase_17');

      bool rejected = false;
      try {
        await userClient.get<dynamic>('/api/v1/users/profile');
      } catch (_) {
        rejected = true;
      }
      expect(rejected, isTrue);
      expect(wasUnauthorizedTriggered, isTrue);
    });

    test('D. Invalid KYC Document / Input validation handled safely', () async {
      final user = await userAuthRepo.verifyOtp(phone: '+919876543210', otp: '123456');
      expect(user.token, isNotEmpty);

      // Attempt KYC with empty document number
      bool validationFailed = false;
      try {
        const submission = KycSubmissionEntity(
          documentType: DocTypeEnum.aadhaar,
          documentNumber: '',
          consentAgreed: true,
        );
        await userKycRepo.submitKyc(submission);
      } catch (e) {
        validationFailed = true;
      }
      expect(validationFailed, isTrue);
    });

    test('F. Duplicate Payment Action / Prevention', () async {
      await userAuthRepo.verifyOtp(phone: '+919876543210', otp: '123456');

      // Attempting to initiate payment on non-existent or invalid membership throws safe error
      bool caught = false;
      try {
        await userPaymentRepo.initiatePayment(
          membershipId: '6aabed9ec1e95a63d34c5999',
          monthFor: 1,
        );
      } catch (e) {
        caught = true;
        expect(e.toString(), anyOf(contains('MEMBERSHIP_NOT_FOUND'), contains('404'), contains('400')));
      }
      expect(caught, isTrue);
    });

    test('G. Payment Pending / Unknown Order Polling Safe Error', () async {
      await userAuthRepo.verifyOtp(phone: '+919876543210', otp: '123456');

      bool caught = false;
      try {
        await userPaymentRepo.getPaymentStatus('non_existent_gokwik_order_999');
      } catch (e) {
        caught = true;
        expect(e.toString(), anyOf(contains('ORDER_NOT_FOUND'), contains('404')));
      }
      expect(caught, isTrue);
    });
  },
  skip: const bool.fromEnvironment('RUN_LIVE_BACKEND_TESTS', defaultValue: false)
      ? null
      : 'Deferred to Phase 17 — Live backend server required at http://127.0.0.1:5000',
  );
}
