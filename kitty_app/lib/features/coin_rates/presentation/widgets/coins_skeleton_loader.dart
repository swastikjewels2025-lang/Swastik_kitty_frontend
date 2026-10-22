import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/feedback/kitty_shimmer.dart';
import '../../../../shared/widgets/feedback/kitty_skeleton.dart';

/// Luxury shimmer skeleton placeholder for the Coins experience during initial rate loading.
class CoinsSkeletonLoader extends StatelessWidget {
  const CoinsSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return KittyShimmer(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          // 1. Heading placeholder
          const Center(
            child: KittySkeletonBox(
              width: 120,
              height: 20,
              borderRadius: AppRadius.border8,
            ),
          ),
          const SizedBox(height: 16),

          // 2. Category Selector & Calculator button row
          const Row(
            children: <Widget>[
              Expanded(
                child: KittySkeletonBox(
                  width: double.infinity,
                  height: 42,
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
              ),
              SizedBox(width: 10),
              KittySkeletonBox(
                width: 100,
                height: 42,
                borderRadius: AppRadius.border12,
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 3. Table Header placeholder
          const KittySkeletonBox(
            width: double.infinity,
            height: 44,
            borderRadius: AppRadius.border10,
          ),
          const SizedBox(height: 8),

          // 4. Predefined 5g, 6g, 7g Coin rows
          ...List<Widget>.generate(3, (int index) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: KittySkeletonBox(
                width: double.infinity,
                height: 54,
                borderRadius: AppRadius.border10,
              ),
            );
          }),

          const SizedBox(height: 24),

          // 5. Custom Coin Section Heading
          const Center(
            child: KittySkeletonBox(
              width: 160,
              height: 18,
              borderRadius: AppRadius.border8,
            ),
          ),
          const SizedBox(height: 16),

          // 6. Custom Configurator Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.creamIvoryCard,
              borderRadius: AppRadius.border16,
              border: Border.all(color: AppColors.surfaceCardBorder),
            ),
            child: const Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: KittySkeletonBox(
                        width: double.infinity,
                        height: 110,
                        borderRadius: AppRadius.border12,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: KittySkeletonBox(
                        width: double.infinity,
                        height: 110,
                        borderRadius: AppRadius.border12,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14),
                KittySkeletonBox(
                  width: double.infinity,
                  height: 48,
                  borderRadius: AppRadius.border12,
                ),
                SizedBox(height: 14),
                KittySkeletonBox(
                  width: double.infinity,
                  height: 54,
                  borderRadius: AppRadius.border10,
                ),
                SizedBox(height: 14),
                KittySkeletonBox(
                  width: double.infinity,
                  height: 44,
                  borderRadius: AppRadius.border10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
