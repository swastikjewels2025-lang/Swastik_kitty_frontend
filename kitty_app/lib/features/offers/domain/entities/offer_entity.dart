/// Pure domain entity representing a promotional discount/privilege offer.
class OfferEntity {
  const OfferEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.code,
    required this.discountPct,
    this.validUntil,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String description;
  final String code;
  final double discountPct;
  final DateTime? validUntil;
  final String? imageUrl;
}
