import 'dart:io' as io;
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/routing/route_paths.dart';
import '../providers/auth_controller.dart';

/// Multi-step Login flow views matching `login.html`.
enum LoginStep {
  initial,
  phone,
  otp,
  profile,
  success,
}

/// Unified Luxury Login Screen.
///
/// Primary Source of Truth: `d:\ui design\login.html` & `login.css` & `diamond-bg.js`.
///
/// Visual Specifications:
/// - Exact Background Color: #05241C
/// - Damask Wallpaper Overlay (`assets/patterns/damask-pattern.jpg`)
/// - Full 3D Luxury Jewelry Constellation Canvas (`JewelryConstellationPainter`)
/// - Ambient Emerald & Gold Radial Glow Orb (`min(600px, 90vw)` with 40px blur)
/// - Glassmorphic Card: 44px backdrop blur, `rgba(6, 32, 24, 0.78)` background,
///   `#CCA243` muted border, top specular hairline highlight, and deep elevation shadows
/// - Persistent Brand Header: Swastik Jewel SVG logo (`assets/icons/swastiklogo.svg`) +
///   "Sign in to continue" with luxury gold gradient
/// - Step Views:
///   * View 0: Continue with Google (4-color Google mark) + Luxury OR Divider + Continue with Mobile
///   * View 1: Enter mobile number with country selector dropdown, auto-spacing `98765 43210`, clear 'X',
///     gold focus ring, and disabled/loading Continue button
///   * View 2: Verify number with 6-digit OTP grid (shake on error, auto-advance, backspace, paste),
///     resend countdown timer, and Verify button
///   * View 3: Authenticated success state with pulsing gold badge, patron greeting, tier chip, and Enter Vault button
/// - Toast notifications matching `.swastik-toast`
/// - 100% Preservation of existing authentication logic, Riverpod state, and repository calls.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({
    super.key,
    this.initialStep = LoginStep.initial,
  });

  /// Initial step when screen is mounted.
  final LoginStep initialStep;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  late LoginStep _currentStep;

  // Animation Controllers
  late final AnimationController _cardEntranceController;
  late final Animation<double> _cardScaleAnimation;
  late final Animation<Offset> _cardSlideAnimation;
  late final Animation<double> _cardFadeAnimation;

  late final AnimationController _bgConstellationController;
  late final AnimationController _successPulseController;
  late final AnimationController _otpShakeController;
  late final Animation<double> _otpShakeAnimation;

  // Phone Form Controls
  late final TextEditingController _phoneController;
  final FocusNode _phoneFocusNode = FocusNode();
  bool _isCountryDropdownOpen = false;

  // OTP Form Controls (6 digit boxes)
  late final List<TextEditingController> _otpControllers;
  late final List<FocusNode> _otpFocusNodes;

  // Profile Form Controls (View 2.5)
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _cityController;
  final GlobalKey<FormState> _profileFormKey = GlobalKey<FormState>();

  // Inline Toast State
  String? _toastMessage;
  bool _isToastError = false;
  bool _isToastVisible = false;

  bool _isAppleSubmitting = false;
  bool _isGoogleSubmitting = false;

  static const List<Map<String, String>> _countryOptions = <Map<String, String>>[
    <String, String>{'code': '+91', 'flag': '🇮🇳', 'name': 'India (+91)'},
    <String, String>{'code': '+971', 'flag': '🇦🇪', 'name': 'UAE (+971)'},
    <String, String>{'code': '+44', 'flag': '🇬🇧', 'name': 'UK (+44)'},
    <String, String>{'code': '+1', 'flag': '🇺🇸', 'name': 'USA / Canada (+1)'},
    <String, String>{'code': '+65', 'flag': '🇸🇬', 'name': 'Singapore (+65)'},
    <String, String>{'code': '+61', 'flag': '🇦🇺', 'name': 'Australia (+61)'},
  ];

  static const String _appleSvg = '''
<svg viewBox="0 0 170 170" fill="#FFFFFF">
  <path d="M150.37 130.25c-2.45 5.66-5.35 10.87-8.71 15.66-4.58 6.53-8.33 11.05-11.22 13.56-4.48 4.12-9.28 6.23-14.42 6.35-3.69 0-8.14-1.05-13.32-3.18-5.19-2.12-9.97-3.17-14.34-3.17-4.58 0-9.49 1.05-14.75 3.17-5.26 2.13-9.5 3.24-12.74 3.35-4.35.13-9.16-1.9-14.42-6.08-3.69-3.04-7.69-7.85-12.01-14.42-6.19-9.39-11.05-20.08-14.58-32.06-3.53-11.98-5.3-23.27-5.3-33.87 0-15.12 3.86-27.42 11.59-36.9 7.73-9.48 17.51-14.32 29.35-14.54 4.57 0 9.87 1.15 15.91 3.44 6.04 2.29 10.27 3.52 12.69 3.69 1.74 0 5.86-1.31 12.37-3.92 6.51-2.61 12.03-3.76 16.57-3.44 14.59.76 25.59 5.87 33.01 15.34-12.94 7.84-19.29 18.7-19.06 32.58.22 10.66 4.3 19.58 12.24 26.76 4.02 3.69 8.59 6.42 13.7 8.18-3.05 8.92-6.75 17.62-11.11 26.11zM119.22 33.15c0-7.72 2.77-15.01 8.31-21.87 5.54-6.86 12.45-10.99 20.73-12.38.22 1.3.33 2.5.33 3.59 0 7.61-2.93 15-8.8 22.18-5.87 7.18-12.99 11.26-21.36 12.24-.22-1.09-.33-2.18-.33-3.26z"/>
</svg>''';

  static const String _googleSvg = '''
<svg viewBox="0 0 24 24">
  <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
  <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
  <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"/>
  <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"/>
</svg>''';

  static const String _phoneIconSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/>
</svg>''';

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;

    final AuthFlowState currentAuth = ref.read(authControllerProvider);
    _phoneController = TextEditingController(text: currentAuth.phone);

    _otpControllers = List<TextEditingController>.generate(
      6,
      (int index) => TextEditingController(),
    );
    _otpFocusNodes = List<FocusNode>.generate(
      6,
      (int index) => FocusNode(),
    );

    final AppAuthState appAuth = ref.read(appAuthStateProvider);
    _nameController = TextEditingController(
      text: appAuth.userName.isNotEmpty && appAuth.userName != 'Rihan'
          ? appAuth.userName
          : (currentAuth.authSession?.user.name ?? ''),
    );
    _emailController = TextEditingController(
      text: currentAuth.authSession?.user.email ?? '',
    );
    _cityController = TextEditingController();

    // 1. Card Entrance Animation (Fast luxury ease ~260ms)
    _cardEntranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    final CurvedAnimation cardCurved = CurvedAnimation(
      parent: _cardEntranceController,
      curve: const Cubic(0.16, 1.0, 0.3, 1.0),
    );

    _cardFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(cardCurved);
    _cardScaleAnimation = Tween<double>(begin: 0.97, end: 1.0).animate(cardCurved);
    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.04),
      end: Offset.zero,
    ).animate(cardCurved);

    _cardEntranceController.forward();

    // 2. Background Animation Controller
    _bgConstellationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    );

    // 3. Success Pulse Badge Animation (active strictly on success step)
    _successPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    if (_isInTest) {
      _successPulseController.value = 0.5;
    } else if (_currentStep == LoginStep.success) {
      _successPulseController.repeat(reverse: true);
    }

    // 4. OTP Error Shake Animation (0.45s)
    _otpShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _otpShakeAnimation = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(tween: Tween<double>(begin: 0.0, end: -6.0), weight: 1),
      TweenSequenceItem<double>(tween: Tween<double>(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem<double>(tween: Tween<double>(begin: 6.0, end: -4.0), weight: 2),
      TweenSequenceItem<double>(tween: Tween<double>(begin: -4.0, end: 4.0), weight: 2),
      TweenSequenceItem<double>(tween: Tween<double>(begin: 4.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _otpShakeController,
      curve: Curves.easeInOutCubic,
    ));
  }

  bool get _isInTest =>
      !kIsWeb && io.Platform.environment.containsKey('FLUTTER_TEST');

  void _handleContinueWithMobile() {
    ref.read(authControllerProvider.notifier).clearErrors();
    try {
      final GoRouter? router = GoRouter.maybeOf(context);
      if (router != null) {
        context.push(RoutePaths.phone);
        return;
      }
    } catch (_) {}
    _goToStep(LoginStep.phone);
  }

  @override
  void dispose() {
    _cardEntranceController.dispose();
    _bgConstellationController.dispose();
    _successPulseController.dispose();
    _otpShakeController.dispose();
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    for (final TextEditingController c in _otpControllers) {
      c.dispose();
    }
    for (final FocusNode f in _otpFocusNodes) {
      f.dispose();
    }
    _nameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // NAVIGATION & VIEW SWITCHING
  // ===========================================================================
  void _goToStep(LoginStep step) {
    setState(() {
      _currentStep = step;
      _isCountryDropdownOpen = false;
    });

    if (step == LoginStep.success && !_isInTest) {
      if (!_successPulseController.isAnimating) {
        _successPulseController.repeat(reverse: true);
      }
    } else if (step != LoginStep.success) {
      if (_successPulseController.isAnimating) {
        _successPulseController.stop();
      }
    }

    if (step == LoginStep.phone) {
      Future<void>.delayed(const Duration(milliseconds: 150), () {
        if (mounted) _phoneFocusNode.requestFocus();
      });
    } else if (step == LoginStep.otp) {
      Future<void>.delayed(const Duration(milliseconds: 150), () {
        if (mounted && _otpFocusNodes.isNotEmpty) {
          _otpFocusNodes[0].requestFocus();
        }
      });
    }
  }

  // ===========================================================================
  // PHONE LOGIC & VALIDATION
  // ===========================================================================
  String get _cleanPhone => _phoneController.text.replaceAll(RegExp(r'\D'), '');

  bool get _isIndian => ref.read(authControllerProvider).countryCode == '+91';

  bool get _canSubmitPhone {
    final String clean = _cleanPhone;
    if (clean.isEmpty) return false;
    if (_isIndian) {
      return clean.length == 10 && RegExp(r'^[6-9]\d{9}$').hasMatch(clean);
    }
    return clean.length >= 7;
  }

  void _formatPhoneInput(String value) {
    final String digits = value.replaceAll(RegExp(r'\D'), '');
    final int maxLen = _isIndian ? 10 : 12;
    final String truncated = digits.length > maxLen ? digits.substring(0, maxLen) : digits;

    String formatted = truncated;
    if (_isIndian && truncated.length > 5) {
      formatted = '${truncated.substring(0, 5)} ${truncated.substring(5)}';
    }

    if (formatted != _phoneController.text) {
      _phoneController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    ref.read(authControllerProvider.notifier).setPhone(truncated);
  }

  Future<void> _handleSendOtp() async {
    if (!_canSubmitPhone) {
      if (_isIndian && _cleanPhone.isNotEmpty && !RegExp(r'^[6-9]\d{9}$').hasMatch(_cleanPhone)) {
        _showToast('Please enter a valid 10-digit Indian mobile number', isError: true);
      }
      return;
    }

    final AuthController controller = ref.read(authControllerProvider.notifier);
    controller.setPhone(_cleanPhone);

    final bool success = await controller.sendOtp();
    if (success && mounted) {
      final AuthFlowState updatedFlow = ref.read(authControllerProvider);
      _clearOtpBoxes();
      _goToStep(LoginStep.otp);
      if (updatedFlow.isExistingUser && updatedFlow.welcomeMessage != null) {
        _showToast(updatedFlow.welcomeMessage!);
      } else {
        _showToast('OTP sent successfully to your number');
      }
    } else if (mounted) {
      final String? err = ref.read(authControllerProvider).phoneError;
      if (err != null) {
        _showToast(err, isError: true);
      }
    }
  }

  // ===========================================================================
  // OTP LOGIC (AUTO-ADVANCE, BACKSPACE, PASTE, SHAKE)
  // ===========================================================================
  String get _currentOtp => _otpControllers.map((TextEditingController c) => c.text).join();

  void _clearOtpBoxes() {
    for (final TextEditingController c in _otpControllers) {
      c.clear();
    }
  }

  void _handleOtpDigitChange(int index, String value) {
    // 1. Paste handling (multiple digits)
    if (value.length > 1) {
      final String cleanDigits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < 6; i++) {
        if (i < cleanDigits.length) {
          _otpControllers[i].text = cleanDigits[i];
        } else {
          _otpControllers[i].clear();
        }
      }
      if (cleanDigits.length >= 6) {
        _otpFocusNodes[5].unfocus();
        _handleVerifyOtp();
      } else {
        _otpFocusNodes[cleanDigits.length.clamp(0, 5)].requestFocus();
      }
      return;
    }

    // 2. Single digit auto-advance
    if (value.isNotEmpty) {
      if (index < 5) {
        _otpFocusNodes[index + 1].requestFocus();
      } else {
        _otpFocusNodes[index].unfocus();
      }
    }

    // 3. Auto-verify when 6th digit entered
    if (_currentOtp.length == 6) {
      _handleVerifyOtp();
    }
  }

  Future<void> _handleVerifyOtp() async {
    final String code = _currentOtp;
    if (code.length != 6) return;

    try {
      final AuthController controller = ref.read(authControllerProvider.notifier);
      final bool success = await controller.verifyOtp(code);
      if (success && mounted) {
        final AppAuthState appAuth = ref.read(appAuthStateProvider);
        if (appAuth.isOnboarded) {
          _showToast('Welcome back, ${appAuth.userName}!');
          context.go(RoutePaths.offers);
        } else {
          await context.push(RoutePaths.profile);
        }
      } else if (mounted) {
        _otpShakeController.forward(from: 0.0);
        final String? err = ref.read(authControllerProvider).otpError;
        if (err != null) {
          _showToast(err, isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _otpShakeController.forward(from: 0.0);
        _showToast('Verification failed. Please try again.', isError: true);
      }
    }
  }

  // ===========================================================================
  // GOOGLE & APPLE AUTHENTICATION (Requirements 7, 8 & 9)
  // ===========================================================================
  Future<void> _handleGoogleSignIn() async {
    if (_isGoogleSubmitting || _isAppleSubmitting) return;
    setState(() {
      _isGoogleSubmitting = true;
    });
    try {
      final AuthController controller = ref.read(authControllerProvider.notifier);
      final bool success = await controller.loginWithGoogle();
      if (success && mounted) {
        final AppAuthState appAuth = ref.read(appAuthStateProvider);
        if (!appAuth.isOnboarded || !appAuth.isKycVerified) {
          await context.push(RoutePaths.profile);
        } else {
          context.go(RoutePaths.offers);
        }
      } else if (mounted) {
        final String? err = ref.read(authControllerProvider).phoneError;
        _showToast(err ?? 'Google sign-in was not completed.', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleSubmitting = false;
        });
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    if (_isAppleSubmitting || _isGoogleSubmitting) return;
    setState(() {
      _isAppleSubmitting = true;
    });
    try {
      final AuthController controller = ref.read(authControllerProvider.notifier);
      final bool success = await controller.loginWithApple();
      if (success && mounted) {
        final AppAuthState appAuth = ref.read(appAuthStateProvider);
        if (!appAuth.isOnboarded || !appAuth.isKycVerified) {
          await context.push(RoutePaths.profile);
        } else {
          context.go(RoutePaths.offers);
        }
      } else if (mounted) {
        final String? err = ref.read(authControllerProvider).phoneError;
        _showToast(err ?? 'Apple sign-in was not completed.', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAppleSubmitting = false;
        });
      }
    }
  }

  Future<void> _handleSubmitProfile() async {
    if (!_profileFormKey.currentState!.validate()) return;

    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String city = _cityController.text.trim();

    try {
      await ref.read(appAuthStateProvider.notifier).updateProfile(
            userName: name,
            userEmail: email,
            city: city,
          );
    } catch (_) {}

    try {
      final AuthController authController = ref.read(authControllerProvider.notifier);
      final AuthFlowState currentFlow = ref.read(authControllerProvider);
      if (currentFlow.authSession != null) {
        final updatedUser = currentFlow.authSession!.user.copyWith(
          name: name,
          email: email,
        );
        final updatedSession = currentFlow.authSession!.copyWith(user: updatedUser);
        authController.updateSession(updatedSession);
      }
    } catch (_) {}

    if (mounted) {
      _goToStep(LoginStep.success);
    }
  }

  Future<void> _handleResendOtp() async {
    if (!ref.read(authControllerProvider).canResend) return;

    final AuthController controller = ref.read(authControllerProvider.notifier);
    final bool success = await controller.resendOtp();
    if (success && mounted) {
      _clearOtpBoxes();
      if (_otpFocusNodes.isNotEmpty) {
        _otpFocusNodes[0].requestFocus();
      }
      _showToast('New OTP dispatched successfully');
    } else if (mounted) {
      final String? err = ref.read(authControllerProvider).otpError;
      if (err != null) {
        _showToast(err, isError: true);
      }
    }
  }

  // ===========================================================================
  // TOAST NOTIFICATION (.swastik-toast)
  // ===========================================================================
  void _showToast(String message, {bool isError = false}) {
    setState(() {
      _toastMessage = message;
      _isToastError = isError;
      _isToastVisible = true;
    });

    Future<void>.delayed(const Duration(milliseconds: 3600), () {
      if (mounted) {
        setState(() {
          _isToastVisible = false;
        });
      }
    });
  }

  String _formatTimer(int totalSeconds) {
    final int s = totalSeconds % 60;
    final String ss = s < 10 ? '0$s' : '$s';
    return '00:$ss';
  }

  void _showLegalDialog(BuildContext context, String title, String content) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: const BorderSide(color: Color(0xFFEFE6DB)),
          ),
          title: Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0A221C),
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              content,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                color: const Color(0xFF68726E),
                height: 1.5,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Close',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF063B2C),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthFlowState authState = ref.watch(authControllerProvider);
    final Size screenSize = MediaQuery.sizeOf(context);
    final double screenWidth = screenSize.width;
    final bool isTiny = screenWidth <= 340;
    final bool isMobile = screenWidth <= 480;

    final EdgeInsets cardPadding = isTiny
        ? const EdgeInsets.symmetric(horizontal: 14.0, vertical: 24.0)
        : isMobile
            ? const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0)
            : const EdgeInsets.symmetric(horizontal: 36.0, vertical: 40.0);

    final double cardRadius = isMobile ? 20.0 : 26.0;
    final double orbSize = math.min(600.0, screenWidth * 0.90);

    return PopScope(
      canPop: _currentStep == LoginStep.initial,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        if (_currentStep == LoginStep.profile) {
          _goToStep(LoginStep.otp);
        } else if (_currentStep == LoginStep.otp) {
          _goToStep(LoginStep.phone);
        } else if (_currentStep == LoginStep.phone) {
          _goToStep(LoginStep.initial);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF7F2), // Gold Plans primary canvas
        body: GestureDetector(
          onTap: () {
            if (_isCountryDropdownOpen) {
              setState(() => _isCountryDropdownOpen = false);
            }
          },
          behavior: HitTestBehavior.translucent,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              // 1. Subtle Damask Wallpaper Pattern Overlay (.wallpaper-overlay)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.035,
                  child: Image.asset(
                    'assets/patterns/damask-pattern.jpg',
                    fit: BoxFit.cover,
                    repeat: ImageRepeat.repeat,
                    color: const Color(0xFFC88A35),
                    colorBlendMode: BlendMode.screen,
                    errorBuilder: (BuildContext ctx, Object err, StackTrace? st) {
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),

              // 2. Ambient Gold Radial Glow Orb (.ambient-glow-orb)
              Center(
                child: RepaintBoundary(
                  child: ImageFiltered(
                    imageFilter: ui.ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: Container(
                      width: orbSize,
                      height: orbSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: <Color>[
                            const Color(0xFFC88A35).withValues(alpha: 0.08),
                            const Color(0xFFEFE6DB).withValues(alpha: 0.14),
                            Colors.transparent,
                          ],
                          stops: const <double>[0.0, 0.45, 0.70],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 4. Glassmorphic Login Card with Entrance Animation (.login-card-container)
              SafeArea(
                child: Center(
                  child: RepaintBoundary(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12.0 : 16.0,
                        vertical: isMobile ? 16.0 : 24.0,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: FadeTransition(
                          opacity: _cardFadeAnimation,
                          child: SlideTransition(
                            position: _cardSlideAnimation,
                            child: ScaleTransition(
                              scale: _cardScaleAnimation,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(cardRadius),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(cardRadius),
                                    border: Border.all(
                                      color: const Color(0xFFEFE6DB), // Gold Plans card border
                                      width: 1.0,
                                    ),
                                    boxShadow: const <BoxShadow>[
                                      BoxShadow(
                                        color: Color(0x0A000000),
                                        blurRadius: 18,
                                        spreadRadius: 0,
                                        offset: Offset(0, 4),
                                      ),
                                      BoxShadow(
                                        color: Color(0x08C88A35),
                                        blurRadius: 28,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: <Widget>[
                                      // Top Specular Hairline Highlight
                                      Positioned(
                                        top: 0,
                                        left: 0,
                                        right: 0,
                                        height: 1.2,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: <Color>[
                                                Colors.transparent,
                                                Color(0x33C88A35),
                                                Color(0x66C88A35),
                                                Color(0x33C88A35),
                                                Colors.transparent,
                                              ],
                                              stops: <double>[0.0, 0.2, 0.5, 0.8, 1.0],
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Card Content
                                      Padding(
                                        padding: cardPadding,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: <Widget>[
                                            // Persistent Card Brand Header
                                            _buildBrandHeader(),

                                            const SizedBox(height: 24),

                                            // Multi-Step Flow Views
                                            AnimatedSwitcher(
                                              duration: const Duration(milliseconds: 280),
                                              switchInCurve: Curves.easeOutCubic,
                                              switchOutCurve: Curves.easeInCubic,
                                              transitionBuilder: (Widget child, Animation<double> animation) {
                                                return FadeTransition(
                                                  opacity: animation,
                                                  child: SlideTransition(
                                                    position: Tween<Offset>(
                                                      begin: const Offset(0.04, 0.0),
                                                      end: Offset.zero,
                                                    ).animate(animation),
                                                    child: child,
                                                  ),
                                                );
                                              },
                                              child: _buildCurrentView(context, isMobile, isTiny, authState),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 5. Toast Notification (.swastik-toast)
              _buildFloatingToast(),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // PERSISTENT CARD BRAND HEADER
  // ===========================================================================
  Widget _buildBrandHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Swastik Logo with Drop Shadow (.brand-logo-img)
        Container(
          margin: const EdgeInsets.only(bottom: 14.0),
          child: SvgPicture.asset(
            'assets/icons/swastiklogo.svg',
            width: 140,
            fit: BoxFit.contain,
            placeholderBuilder: (BuildContext context) {
              return const Icon(
                Icons.diamond_outlined,
                size: 44,
                color: Color(0xFFC88A35),
              );
            },
          ),
        ),

        // Brand Subtitle: "Sign in to continue" (.brand-subtitle)
        Text(
          _currentStep == LoginStep.profile
              ? 'Complete Your Profile'
              : (_currentStep == LoginStep.success
                  ? 'Vault Access Granted'
                  : 'Sign in to continue'),
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: 22.0,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0A221C),
            letterSpacing: -0.2,
            height: 1.25,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // STEP VIEW ROUTER
  // ===========================================================================
  Widget _buildCurrentView(BuildContext context, bool isMobile, bool isTiny, AuthFlowState authState) {
    switch (_currentStep) {
      case LoginStep.initial:
        return _buildViewInitial(context, isMobile, authState);
      case LoginStep.phone:
        return _buildViewPhone(context, isMobile, authState);
      case LoginStep.otp:
        return _buildViewOtp(context, isMobile, isTiny, authState);
      case LoginStep.profile:
        return _buildViewProfile(context, isMobile, authState);
      case LoginStep.success:
        return _buildViewSuccess(context, isMobile, authState);
    }
  }

  // ===========================================================================
  // VIEW 0: INITIAL LOGIN OPTIONS (.flow-step-view active)
  // ===========================================================================
  Widget _buildViewInitial(BuildContext context, bool isMobile, AuthFlowState authState) {
    final double buttonHeight = isMobile ? 48.0 : 52.0;

    return Column(
      key: const ValueKey<String>('view-initial'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // 1. Apple Authentication Button (.btn-apple)
        Container(
          height: buttonHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF000000),
            border: Border.all(
              color: const Color(0x33C88A35),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(14.0),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: (_isAppleSubmitting || _isGoogleSubmitting || authState.isSubmitting)
                  ? null
                  : _handleAppleSignIn,
              borderRadius: BorderRadius.circular(14.0),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: _isAppleSubmitting
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Connecting with Apple...',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: SvgPicture.string(_appleSvg),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Continue with Apple',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 2. Google Authentication Button (.btn-google)
        Container(
          height: buttonHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: const Color(0xFFE5DDD0),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(14.0),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: (_isAppleSubmitting || _isGoogleSubmitting || authState.isSubmitting)
                  ? null
                  : _handleGoogleSignIn,
              borderRadius: BorderRadius.circular(14.0),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: _isGoogleSubmitting
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0A221C)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Connecting with Google...',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF0A221C),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: SvgPicture.string(_googleSvg),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Continue with Google',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0A221C),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // 2. Luxury Gold Divider (.auth-divider)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 22.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  height: 1.0,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        Colors.transparent,
                        Color(0x33C88A35),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Text(
                  'OR',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.38,
                    color: const Color(0xFF8C9691),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1.0,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        Color(0x33C88A35),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 3. Continue with Mobile Button (.mobile-cta-btn)
        Container(
          height: buttonHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF063B2C),
            borderRadius: BorderRadius.circular(14.0),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x1F063B2C),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleContinueWithMobile,
              borderRadius: BorderRadius.circular(14.0),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: SvgPicture.string(_phoneIconSvg),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Continue with Mobile',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // 4. Card Footer Notes (.card-footer-notes)
        Padding(
          padding: const EdgeInsets.only(top: 28.0),
          child: Text.rich(
            TextSpan(
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: const Color(0xFF68726E),
                height: 1.5,
              ),
              children: <InlineSpan>[
                const TextSpan(text: 'Protected by bank-grade 256-bit encryption.\n'),
                const TextSpan(text: 'By continuing, you agree to our '),
                TextSpan(
                  text: 'Terms',
                  style: const TextStyle(
                    color: Color(0xFF063B2C),
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _showLegalDialog(
                        context,
                        'Terms & Conditions',
                        'By using Gold Vault, you agree to abide by statutory PMLA rules, 24K digital bullion accumulation regulations, and scheme terms.',
                      );
                    },
                ),
                const TextSpan(text: ' & '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: const TextStyle(
                    color: Color(0xFF063B2C),
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _showLegalDialog(
                        context,
                        'Privacy Policy',
                        'We value your trust. Patron biometric data and portfolio assets are secured under bank-grade 256-bit encryption and are never disclosed.',
                      );
                    },
                ),
                const TextSpan(text: '.'),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // VIEW 1: ENTER MOBILE NUMBER
  // ===========================================================================
  Widget _buildViewPhone(BuildContext context, bool isMobile, AuthFlowState authState) {
    final double buttonHeight = isMobile ? 48.0 : 52.0;
    final bool hasError = authState.phoneError != null && authState.phoneError!.isNotEmpty;

    return Column(
      key: const ValueKey<String>('view-phone'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Step Navigation Bar: Back Button (.step-nav-bar)
        Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: () {
              setState(() => _isCountryDropdownOpen = false);
              _goToStep(LoginStep.initial);
            },
            borderRadius: BorderRadius.circular(8.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.arrow_back_rounded,
                    size: 16,
                    color: Color(0xFF0A221C),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Back',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0A221C),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 18),

        // Step Heading Group (.step-heading-group)
        Text(
          'Enter your mobile number',
          style: GoogleFonts.playfairDisplay(
            fontSize: isMobile ? 20.0 : 23.0,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0A221C),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'We will send a 6-digit OTP to verify your identity',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.0,
            color: const Color(0xFF68726E),
            height: 1.5,
          ),
        ),

        const SizedBox(height: 20),

        // Phone Input Form Controls (.phone-input-group)
        Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Country Code Selector (.country-selector)
                SizedBox(
                  width: 108,
                  height: buttonHeight,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isCountryDropdownOpen = !_isCountryDropdownOpen;
                      });
                    },
                    borderRadius: BorderRadius.circular(14.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF8F5),
                        border: Border.all(
                          color: _isCountryDropdownOpen
                              ? const Color(0xFFC88A35)
                              : const Color(0xFFE5DDD0),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              '${authState.countryFlag} ${authState.countryCode}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0A221C),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _isCountryDropdownOpen
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              size: 14,
                              color: const Color(0xFF0A221C),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Phone Input Field (.phone-field-wrapper)
                Expanded(
                  child: ListenableBuilder(
                    listenable: Listenable.merge(<Listenable>[_phoneController, _phoneFocusNode]),
                    builder: (BuildContext context, _) {
                      final bool isPhoneFocused = _phoneFocusNode.hasFocus;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: buttonHeight,
                        decoration: BoxDecoration(
                          color: isPhoneFocused
                              ? Colors.white
                              : const Color(0xFFFAF8F5),
                          border: Border.all(
                            color: hasError
                                ? const Color(0xFFEF4444)
                                : (isPhoneFocused
                                    ? const Color(0xFFC88A35)
                                    : const Color(0xFFE5DDD0)),
                            width: isPhoneFocused || hasError ? 1.5 : 1.0,
                          ),
                          borderRadius: BorderRadius.circular(14.0),
                          boxShadow: isPhoneFocused && !hasError
                              ? const <BoxShadow>[
                                  BoxShadow(
                                    color: Color(0x1FC88A35),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                controller: _phoneController,
                                focusNode: _phoneFocusNode,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.done,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(RegExp(r'[\d\s]')),
                                ],
                                onChanged: _formatPhoneInput,
                                onSubmitted: (_) => _handleSendOtp(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.77,
                                  color: const Color(0xFF0A221C),
                                ),
                                cursorColor: const Color(0xFF063B2C),
                                decoration: InputDecoration(
                                  hintText: '98765 43210',
                                  hintStyle: GoogleFonts.plusJakartaSans(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF9CA3AF),
                                    letterSpacing: 0.0,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                                ),
                              ),
                            ),
                            if (_phoneController.text.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _phoneController.clear();
                                  ref.read(authControllerProvider.notifier).setPhone('');
                                },
                                child: const Padding(
                                  padding: EdgeInsets.only(right: 12.0),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 16,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // Country Selector Dropdown List (.country-select-dropdown)
            if (_isCountryDropdownOpen)
              Positioned(
                top: buttonHeight + 6,
                left: 0,
                width: 220,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFEFE6DB)),
                      borderRadius: BorderRadius.circular(14.0),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x1F000000),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(6.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _countryOptions.map((Map<String, String> item) {
                        final bool isSelected = authState.countryCode == item['code'];
                        return InkWell(
                          onTap: () {
                            ref.read(authControllerProvider.notifier).setCountry(
                                  item['code']!,
                                  item['flag']!,
                                );
                            setState(() => _isCountryDropdownOpen = false);
                          },
                          borderRadius: BorderRadius.circular(8.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 9.0),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFF3EDE4) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              children: <Widget>[
                                Text(item['flag'] ?? '', style: const TextStyle(fontSize: 14)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item['name'] ?? '',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13.0,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                      color: isSelected ? const Color(0xFF063B2C) : const Color(0xFF0A221C),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
          ],
        ),

        // Validation Error Feedback (.field-error-text)
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: hasError ? 24 : 8,
          padding: const EdgeInsets.only(top: 4, left: 2),
          alignment: Alignment.centerLeft,
          child: hasError
              ? Row(
                  children: <Widget>[
                    const Icon(Icons.error_outline_rounded, size: 13, color: Color(0xFFEF4444)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        authState.phoneError!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.0,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),

        const SizedBox(height: 10),

        // Primary Gold Action Button: Continue (#btn-send-otp)
        ListenableBuilder(
          listenable: _phoneController,
          builder: (BuildContext context, _) {
            return _buildGoldButton(
              height: buttonHeight,
              text: 'Continue',
              icon: Icons.arrow_forward_rounded,
              isLoading: authState.isSubmitting,
              loadingText: 'Sending OTP...',
              isEnabled: _canSubmitPhone && !authState.isSubmitting,
              onTap: _handleSendOtp,
            );
          },
        ),
      ],
    );
  }

  // ===========================================================================
  // VIEW 2: OTP VERIFICATION (.flow-step-view)
  // ===========================================================================
  Widget _buildViewOtp(BuildContext context, bool isMobile, bool isTiny, AuthFlowState authState) {
    final double buttonHeight = isMobile ? 48.0 : 52.0;
    final bool hasError = authState.otpError != null && authState.otpError!.isNotEmpty;

    return Column(
      key: const ValueKey<String>('view-otp'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Step Navigation Bar: Change Number
        Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: () => _goToStep(LoginStep.phone),
            borderRadius: BorderRadius.circular(8.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.arrow_back_rounded,
                    size: 16,
                    color: Color(0xFF0A221C),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Change Number',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0A221C),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 18),

        // Step Heading Group
        Text(
          'Verify your number',
          style: GoogleFonts.playfairDisplay(
            fontSize: isMobile ? 20.0 : 23.0,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0A221C),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Text(
              'Enter the OTP sent to ',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.0,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF68726E),
                height: 1.5,
              ),
            ),
            Text(
              authState.fullFormattedPhone.isNotEmpty
                  ? authState.fullFormattedPhone
                  : '+91 98765 43210',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.0,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0A221C),
                height: 1.5,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _goToStep(LoginStep.phone),
              child: const Icon(
                Icons.edit_outlined,
                size: 14,
                color: Color(0xFFC88A35),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // 6-Digit OTP Grid with Shake Animation (.otp-inputs-grid)
        AnimatedBuilder(
          animation: _otpShakeAnimation,
          builder: (BuildContext context, Widget? child) {
            return Transform.translate(
              offset: Offset(_otpShakeAnimation.value, 0),
              child: child,
            );
          },
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double gap = isTiny ? 4.0 : (isMobile ? 6.0 : 8.0);
              final double boxHeight = isTiny ? 46.0 : (isMobile ? 50.0 : 56.0);
              final double boxWidth = ((constraints.maxWidth - (5 * gap)) / 6.0).clamp(36.0, 50.0);

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List<Widget>.generate(6, (int index) {
                  final TextEditingController controller = _otpControllers[index];
                  final FocusNode focusNode = _otpFocusNodes[index];

                  return ListenableBuilder(
                    listenable: Listenable.merge(<Listenable>[controller, focusNode]),
                    builder: (BuildContext context, _) {
                      final bool isFilled = controller.text.isNotEmpty;
                      final bool isFocused = focusNode.hasFocus;

                      return Container(
                        width: boxWidth,
                        height: boxHeight,
                        decoration: BoxDecoration(
                          color: isFilled
                              ? const Color(0xFFFBF8F3)
                              : (isFocused ? Colors.white : const Color(0xFFFAF8F5)),
                          border: Border.all(
                            color: hasError
                                ? const Color(0xFFEF4444)
                                : (isFocused
                                    ? const Color(0xFFC88A35)
                                    : (isFilled ? const Color(0xFF063B2C) : const Color(0xFFE5DDD0))),
                            width: isFocused || hasError ? 1.8 : 1.2,
                          ),
                          borderRadius: BorderRadius.circular(isMobile ? 8.0 : 14.0),
                          boxShadow: isFocused && !hasError
                              ? const <BoxShadow>[
                                  BoxShadow(
                                    color: Color(0x1FC88A35),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: KeyboardListener(
                            focusNode: FocusNode(), // Auxiliary listener for backspace
                            onKeyEvent: (KeyEvent event) {
                              if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
                                if (controller.text.isEmpty && index > 0) {
                                  _otpFocusNodes[index - 1].requestFocus();
                                  _otpControllers[index - 1].clear();
                                }
                              }
                            },
                            child: TextField(
                              controller: controller,
                              focusNode: focusNode,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              textInputAction: index == 5 ? TextInputAction.done : TextInputAction.next,
                              maxLength: 1,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (String val) => _handleOtpDigitChange(index, val),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: isTiny ? 18.0 : (isMobile ? 19.0 : 22.0),
                                fontWeight: FontWeight.w700,
                                color: hasError
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF0A221C),
                              ),
                              cursorColor: const Color(0xFF063B2C),
                              decoration: const InputDecoration(
                                counterText: '',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              );
            },
          ),
        ),

        // Validation Error Feedback
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: hasError ? 24 : 8,
          padding: const EdgeInsets.only(top: 4, left: 2),
          alignment: Alignment.centerLeft,
          child: hasError
              ? Text(
                  authState.otpError!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.0,
                    color: const Color(0xFFEF4444),
                  ),
                )
              : const SizedBox.shrink(),
        ),

        const SizedBox(height: 8),

        // Resend OTP Row (.resend-otp-bar)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: authState.resendCountdownSeconds > 0
                  ? Text.rich(
                      TextSpan(
                        text: 'Resend OTP in ',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          color: const Color(0xFF68726E),
                        ),
                        children: <InlineSpan>[
                          TextSpan(
                            text: _formatTimer(authState.resendCountdownSeconds),
                            style: const TextStyle(
                              color: Color(0xFF063B2C),
                              fontWeight: FontWeight.w700,
                              fontFeatures: <ui.FontFeature>[
                                ui.FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Text(
                      "Didn't receive code?",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: const Color(0xFF68726E),
                      ),
                    ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: authState.canResend ? _handleResendOtp : null,
              child: Text(
                'Resend OTP',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: authState.canResend
                      ? const Color(0xFFC88A35)
                      : const Color(0xFF68726E).withValues(alpha: 0.5),
                  decoration: authState.canResend ? TextDecoration.underline : null,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Primary Gold Action Button: Verify & Continue (#btn-verify-otp)
        ListenableBuilder(
          listenable: Listenable.merge(_otpControllers),
          builder: (BuildContext context, _) {
            final bool canVerify = _currentOtp.length == 6 && !authState.isVerifying;
            return _buildGoldButton(
              height: buttonHeight,
              text: 'Verify & Continue',
              icon: Icons.check_rounded,
              isLoading: authState.isVerifying,
              loadingText: 'Verifying...',
              isEnabled: canVerify,
              onTap: _handleVerifyOtp,
            );
          },
        ),
      ],
    );
  }

  // ===========================================================================
  // VIEW 2.5: USER PROFILE INFORMATION COLLECTION (.flow-step-view)
  // ===========================================================================
  Widget _buildViewProfile(BuildContext context, bool isMobile, AuthFlowState authState) {
    final double buttonHeight = isMobile ? 48.0 : 52.0;

    return Form(
      key: _profileFormKey,
      child: Column(
        key: const ValueKey<String>('view-profile'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Step Heading
          Text(
            'Personal Details',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22.0,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0A221C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Enter your name and email to configure your bullion passbook & certificates',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.0,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF68726E),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Name Input
          Row(
            children: <Widget>[
              Text(
                'Full Name',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0A221C),
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFC88A35)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            key: const Key('input_profile_name'),
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15.5,
              color: const Color(0xFF0A221C),
              fontWeight: FontWeight.w600,
            ),
            cursorColor: const Color(0xFF063B2C),
            decoration: InputDecoration(
              hintText: 'e.g. Rihan Saifi',
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14.0,
                color: const Color(0xFF9CA3AF),
              ),
              prefixIcon: const Icon(
                Icons.person_outline_rounded,
                color: Color(0xFF063B2C),
                size: 20,
              ),
              filled: true,
              fillColor: const Color(0xFFFAF8F5),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE5DDD0),
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFC88A35),
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFEF4444),
                  width: 1.0,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFEF4444),
                  width: 1.5,
                ),
              ),
              errorStyle: GoogleFonts.plusJakartaSans(
                fontSize: 11.0,
                color: const Color(0xFFEF4444),
              ),
            ),
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your full name';
              }
              if (value.trim().length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Email Input
          Row(
            children: <Widget>[
              Text(
                'Email Address',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0A221C),
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFC88A35)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            key: const Key('input_profile_email'),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15.5,
              color: const Color(0xFF0A221C),
              fontWeight: FontWeight.w600,
            ),
            cursorColor: const Color(0xFF063B2C),
            decoration: InputDecoration(
              hintText: 'e.g. patron@swastikjewel.com',
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14.0,
                color: const Color(0xFF9CA3AF),
              ),
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: Color(0xFF063B2C),
                size: 20,
              ),
              filled: true,
              fillColor: const Color(0xFFFAF8F5),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE5DDD0),
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFC88A35),
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFEF4444),
                  width: 1.0,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFEF4444),
                  width: 1.5,
                ),
              ),
              errorStyle: GoogleFonts.plusJakartaSans(
                fontSize: 11.0,
                color: const Color(0xFFEF4444),
              ),
            ),
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email address';
              }
              final RegExp emailRegex = RegExp(
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
              );
              if (!emailRegex.hasMatch(value.trim())) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          // City Input (Optional)
          Text(
            'City / Region',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.0,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0A221C),
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            key: const Key('input_profile_city'),
            controller: _cityController,
            textCapitalization: TextCapitalization.words,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15.5,
              color: const Color(0xFF0A221C),
              fontWeight: FontWeight.w600,
            ),
            cursorColor: const Color(0xFF063B2C),
            decoration: InputDecoration(
              hintText: 'e.g. Mumbai, Maharashtra',
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14.0,
                color: const Color(0xFF9CA3AF),
              ),
              prefixIcon: const Icon(
                Icons.location_city_outlined,
                color: Color(0xFF063B2C),
                size: 20,
              ),
              filled: true,
              fillColor: const Color(0xFFFAF8F5),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE5DDD0),
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFC88A35),
                  width: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Primary Gold Action Button: Complete Profile & Enter Vault
          _buildGoldButton(
            height: buttonHeight,
            text: 'Save & Enter Vault',
            icon: Icons.arrow_forward_rounded,
            isLoading: false,
            isEnabled: true,
            onTap: _handleSubmitProfile,
          ),

          const SizedBox(height: 10),

          // Back to OTP Step Option
          Center(
            child: GestureDetector(
              onTap: () => _goToStep(LoginStep.otp),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  'Back to OTP Verification',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF68726E),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // VIEW 3: AUTHENTICATED SUCCESS STATE (.flow-step-view)
  // ===========================================================================
  Widget _buildViewSuccess(BuildContext context, bool isMobile, AuthFlowState authState) {
    final double buttonHeight = isMobile ? 48.0 : 52.0;
    final AppAuthState appAuth = ref.watch(appAuthStateProvider);

    final String displayName = appAuth.userName.isNotEmpty
        ? appAuth.userName
        : (authState.authSession?.user.name.isNotEmpty == true
            ? authState.authSession!.user.name
            : 'Patron');

    final String tierText = appAuth.tier.isNotEmpty
        ? appAuth.tier
        : (authState.authSession?.user.tier.isNotEmpty == true
            ? authState.authSession!.user.tier
            : 'Tier 1 Verified Member');

    final bool isKycVerified = appAuth.isKycVerified;

    return Column(
      key: const ValueKey<String>('view-success'),
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Pulsing Checkmark Badge (.success-icon-badge)
        AnimatedBuilder(
          animation: _successPulseController,
          builder: (BuildContext context, Widget? child) {
            final double scale = 1.0 + (_successPulseController.value * 0.05);
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: <Color>[
                      Color(0xFFC88A35),
                      Color(0xFF063B2C),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFFC88A35),
                    width: 1.5,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: const Color(0xFFC88A35).withValues(
                        alpha: 0.35 + (_successPulseController.value * 0.15),
                      ),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_rounded,
                    size: 34,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        // Success Title
        Text(
          'Welcome Back, $displayName',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: 25.0,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0A221C),
          ),
        ),

        const SizedBox(height: 8),

        // Tier Badge Chip (.success-meta-chip)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF3EDE4),
            border: Border.all(color: const Color(0xFFE5DDD0)),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Text(
            tierText,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF063B2C),
            ),
          ),
        ),

        const SizedBox(height: 18),

        // Subtitle
        Text(
          isKycVerified
              ? 'Accessing your gold schemes and bullion vault...'
              : 'Statutory KYC verification required to access schemes.',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF68726E),
            height: 1.6,
          ),
        ),

        const SizedBox(height: 24),

        // Action Button: Home vs KYC (#btn-enter-app)
        _buildGoldButton(
          height: buttonHeight,
          text: isKycVerified ? 'Enter Gold Vault' : 'Complete Verification',
          icon: Icons.arrow_forward_rounded,
          isLoading: false,
          isEnabled: true,
          onTap: () {
            if (isKycVerified) {
              context.go(RoutePaths.offers);
            } else {
              context.go(RoutePaths.kyc);
            }
          },
        ),
      ],
    );
  }

  // ===========================================================================
  // REUSABLE PRIMARY LUXURY ACTION BUTTON (.btn-primary-gold)
  // ===========================================================================
  Widget _buildGoldButton({
    required double height,
    required String text,
    required IconData icon,
    required bool isLoading,
    String? loadingText,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isEnabled
            ? const Color(0xFF063B2C)
            : const Color(0xFF063B2C).withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(14.0),
        boxShadow: isEnabled
            ? const <BoxShadow>[
                BoxShadow(
                  color: Color(0x1F063B2C),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(14.0),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: isLoading
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            loadingText ?? 'Processing...',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            text,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.42,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            icon,
                            size: 16,
                            color: Colors.white,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // FLOATING TOAST WIDGET (.swastik-toast)
  // ===========================================================================
  Widget _buildFloatingToast() {
    return Positioned(
      top: 24,
      left: 16,
      right: 16,
      child: Center(
        child: AnimatedOpacity(
          opacity: _isToastVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: AnimatedSlide(
            offset: _isToastVisible ? Offset.zero : const Offset(0.0, -0.5),
            duration: const Duration(milliseconds: 300),
            curve: const Cubic(0.16, 1.0, 0.3, 1.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: _isToastError
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF063B2C),
                  borderRadius: BorderRadius.circular(14.0),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      _isToastError
                          ? Icons.error_outline_rounded
                          : Icons.check_circle_outline_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        _toastMessage ?? '',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
