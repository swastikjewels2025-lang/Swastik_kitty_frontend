import '../../../auth/data/dtos/user_dto.dart';
import '../../../auth/data/mappers/auth_mapper.dart';
import '../../../auth/domain/entities/kyc_info_entity.dart';
import '../../domain/entities/profile_entity.dart';
import '../models/profile_dto.dart';

/// Mapper between ProfileDto and ProfileEntity.
class ProfileMapper {
  static ProfileEntity toEntity(ProfileDto dto) {
    return ProfileEntity(
      id: dto.id,
      phone: dto.phone,
      name: dto.name,
      email: dto.email,
      role: dto.role,
      isActive: dto.isActive,
      kyc: AuthMapper.toKycInfoEntity(dto.kyc),
      preferences: toPreferencesEntity(dto.preferences),
      createdAt: DateTime.tryParse(dto.createdAt)?.toUtc() ?? DateTime.now().toUtc(),
      updatedAt: DateTime.tryParse(dto.updatedAt)?.toUtc() ?? DateTime.now().toUtc(),
      avatarUrl: dto.avatarUrl,
    );
  }

  static ProfileDto toDto(ProfileEntity entity) {
    return ProfileDto(
      id: entity.id,
      phone: entity.phone,
      name: entity.name,
      email: entity.email,
      role: entity.role,
      isActive: entity.isActive,
      kyc: toKycInfoDto(entity.kyc),
      preferences: toPreferencesDto(entity.preferences),
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
      avatarUrl: entity.avatarUrl,
    );
  }

  static KycInfoDto toKycInfoDto(KycInfoEntity entity) {
    return KycInfoDto(
      isVerified: entity.isVerified,
      status: entity.status.toJson(),
      documentType: entity.documentType?.toJson(),
      documentNumberMasked: entity.documentNumberMasked,
      documentUrl: entity.documentUrl,
      rejectionReason: entity.rejectionReason,
    );
  }

  static UserPreferencesEntity toPreferencesEntity(UserPreferencesDto dto) {
    return UserPreferencesEntity(
      themeMode: dto.themeMode,
      language: dto.language,
      biometricEnabled: dto.biometricEnabled,
      autoPayEnabled: dto.autoPayEnabled,
      pushNotifications: dto.pushNotifications,
      smsNotifications: dto.smsNotifications,
      whatsappUpdates: dto.whatsappUpdates,
    );
  }

  static UserPreferencesDto toPreferencesDto(UserPreferencesEntity entity) {
    return UserPreferencesDto(
      themeMode: entity.themeMode,
      language: entity.language,
      biometricEnabled: entity.biometricEnabled,
      autoPayEnabled: entity.autoPayEnabled,
      pushNotifications: entity.pushNotifications,
      smsNotifications: entity.smsNotifications,
      whatsappUpdates: entity.whatsappUpdates,
    );
  }
}
