import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/enums/app_enums.dart';
import 'package:kitty_app/core/errors/app_exception.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:kitty_app/features/kyc/domain/entities/kyc_entity.dart';
import 'package:kitty_app/features/kyc/data/repositories/mock_kyc_repository.dart';
import 'package:kitty_app/features/offers/data/repositories/mock_scheme_repository.dart';
import 'package:kitty_app/features/offers/data/repositories/mock_offer_repository.dart';
import 'package:kitty_app/features/dashboard/data/repositories/mock_dashboard_repository.dart';
import 'package:kitty_app/features/passbook/data/repositories/mock_passbook_repository.dart';
import 'package:kitty_app/features/checkout/data/repositories/mock_payment_repository.dart';
import 'package:kitty_app/features/home/data/repositories/mock_gold_rate_repository.dart';
import 'package:kitty_app/features/home/data/repositories/mock_product_repository.dart';
import 'package:kitty_app/features/notifications/data/repositories/mock_notification_repository.dart';
import 'package:kitty_app/features/receipt/data/repositories/mock_receipt_repository.dart';
import 'package:kitty_app/features/settings/domain/entities/profile_entity.dart';
import 'package:kitty_app/features/settings/data/repositories/mock_profile_repository.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues(<String, String>{});

  late MockEngineConfig engineConfig;

  setUp(() {
    engineConfig = MockEngineConfig(latency: MockLatency.instant);
  });

  group('Mock Repositories Tests', () {
    test('MockAuthRepository handles sendOtp, verifyOtp, and logout', () async {
      final repo = MockAuthRepository(engineConfig: engineConfig);

      final otpResult = await repo.sendOtp(phone: '+919876543210');
      expect(otpResult.sessionId, isNotEmpty);
      expect(otpResult.expiresInSeconds, 300);

      // Verify OTP with sandbox OTP
      final session = await repo.verifyOtp(phone: '+919876543210', otp: '123456');
      expect(session.token, isNotEmpty);
      expect(session.user.name, 'Rihan Saifi');

      // Invalid phone check
      expect(
        () => repo.sendOtp(phone: '123'),
        throwsA(isA<ValidationException>()),
      );

      // Invalid OTP check
      expect(
        () => repo.verifyOtp(phone: '+919876543210', otp: '000000'),
        throwsA(isA<ValidationException>()),
      );

      await repo.logout();
    });

    test('MockKycRepository validates document length, consent, and 10MB limit', () async {
      final repo = MockKycRepository(engineConfig: engineConfig);

      // 1. Valid Aadhaar submission
      const validSubmission = KycSubmissionEntity(
        documentType: DocTypeEnum.aadhaar,
        documentNumber: '123456789012',
        consentAgreed: true,
        fileSizeBytes: 2 * 1024 * 1024, // 2 MB
      );
      final result = await repo.submitKyc(validSubmission);
      expect(result.status, KycStatusEnum.pending);
      expect(result.documentNumberMasked, contains('9012'));

      // 2. Over 10MB rejection
      const oversizedSubmission = KycSubmissionEntity(
        documentType: DocTypeEnum.aadhaar,
        documentNumber: '123456789012',
        consentAgreed: true,
        fileSizeBytes: 12 * 1024 * 1024, // 12 MB
      );
      expect(
        () => repo.submitKyc(oversizedSubmission),
        throwsA(isA<ValidationException>()),
      );

      // 3. Invalid PAN format
      const invalidPanSubmission = KycSubmissionEntity(
        documentType: DocTypeEnum.pan,
        documentNumber: 'INVALID_PAN',
        consentAgreed: true,
      );
      expect(
        () => repo.submitKyc(invalidPanSubmission),
        throwsA(isA<ValidationException>()),
      );

      // 4. Missing consent
      const noConsent = KycSubmissionEntity(
        documentType: DocTypeEnum.aadhaar,
        documentNumber: '123456789012',
        consentAgreed: false,
      );
      expect(
        () => repo.submitKyc(noConsent),
        throwsA(isA<ValidationException>()),
      );
    });

    test('MockSchemeRepository and MockOfferRepository return active lists', () async {
      final schemeRepo = MockSchemeRepository(engineConfig: engineConfig);
      final offerRepo = MockOfferRepository(engineConfig: engineConfig);

      final schemes = await schemeRepo.getActiveSchemes();
      expect(schemes.length, 3);
      expect(schemes.first.monthlyInstallment, 5000);

      final scheme12 = await schemeRepo.getSchemeById('sch_12month_suvarna');
      expect(scheme12.name, 'Swastik Suvarna Varsha');

      final filtered = await schemeRepo.getActiveSchemes(durationFilter: 12);
      expect(filtered.length, 1);

      final offers = await offerRepo.getActiveOffers();
      expect(offers.length, 2);
    });

    test('MockDashboardRepository and MockPassbookRepository return data', () async {
      final dashRepo = MockDashboardRepository(engineConfig: engineConfig);
      final passbookRepo = MockPassbookRepository(engineConfig: engineConfig);

      final dash = await dashRepo.getMyDashboard();
      expect(dash.hasActiveScheme, isTrue);
      expect(dash.accumulatedGoldGrams, 5.482);

      dashRepo.setHasActiveScheme(false);
      final emptyDash = await dashRepo.getMyDashboard();
      expect(emptyDash.hasActiveScheme, isFalse);

      final passbook = await passbookRepo.getPassbookEntries();
      expect(passbook.length, 12);
    });

    test('MockPaymentRepository handles initiation and polling state progression', () async {
      final repo = MockPaymentRepository(engineConfig: engineConfig);
      repo.configurePolling(requiredPolls: 2, finalStatus: PaymentStatusEnum.success);

      final order = await repo.initiatePayment(membershipId: 'mem_994411', monthFor: 9);
      expect(order.orderId, 'gokwik_ord_771829');
      expect(order.amount, 5000);

      // Poll 1: Pending
      final poll1 = await repo.getPaymentStatus(order.orderId);
      expect(poll1.status, PaymentStatusEnum.pending);

      // Poll 2: Pending
      final poll2 = await repo.getPaymentStatus(order.orderId);
      expect(poll2.status, PaymentStatusEnum.pending);

      // Poll 3: Success
      final poll3 = await repo.getPaymentStatus(order.orderId);
      expect(poll3.status, PaymentStatusEnum.success);
      expect(poll3.transactionId, 'TXN-SW-50291');
    });

    test('MockGoldRateRepository and MockProductRepository return catalog', () async {
      final goldRepo = MockGoldRateRepository(engineConfig: engineConfig);
      final productRepo = MockProductRepository(engineConfig: engineConfig);

      final rate = await goldRepo.getLiveGoldRate();
      expect(rate.ratePerGram, 15268.000);

      final categories = await productRepo.getCategories();
      expect(categories.length, 6);

      final products = await productRepo.getCuratedProducts();
      expect(products.length, 6);
    });

    test('MockNotificationRepository, MockReceiptRepository, and MockProfileRepository', () async {
      final notifRepo = MockNotificationRepository(engineConfig: engineConfig);
      final receiptRepo = MockReceiptRepository(engineConfig: engineConfig);
      final profileRepo = MockProfileRepository(engineConfig: engineConfig);

      // Notifications
      final notifs = await notifRepo.getNotifications();
      expect(notifs.length, 5);
      final unreadBefore = await notifRepo.getUnreadCount();
      expect(unreadBefore, 3);
      await notifRepo.markAllAsRead();
      final unreadAfter = await notifRepo.getUnreadCount();
      expect(unreadAfter, 0);

      // Receipt
      final receipt = await receiptRepo.getReceipt('rec_10821');
      expect(receipt.amount, 5000);
      final pdfBytes = await receiptRepo.downloadReceiptPdf('rec_10821');
      expect(pdfBytes, isNotEmpty);

      // Profile
      final profile = await profileRepo.getProfile();
      expect(profile.name, 'Rihan Saifi');
      final updatedProfile = await profileRepo.updateProfile(name: 'Rihan S.');
      expect(updatedProfile.name, 'Rihan S.');
      final updatedPrefs = await profileRepo.updatePreferences(
        const UserPreferencesEntity(themeMode: 'dark', language: 'hi'),
      );
      expect(updatedPrefs.themeMode, 'dark');
      expect(updatedPrefs.language, 'hi');
    });
  });
}
