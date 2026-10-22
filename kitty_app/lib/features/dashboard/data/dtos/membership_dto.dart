/// Scheme Membership Data Transfer Object.
class MembershipDto {
  const MembershipDto({
    required this.id,
    required this.userId,
    required this.schemeId,
    required this.schemeName,
    required this.tokenNumber,
    this.tokenString,
    required this.customMonthlyEmi,
    required this.targetAmount,
    required this.totalPaidAmount,
    required this.status,
    required this.joinedAtMonth,
    this.winMonth,
  });

  factory MembershipDto.fromJson(Map<String, dynamic> json) {
    final int tokenNum = json['tokenNumber'] as int? ?? 1;
    final String fallbackToken = '#SW-${tokenNum.toString().padLeft(3, '0')}';

    return MembershipDto(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      schemeId: json['schemeId'] as String? ?? '',
      schemeName: json['schemeName'] as String? ?? '',
      tokenNumber: tokenNum,
      tokenString: json['tokenString'] as String? ?? fallbackToken,
      customMonthlyEmi: json['customMonthlyEmi'] as int? ?? 0,
      targetAmount: json['targetAmount'] as int? ?? 0,
      totalPaidAmount: json['totalPaidAmount'] as int? ?? 0,
      status: json['status'] as String? ?? 'ACTIVE',
      joinedAtMonth: json['joinedAtMonth'] as int? ?? 1,
      winMonth: json['winMonth'] as int?,
    );
  }

  final String id;
  final String userId;
  final String schemeId;
  final String schemeName;
  final int tokenNumber;
  final String? tokenString;
  final int customMonthlyEmi;
  final int targetAmount;
  final int totalPaidAmount;
  final String status;
  final int joinedAtMonth;
  final int? winMonth;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'userId': userId,
        'schemeId': schemeId,
        'schemeName': schemeName,
        'tokenNumber': tokenNumber,
        if (tokenString != null) 'tokenString': tokenString,
        'customMonthlyEmi': customMonthlyEmi,
        'targetAmount': targetAmount,
        'totalPaidAmount': totalPaidAmount,
        'status': status,
        'joinedAtMonth': joinedAtMonth,
        if (winMonth != null) 'winMonth': winMonth,
      };
}

/// Request DTO for enrolling in a scheme.
class JoinSchemeRequestDto {
  const JoinSchemeRequestDto({required this.schemeId});

  final String schemeId;

  Map<String, dynamic> toJson() => <String, dynamic>{'schemeId': schemeId};
}

/// Response DTO for enrolling in a scheme.
class JoinSchemeResponseDto {
  const JoinSchemeResponseDto({required this.membership});

  factory JoinSchemeResponseDto.fromJson(Map<String, dynamic> json) {
    return JoinSchemeResponseDto(
      membership: MembershipDto.fromJson(
        json['membership'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
    );
  }

  final MembershipDto membership;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'membership': membership.toJson(),
      };
}
