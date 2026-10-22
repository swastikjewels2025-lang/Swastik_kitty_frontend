import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

/// Reusable key-value financial row for passbook entries, receipt summaries, and details.
class KittyLabelValueRow extends StatelessWidget {
  const KittyLabelValueRow({
    super.key,
    required this.label,
    required this.value,
    this.valueWidget,
    this.isBoldValue = false,
    this.isGoldValue = false,
    this.isDarkSurface = false,
    this.padding = const EdgeInsets.symmetric(vertical: AppSpacing.space6),
    this.trailing,
  });

  /// Key label string (e.g. "Monthly Installment", "Transaction ID").
  final String label;

  /// Value string (e.g. "₹5,000", "TXN-SW-10821").
  final String value;

  /// Optional custom value widget (e.g. status pill or badge).
  final Widget? valueWidget;

  /// Whether the value text should be bold.
  final bool isBoldValue;

  /// Whether the value text should be highlighted in gold.
  final bool isGoldValue;

  /// Surface mode.
  final bool isDarkSurface;

  /// Inner vertical padding.
  final EdgeInsetsGeometry padding;

  /// Optional trailing widget.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final Color labelColor = isDarkSurface
        ? AppColors.emeraldTextSubtle
        : AppColors.textSecondaryMuted;

    Color valueColor;
    if (isGoldValue) {
      valueColor = AppColors.goldPrimary;
    } else if (isDarkSurface) {
      valueColor = AppColors.textPrimaryLight;
    } else {
      valueColor = AppColors.textPrimaryDark;
    }

    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.space8),
          if (valueWidget != null)
            valueWidget!
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: isBoldValue ? FontWeight.w700 : FontWeight.w600,
                    color: valueColor,
                  ),
                ),
                if (trailing != null) ...<Widget>[
                  const SizedBox(width: AppSpacing.space6),
                  trailing!,
                ],
              ],
            ),
        ],
      ),
    );
  }
}
