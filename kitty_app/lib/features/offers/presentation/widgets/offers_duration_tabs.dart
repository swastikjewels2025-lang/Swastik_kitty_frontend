import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/scheme_entity.dart';

/// Horizontal filter tabs for filtering schemes by duration.
///
/// Matches `.offers-filter-tabs` in `offers.html`.
class OffersDurationTabs extends StatelessWidget {
  const OffersDurationTabs({
    super.key,
    required this.schemes,
    required this.selectedDuration,
    required this.onDurationSelected,
  });

  final List<SchemeEntity> schemes;
  final int? selectedDuration;
  final ValueChanged<int?> onDurationSelected;

  @override
  Widget build(BuildContext context) {
    final int countAll = schemes.length;
    final int count12 = schemes.where((SchemeEntity s) => s.durationMonths == 12).length;
    final int count18 = schemes.where((SchemeEntity s) => s.durationMonths == 18).length;
    final int count6 = schemes.where((SchemeEntity s) => s.durationMonths == 6).length;

    final List<({String label, int? duration})> tabs = <({String label, int? duration})>[
      (label: 'All Plans ($countAll)', duration: null),
      (label: '12 Months ($count12)', duration: 12),
      (label: '18 Months ($count18)', duration: 18),
      (label: 'Express 6-Month ($count6)', duration: 6),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: tabs.map((tab) {
          final bool isSelected = selectedDuration == tab.duration;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.space8),
            child: GestureDetector(
              onTap: () => onDurationSelected(tab.duration),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.deepEmeraldBase : Colors.white,
                  borderRadius: AppRadius.borderPill,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.deepEmeraldBase
                        : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? <BoxShadow>[
                          BoxShadow(
                            color: AppColors.deepEmeraldBase.withValues(alpha: 0.22),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  tab.label,
                  style: AppTypography.bodySmall(
                    color: isSelected
                        ? Colors.white
                        : AppColors.textSecondaryMuted,
                  ).copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
