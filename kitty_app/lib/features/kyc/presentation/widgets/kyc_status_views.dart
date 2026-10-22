import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../shared/widgets/buttons/kitty_primary_button.dart';
import '../../domain/entities/kyc_entity.dart';

/// Gold and emerald visual constants matching `kyc.html` / `kyc.css`.
class _KycStatusTokens {
  static const Color textPrimary = Color(0xFF0A221C);
  static const Color textMuted = Color(0xFF68726E);
  static const Color emerald = Color(0xFF063B2C);
  static const Color border = Color(0xFFEFE6DB);
  static const Color chipBg = Color(0xFFF3EDE4);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerBg = Color(0x1AEF4444);
  static const Color dangerBorder = Color(0x40EF4444);

  static const RadialGradient successOrbGradient = RadialGradient(
    colors: <Color>[
      Color(0x26063B2C),
      Color(0x0D063B2C),
    ],
    stops: <double>[0.0, 1.0],
  );

  static const RadialGradient rejectedOrbGradient = RadialGradient(
    colors: <Color>[
      Color(0x33EF4444),
      Color(0x14EF4444),
    ],
    stops: <double>[0.0, 1.0],
  );
}

/// KYC Submitted Successfully view matching Gold Plans theme.
class KycSuccessView extends StatelessWidget {
  const KycSuccessView({
    super.key,
    required this.result,
    required this.onProceed,
  });

  final KycResultEntity? result;
  final VoidCallback onProceed;

  @override
  Widget build(BuildContext context) {
    final String refCode = result?.referenceId ?? 'KYC-849201';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const SizedBox(height: 16),

        // Success Badge Orb (72x72)
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: _KycStatusTokens.successOrbGradient,
            border: Border.all(
              color: _KycStatusTokens.emerald,
              width: 1.5,
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x14063B2C),
                blurRadius: 20,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.check_rounded,
              size: 34,
              color: _KycStatusTokens.emerald,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Success Heading: Playfair Display
        Text(
          'KYC Submitted Successfully',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: _KycStatusTokens.textPrimary,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // Reference Code Chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: _KycStatusTokens.chipBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _KycStatusTokens.border,
              width: 1,
            ),
          ),
          child: Text(
            'Ref: #$refCode',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _KycStatusTokens.emerald,
              letterSpacing: 0.3,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Success Paragraph
        Text(
          'Your statutory identity documents have been securely encrypted and submitted. Your Royal Gold Vault scheme enrollment is authorized.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            height: 1.6,
            color: _KycStatusTokens.textMuted,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 24),

        // Button: Enter Kitty Vault Dashboard
        KittyPrimaryButton(
          label: 'Enter Gold Scheme Dashboard',
          icon: const Icon(Icons.arrow_forward_rounded, size: 16),
          onPressed: onProceed,
        ),

        const SizedBox(height: 10),
      ],
    );
  }
}

/// KYC Under Verification / Pending review state view.
class KycPendingView extends StatelessWidget {
  const KycPendingView({
    super.key,
    required this.result,
    required this.onReturnHome,
  });

  final KycResultEntity? result;
  final VoidCallback onReturnHome;

  @override
  Widget build(BuildContext context) {
    final String refCode = result?.referenceId ?? 'KYC-PENDING';
    final String masked = result?.documentNumberMasked ?? 'XXXX XXXX 1234';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const SizedBox(height: 16),

        // Pending Clock Badge Orb
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: _KycStatusTokens.successOrbGradient,
            border: Border.all(
              color: _KycStatusTokens.emerald,
              width: 1.5,
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x14063B2C),
                blurRadius: 20,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.hourglass_top_rounded,
              size: 34,
              color: _KycStatusTokens.emerald,
            ),
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'KYC Under Verification',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: _KycStatusTokens.textPrimary,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: _KycStatusTokens.chipBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _KycStatusTokens.border,
              width: 1,
            ),
          ),
          child: Text(
            'Ref: #$refCode',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _KycStatusTokens.emerald,
              letterSpacing: 0.3,
            ),
          ),
        ),

        const SizedBox(height: 14),

        Text(
          'Your identity documents have been submitted and are undergoing statutory review. Verification is typically completed within 2 to 4 business hours.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            height: 1.5,
            color: _KycStatusTokens.textMuted,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // Submitted Document Details Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _KycStatusTokens.border),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Submitted Document',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: _KycStatusTokens.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Text(
                      result?.documentType.name.toUpperCase() ?? 'AADHAAR',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(color: Color(0xFFF5EFE7), height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Document Number',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: _KycStatusTokens.textMuted,
                    ),
                  ),
                  Text(
                    masked,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1C1917),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Status',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: _KycStatusTokens.textMuted,
                    ),
                  ),
                  Text(
                    'UNDER STATUTORY REVIEW',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Reference ID',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: _KycStatusTokens.textMuted,
                    ),
                  ),
                  Text(
                    '#$refCode',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _KycStatusTokens.emerald,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        KittyPrimaryButton(
          label: 'Return to Home',
          icon: const Icon(Icons.home_outlined, size: 16),
          onPressed: onReturnHome,
        ),

        const SizedBox(height: 10),
      ],
    );
  }
}

/// KYC Verified & Approved state view.
class KycApprovedView extends StatelessWidget {
  const KycApprovedView({
    super.key,
    required this.result,
    required this.onProceed,
  });

  final KycResultEntity? result;
  final VoidCallback onProceed;

  @override
  Widget build(BuildContext context) {
    final String refCode = result?.referenceId ?? 'KYC-VERIFIED';
    final String masked = result?.documentNumberMasked ?? 'XXXX XXXX 1234';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const SizedBox(height: 16),

        // Shield Check Orb
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: _KycStatusTokens.successOrbGradient,
            border: Border.all(
              color: _KycStatusTokens.emerald,
              width: 1.5,
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x14063B2C),
                blurRadius: 20,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.verified_user_rounded,
              size: 34,
              color: _KycStatusTokens.emerald,
            ),
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'KYC Verified & Approved',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: _KycStatusTokens.textPrimary,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: _KycStatusTokens.chipBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _KycStatusTokens.border,
              width: 1,
            ),
          ),
          child: Text(
            'Ref: #$refCode • $masked',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _KycStatusTokens.emerald,
              letterSpacing: 0.3,
            ),
          ),
        ),

        const SizedBox(height: 14),

        Text(
          'Your account is fully compliant with statutory gold investment guidelines. You can enroll in schemes and manage your vault without restrictions.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            height: 1.5,
            color: _KycStatusTokens.textMuted,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // Verified Document Details Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFA7F3D0)),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Verified Identity Document',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: _KycStatusTokens.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Text(
                      result?.documentType.name.toUpperCase() ?? 'AADHAAR',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF047857),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(color: Color(0xFFF5EFE7), height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Document Number',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: _KycStatusTokens.textMuted,
                    ),
                  ),
                  Text(
                    masked,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1C1917),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Compliance Status',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: _KycStatusTokens.textMuted,
                    ),
                  ),
                  const Text(
                    'VERIFIED & COMPLIANT',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF047857),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Certificate Reference',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: _KycStatusTokens.textMuted,
                    ),
                  ),
                  Text(
                    '#$refCode',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _KycStatusTokens.emerald,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        KittyPrimaryButton(
          label: 'Enter Gold Scheme Dashboard',
          icon: const Icon(Icons.arrow_forward_rounded, size: 16),
          onPressed: onProceed,
        ),

        const SizedBox(height: 10),
      ],
    );
  }
}

/// KYC Rejected view with reason display and retry action.
class KycRejectedView extends StatelessWidget {
  const KycRejectedView({
    super.key,
    required this.result,
    required this.onRetry,
  });

  final KycResultEntity? result;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final String? reason = result?.rejectionReason;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const SizedBox(height: 16),

        // Rejected Alert Orb
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: _KycStatusTokens.rejectedOrbGradient,
            border: Border.all(
              color: _KycStatusTokens.danger,
              width: 1.5,
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x26EF4444),
                blurRadius: 20,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.warning_amber_rounded,
              size: 34,
              color: _KycStatusTokens.danger,
            ),
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'KYC Verification Rejected',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: _KycStatusTokens.danger,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        if (reason != null && reason.isNotEmpty) ...<Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _KycStatusTokens.dangerBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _KycStatusTokens.dangerBorder,
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: _KycStatusTokens.danger,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reason,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: _KycStatusTokens.danger,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        Text(
          'Your document submission could not be verified by compliance. Please ensure the document is clear, valid, and re-submit your verification.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            height: 1.6,
            color: _KycStatusTokens.textMuted,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 24),

        KittyPrimaryButton(
          label: 'Retry KYC Submission',
          icon: const Icon(Icons.refresh_rounded, size: 16),
          onPressed: onRetry,
        ),

        const SizedBox(height: 10),
      ],
    );
  }
}
