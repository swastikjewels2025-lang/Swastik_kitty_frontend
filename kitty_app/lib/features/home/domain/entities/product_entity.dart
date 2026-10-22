/// Domain entity representing a curated jewelry product in the catalog.
class ProductEntity {
  const ProductEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.purity,
    required this.weightGrams,
    required this.estimatedPrice,
    required this.makingDiscountPct,
    required this.imageUrl,
    this.isNew = false,
  });

  final String id;
  final String title;
  final String category;
  final String purity;
  final double weightGrams;
  final int estimatedPrice;
  final double makingDiscountPct;
  final String imageUrl;
  final bool isNew;
}
