import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/enums/app_enums.dart';
import 'package:kitty_app/core/mock/mock_fixtures.dart';
import 'package:kitty_app/features/auth/data/dtos/auth_dto.dart';
import 'package:kitty_app/features/auth/data/mappers/auth_mapper.dart';
import 'package:kitty_app/features/kyc/data/dtos/kyc_dto.dart';
import 'package:kitty_app/features/kyc/data/mappers/kyc_mapper.dart';
import 'package:kitty_app/features/offers/data/dtos/scheme_dto.dart';
import 'package:kitty_app/features/offers/data/mappers/scheme_mapper.dart';
import 'package:kitty_app/features/dashboard/data/dtos/dashboard_dto.dart';
import 'package:kitty_app/features/dashboard/data/mappers/dashboard_mapper.dart';
import 'package:kitty_app/features/home/data/dtos/gold_rate_dto.dart';
import 'package:kitty_app/features/home/data/dtos/product_dto.dart';
import 'package:kitty_app/features/home/data/mappers/home_mapper.dart';
import 'package:kitty_app/features/notifications/data/models/notification_dto.dart';
import 'package:kitty_app/features/notifications/data/mappers/notification_mapper.dart';
import 'package:kitty_app/features/receipt/data/models/receipt_dto.dart';
import 'package:kitty_app/features/receipt/data/mappers/receipt_mapper.dart';
import 'package:kitty_app/features/settings/data/models/profile_dto.dart';
import 'package:kitty_app/features/settings/data/mappers/profile_mapper.dart';

void main() {
  group('Data Mapper Tests (Frozen Contract v1.0 Compliance)', () {
    test('AuthMapper maps DTO to Entity correctly', () {
      final verifyDto = VerifyOtpResponseDto.fromJson(
        MockFixtures.authVerifySuccessJson['data'] as Map<String, dynamic>,
      );
      final entity = AuthMapper.toSessionEntity(verifyDto);

      expect(entity.token, verifyDto.token);
      expect(entity.user.id, 'usr_654321abcdef');
      expect(entity.user.role, UserRoleEnum.customer);
      expect(entity.user.kyc.isVerified, isTrue);
      expect(entity.user.kyc.status, KycStatusEnum.verified);
      expect(entity.user.kyc.documentType, DocTypeEnum.aadhaar);
    });

    test('KycMapper maps submission and result DTOs to Entities', () {
      final kycDto = KycSubmitResponseDto.fromJson(
        MockFixtures.kycSubmitSuccessJson['data'] as Map<String, dynamic>,
      );
      final entity = KycMapper.toEntity(kycDto);

      expect(entity.referenceId, 'KYC-849201');
      expect(entity.status, KycStatusEnum.pending);
      expect(entity.documentType, DocTypeEnum.aadhaar);
      expect(entity.submittedAt?.isUtc, isTrue);
    });

    test('SchemeMapper maps SchemeDto preserving whole integer rupees', () {
      final rawList = MockFixtures.activeSchemesJson['data']['schemes'] as List<dynamic>;
      final dto = SchemeDto.fromJson(rawList.first as Map<String, dynamic>);
      final entity = SchemeMapper.toEntity(dto);

      expect(entity.id, 'sch_12month_suvarna');
      expect(entity.monthlyInstallment, 5000);
      expect(entity.targetAmount, 60000);
      expect(entity.durationMonths, 12);
      expect(entity.status, SchemeStatusEnum.open);
      expect(entity.isPopular, isTrue);
    });

    test('DashboardMapper and PassbookMapper preserve whole rupees & 3-decimal gold', () {
      final dto = DashboardSummaryResponseDto.fromJson(
        MockFixtures.dashboardActiveSuvarnaJson['data'] as Map<String, dynamic>,
      );
      final entity = DashboardMapper.toEntity(dto);

      expect(entity.hasActiveScheme, isTrue);
      expect(entity.chitToken, '#SW-042');
      expect(entity.targetAmount, 60000);
      expect(entity.customMonthlyEmi, 5000);
      expect(entity.totalMonths, 12);
      expect(entity.monthsPaid, 8);
      expect(entity.totalPaidAmount, 40000);
      expect(entity.remainingAmount, 15000);
      expect(entity.accumulatedGoldGrams, 5.482);
      expect(entity.currentValuation, 41036);
      expect(entity.progressPercentage, 67);

      expect(entity.passbook.length, 12);
      expect(entity.passbook.first.status, InstallmentStatusEnum.paid);
      expect(entity.passbook.first.goldGrams, 0.702);
      expect(entity.passbook[8].status, InstallmentStatusEnum.current);
      expect(entity.passbook[11].status, InstallmentStatusEnum.bonus);
    });

    test('HomeMapper maps GoldRate and Product preserving exact precisions', () {
      final rateDto = LiveGoldRateDto.fromJson(
        MockFixtures.liveGoldRateJson['data'] as Map<String, dynamic>,
      );
      final rateEntity = HomeMapper.toGoldRateEntity(rateDto);

      expect(rateEntity.ratePerGram, 15268.000);
      expect(rateEntity.change24h, -16.000);
      expect(rateEntity.purityFraction, 0.999);
      expect(rateEntity.updatedAt.isUtc, isTrue);

      final productsRaw = MockFixtures.curatedProductsJson['data']['products'] as List<dynamic>;
      final productDto = ProductDto.fromJson(productsRaw.first as Map<String, dynamic>);
      final productEntity = HomeMapper.toProductEntity(productDto);

      expect(productEntity.weightGrams, 28.450);
      expect(productEntity.estimatedPrice, 218500);
    });

    test('NotificationMapper, ReceiptMapper, and ProfileMapper mapping precision', () {
      final notifsRaw = MockFixtures.notificationsListJson['data']['notifications'] as List<dynamic>;
      final notifDto = NotificationDto.fromJson(notifsRaw.first as Map<String, dynamic>);
      final notifEntity = NotificationMapper.toEntity(notifDto);
      expect(notifEntity.type, NotificationTypeEnum.transaction);
      expect(notifEntity.createdAt.isUtc, isTrue);

      final receiptDto = ReceiptDto.fromJson(
        MockFixtures.digitalReceiptJson['data'] as Map<String, dynamic>,
      );
      final receiptEntity = ReceiptMapper.toEntity(receiptDto);
      expect(receiptEntity.receiptId, 'rec_10821');
      expect(receiptEntity.amount, 5000);
      expect(receiptEntity.goldRateAtPayment, 15268.000);
      expect(receiptEntity.goldWeightCreditedGrams, 0.327);

      final profileDto = ProfileDto.fromJson(
        MockFixtures.userProfileJson['data'] as Map<String, dynamic>,
      );
      final profileEntity = ProfileMapper.toEntity(profileDto);
      expect(profileEntity.name, 'Rihan Saifi');
      expect(profileEntity.role, UserRoleEnum.customer);
      expect(profileEntity.preferences.biometricEnabled, isTrue);
    });
  });
}
