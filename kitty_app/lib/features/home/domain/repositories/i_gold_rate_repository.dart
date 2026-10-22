import '../entities/gold_rate_entity.dart';

/// Pure domain repository interface for live bullion gold ticker rates.
abstract interface class IGoldRateRepository {
  /// Retrieves live 24K 999 gold rate per gram.
  Future<LiveGoldRateEntity> getLiveGoldRate();
}
