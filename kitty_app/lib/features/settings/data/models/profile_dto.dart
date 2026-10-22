import '../../../../core/enums/app_enums.dart';
import '../../../auth/data/dtos/user_dto.dart';

/// DTO for user preferences.
class UserPreferencesDto {
  const UserPreferencesDto({
    required this.themeMode,
    required this.language,
    required this.biometricEnabled,
    this.autoPayEnabled = true,
    required this.pushNotifications,
    required this.smsNotifications,
    required this.whatsappUpdates,
  });

  factory UserPreferencesDto.fromJson(Map<String, dynamic> json) {
    return UserPreferencesDto(
      themeMode: json['theme_mode'] as String? ?? json['themeMode'] as String? ?? 'system',
      language: json['language'] as String? ?? 'en',
      biometricEnabled: json['biometric_enabled'] as bool? ?? json['biometricEnabled'] as bool? ?? true,
      autoPayEnabled: json['autopay_enabled'] as bool? ?? json['autoPayEnabled'] as bool? ?? true,
      pushNotifications: json['push_notifications'] as bool? ?? json['pushNotifications'] as bool? ?? true,
      smsNotifications: json['sms_notifications'] as bool? ?? json['smsNotifications'] as bool? ?? true,
      whatsappUpdates: json['whatsapp_updates'] as bool? ?? json['whatsappUpdates'] as bool? ?? true,
    );
  }

  final String themeMode;
  final String language;
  final bool biometricEnabled;
  final bool autoPayEnabled;
  final bool pushNotifications;
  final bool smsNotifications;
  final bool whatsappUpdates;

  Map<String, dynamic> toJson() {
    return {
      'theme_mode': themeMode,
      'language': language,
      'biometric_enabled': biometricEnabled,
      'autopay_enabled': autoPayEnabled,
      'push_notifications': pushNotifications,
      'sms_notifications': smsNotifications,
      'whatsapp_updates': whatsappUpdates,
    };
  }
}

/// DTO for complete user profile.
class ProfileDto {
  const ProfileDto({
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

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    return ProfileDto(
      id: json['id'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: UserRoleEnum.fromString(json['role'] as String?),
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
      kyc: json['kyc'] is Map<String, dynamic>
          ? KycInfoDto.fromJson(json['kyc'] as Map<String, dynamic>)
          : const KycInfoDto(isVerified: false, status: 'NOT_SUBMITTED'),
      preferences: json['preferences'] is Map<String, dynamic>
          ? UserPreferencesDto.fromJson(json['preferences'] as Map<String, dynamic>)
          : const UserPreferencesDto(
              themeMode: 'system',
              language: 'en',
              biometricEnabled: true,
              pushNotifications: true,
              smsNotifications: true,
              whatsappUpdates: true,
            ),
      createdAt: json['created_at'] as String? ?? json['createdAt'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? json['updatedAt'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String?,
    );
  }

  final String id;
  final String phone;
  final String name;
  final String email;
  final UserRoleEnum role;
  final bool isActive;
  final KycInfoDto kyc;
  final UserPreferencesDto preferences;
  final String createdAt;
  final String updatedAt;
  final String? avatarUrl;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'email': email,
      'role': role.toJson(),
      'is_active': isActive,
      'kyc': kyc.toJson(),
      'preferences': preferences.toJson(),
      'created_at': createdAt,
      'updated_at': updatedAt,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };
  }
}
