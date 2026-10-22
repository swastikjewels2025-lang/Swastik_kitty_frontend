import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/routing/route_paths.dart';
import '../widgets/diamond_3d_painter.dart';
import 'web_loader_stub.dart' if (dart.library.js_interop) 'web_loader_web.dart';

/// Luxury Splash & Launch Sequence Screen.
///
/// Implements the exact launch flow:
/// Stage 1: Clean Gold Plans background (#FAF7F2).
/// Stage 2: 3D Diamond appears from center.
/// Stage 3: Diamond rotates a full 360° (2π).
/// Stage 4: Diamond moves/flies smoothly outside the frame.
/// Stage 5: Minimal Brand Screen containing ONLY "Swastik Jewels" centered in Playfair Display.
/// Stage 6: Transitions to Destination Screen (for authenticated patrons) or Login (unauthenticated).
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({
    super.key,
    this.diamondDuration = const Duration(milliseconds: 3200),
    this.brandDuration = const Duration(milliseconds: 1100),
    Duration? totalDuration,
    this.autoNavigate = true,
  }) : totalDuration = totalDuration ?? const Duration(milliseconds: 4300);

  final Duration diamondDuration;
  final Duration brandDuration;
  final Duration totalDuration;
  final bool autoNavigate;

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _diamondController;
  late final AnimationController _brandController;

  // Diamond lifecycle animations
  late final Animation<double> _expansionScale;
  late final Animation<double> _appearanceOpacity;
  late final Animation<double> _rotationY;

  // Brand screen animations
  late final Animation<double> _brandFade;
  late final Animation<double> _brandScale;

  bool _isDiamondFinished = false;
  bool _isNavigated = false;

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      dismissWebLoader();
    }

    final Duration dDuration = widget.totalDuration != const Duration(milliseconds: 4300)
        ? Duration(milliseconds: (widget.totalDuration.inMilliseconds * 0.74).round())
        : widget.diamondDuration;
    final Duration bDuration = widget.totalDuration != const Duration(milliseconds: 4300)
        ? Duration(milliseconds: (widget.totalDuration.inMilliseconds * 0.26).round())
        : widget.brandDuration;

    // 1. Diamond Animation Controller
    // Step 1: ~1.0s Blank (0.0 to 0.3125)
    // Step 2: Appears & pauses stationary at center for ~0.6s (0.3125 to 0.50)
    // Step 3: Rotates and expands beyond visible viewport (0.50 to 1.00)
    _diamondController = AnimationController(
      vsync: this,
      duration: dDuration,
    );

    // Scaling during exit phase (0.50 to 1.00): grows from 1.0 to 32.0+ beyond viewport
    _expansionScale = Tween<double>(begin: 1.0, end: 32.0).animate(
      CurvedAnimation(
        parent: _diamondController,
        curve: const Interval(0.50, 1.00, curve: Curves.easeInOutCubic),
      ),
    );

    // Opacity: Blank for 1s (0.0 to 0.3125), fades in to center, visible during 0.6s pause & exit, dissolves at boundary
    _appearanceOpacity = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(0.0),
        weight: 31.25, // Step 1: Blank screen (~1.0s)
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 3.75, // Diamond appears at center (~0.12s)
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(1.0),
        weight: 53.0, // Stationary pause at center (~0.6s) + expansion
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 12.0, // Dissolves cleanly as vertices exceed viewport
      ),
    ]).animate(_diamondController);

    // Rotation: perfectly 0.0 during pause, then smooth continuous rotation from 0.50 to 1.00
    _rotationY = Tween<double>(begin: 0.0, end: 2.5 * math.pi).animate(
      CurvedAnimation(
        parent: _diamondController,
        curve: const Interval(0.50, 1.00, curve: Curves.easeInOutCubic),
      ),
    );

    // 2. Swastik Jewels Logo Reveal Controller (Step 3: Only after diamond completes)
    _brandController = AnimationController(
      vsync: this,
      duration: bDuration,
    );
    _brandFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _brandController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );
    _brandScale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _brandController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _diamondController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        setState(() {
          _isDiamondFinished = true;
        });
        _brandController.forward();
      }
    });

    _brandController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        if (widget.autoNavigate) {
          _resolveAuthAndNavigate();
        }
      }
    });

    _diamondController.forward();
  }

  @override
  void dispose() {
    _diamondController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  /// Evaluates authentication state with guaranteed safety timeout:
  /// - Authenticated + KYC Verified -> Destination Screen (/onboarding/choice)
  /// - Authenticated + KYC Pending -> /kyc
  /// - Unauthenticated -> /auth/login
  Future<void> _resolveAuthAndNavigate() async {
    if (_isNavigated || !mounted) return;

    AppAuthState auth = ref.read(appAuthStateProvider);

    // If still in booting/initial state, give checkAuthStatus a quick moment to resolve
    if (auth.isInitial) {
      try {
        await ref
            .read(appAuthStateProvider.notifier)
            .checkAuthStatus()
            .timeout(const Duration(milliseconds: 1000), onTimeout: () {});
      } catch (_) {}
      auth = ref.read(appAuthStateProvider);
    }

    if (_isNavigated || !mounted) return;
    _isNavigated = true;

    if (auth.isAuthenticated) {
      if (!auth.isKycVerified && !auth.hasSkippedKyc) {
        context.go(RoutePaths.kyc);
      } else {
        context.go(RoutePaths.postKycChoice);
      }
    } else {
      context.go(RoutePaths.login);
    }
  }

  /// Instant user skip handler on tap.
  void _skipOrComplete() {
    if (_isNavigated || !mounted) return;

    if (!_isDiamondFinished) {
      _diamondController.stop();
      _diamondController.value = 1.0;
      setState(() {
        _isDiamondFinished = true;
      });
      _brandController.forward();
    } else {
      _brandController.stop();
      _brandController.value = 1.0;
      _resolveAuthAndNavigate();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AppAuthState>(appAuthStateProvider, (previous, next) {
      if (!next.isInitial && _brandController.isCompleted && mounted) {
        _resolveAuthAndNavigate();
      }
    });

    final Size screenSize = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2), // Exact Gold Plans Background
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _skipOrComplete,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // 1. Subtle warm ambient radial illumination (Step 2 only, blank in Step 1)
            if (!_isDiamondFinished)
              AnimatedBuilder(
                animation: _diamondController,
                builder: (BuildContext context, Widget? child) {
                  final double ambientOpacity = _appearanceOpacity.value;
                  if (ambientOpacity <= 0.001) {
                    return const SizedBox.shrink();
                  }
                  return Center(
                    child: Opacity(
                      opacity: (ambientOpacity * 0.85).clamp(0.0, 1.0),
                      child: Container(
                        width: 380,
                        height: 380,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: <Color>[
                              Color(0x1FC88A35),
                              Color(0x08F3EDE4),
                              Colors.transparent,
                            ],
                            stops: <double>[0.0, 0.50, 1.0],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

            // 2. Step 2: 3D Diamond Animation Layer (Center Rotating & Scaling beyond viewport)
            if (!_isDiamondFinished)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _diamondController,
                  builder: (BuildContext context, Widget? child) {
                    final double progress = _diamondController.value;
                    if (progress <= 0.3125) {
                      return const SizedBox.shrink();
                    }

                    final double scale = progress <= 0.50
                        ? 1.0
                        : _expansionScale.value;
                    final double opacity = _appearanceOpacity.value;
                    final double rotY = progress <= 0.50
                        ? 0.0
                        : _rotationY.value;

                    return Center(
                      child: RepaintBoundary(
                        child: CustomPaint(
                          size: Size(screenSize.width, screenSize.height),
                          painter: Diamond3DPainter(
                            rotationY: rotY,
                            scaleFactor: scale,
                            opacity: opacity,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // 3. Step 3: Centered Swastik Jewels Logo Reveal (Zero overlap with diamond)
            if (_isDiamondFinished)
              AnimatedBuilder(
                animation: _brandController,
                builder: (BuildContext context, Widget? child) {
                  final double logoWidth =
                      (screenSize.width * 0.58).clamp(180.0, 240.0);
                  return Center(
                    child: Opacity(
                      opacity: _brandFade.value,
                      child: Transform.scale(
                        scale: _brandScale.value,
                        child: SvgPicture.asset(
                          'assets/icons/swastiklogo.svg',
                          width: logoWidth,
                          fit: BoxFit.contain,
                          semanticsLabel: 'Swastik Jewels',
                          placeholderBuilder: (BuildContext context) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
