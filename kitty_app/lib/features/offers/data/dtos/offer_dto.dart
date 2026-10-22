/// Promotional Offer Data Transfer Object.
class OfferDto {
  const OfferDto({
    required this.id,
    required this.title,
    required this.description,
    required this.code,
    required this.discountPct,
    this.validUntil,
    this.imageUrl,
  });

  factory OfferDto.fromJson(Map<String, dynamic> json) {
    return OfferDto(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      code: json['code'] as String? ?? '',
      discountPct: (json['discountPct'] as num?)?.toDouble() ?? 0.0,
      validUntil: json['validUntil'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  final String id;
  final String title;
  final String description;
  final String code;
  final double discountPct;
  final String? validUntil;
  final String? imageUrl;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'description': description,
        'code': code,
        'discountPct': discountPct,
        if (validUntil != null) 'validUntil': validUntil,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };
}
