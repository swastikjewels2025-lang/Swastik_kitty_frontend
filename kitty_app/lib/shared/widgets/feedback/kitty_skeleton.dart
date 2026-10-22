import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import 'kitty_shimmer.dart';

/// Reusable skeleton box placeholder.
class KittySkeletonBox extends StatelessWidget {
  const KittySkeletonBox({
    super.key,
    this.width,
    this.height = 16.0,
    this.borderRadius,
    this.color,
    this.isDarkSurface = false,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final Color? color;
  final bool isDarkSurface;

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = color ??
        (isDarkSurface ? const Color(0xFFE2DDD5) : const Color(0xFFEFE9DF));

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: borderRadius ?? AppRadius.border6,
      ),
    );
  }
}

/// Reusable skeleton text line placeholder.
class KittySkeletonText extends StatelessWidget {
  const KittySkeletonText({
    super.key,
    this.width,
    this.height = 14.0,
    this.isDarkSurface = false,
  });

  final double? width;
  final double height;
  final bool isDarkSurface;

  @override
  Widget build(BuildContext context) {
    return KittySkeletonBox(
      width: width,
      height: height,
      borderRadius: AppRadius.border6,
      isDarkSurface: isDarkSurface,
    );
  }
}

/// Reusable skeleton circular avatar/icon placeholder.
class KittySkeletonCircle extends StatelessWidget {
  const KittySkeletonCircle({
    super.key,
    this.diameter = 40.0,
    this.isDarkSurface = false,
  });

  final double diameter;
  final bool isDarkSurface;

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = isDarkSurface
        ? const Color(0xFF092B22)
        : const Color(0xFFE5E7EB);

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: effectiveColor,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Reusable skeleton card container.
class KittySkeletonCard extends StatelessWidget {
  const KittySkeletonCard({
    super.key,
    this.height = 120.0,
    this.width,
    this.padding = AppSpacing.all16,
    this.borderRadius,
    this.isDarkSurface = false,
    this.child,
  });

  final double height;
  final double? width;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final bool isDarkSurface;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final Color effectiveBg = isDarkSurface
        ? const Color(0xFF07241C)
        : AppColors.surfaceCardBg;

    final Color effectiveBorder = isDarkSurface
        ? AppColors.emeraldBorder
        : AppColors.surfaceCardBorder;

    return KittyShimmer(
      isDarkSurface: isDarkSurface,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: effectiveBg,
          borderRadius: borderRadius ?? AppRadius.border18,
          border: Border.all(color: effectiveBorder, width: 1.0),
        ),
        child: child ??
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                KittySkeletonText(width: 140, isDarkSurface: isDarkSurface),
                KittySkeletonText(width: 220, isDarkSurface: isDarkSurface),
                KittySkeletonText(width: 80, isDarkSurface: isDarkSurface),
              ],
            ),
      ),
    );
  }
}

/// Reusable skeleton list tile placeholder.
class KittySkeletonListTile extends StatelessWidget {
  const KittySkeletonListTile({
    super.key,
    this.isDarkSurface = false,
  });

  final bool isDarkSurface;

  @override
  Widget build(BuildContext context) {
    return KittyShimmer(
      isDarkSurface: isDarkSurface,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
        child: Row(
          children: <Widget>[
            KittySkeletonCircle(diameter: 40, isDarkSurface: isDarkSurface),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  KittySkeletonText(width: 120, height: 14, isDarkSurface: isDarkSurface),
                  const SizedBox(height: AppSpacing.space6),
                  KittySkeletonText(width: 180, height: 11, isDarkSurface: isDarkSurface),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.space12),
            KittySkeletonBox(width: 60, height: 24, isDarkSurface: isDarkSurface),
          ],
        ),
      ),
    );
  }
}
