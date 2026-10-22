import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';

/// Reusable Kitty Number / Token pill badge for Kitty App.
///
/// Implements the aligned terminology (replacing "Chit Token").
/// Displays canonical identifiers like `No. 42`, `#SW-042`, or `Kitty #08`.
/// Supports both dark emerald luxury and clean light surface styling.
class KittyNumberPill extends StatelessWidget {
  const KittyNumberPill({
    super.key,
    required this.number,
    this.isDarkSurface = true,
    this.fontSize = 11.0,
    this.prefixIcon,
  });

  /// The Kitty number or token string (e.g. "No. 42", "#SW-042").
  final String number;

  /// Surface mode: dark emerald vs light surface.
  final bool isDarkSurface;

  /// Font size.
  final double fontSize;

  /// Optional prefix icon (defaults to [AppIcons.tag]).
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: 3.5,
      ),
      decoration: BoxDecoration(
        color: isDarkSurface ? AppColors.goldSubtle : AppColors.champagneFoil,
        borderRadius: BorderRadius.circular(AppRadius.radiusPill),
        border: Border.all(
          color: isDarkSurface
              ? AppColors.goldBorder
              : AppColors.honeyGoldAccent.withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          prefixIcon ??
              Icon(
                AppIcons.tag,
                size: 11,
                color: isDarkSurface ? AppColors.goldPrimary : AppColors.honeyGoldAccent,
              ),
          const SizedBox(width: 3),
          Text(
            number,
            style: GoogleFonts.plusJakartaSans(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: isDarkSurface ? AppColors.goldLight : AppColors.espressoCharcoal,
            ),
          ),
        ],
      ),
    );
  }
}
