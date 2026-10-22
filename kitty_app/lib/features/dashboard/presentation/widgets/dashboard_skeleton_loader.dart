import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/feedback/kitty_shimmer.dart';

/// Shimmer skeleton loader for Kitty Dashboard loading states.
class DashboardSkeletonLoader extends StatelessWidget {
  const DashboardSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
      child: Column(
        children: <Widget>[
          // 1. Hero Card Skeleton
          KittyShimmer(
            isDarkSurface: true,
            child: Container(
              height: 250,
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space16,
                vertical: AppSpacing.space8,
              ),
              decoration: const BoxDecoration(
                color: AppColors.emeraldCard,
                borderRadius: AppRadius.border20,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.space8),

          // 2. 2x2 Stats Grid Skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: KittyShimmer(
                        child: Container(
                          height: 76,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEAECEF),
                            borderRadius: AppRadius.border18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space12),
                    Expanded(
                      child: KittyShimmer(
                        child: Container(
                          height: 76,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEAECEF),
                            borderRadius: AppRadius.border18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: KittyShimmer(
                        child: Container(
                          height: 76,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEAECEF),
                            borderRadius: AppRadius.border18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space12),
                    Expanded(
                      child: KittyShimmer(
                        child: Container(
                          height: 76,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEAECEF),
                            borderRadius: AppRadius.border18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.space8),

          // 3. Next EMI Card Skeleton
          KittyShimmer(
            isDarkSurface: true,
            child: Container(
              height: 130,
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space16,
                vertical: AppSpacing.space8,
              ),
              decoration: const BoxDecoration(
                color: AppColors.emeraldCard,
                borderRadius: AppRadius.border20,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.space8),

          // 4. Trust Bar Skeleton
          KittyShimmer(
            child: Container(
              height: 52,
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space16,
                vertical: AppSpacing.space8,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.border16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
