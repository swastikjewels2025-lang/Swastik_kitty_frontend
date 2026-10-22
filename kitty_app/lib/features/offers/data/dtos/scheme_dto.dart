/// Scheme Data Transfer Object.
class SchemeDto {
  const SchemeDto({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.durationMonths,
    required this.monthlyInstallment,
    required this.maxCapacity,
    required this.currentMembers,
    required this.status,
    required this.benefits,
    this.bannerImageUrl,
    this.isPopular = false,
  });

  factory SchemeDto.fromJson(Map<String, dynamic> json) {
    return SchemeDto(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      targetAmount: json['targetAmount'] as int? ?? 0,
      durationMonths: json['durationMonths'] as int? ?? 12,
      monthlyInstallment: json['monthlyInstallment'] as int? ?? 0,
      maxCapacity: json['maxCapacity'] as int? ?? 100,
      currentMembers: json['currentMembers'] as int? ?? 0,
      status: json['status'] as String? ?? 'OPEN',
      benefits: (json['benefits'] as List<dynamic>?)
              ?.map((dynamic e) => e.toString())
              .toList() ??
          <String>[],
      bannerImageUrl: json['bannerImageUrl'] as String?,
      isPopular: json['isPopular'] as bool? ?? false,
    );
  }

  final String id;
  final String name;
  final int targetAmount;
  final int durationMonths;
  final int monthlyInstallment;
  final int maxCapacity;
  final int currentMembers;
  final String status;
  final List<String> benefits;
  final String? bannerImageUrl;
  final bool isPopular;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'targetAmount': targetAmount,
        'durationMonths': durationMonths,
        'monthlyInstallment': monthlyInstallment,
        'maxCapacity': maxCapacity,
        'currentMembers': currentMembers,
        'status': status,
        'benefits': benefits,
        if (bannerImageUrl != null) 'bannerImageUrl': bannerImageUrl,
        'isPopular': isPopular,
      };
}
