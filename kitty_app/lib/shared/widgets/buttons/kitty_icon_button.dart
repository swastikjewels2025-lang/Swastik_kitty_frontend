import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_spacing.dart';

/// Standard 40px circular action button for Kitty App.
///
/// Used for header navigation (Back, Drawer Menu, Close, Search, Notification, Wishlist).
/// Conforms to the 40px circular footprint and luxury border styling from UI prototypes.
class KittyIconButton extends StatelessWidget {
  const KittyIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.diameter = AppDimensions.headerActionDiameter,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
    this.tooltip,
    this.badgeCount,
    this.showBadgeDot = false,
    this.isDarkSurface = true,
  });

  /// The icon widget or IconData.
  final Widget icon;

  /// Callback on tap.
  final VoidCallback? onPressed;

  /// Circular diameter (default: 40.0).
  final double diameter;

  /// Background color override.
  final Color? backgroundColor;

  /// Border color override.
  final Color? borderColor;

  /// Icon color override.
  final Color? iconColor;

  /// Optional accessibility tooltip.
  final String? tooltip;

  /// Optional numeric badge count rendered at top-right.
  final int? badgeCount;

  /// Optional pulsing / red indicator dot at top-right.
  final bool showBadgeDot;

  /// Surface mode.
  final bool isDarkSurface;

  @override
  Widget build(BuildContext context) {
    final Color effectiveBg = backgroundColor ??
        (isDarkSurface
            ? AppColors.emeraldContainer
            : AppColors.surfaceCardBg);

    final Color effectiveBorder = borderColor ??
        (isDarkSurface
            ? AppColors.goldBorder
            : AppColors.surfaceCardBorder);

    Widget button = Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: effectiveBg,
        border: Border.all(
          color: effectiveBorder,
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Center(
            child: IconTheme(
              data: IconThemeData(
                color: iconColor ??
                    (isDarkSurface
                        ? AppColors.textPrimaryLight
                        : AppColors.textPrimaryDark),
                size: 20,
              ),
              child: icon,
            ),
          ),
        ),
      ),
    );

    if (badgeCount != null && badgeCount! > 0) {
      button = Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          button,
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.goldPrimary,
                borderRadius: BorderRadius.circular(AppRadius.radiusPill),
                border: Border.all(color: AppColors.deepEmeraldBase, width: 1.5),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Center(
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: AppColors.emeraldCard,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (showBadgeDot) {
      button = Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          button,
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.statusErrorText,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.deepEmeraldBase, width: 1.5),
              ),
            ),
          ),
        ],
      );
    }

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}
