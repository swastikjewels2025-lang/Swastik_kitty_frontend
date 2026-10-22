import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_spacing.dart';

/// Reusable luxury text input field for Kitty App.
///
/// Supports dark emerald glassmorphic mode (`isDarkSurface: true`) and
/// crisp light surface mode (`isDarkSurface: false`).
/// Includes label, hint, helper text, error text, prefix/suffix widgets,
/// clear button action, and gold focus glow.
class KittyTextField extends StatefulWidget {
  const KittyTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.showClearButton = false,
    this.isDarkSurface = false,
    this.enabled = true,
    this.readOnly = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
    this.maxLines = 1,
    this.maxLength,
    this.autofocus = false,
  });

  /// Text editing controller.
  final TextEditingController? controller;

  /// Initial string value if controller is not provided.
  final String? initialValue;

  /// Field label displayed above the input.
  final String? label;

  /// Placeholder hint text.
  final String? hintText;

  /// Sub-text helper.
  final String? helperText;

  /// Validation error message.
  final String? errorText;

  /// Leading prefix icon or widget.
  final Widget? prefixIcon;

  /// Trailing suffix widget.
  final Widget? suffixIcon;

  /// Whether the input should obscure text (password / MPIN).
  final bool isPassword;

  /// Whether to show a clear '✕' button when text is present.
  final bool showClearButton;

  /// Surface mode: true for dark emerald canvas, false for crisp white card canvas.
  final bool isDarkSurface;

  /// Whether field is enabled.
  final bool enabled;

  /// Whether field is read-only.
  final bool readOnly;

  /// Keyboard input type.
  final TextInputType? keyboardType;

  /// Keyboard action (Next, Done, etc.).
  final TextInputAction? textInputAction;

  /// Input formatters (regex, length limits, mask).
  final List<TextInputFormatter>? inputFormatters;

  /// Change callback.
  final ValueChanged<String>? onChanged;

  /// Submit callback.
  final ValueChanged<String>? onSubmitted;

  /// Tap callback (for date/dropdown triggers).
  final VoidCallback? onTap;

  /// Focus node.
  final FocusNode? focusNode;

  /// Maximum line count (default: 1).
  final int maxLines;

  /// Maximum character count.
  final int? maxLength;

  /// Whether to auto-focus on appearance.
  final bool autofocus;

  @override
  State<KittyTextField> createState() => _KittyTextFieldState();
}

class _KittyTextFieldState extends State<KittyTextField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _obscureText = true;
  bool _isInternalController = false;
  bool _isInternalFocusNode = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController(text: widget.initialValue);
      _isInternalController = true;
    } else {
      _controller = widget.controller!;
    }

    if (widget.focusNode == null) {
      _focusNode = FocusNode();
      _isInternalFocusNode = true;
    } else {
      _focusNode = widget.focusNode!;
    }

    _obscureText = widget.isPassword;
    _controller.addListener(_handleTextChange);
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    _focusNode.removeListener(_handleFocusChange);
    if (_isInternalController) {
      _controller.dispose();
    }
    if (_isInternalFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleTextChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final bool isFocused = _focusNode.hasFocus;

    // Color resolution based on dark/light surface mode
    final Color textColor = widget.isDarkSurface
        ? AppColors.textPrimaryLight
        : AppColors.textPrimaryDark;

    final Color hintColor = widget.isDarkSurface
        ? AppColors.emeraldTextSubtle
        : AppColors.textSecondaryMuted;

    final Color fillColor = widget.isDarkSurface
        ? Colors.white.withAlpha(18)
        : AppColors.surfaceCardBg;

    final Color defaultBorderColor = widget.isDarkSurface
        ? Colors.white.withAlpha(35)
        : AppColors.surfaceCardBorder;

    const Color focusedBorderColor = AppColors.goldPrimary;

    final Color effectiveBorderColor = hasError
        ? AppColors.statusErrorText
        : (isFocused ? focusedBorderColor : defaultBorderColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.label != null) ...<Widget>[
          Text(
            widget.label!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: widget.isDarkSurface
                  ? AppColors.emeraldTextSubtle
                  : AppColors.textSecondaryMuted,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: AppSpacing.space6),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: AppRadius.border12,
            border: Border.all(
              color: effectiveBorderColor,
              width: isFocused || hasError ? 1.5 : 1.0,
            ),
            boxShadow: isFocused && !hasError
                ? AppShadows.inputFocusGold
                : null,
          ),
          child: Row(
            children: <Widget>[
              if (widget.prefixIcon != null) ...<Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.space12),
                  child: widget.prefixIcon,
                ),
              ],
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  readOnly: widget.readOnly,
                  obscureText: widget.isPassword && _obscureText,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  inputFormatters: widget.inputFormatters,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  onTap: widget.onTap,
                  maxLines: widget.isPassword ? 1 : widget.maxLines,
                  maxLength: widget.maxLength,
                  autofocus: widget.autofocus,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: widget.enabled ? textColor : AppColors.textTertiary,
                  ),
                  cursorColor: AppColors.goldPrimary,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: hintColor,
                    ),
                    counterText: '',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space14,
                      vertical: AppSpacing.space14,
                    ),
                  ),
                ),
              ),
              if (widget.showClearButton &&
                  _controller.text.isNotEmpty &&
                  widget.enabled) ...<Widget>[
                GestureDetector(
                  onTap: () {
                    _controller.clear();
                    widget.onChanged?.call('');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space8),
                    child: Icon(
                      Icons.cancel,
                      size: 18,
                      color: hintColor,
                    ),
                  ),
                ),
              ],
              if (widget.isPassword) ...<Widget>[
                GestureDetector(
                  onTap: () {
                    setState(() => _obscureText = !_obscureText);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space12),
                    child: Icon(
                      _obscureText
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: hintColor,
                    ),
                  ),
                ),
              ] else if (widget.suffixIcon != null) ...<Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.space12),
                  child: widget.suffixIcon,
                ),
              ],
            ],
          ),
        ),
        if (hasError) ...<Widget>[
          const SizedBox(height: AppSpacing.space4),
          Row(
            children: <Widget>[
              const Icon(
                Icons.error_outline,
                size: 13,
                color: AppColors.statusErrorText,
              ),
              const SizedBox(width: AppSpacing.space4),
              Expanded(
                child: Text(
                  widget.errorText!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.statusErrorText,
                  ),
                ),
              ),
            ],
          ),
        ] else if (widget.helperText != null) ...<Widget>[
          const SizedBox(height: AppSpacing.space4),
          Text(
            widget.helperText!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: hintColor,
            ),
          ),
        ],
      ],
    );
  }
}
