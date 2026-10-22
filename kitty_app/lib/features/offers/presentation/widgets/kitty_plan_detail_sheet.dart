import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/buttons/kitty_primary_button.dart';
import '../../domain/entities/scheme_entity.dart';

/// Slide-up modal sheet presenting comprehensive Kitty Plan details, 11+1 bonus mathematics,
/// redemption guidelines, and plain-language customer FAQs.
class KittyPlanDetailSheet extends StatelessWidget {
  const KittyPlanDetailSheet({
    super.key,
    required this.scheme,
    required this.onStartKitty,
  });

  final SchemeEntity scheme;
  final ValueChanged<SchemeEntity> onStartKitty;

  /// Helper to display the sheet from any context.
  static Future<void> show(
    BuildContext context, {
    required SchemeEntity scheme,
    required ValueChanged<SchemeEntity> onStartKitty,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) => KittyPlanDetailSheet(
        scheme: scheme,
        onStartKitty: (SchemeEntity s) {
          Navigator.of(ctx).pop();
          onStartKitty(s);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int customerMonths = scheme.durationMonths == 12
        ? 11
        : scheme.durationMonths == 18
            ? 16
            : (scheme.durationMonths - 1).clamp(1, scheme.durationMonths);
    final int bonusMonths = scheme.durationMonths - customerMonths;
    final int customerTotal = customerMonths * scheme.monthlyInstallment;
    final int bonusValue = bonusMonths * scheme.monthlyInstallment;
    final int totalValue = customerTotal + bonusValue;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Drag Handle & Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: AppColors.champagneFoil,
                          borderRadius: AppRadius.border8,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.savings_rounded,
                          color: AppColors.deepUmberBronze,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'KITTY PLAN DETAILS',
                            style: AppTypography.caption(
                              color: AppColors.goldPrimary,
                            ).copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            scheme.name,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.espressoCharcoal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.warmTaupeBrown,
                      size: 22,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.warmLinenInset),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // 1. Financial Math Breakdown Card
                    _buildMathBreakdownCard(
                      customerMonths: customerMonths,
                      bonusMonths: bonusMonths,
                      customerTotal: customerTotal,
                      bonusValue: bonusValue,
                      totalValue: totalValue,
                    ),
                    const SizedBox(height: AppSpacing.space20),

                    // 2. Key Plan Advantages
                    Text(
                      'KEY PLAN ADVANTAGES',
                      style: AppTypography.caption(
                        color: AppColors.espressoCharcoal,
                      ).copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...scheme.benefits.map((String b) => _buildCheckItem(b)),
                    const SizedBox(height: AppSpacing.space20),

                    // 3. Plain-Language Redemption Rules
                    Text(
                      'HOW REDEMPTION WORKS',
                      style: AppTypography.caption(
                        color: AppColors.espressoCharcoal,
                      ).copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildRuleItem(
                      icon: Icons.verified_rounded,
                      title: '100% BIS Hallmarked Ornaments',
                      subtitle:
                          'Redeem your accumulated gold against 22K (916) or 18K (750) certified jewellery or 24K pure bullion coins.',
                    ),
                    _buildRuleItem(
                      icon: Icons.trending_down_rounded,
                      title: 'Lowest Market Rate Protection',
                      subtitle:
                          'Your gold weight is locked daily at benchmark IBJA rates, protecting you from gold inflation.',
                    ),
                    _buildRuleItem(
                      icon: Icons.card_giftcard_rounded,
                      title: 'Swastik Bonus Month Contribution',
                      subtitle:
                          'Swastik Jewellers funds the final installment entirely upon completion of on-time customer deposits.',
                    ),
                    const SizedBox(height: AppSpacing.space20),

                    // 4. Frequently Asked Questions
                    Text(
                      'FREQUENTLY ASKED QUESTIONS',
                      style: AppTypography.caption(
                        color: AppColors.espressoCharcoal,
                      ).copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildFaqItem(
                      q: 'What happens if I miss a monthly payment?',
                      a: 'You can pay the missed installment the following month. Your plan tenure shifts by one month without any penalty or interest.',
                    ),
                    _buildFaqItem(
                      q: 'Can I choose gold coins instead of jewellery?',
                      a: 'Yes. At maturity, you can convert your full balance into 24K 999 Fine Swastik Gold Coins with zero making charges.',
                    ),
                    _buildFaqItem(
                      q: 'Is my gold savings scheme legally compliant?',
                      a: 'Swastik Jewellers Kitty Schemes strictly adhere to statutory gold savings guidelines with 100% physical bullion asset backing.',
                    ),
                    const SizedBox(height: AppSpacing.space16),
                  ],
                ),
              ),
            ),

            // Bottom Sticky CTA
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: const BoxDecoration(
                color: AppColors.surfaceCardBg,
                border: Border(
                  top: BorderSide(color: AppColors.warmLinenInset, width: 1),
                ),
              ),
              child: KittyPrimaryButton(
                label: 'START ${scheme.name.toUpperCase()} NOW',
                onPressed: () => onStartKitty(scheme),
                height: 52,
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMathBreakdownCard({
    required int customerMonths,
    required int bonusMonths,
    required int customerTotal,
    required int bonusValue,
    required int totalValue,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: AppColors.champagneFoil.withValues(alpha: 0.35),
        borderRadius: AppRadius.border16,
        border: Border.all(color: AppColors.honeyGoldAccent, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.deepUmberBronze,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'MATURITY MATHEMATICS (11+1 ADVANTAGE)',
                style: AppTypography.caption(
                  color: AppColors.deepUmberBronze,
                ).copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildMathRow(
            label: 'You Pay ($customerMonths Months):',
            value: CurrencyFormatter.formatRupees(customerTotal),
            isBold: false,
          ),
          const SizedBox(height: 6),
          _buildMathRow(
            label: 'Swastik Adds ($bonusMonths Month FREE Bonus):',
            value: '+ ${CurrencyFormatter.formatRupees(bonusValue)}',
            valueColor: AppColors.primaryEmerald,
            isBold: true,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: AppColors.warmLinenInset),
          ),
          _buildMathRow(
            label: 'Total Gold Jewellery Value:',
            value: CurrencyFormatter.formatRupees(totalValue),
            valueColor: AppColors.deepUmberBronze,
            isBold: true,
            fontSize: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildMathRow({
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
    double fontSize = 13,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: AppTypography.bodySmall(
            color: AppColors.warmTaupeBrown,
          ).copyWith(
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            fontSize: fontSize,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.espressoCharcoal,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.only(top: 2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.champagneFoil,
            ),
            alignment: Alignment.center,
            child: const Text(
              '✓',
              style: TextStyle(
                color: AppColors.deepUmberBronze,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall(
                color: AppColors.espressoCharcoal,
              ).copyWith(fontSize: 12.5, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: AppColors.goldPrimary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.espressoCharcoal,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.warmTaupeBrown,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem({required String q, required String a}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfacePageBg,
          borderRadius: AppRadius.border12,
          border: Border.all(color: AppColors.warmLinenInset),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              q,
              style: const TextStyle(
                color: AppColors.espressoCharcoal,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              a,
              style: const TextStyle(
                color: AppColors.warmTaupeBrown,
                fontSize: 11.5,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
