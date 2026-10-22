import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../buttons/kitty_primary_button.dart';
import '../buttons/kitty_secondary_button.dart';
import 'kitty_dialog.dart';

/// Confirmation dialog for critical user actions (e.g. Discard Changes, Logout, Cancel Scheme).
class KittyConfirmDialog extends StatelessWidget {
  const KittyConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.isDarkSurface = true,
  });

  /// Dialog title.
  final String title;

  /// Explanatory message.
  final String message;

  /// Confirm button label.
  final String confirmLabel;

  /// Cancel button label.
  final String cancelLabel;

  /// Confirm action callback.
  final VoidCallback? onConfirm;

  /// Cancel action callback.
  final VoidCallback? onCancel;

  /// Whether the confirmation is destructive (red CTA styling).
  final bool isDestructive;

  /// Surface mode.
  final bool isDarkSurface;

  /// Static helper to display [KittyConfirmDialog].
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
    bool isDarkSurface = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withAlpha(190),
      builder: (BuildContext ctx) => KittyConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        isDarkSurface: isDarkSurface,
        onConfirm: () => Navigator.of(ctx).pop(true),
        onCancel: () => Navigator.of(ctx).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = isDarkSurface
        ? AppColors.emeraldTextSubtle
        : AppColors.textSecondaryMuted;

    return KittyDialog(
      title: title,
      isDarkSurface: isDarkSurface,
      showCloseButton: false,
      actions: <Widget>[
        KittySecondaryButton(
          label: cancelLabel,
          onPressed: onCancel ?? () => Navigator.of(context).pop(false),
          isDarkSurface: isDarkSurface,
        ),
        const SizedBox(width: AppSpacing.space10),
        KittyPrimaryButton(
          label: confirmLabel,
          onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
          fullWidth: false,
          height: 40,
          backgroundColor: isDestructive ? AppColors.statusErrorText : null,
          textColor: isDestructive ? Colors.white : null,
        ),
      ],
      child: Text(
        message,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13.5,
          fontWeight: FontWeight.w400,
          color: textColor,
          height: 1.45,
        ),
      ),
    );
  }
}
