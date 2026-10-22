import '../../../passbook/data/dtos/passbook_dto.dart';

/// Next installment due DTO.
class NextInstallmentDto {
  const NextInstallmentDto({
    required this.month,
    required this.amount,
    required this.dueDate,
    required this.daysRemaining,
  });

  factory NextInstallmentDto.fromJson(Map<String, dynamic> json) {
    return NextInstallmentDto(
      month: json['month'] as int? ?? 1,
      amount: json['amount'] as int? ?? 0,
      dueDate: json['dueDate'] as String? ?? '',
      daysRemaining: json['daysRemaining'] as int? ?? 0,
    );
  }

  final int month;
  final int amount;
  final String dueDate;
  final int daysRemaining;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'month': month,
        'amount': amount,
        'dueDate': dueDate,
        'daysRemaining': daysRemaining,
      };
}

/// Aggregated Dashboard Data DTO.
class DashboardDetailsDto {
  const DashboardDetailsDto({
    required this.membershipId,
    required this.chitToken,
    required this.schemeName,
    required this.targetAmount,
    required this.customMonthlyEmi,
    required this.totalMonths,
    required this.monthsPaid,
    required this.totalPaidAmount,
    required this.remainingAmount,
    required this.accumulatedGoldGrams,
    required this.currentValuation,
    required this.valuationGainPct,
    this.nextInstallment,
    required this.passbook,
    this.status = 'ACTIVE',
    this.startDate,
    this.endDate,
  });

  factory DashboardDetailsDto.fromJson(Map<String, dynamic> json) {
    return DashboardDetailsDto(
      membershipId: json['membershipId'] as String? ?? '',
      chitToken: json['chitToken'] as String? ?? '#SW-001',
      schemeName: json['schemeName'] as String? ?? '',
      targetAmount: json['targetAmount'] as int? ?? 0,
      customMonthlyEmi: json['customMonthlyEmi'] as int? ?? 0,
      totalMonths: json['totalMonths'] as int? ?? 12,
      monthsPaid: json['monthsPaid'] as int? ?? 0,
      totalPaidAmount: json['totalPaidAmount'] as int? ?? 0,
      remainingAmount: json['remainingAmount'] as int? ?? 0,
      accumulatedGoldGrams: (json['accumulatedGoldGrams'] as num?)?.toDouble() ?? 0.0,
      currentValuation: json['currentValuation'] as int? ?? 0,
      valuationGainPct: (json['valuationGainPct'] as num?)?.toDouble() ?? 0.0,
      nextInstallment: json['nextInstallment'] != null
          ? NextInstallmentDto.fromJson(
              json['nextInstallment'] as Map<String, dynamic>)
          : null,
      passbook: (json['passbook'] as List<dynamic>?)
              ?.map((dynamic e) =>
                  PassbookEntryDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <PassbookEntryDto>[],
      status: json['status'] as String? ?? 'ACTIVE',
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
    );
  }

  final String membershipId;
  final String chitToken;
  final String schemeName;
  final int targetAmount;
  final int customMonthlyEmi;
  final int totalMonths;
  final int monthsPaid;
  final int totalPaidAmount;
  final int remainingAmount;
  final double accumulatedGoldGrams;
  final int currentValuation;
  final double valuationGainPct;
  final NextInstallmentDto? nextInstallment;
  final List<PassbookEntryDto> passbook;
  final String status;
  final String? startDate;
  final String? endDate;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'membershipId': membershipId,
        'chitToken': chitToken,
        'schemeName': schemeName,
        'targetAmount': targetAmount,
        'customMonthlyEmi': customMonthlyEmi,
        'totalMonths': totalMonths,
        'monthsPaid': monthsPaid,
        'totalPaidAmount': totalPaidAmount,
        'remainingAmount': remainingAmount,
        'accumulatedGoldGrams': accumulatedGoldGrams,
        'currentValuation': currentValuation,
        'valuationGainPct': valuationGainPct,
        if (nextInstallment != null)
          'nextInstallment': nextInstallment!.toJson(),
        'passbook': passbook.map((PassbookEntryDto e) => e.toJson()).toList(),
        'status': status,
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
      };
}

/// Root Dashboard Response DTO.
class DashboardSummaryResponseDto {
  const DashboardSummaryResponseDto({
    required this.hasActiveScheme,
    this.dashboard,
  });

  factory DashboardSummaryResponseDto.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryResponseDto(
      hasActiveScheme: json['hasActiveScheme'] as bool? ?? false,
      dashboard: json['dashboard'] != null
          ? DashboardDetailsDto.fromJson(
              json['dashboard'] as Map<String, dynamic>)
          : null,
    );
  }

  final bool hasActiveScheme;
  final DashboardDetailsDto? dashboard;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'hasActiveScheme': hasActiveScheme,
        if (dashboard != null) 'dashboard': dashboard!.toJson(),
      };
}
