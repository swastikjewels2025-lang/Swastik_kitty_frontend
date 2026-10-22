import 'package:flutter/material.dart';
import 'kitty_number_pill.dart';

/// Backwards-compatible alias for [KittyNumberPill].
///
/// In Phase 2, "Chit Token" was simplified to "Kitty Number / ID".
class KittyChitTokenPill extends StatelessWidget {
  const KittyChitTokenPill({
    super.key,
    required this.token,
    this.isDarkSurface = true,
    this.fontSize = 11.0,
  });

  /// Chit token string (e.g. "#SW-042").
  final String token;

  /// Surface mode.
  final bool isDarkSurface;

  /// Font size.
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return KittyNumberPill(
      number: token,
      isDarkSurface: isDarkSurface,
      fontSize: fontSize,
    );
  }
}
