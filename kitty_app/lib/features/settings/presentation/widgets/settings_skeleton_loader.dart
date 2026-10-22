import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/feedback/kitty_shimmer.dart';
import '../../../../shared/widgets/feedback/kitty_skeleton.dart';

/// Shimmer skeleton loader for Settings & Patron Profile screen.
class SettingsSkeletonLoader extends StatelessWidget {
  const SettingsSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return KittyShimmer(
      isDarkSurface: isDark,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Patron Profile Card Skeleton
            KittySkeletonCard(
              height: 96,
              isDarkSurface: isDark,
              child: Row(
                children: <Widget>[
                  KittySkeletonCircle(diameter: 54, isDarkSurface: isDark),
                  const SizedBox(width: AppSpacing.space16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        KittySkeletonText(width: 140, height: 16, isDarkSurface: isDark),
                        const SizedBox(height: 8),
                        KittySkeletonText(width: 100, height: 12, isDarkSurface: isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space20),

            // Section 1 Skeleton Card
            KittySkeletonCard(
              height: 180,
              isDarkSurface: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  KittySkeletonText(width: 180, height: 14, isDarkSurface: isDark),
                  const SizedBox(height: 16),
                  KittySkeletonBox(width: double.infinity, height: 36, isDarkSurface: isDark),
                  const SizedBox(height: 12),
                  KittySkeletonBox(width: double.infinity, height: 36, isDarkSurface: isDark),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space20),

            // Section 2 Skeleton Card
            KittySkeletonCard(
              height: 200,
              isDarkSurface: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  KittySkeletonText(width: 150, height: 14, isDarkSurface: isDark),
                  const SizedBox(height: 16),
                  KittySkeletonBox(width: double.infinity, height: 36, isDarkSurface: isDark),
                  const SizedBox(height: 12),
                  KittySkeletonBox(width: double.infinity, height: 36, isDarkSurface: isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
