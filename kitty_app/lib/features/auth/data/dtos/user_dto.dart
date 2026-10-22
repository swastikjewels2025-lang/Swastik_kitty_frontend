/// API Data Transfer Objects for User and KYC subdocument.
class KycInfoDto {
  const KycInfoDto({
    required this.isVerified,
    required this.status,
    this.documentType,
    this.documentNumberMasked,
    this.documentUrl,
    this.rejectionReason,
  });

  factory KycInfoDto.fromJson(Map<String, dynamic> json) {
    return KycInfoDto(
      isVerified: json['isVerified'] as bool? ?? false,
      status: json['status'] as String? ?? 'NOT_SUBMITTED',
      documentType: json['documentType'] as String?,
      documentNumberMasked: json['documentNumberMasked'] as String?,
      documentUrl: json['documentUrl'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
    );
  }

  final bool isVerified;
  final String status;
  final String? documentType;
  final String? documentNumberMasked;
  final String? documentUrl;
  final String? rejectionReason;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'isVerified': isVerified,
      'status': status,
      if (documentType != null) 'documentType': documentType,
      if (documentNumberMasked != null) 'documentNumberMasked': documentNumberMasked,
      if (documentUrl != null) 'documentUrl': documentUrl,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
    };
  }
}

class UserDto {
  const UserDto({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.email,
    this.address,
    this.city,
    this.pincode,
    this.tier,
    this.kyc,
    this.createdAt,
    this.nomineeName,
    this.nomineeRelationship,
    this.nomineePhone,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? nomineeObj = json['nominee'] is Map<String, dynamic>
        ? json['nominee'] as Map<String, dynamic>
        : null;

    return UserDto(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      pincode: json['pincode'] as String?,
      role: json['role'] as String? ?? 'CUSTOMER',
      tier: json['tier'] as String?,
      kyc: json['kyc'] != null
          ? KycInfoDto.fromJson(json['kyc'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] as String?,
      nomineeName: nomineeObj?['name'] as String? ?? json['nomineeName'] as String?,
      nomineeRelationship: nomineeObj?['relationship'] as String? ?? json['nomineeRelationship'] as String?,
      nomineePhone: nomineeObj?['phone'] as String? ?? json['nomineePhone'] as String?,
    );
  }

  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String? city;
  final String? pincode;
  final String role;
  final String? tier;
  final KycInfoDto? kyc;
  final String? createdAt;
  final String? nomineeName;
  final String? nomineeRelationship;
  final String? nomineePhone;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (pincode != null) 'pincode': pincode,
      'role': role,
      if (tier != null) 'tier': tier,
      if (kyc != null) 'kyc': kyc!.toJson(),
      if (createdAt != null) 'createdAt': createdAt,
      if (nomineeName != null) 'nomineeName': nomineeName,
      if (nomineeRelationship != null) 'nomineeRelationship': nomineeRelationship,
      if (nomineePhone != null) 'nomineePhone': nomineePhone,
    };
  }
}
