import '../../../../core/mock/mock_engine_config.dart';
import '../../../../core/mock/mock_fixtures.dart';
import '../../domain/entities/offer_entity.dart';
import '../../domain/repositories/i_offer_repository.dart';
import '../dtos/offer_dto.dart';
import '../mappers/offer_mapper.dart';

/// Mock implementation of [IOfferRepository].
class MockOfferRepository implements IOfferRepository {
  MockOfferRepository({MockEngineConfig? engineConfig})
      : _engineConfig = engineConfig ?? MockEngineConfig.instance;

  final MockEngineConfig _engineConfig;

  @override
  Future<List<OfferEntity>> getActiveOffers() async {
    await _engineConfig.simulate();

    final List<dynamic> rawList =
        MockFixtures.activeOffersJson['data']['offers'] as List<dynamic>;

    return rawList
        .map((dynamic json) =>
            OfferMapper.toEntity(OfferDto.fromJson(json as Map<String, dynamic>)))
        .toList();
  }
}
