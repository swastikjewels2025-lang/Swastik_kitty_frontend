import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_spacing.dart';

/// Reusable outlined CTA button for Kitty App.
///
/// Features:
/// - Default 52px accessible touch target height (or custom height).
/// - Gold border on dark emerald surfaces or subtle card border on light surfaces.
/// - Supports loading, disabled, icon, and full-width states.
class KittyOutlinedButton extends StatelessWidget {
  const KittyOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
    this.fullWidth = true,
    this.height = AppDimensions.primaryButtonHeight,
    this.isDarkSurface = false,
    this.borderColor,
    this.textColor,
    this.borderRadius,
  });

  /// Button label.
  final String label;

  /// Callback when pressed.
  final VoidCallback? onPressed;

  /// Optional leading icon.
  final Widget? icon;

  /// Loading state indicator.
  final bool isLoading;

  /// Whether the button is actionable.
  final bool isEnabled;

  /// Whether the button fills parent width.
  final bool fullWidth;

  /// Height constraint (default: [AppDimensions.primaryButtonHeight] 52px).
  final double height;

  /// Whether rendered on dark emerald canvas.
  final bool isDarkSurface;

  /// Custom border color override.
  final Color? borderColor;

  /// Custom text color override.
  final Color? textColor;

  /// Optional custom border radius.
  final BorderRadius? borderRadius;

  bool get _isActionable => isEnabled && !isLoading && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final BorderRadius effectiveRadius = borderRadius ?? AppRadius.border14;

    final Color effectiveBorder = borderColor ??
        (isDarkSurface ? AppColors.goldPrimary : AppColors.surfaceCardBorder);

    final Color effectiveText = textColor ??
        (isDarkSurface ? AppColors.goldLight : AppColors.textPrimaryDark);

    final Widget buttonContent = AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isEnabled ? 1.0 : 0.45,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: effectiveRadius,
          border: Border.all(
            color: effectiveBorder,
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: effectiveRadius,
            onTap: _isActionable ? onPressed : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(effectiveText),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          if (icon != null) ...<Widget>[
                            icon!,
                            const SizedBox(width: AppSpacing.space8),
                          ],
                          Flexible(
                            child: Text(
                              label,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: effectiveText,
                                letterSpacing: 0.3,
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

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: buttonContent,
      );
    }

    return buttonContent;
  }
}
