import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';

/// Contextual banner displayed when the scheme is in PRE_JOIN / late-joiner state.
class DashboardPrejoinBanner extends StatelessWidget {
  const DashboardPrejoinBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space6,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space12,
      ),
      decoration: BoxDecoration(
        color: AppColors.goldSubtle.withValues(alpha: 0.15),
        borderRadius: AppRadius.border16,
        border: Border.all(
          color: AppColors.goldBorder.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.goldPrimary.withValues(alpha: 0.2),
              border: Border.all(
                color: AppColors.goldBorder,
                width: 1,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.info_outline,
                color: AppColors.goldPrimary,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'PRE-JOIN SCHEME ENROLLED',
                  style: AppTypography.kickerCaps(
                    color: AppColors.goldLight,
                  ).copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Your membership is registered as a late joiner. Monthly gold allocation will activate upon your first installment clearance.',
                  style: AppTypography.bodySmall(
                    color: AppColors.textPrimaryLight,
                  ).copyWith(
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
