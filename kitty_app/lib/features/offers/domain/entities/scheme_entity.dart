import '../../../../core/enums/app_enums.dart';

/// Pure domain entity representing a Gold Kitty Savings Scheme.
class SchemeEntity {
  const SchemeEntity({
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

  final String id;
  final String name;
  final int targetAmount;
  final int durationMonths;
  final int monthlyInstallment;
  final int maxCapacity;
  final int currentMembers;
  final SchemeStatusEnum status;
  final List<String> benefits;
  final String? bannerImageUrl;
  final bool isPopular;

  bool get isFull => currentMembers >= maxCapacity;
  int get slotsRemaining => (maxCapacity - currentMembers).clamp(0, maxCapacity);
}
