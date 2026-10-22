import '../../../../core/enums/app_enums.dart';
import 'kyc_info_entity.dart';

/// Pure domain entity representing an authenticated Kitty App patron.
class UserEntity {
  const UserEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.email,
    this.address,
    this.city,
    this.pincode,
    this.tier = 'Tier 1 Verified Member',
    this.kyc = const KycInfoEntity(
      isVerified: false,
      status: KycStatusEnum.notSubmitted,
    ),
    required this.createdAt,
    this.nomineeName,
    this.nomineeRelationship,
    this.nomineePhone,
  });

  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String? city;
  final String? pincode;
  final UserRoleEnum role;
  final String tier;
  final KycInfoEntity kyc;
  final DateTime createdAt;
  final String? nomineeName;
  final String? nomineeRelationship;
  final String? nomineePhone;

  UserEntity copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? pincode,
    UserRoleEnum? role,
    String? tier,
    KycInfoEntity? kyc,
    DateTime? createdAt,
    String? nomineeName,
    String? nomineeRelationship,
    String? nomineePhone,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      role: role ?? this.role,
      tier: tier ?? this.tier,
      kyc: kyc ?? this.kyc,
      createdAt: createdAt ?? this.createdAt,
      nomineeName: nomineeName ?? this.nomineeName,
      nomineeRelationship: nomineeRelationship ?? this.nomineeRelationship,
      nomineePhone: nomineePhone ?? this.nomineePhone,
    );
  }
}
