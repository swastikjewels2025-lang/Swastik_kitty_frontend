import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

/// Borderless text / link button for Kitty App.
///
/// Used for secondary inline actions like "Resend OTP", "Forgot PIN", "Change Number".
class KittyGhostButton extends StatelessWidget {
  const KittyGhostButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.textColor,
    this.fontSize = 13.0,
    this.fontWeight = FontWeight.w600,
    this.isEnabled = true,
    this.underline = false,
  });

  /// Text label.
  final String label;

  /// Callback when pressed.
  final VoidCallback? onPressed;

  /// Optional leading or trailing icon.
  final Widget? icon;

  /// Text color override (default: [AppColors.goldPrimary]).
  final Color? textColor;

  /// Font size (default: 13.0).
  final double fontSize;

  /// Font weight (default: SemiBold 600).
  final FontWeight fontWeight;

  /// Whether interactable.
  final bool isEnabled;

  /// Whether text is underlined.
  final bool underline;

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = isEnabled
        ? (textColor ?? AppColors.goldPrimary)
        : AppColors.textTertiary;

    return InkWell(
      onTap: isEnabled ? onPressed : null,
      borderRadius: AppRadius.border6,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space8,
          vertical: AppSpacing.space4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              icon!,
              const SizedBox(width: AppSpacing.space4),
            ],
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: effectiveColor,
                decoration: underline ? TextDecoration.underline : null,
                decorationColor: effectiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
