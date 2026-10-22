import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/enums/app_enums.dart';
import 'package:kitty_app/features/dashboard/data/dtos/dashboard_dto.dart';
import 'package:kitty_app/features/dashboard/data/mappers/dashboard_mapper.dart';
import 'package:kitty_app/features/dashboard/domain/entities/dashboard_summary_entity.dart';

void main() {
  group('Dashboard Mapping & Domain Calculation Tests', () {
    test('DashboardMapper maps active scheme response accurately', () {
      const dto = DashboardSummaryResponseDto(
        hasActiveScheme: true,
        dashboard: DashboardDetailsDto(
          membershipId: 'mem_123',
          chitToken: '#SW-042',
          schemeName: 'Swastik Suvarna Varsha',
          targetAmount: 60000,
          customMonthlyEmi: 5000,
          totalMonths: 12,
          monthsPaid: 8,
          totalPaidAmount: 40000,
          remainingAmount: 15000,
          accumulatedGoldGrams: 5.482,
          currentValuation: 41036,
          valuationGainPct: 2.59,
          nextInstallment: NextInstallmentDto(
            month: 9,
            amount: 5000,
            dueDate: '2026-09-15T00:00:00.000Z',
            daysRemaining: 5,
          ),
          passbook: [],
          status: 'ACTIVE',
        ),
      );

      final entity = DashboardMapper.toEntity(dto);

      expect(entity.hasActiveScheme, isTrue);
      expect(entity.membershipId, 'mem_123');
      expect(entity.chitToken, '#SW-042');
      expect(entity.schemeName, 'Swastik Suvarna Varsha');
      expect(entity.targetAmount, 60000);
      expect(entity.customMonthlyEmi, 5000);
      expect(entity.totalMonths, 12);
      expect(entity.monthsPaid, 8);
      expect(entity.totalPaidAmount, 40000);
      expect(entity.remainingAmount, 15000);
      expect(entity.accumulatedGoldGrams, 5.482);
      expect(entity.currentValuation, 41036);
      expect(entity.valuationGainPct, 2.59);
      expect(entity.progressRatio, closeTo(0.666, 0.001));
      expect(entity.progressPercentage, 67);
      expect(entity.remainingMonthsPayable, 3); // (12 - 1) - 8 = 3
      expect(entity.isPreJoin, isFalse);
      expect(entity.isCompleted, isFalse);
      expect(entity.status, MembershipStatusEnum.active);
      expect(entity.nextInstallment, isNotNull);
      expect(entity.nextInstallment!.month, 9);
      expect(entity.nextInstallment!.amount, 5000);
      expect(entity.nextInstallment!.daysRemaining, 5);
    });

    test('DashboardMapper handles null/empty dashboard safely', () {
      const dto = DashboardSummaryResponseDto(
        hasActiveScheme: false,
        dashboard: null,
      );

      final entity = DashboardMapper.toEntity(dto);
      expect(entity.hasActiveScheme, isFalse);
      expect(entity.progressRatio, 0.0);
      expect(entity.progressPercentage, 0);
      expect(entity.remainingMonthsPayable, 0);
    });

    test('PRE_JOIN status deserializes safely', () {
      const dto = DashboardSummaryResponseDto(
        hasActiveScheme: true,
        dashboard: DashboardDetailsDto(
          membershipId: 'mem_prejoin',
          chitToken: '#SW-099',
          schemeName: 'Pre-Join Scheme',
          targetAmount: 60000,
          customMonthlyEmi: 5000,
          totalMonths: 12,
          monthsPaid: 0,
          totalPaidAmount: 0,
          remainingAmount: 60000,
          accumulatedGoldGrams: 0.0,
          currentValuation: 0,
          valuationGainPct: 0.0,
          passbook: [],
          status: 'PRE_JOIN',
        ),
      );

      final entity = DashboardMapper.toEntity(dto);
      expect(entity.status, MembershipStatusEnum.preJoin);
      expect(entity.isPreJoin, isTrue);
    });

    test('Unknown status deserializes to unknown without crashing', () {
      const dto = DashboardSummaryResponseDto(
        hasActiveScheme: true,
        dashboard: DashboardDetailsDto(
          membershipId: 'mem_unknown',
          chitToken: '#SW-999',
          schemeName: 'Future Scheme',
          targetAmount: 60000,
          customMonthlyEmi: 5000,
          totalMonths: 12,
          monthsPaid: 0,
          totalPaidAmount: 0,
          remainingAmount: 60000,
          accumulatedGoldGrams: 0.0,
          currentValuation: 0,
          valuationGainPct: 0.0,
          passbook: [],
          status: 'FUTURE_SPECIAL_TIER_STATUS',
        ),
      );

      final entity = DashboardMapper.toEntity(dto);
      expect(entity.status, MembershipStatusEnum.unknown);
    });

    test('progressRatio protects against zero totalMonths', () {
      const entity = DashboardSummaryEntity(
        hasActiveScheme: true,
        totalMonths: 0,
        monthsPaid: 5,
      );

      expect(entity.progressRatio, 0.0);
      expect(entity.progressPercentage, 0);
    });
  });
}
