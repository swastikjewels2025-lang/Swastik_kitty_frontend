import '../../../../core/enums/app_enums.dart';
import '../../domain/entities/auth_session_entity.dart';
import '../../domain/entities/kyc_info_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../dtos/auth_dto.dart';
import '../dtos/user_dto.dart';

/// Explicit type-safe mapper between Auth DTOs and Domain Entities.
abstract final class AuthMapper {
  static KycInfoEntity toKycInfoEntity(KycInfoDto? dto) {
    if (dto == null) {
      return const KycInfoEntity(
        isVerified: false,
        status: KycStatusEnum.notSubmitted,
      );
    }

    return KycInfoEntity(
      isVerified: dto.isVerified,
      status: KycStatusEnum.fromString(dto.status),
      documentType: dto.documentType != null
          ? DocTypeEnum.fromString(dto.documentType)
          : null,
      documentNumberMasked: dto.documentNumberMasked,
      documentUrl: dto.documentUrl,
      rejectionReason: dto.rejectionReason,
    );
  }

  static UserEntity toUserEntity(UserDto dto) {
    final DateTime parsedCreatedAt = dto.createdAt != null
        ? DateTime.tryParse(dto.createdAt!)?.toUtc() ?? DateTime.now().toUtc()
        : DateTime.now().toUtc();

    return UserEntity(
      id: dto.id,
      name: dto.name,
      phone: dto.phone,
      email: dto.email,
      address: dto.address,
      city: dto.city,
      pincode: dto.pincode,
      role: UserRoleEnum.fromString(dto.role),
      tier: dto.tier ?? 'Tier 1 Verified Member',
      kyc: toKycInfoEntity(dto.kyc),
      createdAt: parsedCreatedAt,
      nomineeName: dto.nomineeName,
      nomineeRelationship: dto.nomineeRelationship,
      nomineePhone: dto.nomineePhone,
    );
  }

  static AuthSessionEntity toSessionEntity(VerifyOtpResponseDto dto) {
    return AuthSessionEntity(
      token: dto.token,
      user: toUserEntity(dto.user),
      isNewUser: dto.isNewUser,
    );
  }

  static SendOtpResultEntity toSendOtpResultEntity(SendOtpResponseDto dto) {
    return SendOtpResultEntity(
      sessionId: dto.sessionId,
      expiresInSeconds: dto.expiresInSeconds,
      isExistingUser: dto.isExistingUser,
      userName: dto.userName,
      message: dto.message,
    );
  }
}
