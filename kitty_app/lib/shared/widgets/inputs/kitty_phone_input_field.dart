import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_spacing.dart';

/// Standard phone number entry foundation for Kitty App.
///
/// Features:
/// - Country code selector pill (Default: India `+91 🇮🇳`)
/// - 10-digit formatted phone number entry
/// - Quick clear button
/// - Inline validation error feedback
/// - Light and dark emerald surface support
class KittyPhoneInputField extends StatefulWidget {
  const KittyPhoneInputField({
    super.key,
    this.controller,
    this.initialValue,
    this.label = 'Mobile Number',
    this.hintText = 'Enter 10-digit number',
    this.countryCode = '+91',
    this.countryFlag = '🇮🇳',
    this.onCountryCodeTap,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.helperText,
    this.enabled = true,
    this.autofocus = false,
    this.isDarkSurface = true,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final String? label;
  final String hintText;
  final String countryCode;
  final String countryFlag;
  final VoidCallback? onCountryCodeTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final String? helperText;
  final bool enabled;
  final bool autofocus;
  final bool isDarkSurface;

  @override
  State<KittyPhoneInputField> createState() => _KittyPhoneInputFieldState();
}

class _KittyPhoneInputFieldState extends State<KittyPhoneInputField> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isInternalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController(text: widget.initialValue);
      _isInternalController = true;
    } else {
      _controller = widget.controller!;
    }

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
    _focusNode.dispose();
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

    final Color textColor = widget.isDarkSurface
        ? AppColors.textPrimaryLight
        : AppColors.textPrimaryDark;

    final Color hintColor = widget.isDarkSurface
        ? AppColors.emeraldTextSubtle
        : AppColors.textSecondaryMuted;

    final Color fillColor = widget.isDarkSurface
        ? const Color(0xD8041913)
        : AppColors.surfaceCardBg;

    final Color defaultBorder = widget.isDarkSurface
        ? AppColors.goldBorder
        : AppColors.surfaceCardBorder;

    final Color effectiveBorder = hasError
        ? AppColors.statusErrorText
        : (isFocused ? AppColors.goldPrimary : defaultBorder);

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
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Country Code Pill
            InkWell(
              onTap: widget.enabled ? widget.onCountryCodeTap : null,
              borderRadius: AppRadius.border12,
              child: Container(
                height: AppDimensions.inputFieldHeight,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space12),
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: AppRadius.border12,
                  border: Border.all(
                    color: defaultBorder,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      widget.countryFlag,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: AppSpacing.space6),
                    Text(
                      widget.countryCode,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    if (widget.onCountryCodeTap != null) ...<Widget>[
                      const SizedBox(width: AppSpacing.space4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: hintColor,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.space8),
            // Phone Number Input Box
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: AppDimensions.inputFieldHeight,
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: AppRadius.border12,
                  border: Border.all(
                    color: effectiveBorder,
                    width: isFocused || hasError ? 1.5 : 1.2,
                  ),
                  boxShadow: isFocused && !hasError
                      ? AppShadows.inputFocusGold
                      : null,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        enabled: widget.enabled,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        autofocus: widget.autofocus,
                        maxLength: 10,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        onChanged: widget.onChanged,
                        onSubmitted: widget.onSubmitted,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: widget.enabled ? textColor : AppColors.textTertiary,
                        ),
                        cursorColor: AppColors.goldPrimary,
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.0,
                            color: hintColor,
                          ),
                          counterText: '',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.space14,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    if (_controller.text.isNotEmpty && widget.enabled)
                      GestureDetector(
                        onTap: () {
                          _controller.clear();
                          widget.onChanged?.call('');
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.space12),
                          child: Icon(
                            Icons.cancel,
                            size: 18,
                            color: hintColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
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
