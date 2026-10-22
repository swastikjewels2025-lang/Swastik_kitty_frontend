import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_spacing.dart';

/// Reusable modal dialog foundation for Kitty App.
///
/// Features:
/// - Luxury framed card background (`#05241C` dark or `#FFFFFF` light)
/// - Top right circular close button (optional)
/// - Heritage serif title and subtitle
/// - Standardized 20px-24px rounded corners and gold border
class KittyDialog extends StatelessWidget {
  const KittyDialog({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.actions,
    this.showCloseButton = true,
    this.onClose,
    this.isDarkSurface = true,
    this.padding = AppSpacing.all24,
    this.maxWidth = AppDimensions.maxContainerWidth,
  });

  /// Dialog title (Heritage Serif).
  final String title;

  /// Optional subtitle.
  final String? subtitle;

  /// Dialog main content.
  final Widget child;

  /// Bottom action buttons row/list.
  final List<Widget>? actions;

  /// Whether to render top-right circular close button.
  final bool showCloseButton;

  /// Custom close callback (defaults to Navigator.pop).
  final VoidCallback? onClose;

  /// Surface mode.
  final bool isDarkSurface;

  /// Inner padding.
  final EdgeInsetsGeometry padding;

  /// Maximum width constraint.
  final double maxWidth;

  /// Static helper to show [KittyDialog] with glassmorphic modal barrier.
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? subtitle,
    required Widget child,
    List<Widget>? actions,
    bool showCloseButton = true,
    VoidCallback? onClose,
    bool isDarkSurface = true,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withAlpha(190),
      builder: (BuildContext ctx) => KittyDialog(
        title: title,
        subtitle: subtitle,
        actions: actions,
        showCloseButton: showCloseButton,
        onClose: onClose ?? () => Navigator.of(ctx).pop(),
        isDarkSurface: isDarkSurface,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isDarkSurface
        ? AppColors.deepEmeraldBase
        : AppColors.surfaceCardBg;

    final Color borderColor = isDarkSurface
        ? AppColors.goldBorder
        : AppColors.surfaceCardBorder;

    final Color titleColor = isDarkSurface
        ? AppColors.textPrimaryLight
        : AppColors.textPrimaryDark;

    final Color subColor = isDarkSurface
        ? AppColors.emeraldTextSubtle
        : AppColors.textSecondaryMuted;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(24.0),
              border: Border.all(
                color: borderColor,
                width: 1.4,
              ),
              boxShadow: AppShadows.cardLuxury,
            ),
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: padding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Header
                      Padding(
                        padding: EdgeInsets.only(
                          right: showCloseButton ? 36.0 : 0.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18.5,
                                fontWeight: FontWeight.w700,
                                color: titleColor,
                                letterSpacing: -0.2,
                              ),
                            ),
                            if (subtitle != null) ...<Widget>[
                              const SizedBox(height: 4),
                              Text(
                                subtitle!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w400,
                                  color: subColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space16),
                      // Body
                      Flexible(child: child),
                      // Actions
                      if (actions != null && actions!.isNotEmpty) ...<Widget>[
                        const SizedBox(height: AppSpacing.space20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: actions!,
                        ),
                      ],
                    ],
                  ),
                ),
                // Top-Right Close Button
                if (showCloseButton)
                  Positioned(
                    top: 14,
                    right: 14,
                    child: InkWell(
                      onTap: onClose ?? () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(AppRadius.radiusPill),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDarkSurface
                              ? Colors.white.withAlpha(20)
                              : const Color(0xFFF1F5F9),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: isDarkSurface
                              ? AppColors.textPrimaryLight
                              : AppColors.textSecondaryMuted,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
