import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_spacing.dart';
import '../buttons/kitty_primary_button.dart';
import '../buttons/kitty_secondary_button.dart';

/// Standard error and retry view foundation for Kitty App.
///
/// Features error illustration, failure message, retry CTA,
/// and optional secondary action (e.g. "Contact Concierge").
class KittyErrorState extends StatelessWidget {
  const KittyErrorState({
    super.key,
    this.title = 'Unable to Load Data',
    required this.message,
    this.onRetry,
    this.retryLabel = 'Try Again',
    this.secondaryLabel,
    this.onSecondaryAction,
    this.icon,
    this.isDarkSurface = false,
    this.padding = AppSpacing.all24,
  });

  /// Error heading.
  final String title;

  /// Explanatory error description.
  final String message;

  /// Retry callback.
  final VoidCallback? onRetry;

  /// Retry button label.
  final String retryLabel;

  /// Optional secondary button label.
  final String? secondaryLabel;

  /// Optional secondary button callback.
  final VoidCallback? onSecondaryAction;

  /// Custom error icon.
  final Widget? icon;

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
            // Error icon circle
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.statusErrorBg,
                border: Border.all(
                  color: AppColors.statusErrorBorder,
                  width: 1.2,
                ),
              ),
              child: Center(
                child: icon ??
                    const Icon(
                      Icons.error_outline,
                      size: 34,
                      color: AppColors.statusErrorText,
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
            // Message
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                message,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: descColor,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.space24),
            // Action buttons
            if (onRetry != null) ...<Widget>[
              KittyPrimaryButton(
                label: retryLabel,
                onPressed: onRetry,
                fullWidth: false,
                height: AppDimensions.primaryButtonHeight,
                icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
              ),
            ],
            if (secondaryLabel != null && onSecondaryAction != null) ...<Widget>[
              const SizedBox(height: AppSpacing.space10),
              KittySecondaryButton(
                label: secondaryLabel!,
                onPressed: onSecondaryAction,
                isDarkSurface: isDarkSurface,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
