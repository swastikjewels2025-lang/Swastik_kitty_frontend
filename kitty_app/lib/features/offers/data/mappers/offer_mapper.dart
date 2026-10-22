import '../../domain/entities/offer_entity.dart';
import '../dtos/offer_dto.dart';

/// Mapper between Offer DTO and Domain Entity.
abstract final class OfferMapper {
  static OfferEntity toEntity(OfferDto dto) {
    final DateTime? parsedValidUntil = dto.validUntil != null
        ? DateTime.tryParse(dto.validUntil!)?.toUtc()
        : null;

    return OfferEntity(
      id: dto.id,
      title: dto.title,
      description: dto.description,
      code: dto.code,
      discountPct: dto.discountPct,
      validUntil: parsedValidUntil,
      imageUrl: dto.imageUrl,
    );
  }
}
