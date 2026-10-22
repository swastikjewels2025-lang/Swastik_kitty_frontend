import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/feedback/kitty_shimmer.dart';

/// Shimmer skeleton loader mirroring the redesigned Home screen layout.
class HomeSkeletonLoader extends StatelessWidget {
  const HomeSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return KittyShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 1. Today's Gold Rates Skeleton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
              child: Container(
                height: 180,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.border18,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space16),

            // 2. Active Kitty Card Skeleton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
              child: Container(
                height: 200,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.border20,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space16),

            // 3. Quick Actions (3 Tiles)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
              child: Row(
                children: List<Widget>.generate(3, (int index) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        height: 90,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppRadius.border16,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: AppSpacing.space16),

            // 4. Offers Carousel Skeleton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
              child: Container(
                height: 180,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.border16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
