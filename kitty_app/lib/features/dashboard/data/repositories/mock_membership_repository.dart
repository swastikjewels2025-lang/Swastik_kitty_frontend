import '../../../../core/mock/mock_engine_config.dart';
import '../../../../core/mock/mock_fixtures.dart';
import '../../domain/entities/membership_entity.dart';
import '../../domain/repositories/i_membership_repository.dart';
import '../dtos/membership_dto.dart';
import '../mappers/membership_mapper.dart';

/// Mock implementation of [IMembershipRepository].
class MockMembershipRepository implements IMembershipRepository {
  MockMembershipRepository({MockEngineConfig? engineConfig})
      : _engineConfig = engineConfig ?? MockEngineConfig.instance;

  final MockEngineConfig _engineConfig;

  @override
  Future<MembershipEntity> joinScheme({required String schemeId}) async {
    await _engineConfig.simulate();

    final JoinSchemeResponseDto dto = JoinSchemeResponseDto.fromJson(
      MockFixtures.joinSchemeSuccessJson['data'] as Map<String, dynamic>,
    );

    return MembershipMapper.toEntity(dto.membership);
  }

  @override
  Future<MembershipEntity> getMembershipById(String membershipId) async {
    await _engineConfig.simulate();

    final JoinSchemeResponseDto dto = JoinSchemeResponseDto.fromJson(
      MockFixtures.joinSchemeSuccessJson['data'] as Map<String, dynamic>,
    );

    return MembershipMapper.toEntity(dto.membership);
  }
}
