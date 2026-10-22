import '../entities/offer_entity.dart';

/// Pure domain repository interface for promotional discount offers.
abstract interface class IOfferRepository {
  /// Retrieves list of currently active promotional offers.
  Future<List<OfferEntity>> getActiveOffers();
}
