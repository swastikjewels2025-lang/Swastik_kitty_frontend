import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

/// Luxury centered section heading with short decorative horizontal lines
/// on both the left and right sides, matching the "Curated Masterpieces" design.
class HomeSectionHeading extends StatelessWidget {
  const HomeSectionHeading({
    super.key,
    required this.title,
    this.padding = EdgeInsets.zero,
    this.fontSize = 12.5,
  });

  /// Section title text.
  final String title;

  /// Optional padding around the heading.
  final EdgeInsetsGeometry padding;

  /// Font size for the heading text (default: 12.5).
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 28,
            height: 1,
            color: AppColors.honeyGoldAccent.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: AppTypography.kickerCaps(
              color: AppColors.honeyGoldAccent,
            ).copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 28,
            height: 1,
            color: AppColors.honeyGoldAccent.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }
}
