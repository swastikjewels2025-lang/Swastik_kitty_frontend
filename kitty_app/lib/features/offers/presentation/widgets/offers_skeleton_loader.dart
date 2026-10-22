import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/feedback/kitty_shimmer.dart';

/// Shimmer skeleton placeholder displayed while schemes and catalog are loading.
class OffersSkeletonLoader extends StatelessWidget {
  const OffersSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header Skeleton
          KittyShimmer(
            child: Container(
              width: 140,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.surfaceCardBorder,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 8),
          KittyShimmer(
            child: Container(
              width: 220,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.surfaceCardBorder,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space20),

          // Section Switcher Skeleton
          KittyShimmer(
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.surfaceCardBorder,
                borderRadius: AppRadius.borderPill,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space16),

          // Duration Tabs Skeleton
          Row(
            children: <Widget>[
              for (int i = 0; i < 3; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: KittyShimmer(
                    child: Container(
                      width: 100,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceCardBorder,
                        borderRadius: AppRadius.borderPill,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.space20),

          // Scheme Cards Skeleton
          for (int i = 0; i < 2; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space16),
              child: KittyShimmer(
                child: Container(
                  width: double.infinity,
                  height: 240,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceCardBorder,
                    borderRadius: AppRadius.border20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
