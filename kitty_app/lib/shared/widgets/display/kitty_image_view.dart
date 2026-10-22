import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../feedback/kitty_shimmer.dart';

/// Standard image presentation foundation for Kitty App.
///
/// Features:
/// - Handles both local asset images and remote network images
/// - Shimmer loading placeholder
/// - Graceful error fallback
/// - Configurable border radius and aspect ratio
class KittyImageView extends StatelessWidget {
  const KittyImageView({
    super.key,
    this.imageUrl,
    this.assetPath,
    this.width,
    this.height,
    this.aspectRatio,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.borderColor,
    this.borderWidth = 1.0,
    this.isDarkSurface = false,
  });

  /// Remote image URL.
  final String? imageUrl;

  /// Local asset image path.
  final String? assetPath;

  /// Fixed width.
  final double? width;

  /// Fixed height.
  final double? height;

  /// Aspect ratio constraint (e.g. 16/9, 4/3, 1/1).
  final double? aspectRatio;

  /// Corner radius.
  final BorderRadius? borderRadius;

  /// Image BoxFit mode.
  final BoxFit fit;

  /// Optional border frame color.
  final Color? borderColor;

  /// Border frame thickness.
  final double borderWidth;

  /// Surface mode for placeholder shimmer.
  final bool isDarkSurface;

  @override
  Widget build(BuildContext context) {
    final BorderRadius effectiveRadius = borderRadius ?? AppRadius.border12;

    final Widget imageWidget;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      imageWidget = Image.network(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: width != null && width! > 0 ? (width! * 2).round() : null,
        cacheHeight: height != null && height! > 0 ? (height! * 2).round() : null,
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? progress) {
          if (progress == null) return child;
          return _buildPlaceholder(effectiveRadius);
        },
        errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
          return _buildErrorPlaceholder(effectiveRadius);
        },
      );
    } else if (assetPath != null && assetPath!.isNotEmpty) {
      imageWidget = Image.asset(
        assetPath!,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: width != null && width! > 0 ? (width! * 2).round() : null,
        cacheHeight: height != null && height! > 0 ? (height! * 2).round() : null,
        errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
          return _buildErrorPlaceholder(effectiveRadius);
        },
      );
    } else {
      imageWidget = _buildErrorPlaceholder(effectiveRadius);
    }

    final Widget container = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: imageWidget,
    );

    if (aspectRatio != null) {
      return AspectRatio(
        aspectRatio: aspectRatio!,
        child: container,
      );
    }

    return container;
  }

  Widget _buildPlaceholder(BorderRadius radius) {
    return KittyShimmer(
      isDarkSurface: isDarkSurface,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDarkSurface ? AppColors.emeraldCard : const Color(0xFFE5E7EB),
          borderRadius: radius,
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder(BorderRadius radius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDarkSurface ? AppColors.emeraldContainer : const Color(0xFFF3F4F6),
        borderRadius: radius,
      ),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 28,
          color: isDarkSurface ? AppColors.emeraldTextSubtle : AppColors.textTertiary,
        ),
      ),
    );
  }
}
