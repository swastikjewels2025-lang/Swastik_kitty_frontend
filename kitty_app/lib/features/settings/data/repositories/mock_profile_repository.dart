import '../../../../core/mock/mock_engine_config.dart';
import '../../../../core/mock/mock_fixtures.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/i_profile_repository.dart';
import '../mappers/profile_mapper.dart';
import '../models/profile_dto.dart';

/// Mock implementation of IProfileRepository with in-memory state.
class MockProfileRepository implements IProfileRepository {
  MockProfileRepository({MockEngineConfig? engineConfig})
      : _engineConfig = engineConfig ?? MockEngineConfig();

  final MockEngineConfig _engineConfig;
  ProfileEntity? _inMemoryProfile;

  ProfileEntity get _profile {
    _inMemoryProfile ??= ProfileMapper.toEntity(ProfileDto.fromJson(
      MockFixtures.userProfileJson['data'] as Map<String, dynamic>? ?? {},
    ));
    return _inMemoryProfile!;
  }

  @override
  Future<ProfileEntity> getProfile() async {
    await _engineConfig.simulateResponse();
    return _profile;
  }

  @override
  Future<ProfileEntity> updateProfile({
    String? name,
    String? email,
    String? avatarUrl,
  }) async {
    await _engineConfig.simulateResponse();
    _inMemoryProfile = _profile.copyWith(
      name: name ?? _profile.name,
      email: email ?? _profile.email,
      avatarUrl: avatarUrl ?? _profile.avatarUrl,
      updatedAt: DateTime.now().toUtc(),
    );
    return _inMemoryProfile!;
  }

  @override
  Future<UserPreferencesEntity> updatePreferences(UserPreferencesEntity preferences) async {
    await _engineConfig.simulateResponse();
    _inMemoryProfile = _profile.copyWith(
      preferences: preferences,
      updatedAt: DateTime.now().toUtc(),
    );
    return _inMemoryProfile!.preferences;
  }
}
