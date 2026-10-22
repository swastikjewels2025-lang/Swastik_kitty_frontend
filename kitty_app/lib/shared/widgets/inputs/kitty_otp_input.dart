import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_spacing.dart';

/// Reusable 6-digit segmented OTP verification input for Kitty App.
///
/// Features:
/// - 6 individual digit input boxes (`clamp(38px, 12vw, 48px) x 52px`)
/// - Auto-advance to next box on input
/// - Automatic backward focus on backspace
/// - Full 6-digit paste handling from SMS / Clipboard
/// - Visual states: default, focused (gold glow), filled, error, disabled
/// - Shake animation on validation error
class KittyOtpInput extends StatefulWidget {
  const KittyOtpInput({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.hasError = false,
    this.enabled = true,
    this.obscureText = false,
    this.autofocus = true,
    this.isDarkSurface = true,
  });

  /// Total number of OTP digits (default: 6).
  final int length;

  /// Triggered when all digits are filled.
  final ValueChanged<String>? onCompleted;

  /// Triggered on every digit change.
  final ValueChanged<String>? onChanged;

  /// Whether currently in error state.
  final bool hasError;

  /// Whether inputs are enabled.
  final bool enabled;

  /// Whether digits are obscured (bullet points).
  final bool obscureText;

  /// Whether first box auto-focuses on render.
  final bool autofocus;

  /// Surface mode: dark emerald canvas vs crisp white light canvas.
  final bool isDarkSurface;

  @override
  State<KittyOtpInput> createState() => KittyOtpInputState();
}

class KittyOtpInputState extends State<KittyOtpInput>
    with SingleTickerProviderStateMixin {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controllers = List<TextEditingController>.generate(
      widget.length,
      (int i) => TextEditingController(),
    );
    _focusNodes = List<FocusNode>.generate(
      widget.length,
      (int i) => FocusNode(),
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );

    _shakeAnimation = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(tween: Tween<double>(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem<double>(tween: Tween<double>(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem<double>(tween: Tween<double>(begin: 8.0, end: -6.0), weight: 2),
      TweenSequenceItem<double>(tween: Tween<double>(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem<double>(tween: Tween<double>(begin: 6.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOutCubic,
    ));

    if (widget.hasError) {
      _shakeController.forward();
    }
  }

  @override
  void didUpdateWidget(KittyOtpInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasError && !oldWidget.hasError) {
      _shakeController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    for (final TextEditingController c in _controllers) {
      c.dispose();
    }
    for (final FocusNode f in _focusNodes) {
      f.dispose();
    }
    _shakeController.dispose();
    super.dispose();
  }

  /// Clears all OTP input boxes and refocuses the first box.
  void clear() {
    for (final TextEditingController c in _controllers) {
      c.clear();
    }
    if (widget.enabled && _focusNodes.isNotEmpty) {
      _focusNodes[0].requestFocus();
    }
    widget.onChanged?.call('');
    setState(() {});
  }

  /// Programmatically fills the OTP boxes (e.g. from SMS auto-read).
  void setOtp(String otp) {
    final String clean = otp.replaceAll(RegExp(r'\D'), '');
    for (int i = 0; i < widget.length; i++) {
      if (i < clean.length) {
        _controllers[i].text = clean[i];
      } else {
        _controllers[i].clear();
      }
    }
    _notifyChanges();
    if (clean.length >= widget.length) {
      _focusNodes.last.unfocus();
    } else if (clean.isNotEmpty) {
      _focusNodes[clean.length.clamp(0, widget.length - 1)].requestFocus();
    }
    setState(() {});
  }

  String get currentCode =>
      _controllers.map((TextEditingController c) => c.text).join();

  void _notifyChanges() {
    final String code = currentCode;
    widget.onChanged?.call(code);
    if (code.length == widget.length) {
      widget.onCompleted?.call(code);
    }
  }

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      // Handle paste
      setOtp(value);
      return;
    }

    if (value.isNotEmpty) {
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
    _notifyChanges();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = widget.isDarkSurface
        ? AppColors.textPrimaryLight
        : AppColors.textPrimaryDark;

    final Color fillColor = widget.isDarkSurface
        ? const Color(0xD8041913)
        : AppColors.surfaceCardBg;

    final Color defaultBorder = widget.isDarkSurface
        ? AppColors.goldBorder
        : AppColors.surfaceCardBorder;

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (BuildContext context, Widget? child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double availableWidth = constraints.maxWidth;
          // Calculate individual box width dynamically to avoid overflow on small screens
          final double boxWidth = ((availableWidth - (widget.length - 1) * 8) /
                  widget.length)
              .clamp(36.0, 50.0);

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List<Widget>.generate(widget.length, (int index) {
              final TextEditingController controller = _controllers[index];
              final FocusNode focusNode = _focusNodes[index];
              final bool isFilled = controller.text.isNotEmpty;
              final bool isFocused = focusNode.hasFocus;

              final Color effectiveBorder = widget.hasError
                  ? AppColors.statusErrorText
                  : (isFocused
                      ? AppColors.goldLight
                      : (isFilled ? AppColors.goldPrimary : defaultBorder));

              return Container(
                width: boxWidth,
                height: AppDimensions.otpBoxHeight,
                decoration: BoxDecoration(
                  color: isFilled && widget.isDarkSurface
                      ? const Color(0xE6082A21)
                      : fillColor,
                  borderRadius: AppRadius.border12,
                  border: Border.all(
                    color: effectiveBorder,
                    width: isFocused || widget.hasError ? 1.8 : 1.2,
                  ),
                  boxShadow: isFocused && !widget.hasError
                      ? AppShadows.inputFocusGold
                      : null,
                ),
                child: Center(
                  child: KeyboardListener(
                    focusNode: FocusNode(), // auxiliary listener for backspace
                    onKeyEvent: (KeyEvent event) {
                      if (event is KeyDownEvent &&
                          event.logicalKey == LogicalKeyboardKey.backspace) {
                        if (controller.text.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                          _controllers[index - 1].clear();
                          _notifyChanges();
                          setState(() {});
                        }
                      }
                    },
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      enabled: widget.enabled,
                      autofocus: widget.autofocus && index == 0,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      textInputAction: index == widget.length - 1
                          ? TextInputAction.done
                          : TextInputAction.next,
                      obscureText: widget.obscureText,
                      obscuringCharacter: '●',
                      maxLength: 1,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (String val) => _onDigitChanged(index, val),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: widget.hasError
                            ? AppColors.statusErrorText
                            : (widget.enabled ? textColor : AppColors.textTertiary),
                      ),
                      cursorColor: AppColors.goldPrimary,
                      decoration: const InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
