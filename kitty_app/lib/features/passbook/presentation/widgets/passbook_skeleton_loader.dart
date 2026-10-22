import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/feedback/kitty_shimmer.dart';

/// Shimmer skeleton loader for Passbook ledger during loading states.
class PassbookSkeletonLoader extends StatelessWidget {
  const PassbookSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 1. Controls Row Skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                KittyShimmer(
                  child: Container(
                    width: 90,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceCardBorder,
                      borderRadius: AppRadius.border20,
                    ),
                  ),
                ),
                KittyShimmer(
                  child: Container(
                    width: 170,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceCardBorder,
                      borderRadius: AppRadius.border20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.space12),

          // 2. Summary Card Skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
            child: KittyShimmer(
              child: Container(
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceCardBorder,
                  borderRadius: AppRadius.border16,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.space16),

          // 3. Ledger Items Skeleton (Cards / Rows)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
            child: Column(
              children: List<Widget>.generate(
                5,
                (int index) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.space12),
                  child: KittyShimmer(
                    child: Container(
                      height: 96,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceCardBorder,
                        borderRadius: AppRadius.border18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
