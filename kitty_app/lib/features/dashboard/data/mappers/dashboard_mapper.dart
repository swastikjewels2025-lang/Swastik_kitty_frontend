import '../../../../core/enums/app_enums.dart';
import '../../../passbook/data/mappers/passbook_mapper.dart';
import '../../domain/entities/dashboard_summary_entity.dart';
import '../dtos/dashboard_dto.dart';

/// Mapper between Dashboard DTOs and Domain Entities.
abstract final class DashboardMapper {
  static NextInstallmentEntity? toNextInstallmentEntity(NextInstallmentDto? dto) {
    if (dto == null) return null;
    final DateTime parsedDueDate = DateTime.tryParse(dto.dueDate)?.toUtc() ??
        DateTime.now().toUtc().add(Duration(days: dto.daysRemaining));

    return NextInstallmentEntity(
      month: dto.month,
      amount: dto.amount,
      dueDate: parsedDueDate,
      daysRemaining: dto.daysRemaining,
    );
  }

  static DashboardSummaryEntity toEntity(DashboardSummaryResponseDto dto) {
    if (!dto.hasActiveScheme || dto.dashboard == null) {
      return const DashboardSummaryEntity(hasActiveScheme: false);
    }

    final DashboardDetailsDto d = dto.dashboard!;

    return DashboardSummaryEntity(
      hasActiveScheme: true,
      membershipId: d.membershipId,
      chitToken: d.chitToken,
      schemeName: d.schemeName,
      targetAmount: d.targetAmount,
      customMonthlyEmi: d.customMonthlyEmi,
      totalMonths: d.totalMonths,
      monthsPaid: d.monthsPaid,
      totalPaidAmount: d.totalPaidAmount,
      remainingAmount: d.remainingAmount,
      accumulatedGoldGrams: d.accumulatedGoldGrams,
      currentValuation: d.currentValuation,
      valuationGainPct: d.valuationGainPct,
      nextInstallment: toNextInstallmentEntity(d.nextInstallment),
      passbook: d.passbook.map<dynamic>(PassbookMapper.toEntity).toList().cast(),
      status: MembershipStatusEnum.fromString(d.status),
      startDate: d.startDate != null ? DateTime.tryParse(d.startDate!)?.toUtc() : null,
      endDate: d.endDate != null ? DateTime.tryParse(d.endDate!)?.toUtc() : null,
    );
  }
}
