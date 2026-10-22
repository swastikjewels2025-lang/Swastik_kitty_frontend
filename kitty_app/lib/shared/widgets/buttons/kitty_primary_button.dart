import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_spacing.dart';

/// High-prominence luxury call-to-action button for Kitty App.
///
/// Follows the approved redesign with Deep Emerald Green (`#063D2E`),
/// crisp white text (`#FFFFFF`), bold typography with `letterSpacing: 1.2`,
/// rounded corners (`radius14`), and supports loading and disabled states.
class KittyPrimaryButton extends StatefulWidget {
  const KittyPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
    this.fullWidth = true,
    this.height = AppDimensions.primaryButtonHeight,
    this.borderRadius,
    this.backgroundColor,
    this.textColor,
    this.loadingLabel,
  });

  /// Button label text (rendered uppercase with tracking by default).
  final String label;

  /// Callback when pressed. If null or [isEnabled] is false, button is disabled.
  final VoidCallback? onPressed;

  /// Optional leading or action icon.
  final Widget? icon;

  /// Whether the button is in a loading state.
  final bool isLoading;

  /// Whether the button is interactable.
  final bool isEnabled;

  /// Whether the button expands to fill parent width.
  final bool fullWidth;

  /// Height constraint (default: [AppDimensions.primaryButtonHeight] 50px).
  final double height;

  /// Optional custom border radius override.
  final BorderRadius? borderRadius;

  /// Optional background color override (replaces metallic gradient if provided).
  final Color? backgroundColor;

  /// Optional text color override.
  final Color? textColor;

  /// Optional text displayed alongside loading spinner.
  final String? loadingLabel;

  @override
  State<KittyPrimaryButton> createState() => _KittyPrimaryButtonState();
}

class _KittyPrimaryButtonState extends State<KittyPrimaryButton> {
  bool _isPressed = false;

  bool get _isActionable =>
      widget.isEnabled && !widget.isLoading && widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = widget.borderRadius ?? AppRadius.border14;
    final Color textColor = widget.textColor ?? Colors.white;

    final Widget buttonContent = AnimatedScale(
      scale: _isPressed && _isActionable ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: widget.isEnabled ? 1.0 : 0.45,
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: widget.backgroundColor == null
                ? AppColors.emeraldPrimaryGradient
                : null,
            color: widget.backgroundColor,
            boxShadow: _isActionable ? AppShadows.ctaEmerald : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: radius,
              onTap: _isActionable ? widget.onPressed : null,
              onHighlightChanged: (bool value) {
                if (_isActionable && mounted) {
                  setState(() => _isPressed = value);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
                child: Center(
                  child: widget.isLoading
                      ? _buildLoadingState(textColor)
                      : _buildDefaultState(textColor),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final Widget semanticContent = Semantics(
      button: true,
      enabled: _isActionable,
      label: widget.label,
      child: buttonContent,
    );

    if (widget.fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: semanticContent,
      );
    }

    return semanticContent;
  }

  Widget _buildDefaultState(Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (widget.icon != null) ...<Widget>[
          widget.icon!,
          const SizedBox(width: AppSpacing.space8),
        ],
        Flexible(
          child: Text(
            widget.label.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            valueColor: AlwaysStoppedAnimation<Color>(textColor),
          ),
        ),
        if (widget.loadingLabel != null) ...<Widget>[
          const SizedBox(width: AppSpacing.space10),
          Text(
            widget.loadingLabel!.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: textColor,
            ),
          ),
        ],
      ],
    );
  }
}
