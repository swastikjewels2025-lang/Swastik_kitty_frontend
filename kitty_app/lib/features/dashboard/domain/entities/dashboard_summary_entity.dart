import '../../../../core/enums/app_enums.dart';
import '../../../passbook/domain/entities/passbook_entry_entity.dart';

/// Next installment due summary.
class NextInstallmentEntity {
  const NextInstallmentEntity({
    required this.month,
    required this.amount,
    required this.dueDate,
    required this.daysRemaining,
  });

  final int month;
  final int amount; // Whole integer rupees
  final DateTime dueDate;
  final int daysRemaining;
}

/// Pure domain entity representing aggregated active scheme dashboard metrics.
class DashboardSummaryEntity {
  const DashboardSummaryEntity({
    required this.hasActiveScheme,
    this.membershipId,
    this.chitToken,
    this.schemeName,
    this.targetAmount,
    this.customMonthlyEmi,
    this.totalMonths,
    this.monthsPaid,
    this.totalPaidAmount,
    this.remainingAmount,
    this.accumulatedGoldGrams,
    this.currentValuation,
    this.valuationGainPct,
    this.nextInstallment,
    this.passbook = const <PassbookEntryEntity>[],
    this.status = MembershipStatusEnum.active,
    this.startDate,
    this.endDate,
  });

  final bool hasActiveScheme;
  final String? membershipId;
  final String? chitToken; // e.g. "#SW-042"
  final String? schemeName;
  final int? targetAmount; // Whole integer rupees
  final int? customMonthlyEmi; // Whole integer rupees
  final int? totalMonths;
  final int? monthsPaid;
  final int? totalPaidAmount; // Whole integer rupees
  final int? remainingAmount; // Whole integer rupees
  final double? accumulatedGoldGrams; // 3 Decimal precision
  final int? currentValuation; // Whole integer rupees
  final double? valuationGainPct;
  final NextInstallmentEntity? nextInstallment;
  final List<PassbookEntryEntity> passbook;
  final MembershipStatusEnum status;
  final DateTime? startDate;
  final DateTime? endDate;

  double get progressRatio {
    if (totalMonths == null || totalMonths == 0 || monthsPaid == null) return 0.0;
    return (monthsPaid! / totalMonths!).clamp(0.0, 1.0);
  }

  int get progressPercentage {
    return (progressRatio * 100).round();
  }

  int get remainingMonthsPayable {
    if (totalMonths == null || monthsPaid == null) return 0;
    // 12th month is free bonus, so payable remaining = totalMonths - 1 - monthsPaid
    final int payable = (totalMonths! - 1) - monthsPaid!;
    return payable < 0 ? 0 : payable;
  }

  bool get isPreJoin => status == MembershipStatusEnum.preJoin;
  bool get isCompleted => (totalMonths != null && monthsPaid != null && monthsPaid! >= totalMonths!) || status == MembershipStatusEnum.completed;
}
