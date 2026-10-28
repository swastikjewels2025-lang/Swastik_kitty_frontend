import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../shared/widgets/buttons/kitty_primary_button.dart';
import '../../../../shared/widgets/feedback/kitty_error_state.dart';
import '../../../../shared/widgets/feedback/kitty_loading_indicator.dart';
import '../../../../shared/widgets/navigation/kitty_hamburger_button.dart';
import '../../../auth/presentation/widgets/jewelry_constellation_painter.dart';
import '../providers/kyc_controller.dart';
import '../providers/kyc_state.dart';
import '../widgets/kyc_doc_number_field.dart';
import '../widgets/kyc_doc_tabs.dart';
import '../widgets/kyc_status_views.dart';
import '../widgets/kyc_upload_card.dart';

/// Statutory KYC Identity Verification screen matching Gold Plans luxury theme
class KycScreen extends ConsumerStatefulWidget {
  const KycScreen({super.key});

  @override
  ConsumerState<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends ConsumerState<KycScreen>
    with TickerProviderStateMixin {
  late final TextEditingController _docNumberController;
  bool _termsAccepted = false;

  // Animation Controllers matching Login Screen
  late final AnimationController _cardEntranceController;
  late final Animation<double> _cardScaleAnimation;
  late final Animation<Offset> _cardSlideAnimation;
  late final Animation<double> _cardFadeAnimation;

  late final AnimationController _bgConstellationController;

  static const Color _bgPrimary = AppColors.warmPearl; // Canvas #FAF7F2

  bool get _isInTest =>
      !kIsWeb && io.Platform.environment.containsKey('FLUTTER_TEST');

  @override
  void initState() {
    super.initState();
    _docNumberController = TextEditingController();

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

    // 2. 3D Background Jewelry Constellation (continuous 24s loop matching Login)
    _bgConstellationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    );
    if (!_isInTest) {
      _bgConstellationController.repeat();
    } else {
      _bgConstellationController.value = 0.5;
    }

    // Check existing statutory KYC status on appearance
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(kycControllerProvider.notifier).loadKycStatus();
    });
  }

  @override
  void dispose() {
    _cardEntranceController.dispose();
    _bgConstellationController.dispose();
    _docNumberController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RoutePaths.postKycChoice);
    }
  }

  Future<void> _handleSkip() async {
    await HapticFeedback.lightImpact();
    await ref.read(appAuthStateProvider.notifier).skipKyc();
    if (mounted) {
      context.go(RoutePaths.postKycChoice);
    }
  }

  void _handleDocTypeChanged(DocTypeEnum newType) {
    ref.read(kycControllerProvider.notifier).selectDocType(newType);
    final String restoredNumber = ref.read(kycControllerProvider).documentNumber;
    _docNumberController.value = TextEditingValue(
      text: restoredNumber,
      selection: TextSelection.collapsed(offset: restoredNumber.length),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_termsAccepted) {
      await HapticFeedback.heavyImpact();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please accept the Terms & Conditions to continue.',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
      return;
    }

    final KycController controller = ref.read(kycControllerProvider.notifier);
    final bool success = await controller.submitKyc();
    if (success && mounted) {
      await ref.read(appAuthStateProvider.notifier).completeKyc();
      if (mounted) {
        try {
          context.go(RoutePaths.postKycChoice);
        } catch (_) {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final KycState state = ref.watch(kycControllerProvider);
    final KycController controller = ref.read(kycControllerProvider.notifier);
    final Size screenSize = MediaQuery.sizeOf(context);
    final double screenWidth = screenSize.width;
    final bool isTiny = screenWidth <= 340;
    final bool isSmall = screenWidth <= 480;

    final EdgeInsets cardPadding = isTiny
        ? const EdgeInsets.symmetric(horizontal: 14.0, vertical: 24.0)
        : isSmall
            ? const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0)
            : const EdgeInsets.symmetric(horizontal: 36.0, vertical: 40.0);

    final double cardRadius = isSmall ? 20.0 : 26.0;

    // Keep text controller in sync if documentNumber changed
    if (_docNumberController.text != state.documentNumber &&
        (state.documentNumber.isEmpty || _docNumberController.text.isEmpty)) {
      _docNumberController.value = TextEditingValue(
        text: state.documentNumber,
        selection: TextSelection.collapsed(offset: state.documentNumber.length),
      );
    }

    final bool isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    if (isKeyboardVisible) {
      if (_bgConstellationController.isAnimating) {
        _bgConstellationController.stop();
      }
    } else {
      if (!_isInTest && !_bgConstellationController.isAnimating) {
        _bgConstellationController.repeat();
      }
    }

    return Scaffold(
      backgroundColor: _bgPrimary,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // 1. Subtle Damask Wallpaper Pattern Overlay
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.035,
                child: Image.asset(
                  'assets/patterns/damask-pattern.jpg',
                  fit: BoxFit.cover,
                  repeat: ImageRepeat.repeat,
                  color: AppColors.goldPrimary,
                  colorBlendMode: BlendMode.screen,
                  errorBuilder: (BuildContext ctx, Object err, StackTrace? st) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),

          // 2. 3D Faceted Jewelry Constellation Canvas
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _bgConstellationController,
                  builder: (BuildContext context, Widget? child) {
                    return CustomPaint(
                      painter: JewelryConstellationPainter(
                        progress: _bgConstellationController.value,
                        opacity: 0.35,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // 3. Foreground Content with Floating Controls and Steady Scrollable Card
          SafeArea(
            child: Stack(
              children: <Widget>[
                // Steady Card Container matching Gold Plans theme
                Align(
                  alignment: Alignment.topCenter,
                  child: RepaintBoundary(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(
                        left: isSmall ? 12.0 : 16.0,
                        right: isSmall ? 12.0 : 16.0,
                        top: isSmall ? 56.0 : 64.0,
                        bottom: isSmall ? 24.0 : 36.0,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: FadeTransition(
                          opacity: _cardFadeAnimation,
                          child: SlideTransition(
                            position: _cardSlideAnimation,
                            child: ScaleTransition(
                              scale: _cardScaleAnimation,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(cardRadius),
                                  border: Border.all(
                                    color: AppColors.surfaceCardBorder,
                                    width: 1.0,
                                  ),
                                  boxShadow: const <BoxShadow>[
                                    BoxShadow(
                                      color: Color(0x0C000000),
                                      blurRadius: 24,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: cardPadding,
                                  child: _buildCardContent(state, controller, isSmall),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Floating Luxury Back Button in top-left
                Positioned(
                  top: 8,
                  left: 12,
                  child: Tooltip(
                    message: 'Back',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _handleBack,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.surfaceCardBorder,
                              width: 1,
                            ),
                            boxShadow: const <BoxShadow>[
                              BoxShadow(
                                color: Color(0x0A000000),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 16,
                              color: AppColors.deepForestCharcoal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Top-right Skip Button
                Positioned(
                  top: 8,
                  right: 58,
                  child: TextButton(
                    onPressed: state.status == KycFormStatus.submitting ? null : _handleSkip,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Skip',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryEmerald,
                      ),
                    ),
                  ),
                ),

                // Top-right Hamburger Menu Button
                const Positioned(
                  top: 8,
                  right: 12,
                  child: KittyHamburgerButton(isLightSurface: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContent(KycState state, KycController controller, bool isSmall) {
    if (state.status == KycFormStatus.loadingStatus) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 36),
          child: KittyLoadingIndicator(
            message: 'Verifying Compliance Status...',
          ),
        ),
      );
    }

    if (state.status == KycFormStatus.error && state.kycResult == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: KittyErrorState(
          message: state.errorMessage ?? 'Unable to connect to verification services.',
          onRetry: () => controller.loadKycStatus(),
          isDarkSurface: true,
        ),
      );
    }

    // Success / Approved State
    if (state.status == KycFormStatus.verified) {
      return KycApprovedView(
        result: state.kycResult,
        onProceed: () async {
          await ref.read(appAuthStateProvider.notifier).completeKyc();
          if (mounted) {
            context.go(RoutePaths.postKycChoice);
          }
        },
      );
    }

    // Pending State (under review)
    if (state.status == KycFormStatus.pending) {
      return KycPendingView(
        result: state.kycResult,
        onReturnHome: () async {
          await ref.read(appAuthStateProvider.notifier).submitKycPending();
          if (mounted) {
            context.go(RoutePaths.postKycChoice);
          }
        },
      );
    }

    // Rejected State
    if (state.status == KycFormStatus.rejected) {
      return KycRejectedView(
        result: state.kycResult,
        onRetry: () => controller.retry(),
      );
    }

    // Default Form View (notSubmitted, submitting)
    return _buildFormView(state, controller, isSmall);
  }

  Widget _buildFormView(KycState state, KycController controller, bool isSmall) {
    final bool isSubmitting = state.status == KycFormStatus.submitting;
    final double logoWidth = isSmall ? 140 : 156;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Brand Header matching Login Screen
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Swastik Logo with Drop Shadow (.brand-logo-img)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                child: SvgPicture.asset(
                  'assets/icons/swastiklogo.svg',
                  width: logoWidth,
                  semanticsLabel: 'Swastik Jewellers',
                  fit: BoxFit.contain,
                  placeholderBuilder: (BuildContext context) {
                    return const Icon(
                      Icons.diamond_outlined,
                      size: 44,
                      color: Color(0xFFCCA243),
                    );
                  },
                ),
              ),

              // Card Title: "KYC Document Verification" with gold gradient
              Text(
                'KYC Document Verification',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                  color: AppColors.deepForestCharcoal,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 1. Document Selector Tabs (Aadhaar / PAN)
        KycDocTabs(
          selectedDocType: state.selectedDocType,
          onDocTypeChanged: _handleDocTypeChanged,
          enabled: !isSubmitting,
        ),

        const SizedBox(height: 18),

        // 2. Document Number Input Field
        KycDocNumberField(
          docType: state.selectedDocType,
          controller: _docNumberController,
          onChanged: (String val) => controller.updateDocNumber(val),
          isValid: state.isDocNumberValid,
          errorText: state.docNumberError,
          enabled: !isSubmitting,
        ),

        const SizedBox(height: 20),

        // 3. Document Upload / Camera / Gallery Section
        KycUploadCard(
          selectedFile: state.selectedFile,
          onTakePhoto: () => controller.pickFileFromCamera(),
          onChooseGallery: () => controller.pickFileFromGallery(),
          onRemoveFile: () => controller.removeFile(),
          enabled: !isSubmitting,
        ),

        // 4. Mandatory Terms & Conditions Acceptance Checkbox
        _buildTermsAndConditionsCheckbox(isSubmitting),

        // Error Message Banner (if any)
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) ...<Widget>[
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0x26EF4444),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0x80EF4444),
                width: 1,
              ),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.error_outline_rounded,
                  size: 16,
                  color: Color(0xFFEF4444),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.errorMessage!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // 5. Submit KYC Button (.btn-submit-kyc)
        KittyPrimaryButton(
          label: isSubmitting
              ? 'Verifying & Encrypting...'
              : 'Complete KYC',
          icon: const Icon(Icons.shield_outlined, size: 18),
          isLoading: isSubmitting,
          isEnabled: !isSubmitting,
          onPressed: _handleSubmit,
        ),

        const SizedBox(height: 12),

        // 6. Skip for now link
        Center(
          child: TextButton(
            onPressed: isSubmitting ? null : _handleSkip,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Skip for now',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.mutedSlateGray,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.mutedSlateGray,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  void _showTermsDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: const BorderSide(color: AppColors.surfaceCardBorder),
          ),
          title: Text(
            'Terms & Conditions',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.deepForestCharcoal,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              'By completing KYC verification and using Kitty App:\n\n'
              '1. You confirm that all submitted identity information and documents belong to you and are legally valid under statutory PMLA guidelines.\n\n'
              '2. You consent to statutory verification of your identity documents for bullion purchases and gold scheme enrollment.\n\n'
              '3. Patron biometric data and personal information are secured with bank-grade 256-bit encryption and are never disclosed to unauthorized parties.\n\n'
              '4. You agree to adhere to Swastik Jewellers terms of service, gold redemption policies, and digital bullion accumulation guidelines.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.0,
                color: AppColors.mutedSlateGray,
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
                  color: AppColors.primaryEmerald,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTermsAndConditionsCheckbox(bool isSubmitting) {
    return Container(
      margin: const EdgeInsets.only(top: 14, bottom: 18),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isSubmitting
              ? null
              : () {
                  final bool nextVal = !_termsAccepted;
                  setState(() {
                    _termsAccepted = nextVal;
                  });
                  ref.read(kycControllerProvider.notifier).toggleConsent(nextVal);
                },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Custom 20x20 Checkbox
                AnimatedContainer(
                  key: const Key('terms_checkbox'),
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(top: 2, right: 12),
                  decoration: BoxDecoration(
                    color: _termsAccepted ? AppColors.primaryEmerald : const Color(0xFFFAF8F5),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _termsAccepted
                          ? AppColors.primaryEmerald
                          : const Color(0xFFD6CBC0),
                      width: 1.5,
                    ),
                    boxShadow: _termsAccepted
                        ? const <BoxShadow>[
                            BoxShadow(
                              color: Color(0x1F063B2C),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: _termsAccepted
                      ? const Center(
                          child: Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),

                // Terms text with clickable "Terms & Conditions"
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        height: 1.5,
                        color: AppColors.mutedSlateGray,
                      ),
                      children: <InlineSpan>[
                        const TextSpan(text: 'I agree to the '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: GestureDetector(
                            onTap: _showTermsDialog,
                            child: Text(
                              'Terms & Conditions',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryEmerald,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primaryEmerald,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
