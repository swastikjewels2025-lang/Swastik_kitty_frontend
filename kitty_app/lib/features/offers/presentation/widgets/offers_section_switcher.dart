import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/offers_state.dart';

/// Segmented pill switch between Kitty Savings Schemes and Curated Jewellery Catalog.
class OffersSectionSwitcher extends StatelessWidget {
  const OffersSectionSwitcher({
    super.key,
    required this.activeSection,
    required this.onSectionChanged,
  });

  final OffersViewSection activeSection;
  final ValueChanged<OffersViewSection> onSectionChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
        borderRadius: AppRadius.borderPill,
        border: Border.all(
          color: AppColors.surfaceCardBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _SwitchPill(
              label: '✦ Savings Schemes',
              isActive: activeSection == OffersViewSection.schemes,
              onTap: () => onSectionChanged(OffersViewSection.schemes),
            ),
          ),
          Expanded(
            child: _SwitchPill(
              label: '💎 Jewellery Catalog',
              isActive: activeSection == OffersViewSection.catalog,
              onTap: () => onSectionChanged(OffersViewSection.catalog),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchPill extends StatelessWidget {
  const _SwitchPill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? AppColors.deepEmeraldBase : Colors.transparent,
          borderRadius: AppRadius.borderPill,
          boxShadow: isActive
              ? <BoxShadow>[
                  BoxShadow(
                    color: AppColors.deepEmeraldBase.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall(
            color: isActive ? Colors.white : AppColors.textSecondaryMuted,
          ).copyWith(
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
