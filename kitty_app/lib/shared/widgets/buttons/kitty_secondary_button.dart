import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_spacing.dart';

/// Clean secondary / outline button for Kitty App.
///
/// Used for secondary flows like "View Receipt", "Print Statement", "Choose File".
/// Supports both light surface mode (`#FFFFFF` bg with gray/gold border) and
/// dark emerald surface mode.
class KittySecondaryButton extends StatelessWidget {
  const KittySecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
    this.fullWidth = false,
    this.height = AppDimensions.compactButtonHeight,
    this.isDarkSurface = false,
    this.borderColor,
    this.textColor,
    this.backgroundColor,
  });

  /// Button label.
  final String label;

  /// Callback when pressed.
  final VoidCallback? onPressed;

  /// Optional leading icon.
  final Widget? icon;

  /// Whether button is in loading state.
  final bool isLoading;

  /// Whether button is interactable.
  final bool isEnabled;

  /// Whether button occupies full available width.
  final bool fullWidth;

  /// Height constraint (default: [AppDimensions.compactButtonHeight] 40px).
  final double height;

  /// Whether rendered on dark emerald canvas.
  final bool isDarkSurface;

  /// Optional custom border color.
  final Color? borderColor;

  /// Optional custom text color.
  final Color? textColor;

  /// Optional custom background fill.
  final Color? backgroundColor;

  bool get _isActionable => isEnabled && !isLoading && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final Color effectiveBorder = borderColor ??
        (isDarkSurface ? AppColors.goldBorder : AppColors.surfaceCardBorder);

    final Color effectiveText = textColor ??
        (isDarkSurface ? AppColors.goldLight : AppColors.textPrimaryDark);

    final Color effectiveBg = backgroundColor ??
        (isDarkSurface ? Colors.white.withAlpha(12) : AppColors.surfaceCardBg);

    final Widget buttonContent = AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isEnabled ? 1.0 : 0.45,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: effectiveBg,
          borderRadius: AppRadius.border12,
          border: Border.all(
            color: effectiveBorder,
            width: 1.2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: AppRadius.border12,
            onTap: _isActionable ? onPressed : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(effectiveText),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          if (icon != null) ...<Widget>[
                            icon!,
                            const SizedBox(width: AppSpacing.space6),
                          ],
                          Flexible(
                            child: Text(
                              label,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: effectiveText,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );

    final Widget semanticContent = Semantics(
      button: true,
      enabled: _isActionable,
      label: label,
      child: buttonContent,
    );

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: semanticContent,
      );
    }

    return semanticContent;
  }
}
