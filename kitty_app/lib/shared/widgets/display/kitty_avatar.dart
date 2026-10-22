import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Luxury profile avatar component for Kitty App.
///
/// Features:
/// - Metallic gold or emerald circular ring border
/// - Image (network or asset) with fallback to patron initials
/// - Size variants (sm: 32px, md: 44px, lg: 56px, xl: 72px)
class KittyAvatar extends StatelessWidget {
  const KittyAvatar({
    super.key,
    this.imageUrl,
    this.assetPath,
    this.initials,
    this.size = AppDimensions.avatarSize,
    this.borderColor,
    this.borderWidth = 1.5,
    this.backgroundColor,
    this.textColor,
    this.onTap,
  });

  /// Optional remote image URL.
  final String? imageUrl;

  /// Optional local asset image path.
  final String? assetPath;

  /// Fallback initials (e.g. "RS" or "SJ").
  final String? initials;

  /// Diameter of the avatar (default: 44px).
  final double size;

  /// Border ring color override (default: [AppColors.goldPrimary]).
  final Color? borderColor;

  /// Border ring thickness.
  final double borderWidth;

  /// Background color fill behind initials/image.
  final Color? backgroundColor;

  /// Text color for initials.
  final Color? textColor;

  /// Optional tap handler.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color effectiveBorder = borderColor ?? AppColors.goldPrimary;
    final Color effectiveBg = backgroundColor ?? AppColors.emeraldCard;
    final Color effectiveText = textColor ?? AppColors.goldLight;

    Widget avatarContent;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatarContent = Image.network(
        imageUrl!,
        cacheWidth: 120,
        cacheHeight: 120,
        fit: BoxFit.cover,
        errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
            _buildInitials(effectiveText),
      );
    } else if (assetPath != null && assetPath!.isNotEmpty) {
      avatarContent = Image.asset(
        assetPath!,
        cacheWidth: 120,
        cacheHeight: 120,
        fit: BoxFit.cover,
        errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
            _buildInitials(effectiveText),
      );
    } else {
      avatarContent = _buildInitials(effectiveText);
    }

    final Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: effectiveBg,
        border: Border.all(
          color: effectiveBorder,
          width: borderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Center(child: avatarContent),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _buildInitials(Color effectiveText) {
    final String text = (initials != null && initials!.isNotEmpty)
        ? (initials!.length > 2 ? initials!.substring(0, 2) : initials!).toUpperCase()
        : 'SJ';

    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: size * 0.38,
        fontWeight: FontWeight.w700,
        color: effectiveText,
        letterSpacing: 0.5,
      ),
    );
  }
}
