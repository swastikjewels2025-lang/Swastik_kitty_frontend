import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

/// Reusable form selector tile for Kitty App.
///
/// Used for triggering bottom sheets or modal pickers
/// (e.g., Karat selection, Kitty plan selection, Payment method selection).
class KittySelector extends StatelessWidget {
  const KittySelector({
    super.key,
    this.label,
    required this.value,
    this.hint,
    required this.onTap,
    this.leading,
    this.trailing,
    this.isDarkSurface = false,
    this.isEnabled = true,
    this.hasError = false,
    this.errorText,
  });

  /// Optional label above selector.
  final String? label;

  /// Current display value (or empty if none).
  final String? value;

  /// Placeholder hint if value is empty.
  final String? hint;

  /// Tap callback (opens picker/sheet).
  final VoidCallback onTap;

  /// Optional leading icon or widget.
  final Widget? leading;

  /// Custom trailing icon (defaults to down chevron).
  final Widget? trailing;

  /// Surface mode.
  final bool isDarkSurface;

  /// Whether selector is actionable.
  final bool isEnabled;

  /// Error state.
  final bool hasError;

  /// Error message.
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final bool hasValue = value != null && value!.isNotEmpty;

    final Color textColor = isDarkSurface
        ? AppColors.textPrimaryLight
        : AppColors.textPrimaryDark;

    final Color hintColor = isDarkSurface
        ? AppColors.emeraldTextSubtle
        : AppColors.textSecondaryMuted;

    final Color fillColor = isDarkSurface
        ? Colors.white.withAlpha(18)
        : AppColors.surfaceCardBg;

    final Color borderColor = hasError
        ? AppColors.statusErrorText
        : (isDarkSurface
            ? Colors.white.withAlpha(35)
            : AppColors.surfaceCardBorder);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (label != null) ...<Widget>[
          Text(
            label!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDarkSurface
                  ? AppColors.emeraldTextSubtle
                  : AppColors.textSecondaryMuted,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: AppSpacing.space6),
        ],
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: AppRadius.border12,
            border: Border.all(
              color: borderColor,
              width: hasError ? 1.5 : 1.0,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: AppRadius.border12,
              onTap: isEnabled ? onTap : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space14),
                child: Row(
                  children: <Widget>[
                    if (leading != null) ...<Widget>[
                      leading!,
                      const SizedBox(width: AppSpacing.space10),
                    ],
                    Expanded(
                      child: Text(
                        hasValue ? value! : (hint ?? 'Select'),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                          color: isEnabled
                              ? (hasValue ? textColor : hintColor)
                              : AppColors.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    trailing ??
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 22,
                          color: hintColor,
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (hasError && errorText != null) ...<Widget>[
          const SizedBox(height: AppSpacing.space4),
          Text(
            errorText!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.statusErrorText,
            ),
          ),
        ],
      ],
    );
  }
}
