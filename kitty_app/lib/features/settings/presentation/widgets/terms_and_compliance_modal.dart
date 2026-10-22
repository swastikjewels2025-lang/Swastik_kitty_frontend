import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/buttons/kitty_primary_button.dart';

/// Modal bottom sheet detailing BIS 24K Hallmarking compliance and Kitty scheme terms.
class TermsAndComplianceModal extends StatelessWidget {
  const TermsAndComplianceModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) => const TermsAndComplianceModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color modalBg = isDark ? AppColors.emeraldCard : Colors.white;
    final Color titleColor = isDark ? AppColors.textPrimaryLight : const Color(0xFF0F172A);
    final Color subColor = isDark ? AppColors.emeraldTextSubtle : const Color(0xFF64748B);
    final Color boxBg = isDark ? AppColors.deepEmeraldBase : const Color(0xFFF8FAFC);
    final Color boxBorder = isDark ? AppColors.emeraldBorder : const Color(0xFFE2E8F0);

    return Container(
      decoration: BoxDecoration(
        color: modalBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Drag Handle
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space16),

          // Header
          Row(
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.goldSubtle,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.verified_outlined, color: AppColors.goldPrimary, size: 20),
              ),
              const SizedBox(width: AppSpacing.space12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'BIS 24K Compliance & Terms',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                  Text(
                    'Swastik Jewellers Quality Guarantee',
                    style: TextStyle(fontSize: 12, color: subColor),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space16),

          Container(
            padding: AppSpacing.all16,
            decoration: BoxDecoration(
              color: boxBg,
              borderRadius: AppRadius.border16,
              border: Border.all(color: boxBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildPoint(
                  title: '100% BIS 24K Hallmarked (999 Purity)',
                  desc: 'Every gram of gold credited under the gold scheme is backed by physical 24 Karat gold bullion with certified BIS hallmarking.',
                  titleColor: titleColor,
                  descColor: subColor,
                ),
                const SizedBox(height: 12),
                _buildPoint(
                  title: 'Fixed Monthly Installments',
                  desc: 'Installments are due on the 15th of each calendar month. UPI AutoPay ensures seamless ledger booking at the daily benchmark rate.',
                  titleColor: titleColor,
                  descColor: subColor,
                ),
                const SizedBox(height: 12),
                _buildPoint(
                  title: 'Maturity & Redemption Freedom',
                  desc: 'Upon completion of the 12-month tenure, patrons can redeem their accumulated bullion weight in physical gold coins or showroom jewellery with zero making charges up to 18%.',
                  titleColor: titleColor,
                  descColor: subColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space20),

          KittyPrimaryButton(
            label: 'I Understand',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildPoint({
    required String title,
    required String desc,
    required Color titleColor,
    required Color descColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Text('✦ ', style: TextStyle(color: AppColors.goldPrimary, fontSize: 12)),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: titleColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Text(desc, style: TextStyle(fontSize: 11.5, color: descColor, height: 1.35)),
        ),
      ],
    );
  }
}
