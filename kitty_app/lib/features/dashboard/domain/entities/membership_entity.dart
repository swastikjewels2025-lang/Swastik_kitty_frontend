import '../../../../core/enums/app_enums.dart';

/// Pure domain entity representing an enrolled scheme membership.
class MembershipEntity {
  const MembershipEntity({
    required this.id,
    required this.userId,
    required this.schemeId,
    required this.schemeName,
    required this.tokenNumber,
    required this.tokenString,
    required this.customMonthlyEmi,
    required this.targetAmount,
    required this.totalPaidAmount,
    required this.status,
    required this.joinedAtMonth,
    this.winMonth,
  });

  final String id;
  final String userId;
  final String schemeId;
  final String schemeName;
  final int tokenNumber;
  final String tokenString; // e.g. "#SW-042"
  final int customMonthlyEmi; // Whole integer rupees
  final int targetAmount; // Whole integer rupees
  final int totalPaidAmount; // Whole integer rupees
  final MembershipStatusEnum status;
  final int joinedAtMonth;
  final int? winMonth;
}
