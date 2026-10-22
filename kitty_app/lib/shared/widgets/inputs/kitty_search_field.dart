import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';

/// Reusable search input field for Kitty App.
///
/// Features:
/// - Leading search icon.
/// - Clear button when query is present.
/// - Built-in debounce mechanism (defaults to 300ms, or instant if debounce is 0).
/// - Consistent 12px rounded border with gold focus glow.
/// - Dark & light surface support.
class KittySearchField extends StatefulWidget {
  const KittySearchField({
    super.key,
    this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.isDarkSurface = false,
    this.autofocus = false,
  });

  /// Optional text controller.
  final TextEditingController? controller;

  /// Placeholder hint text.
  final String hintText;

  /// Debounced change callback.
  final ValueChanged<String>? onChanged;

  /// Immediate submission callback (on keyboard Enter).
  final ValueChanged<String>? onSubmitted;

  /// Debounce duration.
  final Duration debounceDuration;

  /// Surface mode: dark emerald vs light surface.
  final bool isDarkSurface;

  /// Whether to auto-focus when mounted.
  final bool autofocus;

  @override
  State<KittySearchField> createState() => _KittySearchFieldState();
}

class _KittySearchFieldState extends State<KittySearchField> {
  late final TextEditingController _controller;
  bool _isInternalController = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController();
      _isInternalController = true;
    } else {
      _controller = widget.controller!;
    }
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.removeListener(_onTextChanged);
    if (_isInternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleChanged(String value) {
    if (widget.debounceDuration == Duration.zero) {
      widget.onChanged?.call(value);
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      if (mounted) {
        widget.onChanged?.call(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = widget.isDarkSurface
        ? AppColors.textPrimaryLight
        : AppColors.textPrimaryDark;

    final Color hintColor = widget.isDarkSurface
        ? AppColors.emeraldTextSubtle
        : AppColors.textSecondaryMuted;

    final Color fillColor = widget.isDarkSurface
        ? Colors.white.withAlpha(18)
        : AppColors.surfaceCardBg;

    final Color borderColor = widget.isDarkSurface
        ? Colors.white.withAlpha(35)
        : AppColors.surfaceCardBorder;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: AppRadius.border12,
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
      ),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space12),
            child: Icon(
              AppIcons.search,
              size: 20,
              color: hintColor,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: widget.autofocus,
              onChanged: _handleChanged,
              onSubmitted: widget.onSubmitted,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
              cursorColor: AppColors.goldPrimary,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: hintColor,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (_controller.text.isNotEmpty) ...<Widget>[
            IconButton(
              icon: Icon(
                AppIcons.close,
                size: 16,
                color: hintColor,
              ),
              onPressed: () {
                _controller.clear();
                _handleChanged('');
              },
            ),
          ],
        ],
      ),
    );
  }
}
