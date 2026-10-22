import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

/// Reusable subtle luxury divider line with optional label or diamond embellishment.
class KittyDivider extends StatelessWidget {
  const KittyDivider({
    super.key,
    this.label,
    this.color,
    this.thickness = 1.0,
    this.height = AppSpacing.space24,
    this.showDiamond = false,
    this.isDarkSurface = false,
  });

  /// Optional center text label (e.g. "OR").
  final String? label;

  /// Line color override.
  final Color? color;

  /// Line thickness.
  final double thickness;

  /// Vertical height container constraint.
  final double height;

  /// Whether to show a miniature gold diamond in the center.
  final bool showDiamond;

  /// Surface mode.
  final bool isDarkSurface;

  @override
  Widget build(BuildContext context) {
    final Color effectiveLineColor = color ??
        (isDarkSurface
            ? Colors.white.withAlpha(25)
            : AppColors.surfaceDivider);

    final Color labelColor = isDarkSurface
        ? AppColors.emeraldTextSubtle
        : AppColors.textSecondaryMuted;

    if (label != null) {
      return SizedBox(
        height: height,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Divider(
                color: effectiveLineColor,
                thickness: thickness,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space12),
              child: Text(
                label!.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: labelColor,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: effectiveLineColor,
                thickness: thickness,
              ),
            ),
          ],
        ),
      );
    }

    if (showDiamond) {
      return SizedBox(
        height: height,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Divider(
                color: effectiveLineColor,
                thickness: thickness,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space8),
              child: Transform.rotate(
                angle: 0.785398, // 45 degrees
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AppColors.goldPrimary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: effectiveLineColor,
                thickness: thickness,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: height,
      child: Center(
        child: Divider(
          color: effectiveLineColor,
          thickness: thickness,
          height: thickness,
        ),
      ),
    );
  }
}
