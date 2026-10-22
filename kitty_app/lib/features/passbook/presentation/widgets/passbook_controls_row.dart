import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/passbook_state.dart';

/// Passbook controls row featuring canonical chit token pill and layout view switcher.
class PassbookControlsRow extends StatelessWidget {
  const PassbookControlsRow({
    super.key,
    required this.chitToken,
    required this.currentMode,
    required this.onModeChanged,
  });

  final String chitToken;
  final PassbookViewMode currentMode;
  final ValueChanged<PassbookViewMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Left: Canonical Chit Token Pill (#SW-042)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceCardBg,
              borderRadius: AppRadius.border20,
              border: Border.all(
                color: AppColors.surfaceCardBorder,
                width: 1,
              ),
              boxShadow: AppShadows.cardSubtle,
            ),
            child: Text(
              chitToken,
              style: AppTypography.labelMeta(
                color: AppColors.textPrimaryDark,
              ).copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                fontSize: 12,
              ),
            ),
          ),

          // Right: Segmented View Switcher (Table View | Card View)
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: AppRadius.border20,
              border: Border.all(
                color: AppColors.surfaceCardBorder,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _ViewToggleButton(
                  title: 'Table View',
                  icon: Icons.table_chart_outlined,
                  isSelected: currentMode == PassbookViewMode.table,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onModeChanged(PassbookViewMode.table);
                  },
                ),
                const SizedBox(width: 2),
                _ViewToggleButton(
                  title: 'Card View',
                  icon: Icons.view_agenda_outlined,
                  isSelected: currentMode == PassbookViewMode.card,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onModeChanged(PassbookViewMode.card);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewToggleButton extends StatelessWidget {
  const _ViewToggleButton({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.deepEmeraldBase : Colors.transparent,
          borderRadius: AppRadius.border20,
          boxShadow: isSelected ? AppShadows.ctaEmerald : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 13,
              color: isSelected ? Colors.white : AppColors.textSecondaryMuted,
            ),
            const SizedBox(width: 5),
            Text(
              title,
              style: AppTypography.labelMeta(
                color: isSelected ? Colors.white : AppColors.textSecondaryMuted,
              ).copyWith(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
