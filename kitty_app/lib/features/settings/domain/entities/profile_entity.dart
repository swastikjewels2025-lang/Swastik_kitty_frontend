import '../../../../core/enums/app_enums.dart';
import '../../../auth/domain/entities/kyc_info_entity.dart';

/// User Preferences configuration entity.
class UserPreferencesEntity {
  const UserPreferencesEntity({
    this.themeMode = 'system',
    this.language = 'en',
    this.biometricEnabled = true,
    this.autoPayEnabled = true,
    this.pushNotifications = true,
    this.smsNotifications = true,
    this.whatsappUpdates = true,
  });

  final String themeMode;
  final String language;
  final bool biometricEnabled;
  final bool autoPayEnabled;
  final bool pushNotifications;
  final bool smsNotifications;
  final bool whatsappUpdates;

  UserPreferencesEntity copyWith({
    String? themeMode,
    String? language,
    bool? biometricEnabled,
    bool? autoPayEnabled,
    bool? pushNotifications,
    bool? smsNotifications,
    bool? whatsappUpdates,
  }) {
    return UserPreferencesEntity(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      autoPayEnabled: autoPayEnabled ?? this.autoPayEnabled,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      whatsappUpdates: whatsappUpdates ?? this.whatsappUpdates,
    );
  }
}

/// Domain entity representing full user profile with settings and KYC info.
class ProfileEntity {
  const ProfileEntity({
    required this.id,
    required this.phone,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    required this.kyc,
    required this.preferences,
    required this.createdAt,
    required this.updatedAt,
    this.avatarUrl,
  });

  final String id;
  final String phone;
  final String name;
  final String email;
  final UserRoleEnum role;
  final bool isActive;
  final KycInfoEntity kyc;
  final UserPreferencesEntity preferences;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? avatarUrl;

  ProfileEntity copyWith({
    String? id,
    String? phone,
    String? name,
    String? email,
    UserRoleEnum? role,
    bool? isActive,
    KycInfoEntity? kyc,
    UserPreferencesEntity? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? avatarUrl,
  }) {
    return ProfileEntity(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      kyc: kyc ?? this.kyc,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
