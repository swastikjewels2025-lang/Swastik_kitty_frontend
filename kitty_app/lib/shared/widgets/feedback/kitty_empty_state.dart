import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_spacing.dart';
import '../buttons/kitty_primary_button.dart';

/// Reusable empty state guidance component for Kitty App.
///
/// Used when a user has no active scheme, empty passbook ledger,
/// or no matching scheme search results.
class KittyEmptyState extends StatelessWidget {
  const KittyEmptyState({
    super.key,
    required this.title,
    required this.description,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.isDarkSurface = false,
    this.padding = AppSpacing.all24,
  });

  /// Primary bold title.
  final String title;

  /// Explanatory description.
  final String description;

  /// Custom illustrative icon.
  final Widget? icon;

  /// Optional call-to-action button text.
  final String? actionLabel;

  /// Callback when CTA is pressed.
  final VoidCallback? onAction;

  /// Surface mode.
  final bool isDarkSurface;

  /// Outer padding.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final Color titleColor = isDarkSurface
        ? AppColors.textPrimaryLight
        : AppColors.textPrimaryDark;

    final Color descColor = isDarkSurface
        ? AppColors.emeraldTextSubtle
        : AppColors.textSecondaryMuted;

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Icon illustration circle
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkSurface
                    ? AppColors.goldSubtle
                    : const Color(0xFFFBF7EE),
                border: Border.all(
                  color: const Color(0x47C59B27),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: icon ??
                    const Icon(
                      Icons.inbox_outlined,
                      size: 32,
                      color: AppColors.goldPrimary,
                    ),
              ),
            ),
            const SizedBox(height: AppSpacing.space16),
            // Title
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space8),
            // Description
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                description,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: descColor,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: AppSpacing.space20),
              KittyPrimaryButton(
                label: actionLabel!,
                onPressed: onAction,
                fullWidth: false,
                height: AppDimensions.primaryButtonHeight,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
