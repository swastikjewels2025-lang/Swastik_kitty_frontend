import '../../../../core/mock/mock_engine_config.dart';
import '../../../../core/mock/mock_fixtures.dart';
import '../../domain/entities/gold_rate_entity.dart';
import '../../domain/repositories/i_gold_rate_repository.dart';
import '../dtos/gold_rate_dto.dart';
import '../mappers/home_mapper.dart';

/// Mock implementation of [IGoldRateRepository] with 3-decimal gold rates.
class MockGoldRateRepository implements IGoldRateRepository {
  MockGoldRateRepository({MockEngineConfig? engineConfig})
      : _engineConfig = engineConfig ?? MockEngineConfig.instance;

  final MockEngineConfig _engineConfig;

  @override
  Future<LiveGoldRateEntity> getLiveGoldRate() async {
    await _engineConfig.simulate();

    final LiveGoldRateDto dto = LiveGoldRateDto.fromJson(
      MockFixtures.liveGoldRateJson['data'] as Map<String, dynamic>,
    );

    return HomeMapper.toGoldRateEntity(dto);
  }
}
