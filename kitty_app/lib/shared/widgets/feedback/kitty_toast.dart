import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

/// Toast feedback types for Kitty App.
enum KittyToastType {
  success,
  error,
  warning,
  info,
}

/// Floating transient toast notification foundation for Kitty App.
///
/// Implements the luxury floating feedback banner matching `dashboard.html` / `dashboard.js`.
class KittyToast extends StatelessWidget {
  const KittyToast({
    super.key,
    required this.message,
    this.type = KittyToastType.info,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  /// The message string to present.
  final String message;

  /// Semantic feedback style.
  final KittyToastType type;

  /// Custom icon override.
  final Widget? icon;

  /// Optional action button label.
  final String? actionLabel;

  /// Optional action callback.
  final VoidCallback? onAction;

  /// Helper static method to display a luxury toast via ScaffoldMessenger.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context, {
    required String message,
    KittyToastType type = KittyToastType.info,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space16,
        ),
        padding: EdgeInsets.zero,
        duration: duration,
        content: KittyToast(
          message: message,
          type: type,
          actionLabel: actionLabel,
          onAction: onAction,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color textColor;
    IconData defaultIcon;
    Color iconColor;

    switch (type) {
      case KittyToastType.success:
        bgColor = AppColors.primaryEmerald;
        borderColor = AppColors.statusSuccessText;
        textColor = AppColors.textPrimaryLight;
        defaultIcon = Icons.check_circle_outline;
        iconColor = AppColors.statusSuccessText;
        break;
      case KittyToastType.error:
        bgColor = const Color(0xFF1E1111);
        borderColor = AppColors.statusErrorText;
        textColor = AppColors.textPrimaryLight;
        defaultIcon = Icons.error_outline;
        iconColor = AppColors.statusErrorText;
        break;
      case KittyToastType.warning:
        bgColor = const Color(0xFF1E1A11);
        borderColor = AppColors.statusWarningText;
        textColor = AppColors.textPrimaryLight;
        defaultIcon = Icons.warning_amber_rounded;
        iconColor = AppColors.statusWarningText;
        break;
      case KittyToastType.info:
        bgColor = AppColors.emeraldCard;
        borderColor = AppColors.goldPrimary;
        textColor = AppColors.textPrimaryLight;
        defaultIcon = Icons.info_outline;
        iconColor = AppColors.goldPrimary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space12,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.border14,
        border: Border.all(
          color: borderColor,
          width: 1.2,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          icon ??
              Icon(
                defaultIcon,
                size: 20,
                color: iconColor,
              ),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
                letterSpacing: 0.1,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null) ...<Widget>[
            const SizedBox(width: AppSpacing.space8),
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.goldPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
