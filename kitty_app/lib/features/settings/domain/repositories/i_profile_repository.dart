import '../../domain/entities/profile_entity.dart';

/// Repository contract for user profile and settings management.
abstract class IProfileRepository {
  /// Fetches current user profile.
  Future<ProfileEntity> getProfile();

  /// Updates user profile fields (name, email, avatar).
  Future<ProfileEntity> updateProfile({
    String? name,
    String? email,
    String? avatarUrl,
  });

  /// Updates user preferences.
  Future<UserPreferencesEntity> updatePreferences(UserPreferencesEntity preferences);
}
