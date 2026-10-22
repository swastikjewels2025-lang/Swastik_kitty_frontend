import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/mock/mock_fixtures.dart';
import 'package:kitty_app/features/auth/data/dtos/auth_dto.dart';
import 'package:kitty_app/features/kyc/data/dtos/kyc_dto.dart';
import 'package:kitty_app/features/offers/data/dtos/scheme_dto.dart';
import 'package:kitty_app/features/offers/data/dtos/offer_dto.dart';
import 'package:kitty_app/features/dashboard/data/dtos/dashboard_dto.dart';
import 'package:kitty_app/features/checkout/data/dtos/payment_dto.dart';
import 'package:kitty_app/features/home/data/dtos/gold_rate_dto.dart';
import 'package:kitty_app/features/home/data/dtos/product_dto.dart';
import 'package:kitty_app/features/notifications/data/models/notification_dto.dart';
import 'package:kitty_app/features/receipt/data/models/receipt_dto.dart';
import 'package:kitty_app/features/settings/data/models/profile_dto.dart';

void main() {
  group('DTO Serialization & Deserialization Tests', () {
    test('Auth DTOs deserialize from MockFixtures', () {
      final sendOtpDto = SendOtpResponseDto.fromJson(
        MockFixtures.authSendOtpSuccessJson['data'] as Map<String, dynamic>,
      );
      expect(sendOtpDto.sessionId, 'sess_otp_88992211');
      expect(sendOtpDto.expiresInSeconds, 300);

      final verifyDto = VerifyOtpResponseDto.fromJson(
        MockFixtures.authVerifySuccessJson['data'] as Map<String, dynamic>,
      );
      expect(verifyDto.token.isNotEmpty, isTrue);
      expect(verifyDto.user.name, 'Rihan Saifi');
      expect(verifyDto.user.kyc?.isVerified, isTrue);
    });

    test('KYC DTO deserialization and serialization', () {
      final kycDto = KycSubmitResponseDto.fromJson(
        MockFixtures.kycSubmitSuccessJson['data'] as Map<String, dynamic>,
      );
      expect(kycDto.referenceId, 'KYC-849201');
      expect(kycDto.status, 'PENDING');
      expect(kycDto.documentType, 'AADHAAR');

      final json = kycDto.toJson();
      expect(json['referenceId'], 'KYC-849201');
    });

    test('Schemes and Offers DTOs deserialization', () {
      final schemesRaw = MockFixtures.activeSchemesJson['data']['schemes'] as List<dynamic>;
      final schemes = schemesRaw
          .map((e) => SchemeDto.fromJson(e as Map<String, dynamic>))
          .toList();
      expect(schemes.length, 3);
      expect(schemes.first.id, 'sch_12month_suvarna');
      expect(schemes.first.monthlyInstallment, 5000); // Whole integer rupees
      expect(schemes.first.targetAmount, 60000);

      final offersRaw = MockFixtures.activeOffersJson['data']['offers'] as List<dynamic>;
      final offers = offersRaw
          .map((e) => OfferDto.fromJson(e as Map<String, dynamic>))
          .toList();
      expect(offers.length, 2);
      expect(offers.first.code, 'DIWALI2026');
    });

    test('Dashboard and Passbook DTOs preserve whole integer rupees & 3-decimal gold', () {
      final dashDto = DashboardSummaryResponseDto.fromJson(
        MockFixtures.dashboardActiveSuvarnaJson['data'] as Map<String, dynamic>,
      );
      expect(dashDto.hasActiveScheme, isTrue);
      expect(dashDto.dashboard?.targetAmount, 60000);
      expect(dashDto.dashboard?.totalPaidAmount, 40000);
      expect(dashDto.dashboard?.accumulatedGoldGrams, 5.482);
      expect(dashDto.dashboard?.passbook.length, 12);

      final firstEntry = dashDto.dashboard!.passbook.first;
      expect(firstEntry.month, 1);
      expect(firstEntry.amount, 5000);
      expect(firstEntry.goldGrams, 0.702);
      expect(firstEntry.status, 'PAID');
    });

    test('Payment DTOs deserialization', () {
      final initDto = PaymentInitiateResponseDto.fromJson(
        MockFixtures.paymentInitiateSuccessJson['data'] as Map<String, dynamic>,
      );
      expect(initDto.orderId, 'gokwik_ord_771829');
      expect(initDto.amount, 5000);

      final statusDto = PaymentStatusResponseDto.fromJson(
        MockFixtures.paymentStatusSuccessJson['data'] as Map<String, dynamic>,
      );
      expect(statusDto.status, 'SUCCESS');
      expect(statusDto.transactionId, 'TXN-SW-50291');
    });

    test('Live Gold Rate and Product DTOs preserve 3-decimal precision', () {
      final rateDto = LiveGoldRateDto.fromJson(
        MockFixtures.liveGoldRateJson['data'] as Map<String, dynamic>,
      );
      expect(rateDto.ratePerGram, 15268.000);
      expect(rateDto.change24h, -16.000);

      final productsRaw = MockFixtures.curatedProductsJson['data']['products'] as List<dynamic>;
      final products = productsRaw
          .map((e) => ProductDto.fromJson(e as Map<String, dynamic>))
          .toList();
      expect(products.first.weightGrams, 28.450);
      expect(products.first.estimatedPrice, 218500);
    });

    test('Notification, Receipt, and Profile DTOs deserialization', () {
      final notifsRaw = MockFixtures.notificationsListJson['data']['notifications'] as List<dynamic>;
      final notifDto = NotificationDto.fromJson(notifsRaw.first as Map<String, dynamic>);
      expect(notifDto.id, 'notif_001');

      final receiptDto = ReceiptDto.fromJson(
        MockFixtures.digitalReceiptJson['data'] as Map<String, dynamic>,
      );
      expect(receiptDto.receiptId, 'rec_10821');
      expect(receiptDto.goldRateAtPayment, 15268.000);
      expect(receiptDto.goldWeightCreditedGrams, 0.327);

      final profileDto = ProfileDto.fromJson(
        MockFixtures.userProfileJson['data'] as Map<String, dynamic>,
      );
      expect(profileDto.name, 'Rihan Saifi');
      expect(profileDto.preferences.language, 'en');
    });
  });
}
