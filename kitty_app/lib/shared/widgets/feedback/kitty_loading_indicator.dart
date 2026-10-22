import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

/// Loading indicator types for Kitty App.
enum KittyLoadingType {
  /// Circular progress spinner.
  spinner,

  /// Luxury rotating jewel diamond loader.
  jewel,

  /// Page-level full screen loader.
  fullScreen,
}

/// Standardized loading indicators for Kitty App.
class KittyLoadingIndicator extends StatefulWidget {
  const KittyLoadingIndicator({
    super.key,
    this.type = KittyLoadingType.spinner,
    this.size = 28.0,
    this.color,
    this.message,
    this.isDarkSurface = false,
  });

  /// Visual presentation type.
  final KittyLoadingType type;

  /// Diameter of the indicator.
  final double size;

  /// Custom color override (default: [AppColors.goldPrimary]).
  final Color? color;

  /// Optional message rendered below the loader.
  final String? message;

  /// Surface mode.
  final bool isDarkSurface;

  @override
  State<KittyLoadingIndicator> createState() => _KittyLoadingIndicatorState();
}

class _KittyLoadingIndicatorState extends State<KittyLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = widget.color ?? AppColors.goldPrimary;
    final Color textColor = widget.isDarkSurface
        ? AppColors.textPrimaryLight
        : AppColors.textPrimaryDark;

    Widget indicator;

    switch (widget.type) {
      case KittyLoadingType.spinner:
        indicator = SizedBox(
          width: widget.size,
          height: widget.size,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
          ),
        );
        break;

      case KittyLoadingType.jewel:
        indicator = RotationTransition(
          turns: _rotationController,
          child: Icon(
            Icons.diamond_outlined,
            size: widget.size,
            color: effectiveColor,
          ),
        );
        break;

      case KittyLoadingType.fullScreen:
        indicator = Container(
          color: widget.isDarkSurface
              ? AppColors.deepEmeraldBase
              : AppColors.surfacePageBg,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RotationTransition(
                  turns: _rotationController,
                  child: Icon(
                    Icons.diamond_outlined,
                    size: 48,
                    color: effectiveColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.space16),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
                  ),
                ),
              ],
            ),
          ),
        );
        break;
    }

    if (widget.message != null && widget.type != KittyLoadingType.fullScreen) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          indicator,
          const SizedBox(height: AppSpacing.space10),
          Text(
            widget.message!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return indicator;
  }
}
