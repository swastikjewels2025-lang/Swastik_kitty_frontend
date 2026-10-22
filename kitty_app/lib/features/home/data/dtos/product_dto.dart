/// DTO representing a product from the backend jewelry catalog.
class ProductDto {
  const ProductDto({
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

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      purity: json['purity'] as String? ?? '',
      weightGrams: (json['weightGrams'] as num? ?? json['weight_grams'] as num? ?? 0.0).toDouble(),
      estimatedPrice: (json['estimatedPrice'] as num? ?? json['estimated_price'] as num? ?? 0).toInt(),
      makingDiscountPct: (json['makingDiscountPct'] as num? ?? json['making_discount_pct'] as num? ?? 0.0).toDouble(),
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String? ?? '',
      isNew: json['isNew'] as bool? ?? json['is_new'] as bool? ?? false,
    );
  }

  final String id;
  final String title;
  final String category;
  final String purity;
  final double weightGrams;
  final int estimatedPrice;
  final double makingDiscountPct;
  final String imageUrl;
  final bool isNew;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'purity': purity,
      'weightGrams': weightGrams,
      'estimatedPrice': estimatedPrice,
      'makingDiscountPct': makingDiscountPct,
      'imageUrl': imageUrl,
      'isNew': isNew,
    };
  }
}
