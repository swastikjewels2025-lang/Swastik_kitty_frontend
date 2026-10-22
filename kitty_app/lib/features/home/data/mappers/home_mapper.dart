import '../../domain/entities/gold_rate_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../dtos/gold_rate_dto.dart';
import '../dtos/product_dto.dart';

/// Mapper between Gold Rate & Product DTOs and Domain Entities.
abstract final class HomeMapper {
  static LiveGoldRateEntity toGoldRateEntity(LiveGoldRateDto dto) {
    final DateTime parsedUpdatedAt =
        DateTime.tryParse(dto.updatedAt)?.toUtc() ?? DateTime.now().toUtc();

    return LiveGoldRateEntity(
      ratePerGram: dto.ratePerGram, // 3-decimal precision preserved
      purity: dto.purity,
      purityFraction: dto.purityFraction,
      currency: dto.currency,
      change24h: dto.change24h,
      changePct: dto.changePct,
      isUp: dto.isUp,
      updatedAt: parsedUpdatedAt,
      silverRatePerGram: dto.silverRatePerGram,
      rate22k: dto.rate22k,
    );
  }

  static ProductEntity toProductEntity(ProductDto dto) {
    return ProductEntity(
      id: dto.id,
      title: dto.title,
      category: dto.category,
      purity: dto.purity,
      weightGrams: dto.weightGrams, // 3-decimal precision preserved
      estimatedPrice: dto.estimatedPrice, // Whole integer rupees preserved
      makingDiscountPct: dto.makingDiscountPct,
      imageUrl: dto.imageUrl,
      isNew: dto.isNew,
    );
  }
}
