import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_spacing.dart';

/// Modal bottom sheet container for Kitty App.
///
/// Features:
/// - Rounded top corners (24px)
/// - Centered grab handle
/// - Dark emerald or light surface styling
/// - Title and optional close trigger
class KittyBottomSheet extends StatelessWidget {
  const KittyBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.showGrabHandle = true,
    this.showCloseButton = true,
    this.onClose,
    this.isDarkSurface = false,
    this.padding = AppSpacing.all20,
    this.maxHeightFraction = 0.85,
  });

  /// Sheet content.
  final Widget child;

  /// Optional header title.
  final String? title;

  /// Optional header subtitle.
  final String? subtitle;

  /// Whether to render the pill grab handle at the top.
  final bool showGrabHandle;

  /// Whether to render top-right close button.
  final bool showCloseButton;

  /// Close callback (defaults to Navigator.pop).
  final VoidCallback? onClose;

  /// Surface mode: dark emerald vs light surface.
  final bool isDarkSurface;

  /// Inner padding.
  final EdgeInsetsGeometry padding;

  /// Maximum sheet height as a fraction of screen height (default: 0.85).
  final double maxHeightFraction;

  /// Static helper to display [KittyBottomSheet].
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    String? subtitle,
    bool showGrabHandle = true,
    bool showCloseButton = true,
    VoidCallback? onClose,
    bool isDarkSurface = false,
    bool isScrollControlled = true,
    EdgeInsetsGeometry padding = AppSpacing.all20,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (BuildContext ctx) => KittyBottomSheet(
        title: title,
        subtitle: subtitle,
        showGrabHandle: showGrabHandle,
        showCloseButton: showCloseButton,
        onClose: onClose ?? () => Navigator.of(ctx).pop(),
        isDarkSurface: isDarkSurface,
        padding: padding,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isDarkSurface
        ? AppColors.deepEmeraldBase
        : AppColors.surfacePageBg;

    final Color borderColor = isDarkSurface
        ? AppColors.goldBorder
        : AppColors.surfaceCardBorder;

    final Color titleColor = isDarkSurface
        ? AppColors.textPrimaryLight
        : AppColors.textPrimaryDark;

    final Color subColor = isDarkSurface
        ? AppColors.emeraldTextSubtle
        : AppColors.textSecondaryMuted;

    final Color handleColor = isDarkSurface
        ? Colors.white.withAlpha(50)
        : const Color(0xFFCBD5E1);

    final double screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppDimensions.maxWideContainerWidth,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: screenHeight * maxHeightFraction,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
            border: Border.all(
              color: borderColor,
              width: 1.2,
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x66000000),
                offset: Offset(0, -6),
                blurRadius: 28,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (showGrabHandle) ...<Widget>[
                const SizedBox(height: AppSpacing.space10),
                Center(
                  child: Container(
                    width: 38,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: handleColor,
                      borderRadius: BorderRadius.circular(AppRadius.radiusPill),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.space8),
              ],
              if (title != null) ...<Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space20,
                    vertical: AppSpacing.space8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              title!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: titleColor,
                              ),
                            ),
                            if (subtitle != null) ...<Widget>[
                              const SizedBox(height: 2),
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
                      if (showCloseButton)
                        InkWell(
                          onTap: onClose ?? () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(AppRadius.radiusPill),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDarkSurface
                                  ? Colors.white.withAlpha(20)
                                  : const Color(0xFFEDF2F7),
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
                    ],
                  ),
                ),
                Divider(
                  color: isDarkSurface ? AppColors.emeraldBorder : AppColors.surfaceDivider,
                  height: 1,
                  thickness: 1,
                ),
              ],
              Flexible(
                child: SingleChildScrollView(
                  padding: padding,
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
