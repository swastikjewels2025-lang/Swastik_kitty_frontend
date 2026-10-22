import 'package:flutter/material.dart';

/// Luxury animated shimmer sweeping effect for loading placeholders.
///
/// Features champagne/gold or modern neutral shimmer gradients that sweep
/// continuously across child skeleton primitives.
class KittyShimmer extends StatefulWidget {
  const KittyShimmer({
    super.key,
    required this.child,
    this.isDarkSurface = false,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1400),
  });

  /// The skeleton tree or widget to apply shimmer to.
  final Widget child;

  /// Surface mode: dark emerald canvas vs light surface canvas.
  final bool isDarkSurface;

  /// Shimmer base background color.
  final Color? baseColor;

  /// Shimmer peak highlight sweep color.
  final Color? highlightColor;

  /// Shimmer sweep cycle duration.
  final Duration duration;

  @override
  State<KittyShimmer> createState() => _KittyShimmerState();
}

class _KittyShimmerState extends State<KittyShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color effectiveBase = widget.baseColor ??
        (widget.isDarkSurface
            ? const Color(0xFFE2DDD5)
            : const Color(0xFFEFE9DF));

    final Color effectiveHighlight = widget.highlightColor ??
        (widget.isDarkSurface
            ? const Color(0xFFF3EFE8)
            : const Color(0xFFFAF7F2));

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(1.0, 0.3),
              colors: <Color>[
                effectiveBase,
                effectiveHighlight,
                effectiveBase,
              ],
              stops: const <double>[0.1, 0.5, 0.9],
              transform: _SlidingGradientTransform(
                slidePercent: _controller.value,
              ),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.width * (slidePercent * 2 - 1),
      0.0,
      0.0,
    );
  }
}
