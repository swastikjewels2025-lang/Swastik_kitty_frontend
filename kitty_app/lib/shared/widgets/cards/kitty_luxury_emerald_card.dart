import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_spacing.dart';

/// High-impact luxury hero card container for Kitty App.
///
/// Features:
/// - Deep emerald gradient surface (`#092B22` to `#05241C`)
/// - Ornate subtle metallic gold border (`AppColors.goldBorder`)
/// - Ambient luxury shadow (`AppShadows.cardLuxury`)
/// - Standard 20px rounded corners
class KittyLuxuryEmeraldCard extends StatelessWidget {
  const KittyLuxuryEmeraldCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.all20,
    this.margin,
    this.borderRadius,
    this.borderColor,
    this.onTap,
    this.showAmbientGlow = true,
  });

  /// Card body content.
  final Widget child;

  /// Inner padding (default: 20px).
  final EdgeInsetsGeometry padding;

  /// External margin.
  final EdgeInsetsGeometry? margin;

  /// Border radius (default: 20px).
  final BorderRadius? borderRadius;

  /// Custom border color.
  final Color? borderColor;

  /// Optional tap handler.
  final VoidCallback? onTap;

  /// Whether to render subtle gold border glow.
  final bool showAmbientGlow;

  @override
  Widget build(BuildContext context) {
    final BorderRadius effectiveRadius = borderRadius ?? AppRadius.border20;
    final Color effectiveBorder = borderColor ?? AppColors.goldBorder;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: AppColors.emeraldHeroGradient,
        borderRadius: effectiveRadius,
        border: Border.all(
          color: effectiveBorder,
          width: 1.4,
        ),
        boxShadow: showAmbientGlow ? AppShadows.cardLuxury : null,
      ),
      clipBehavior: Clip.antiAlias,
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
  }
}
