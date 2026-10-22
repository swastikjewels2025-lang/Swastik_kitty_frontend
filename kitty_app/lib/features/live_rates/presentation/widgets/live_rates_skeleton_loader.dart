import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/feedback/kitty_shimmer.dart';

/// Shimmer skeleton loader for the dedicated Live Rates screen.
class LiveRatesSkeletonLoader extends StatelessWidget {
  const LiveRatesSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return KittyShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Timestamp / Live badge placeholder
            Container(
              height: 48,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.border12,
              ),
            ),
            const SizedBox(height: AppSpacing.space16),

            // 4 Gold Karat Card placeholders
            ...List<Widget>.generate(4, (int index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.space12),
                child: Container(
                  height: 104,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.border16,
                  ),
                ),
              );
            }),

            const SizedBox(height: AppSpacing.space8),

            // Silver Card placeholder
            Container(
              height: 104,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.border16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
