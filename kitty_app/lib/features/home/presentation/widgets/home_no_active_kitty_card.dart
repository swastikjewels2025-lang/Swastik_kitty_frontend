import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/badges/kitty_status_badge.dart';
import '../../../../shared/widgets/buttons/kitty_primary_button.dart';

/// Warm, prestigious onboarding card for patrons who do not currently have an active Kitty.
///
/// Communicates the 11+1 month bonus proposition, pure gold hallmarking,
/// and provides a direct primary CTA to start a Kitty.
class HomeNoActiveKittyCard extends StatelessWidget {
  const HomeNoActiveKittyCard({
    super.key,
    required this.onStartKittyTap,
    this.onCalculateTap,
  });

  final VoidCallback onStartKittyTap;
  final VoidCallback? onCalculateTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space8,
      ),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: AppRadius.border20,
        border: Border.all(
          color: AppColors.surfaceCardBorder,
          width: 1.2,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0A063D2E),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          // Subtle radial glow
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    AppColors.honeyGoldAccent.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Top Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const KittyStatusBadge(
                      status: KittyInstallmentStatus.preJoin,
                      customLabel: 'READY TO START',
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(
                          Icons.stars_rounded,
                          color: AppColors.honeyGoldAccent,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'SWASTIK KITTY',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: AppColors.honeyGoldAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.space12),

                // Title & Subtitle
                Text(
                  'Start Your Gold Savings Today',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.espressoCharcoal,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Save monthly in 100% BIS hallmarked 24K gold and receive 1 month installment as bonus from Swastik Jewellers on maturity.',
                  style: AppTypography.bodySmall(
                    color: AppColors.warmTaupeBrown,
                  ).copyWith(height: 1.45),
                ),

                const SizedBox(height: AppSpacing.space14),

                // Benefit Pills Wrap
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _BenefitPill(
                      icon: Icons.card_giftcard_rounded,
                      label: '11+1 Bonus Month',
                    ),
                    _BenefitPill(
                      icon: Icons.verified_rounded,
                      label: '100% BIS Hallmarked',
                    ),
                    _BenefitPill(
                      icon: Icons.auto_awesome_rounded,
                      label: '0% Making Charge*',
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.space16),

                // Primary CTA Button
                KittyPrimaryButton(
                  label: 'START A KITTY',
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                  onPressed: onStartKittyTap,
                ),

                if (onCalculateTap != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.space10),
                  Center(
                    child: InkWell(
                      onTap: onCalculateTap,
                      borderRadius: AppRadius.border8,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'Calculate Gold Value & Plan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryEmerald,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: AppColors.primaryEmerald,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitPill extends StatelessWidget {
  const _BenefitPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF9F5),
        borderRadius: BorderRadius.circular(AppRadius.radiusPill),
        border: Border.all(
          color: const Color(0xFFECE7DE),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: 13,
            color: AppColors.honeyGoldAccent,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.deepForestCharcoal,
            ),
          ),
        ],
      ),
    );
  }
}
