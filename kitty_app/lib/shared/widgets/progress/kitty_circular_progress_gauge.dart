import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

/// Luxury circular progress gauge for Kitty App active schemes.
///
/// Features:
/// - CustomPainter circular arc with smooth antialiased strokes
/// - Metallic gold gradient progress track with rounded stroke caps
/// - Dark emerald background circle track
/// - Center fraction display (`currentValue / totalValue`), percentage, and subtitle
/// - Smooth animated value transition
/// - Accessible semantics
class KittyCircularProgressGauge extends StatelessWidget {
  const KittyCircularProgressGauge({
    super.key,
    required this.currentValue,
    required this.totalValue,
    this.centerFractionText,
    this.centerPercentageText,
    this.subtitle,
    this.size = 144.0,
    this.strokeWidth = 10.0,
    this.animationDuration = const Duration(milliseconds: 900),
    this.isDarkSurface = true,
    this.showPercentageInCenter = false,
  });

  /// Current progress value (e.g. 8 months paid).
  final int currentValue;

  /// Total target value (e.g. 12 months total).
  final int totalValue;

  /// Custom center fraction text override (default: "$currentValue / $totalValue").
  final String? centerFractionText;

  /// Custom center percentage text override (default: "${pct}%").
  final String? centerPercentageText;

  /// Subtitle below fraction (e.g. "1 to Pay • 1 Bonus Month Free").
  final String? subtitle;

  /// Outer diameter of the gauge (default: 144px).
  final double size;

  /// Stroke width of the circular track (default: 10px).
  final double strokeWidth;

  /// Animation duration when progress changes.
  final Duration animationDuration;

  /// Surface mode.
  final bool isDarkSurface;

  /// If true, displays percentage as large primary center text instead of fraction.
  final bool showPercentageInCenter;

  double get progressRatio {
    if (totalValue <= 0) return 0.0;
    return (currentValue / totalValue).clamp(0.0, 1.0);
  }

  int get percentage {
    if (totalValue <= 0) return 0;
    return (progressRatio * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final String fractionString = centerFractionText ?? '$currentValue / $totalValue';
    final String percentageString = centerPercentageText ?? '$percentage%';

    final Color primaryTextColor = isDarkSurface
        ? AppColors.textPrimaryLight
        : AppColors.textPrimaryDark;

    final Color secondaryTextColor = isDarkSurface
        ? AppColors.emeraldTextSubtle
        : AppColors.textSecondaryMuted;

    final Widget centerContent = Center(
      child: Padding(
        padding: EdgeInsets.all(strokeWidth + 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (showPercentageInCenter) ...<Widget>[
              Text(
                percentageString,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: size * 0.18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: primaryTextColor,
                ),
              ),
              Text(
                fractionString,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: size * 0.09,
                  fontWeight: FontWeight.w600,
                  color: secondaryTextColor,
                ),
              ),
            ] else ...<Widget>[
              Text(
                fractionString,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: size * 0.16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                  color: primaryTextColor,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: AppColors.goldSubtle,
                  borderRadius: BorderRadius.circular(AppRadius.radiusPill),
                ),
                child: Text(
                  percentageString,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: size * 0.08,
                    fontWeight: FontWeight.w700,
                    color: AppColors.goldLight,
                  ),
                ),
              ),
            ],
            if (subtitle != null) ...<Widget>[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: size * 0.07,
                  fontWeight: FontWeight.w500,
                  color: secondaryTextColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );

    return Semantics(
      label: 'Savings installment progress gauge',
      value: '$currentValue of $totalValue installments paid, $percentage percent complete',
      child: SizedBox(
        width: size,
        height: size,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: progressRatio),
          duration: animationDuration,
          curve: Curves.easeOutCubic,
          child: centerContent,
          builder: (BuildContext context, double animatedRatio, Widget? child) {
            return CustomPaint(
              painter: _CircularGaugePainter(
                progress: animatedRatio,
                strokeWidth: strokeWidth,
                trackColor: isDarkSurface
                    ? Colors.white.withAlpha(20)
                    : AppColors.warmLinenInset,
                progressGradient: const LinearGradient(
                  colors: <Color>[
                    AppColors.honeyGoldAccent,
                    Color(0xFFF3D07B),
                    AppColors.honeyGoldAccent,
                  ],
                ),
              ),
              child: child,
            );
          },
        ),
      ),
    );
  }
}

class _CircularGaugePainter extends CustomPainter {
  const _CircularGaugePainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressGradient,
  });

  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Gradient progressGradient;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (size.width - strokeWidth) / 2;

    // 1. Draw Background Track Circle
    final Paint trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0.0) return;

    // 2. Draw Progress Arc with Sweep Gradient
    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    final Paint progressPaint = Paint()
      ..shader = progressGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Start at top (-pi / 2) and sweep clockwise
    const double startAngle = -math.pi / 2;
    final double sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.trackColor != trackColor;
  }
}
