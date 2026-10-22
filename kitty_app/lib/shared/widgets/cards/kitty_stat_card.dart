import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import 'kitty_card.dart';

/// Financial metric statistic card for Kitty App.
///
/// Implements the 2x2 dashboard statistic grid widget with:
/// - Frosted gold icon circle (`44px x 44px`)
/// - Uppercase kicker label
/// - Bold currency / gold weight metric value
/// - Optional gain/loss percentage delta pill (`+2.59%`)
/// - Optional subtitle description
class KittyStatCard extends StatelessWidget {
  const KittyStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    this.deltaText,
    this.isGain = true,
    this.onTap,
    this.isDarkSurface = false,
  });

  /// Leading icon widget.
  final Widget icon;

  /// Uppercase metadata label (e.g. "SCHEME TARGET", "GOLD ACCUMULATED").
  final String label;

  /// High-contrast primary metric value (e.g. "₹60,000", "5.482 g").
  final String value;

  /// Optional bottom subtitle or detail note.
  final String? subtitle;

  /// Optional percentage change string (e.g. "+2.59%").
  final String? deltaText;

  /// Whether the delta is positive (gain / green) or negative (loss / red).
  final bool isGain;

  /// Optional card tap callback.
  final VoidCallback? onTap;

  /// Whether card is rendered on dark emerald surface.
  final bool isDarkSurface;

  @override
  Widget build(BuildContext context) {
    final Color textColor = isDarkSurface
        ? AppColors.textPrimaryLight
        : AppColors.textPrimaryDark;

    final Color labelColor = isDarkSurface
        ? AppColors.emeraldTextSubtle
        : AppColors.textSecondaryMuted;

    return KittyCard(
      variant: isDarkSurface
          ? KittyCardVariant.emeraldDark
          : KittyCardVariant.surfaceLight,
      padding: AppSpacing.all14,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Header: Icon circle + Delta tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: <Color>[Color(0xFFFBF7EE), Color(0xFFF5EBDA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: const Color(0x33C59B27),
                    width: 1.0,
                  ),
                ),
                child: Center(
                  child: IconTheme(
                    data: const IconThemeData(
                      color: AppColors.goldPrimary,
                      size: 20,
                    ),
                    child: icon,
                  ),
                ),
              ),
              if (deltaText != null) ...<Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space6,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: isGain
                        ? AppColors.statusSuccessBg
                        : AppColors.statusErrorBg,
                    borderRadius: BorderRadius.circular(AppRadius.radiusPill),
                    border: Border.all(
                      color: isGain
                          ? AppColors.statusSuccessBorder
                          : AppColors.statusErrorBorder,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        isGain ? Icons.trending_up : Icons.trending_down,
                        size: 11,
                        color: isGain
                            ? AppColors.statusSuccessText
                            : AppColors.statusErrorText,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        deltaText!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isGain
                              ? AppColors.statusSuccessText
                              : AppColors.statusErrorText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.space12),
          // Label
          Text(
            label.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: labelColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.space2),
          // Value
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...<Widget>[
            const SizedBox(height: AppSpacing.space2),
            Text(
              subtitle!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
