import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_spacing.dart';

/// Card style variants for Kitty App.
enum KittyCardVariant {
  /// Soft white card with subtle gray border (`#FFFFFF`).
  surfaceLight,

  /// Deep emerald luxury card with subtle gold border (`#092B22`).
  emeraldDark,

  /// Elevated card with soft drop shadow.
  elevated,

  /// Outlined neutral card.
  outlined,

  /// Frosted glassmorphic card on dark background.
  glassmorphic,

  /// Amber/gold highlight card (used for bonus/special notices).
  goldHighlight,
}

/// Universal configurable card container for Kitty App.
///
/// Implements standardized 18px-20px corner radius, tokenized padding,
/// luxury borders, and interactive tap states.
class KittyCard extends StatelessWidget {
  const KittyCard({
    super.key,
    required this.child,
    this.variant = KittyCardVariant.surfaceLight,
    this.padding = AppSpacing.all16,
    this.margin,
    this.borderRadius,
    this.borderColor,
    this.backgroundColor,
    this.onTap,
    this.boxShadow,
    this.clipBehavior = Clip.antiAlias,
  });

  /// The widget content inside the card.
  final Widget child;

  /// Preset visual variant.
  final KittyCardVariant variant;

  /// Internal padding (default: 16px).
  final EdgeInsetsGeometry padding;

  /// External margin.
  final EdgeInsetsGeometry? margin;

  /// Border radius override (default: 18px).
  final BorderRadius? borderRadius;

  /// Custom border color override.
  final Color? borderColor;

  /// Custom background color override.
  final Color? backgroundColor;

  /// Tap callback (makes card actionable with ripple effect).
  final VoidCallback? onTap;

  /// Custom shadow override.
  final List<BoxShadow>? boxShadow;

  /// Clipping behavior.
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final BorderRadius effectiveRadius = borderRadius ?? AppRadius.border18;

    Color resolvedBg;
    Color resolvedBorder;
    List<BoxShadow>? resolvedShadow = boxShadow;

    switch (variant) {
      case KittyCardVariant.surfaceLight:
        resolvedBg = backgroundColor ?? AppColors.surfaceCardBg;
        resolvedBorder = borderColor ?? AppColors.surfaceCardBorder;
        resolvedShadow ??= AppShadows.cardSubtle;
        break;
      case KittyCardVariant.emeraldDark:
        resolvedBg = backgroundColor ?? AppColors.emeraldCard;
        resolvedBorder = borderColor ?? AppColors.emeraldBorder;
        resolvedShadow ??= AppShadows.cardLuxury;
        break;
      case KittyCardVariant.elevated:
        resolvedBg = backgroundColor ?? AppColors.surfaceCardBg;
        resolvedBorder = borderColor ?? AppColors.surfaceCardBorder;
        resolvedShadow ??= AppShadows.cardElevated;
        break;
      case KittyCardVariant.outlined:
        resolvedBg = backgroundColor ?? Colors.transparent;
        resolvedBorder = borderColor ?? AppColors.surfaceCardBorder;
        resolvedShadow = null;
        break;
      case KittyCardVariant.glassmorphic:
        resolvedBg = backgroundColor ?? const Color(0xBF082A21);
        resolvedBorder = borderColor ?? AppColors.goldBorder;
        resolvedShadow ??= AppShadows.cardLuxury;
        break;
      case KittyCardVariant.goldHighlight:
        resolvedBg = backgroundColor ?? AppColors.statusBonusBg;
        resolvedBorder = borderColor ?? const Color(0x59C59B27);
        resolvedShadow ??= AppShadows.cardSubtle;
        break;
    }

    final Widget content = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: resolvedBg,
        borderRadius: effectiveRadius,
        border: Border.all(
          color: resolvedBorder,
          width: 1.2,
        ),
        boxShadow: resolvedShadow,
      ),
      clipBehavior: clipBehavior,
      child: Material(
        color: Colors.transparent,
        child: onTap != null
            ? InkWell(
                borderRadius: effectiveRadius,
                onTap: onTap,
                child: Padding(
                  padding: padding,
                  child: child,
                ),
              )
            : Padding(
                padding: padding,
                child: child,
              ),
      ),
    );

    return content;
  }
}
