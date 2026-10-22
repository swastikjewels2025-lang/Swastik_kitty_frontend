import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/badges/kitty_status_badge.dart';
import '../../../../shared/widgets/buttons/kitty_primary_button.dart';
import '../../domain/entities/scheme_entity.dart';
import 'kitty_plan_detail_sheet.dart';

/// Card component representing a single Gold Savings Scheme plan.
///
/// Implements the approved benefit-first presentation:
/// - Prominent 11+1 bonus calculation callout
/// - Clear monthly deposit and total maturity value
/// - Key benefits checklist
/// - "View Plan Details & Rules" trigger for the slide-up sheet
/// - Standard 52px primary Start Kitty CTA
class OffersSchemeCard extends StatelessWidget {
  const OffersSchemeCard({
    super.key,
    required this.scheme,
    required this.onEnrollTap,
    this.onDetailsTap,
  });

  final SchemeEntity scheme;
  final ValueChanged<SchemeEntity> onEnrollTap;
  final ValueChanged<SchemeEntity>? onDetailsTap;

  @override
  Widget build(BuildContext context) {
    final String formattedMonthly =
        CurrencyFormatter.formatRupees(scheme.monthlyInstallment);
    final String durationSub =
        '${scheme.durationMonths} Months • Monthly $formattedMonthly';

    final int customerMonths = scheme.durationMonths == 12
        ? 11
        : scheme.durationMonths == 18
            ? 16
            : (scheme.durationMonths - 1).clamp(1, scheme.durationMonths);
    final int bonusMonths = scheme.durationMonths - customerMonths;
    final int customerDeposit = customerMonths * scheme.monthlyInstallment;
    final int bonusGift = bonusMonths * scheme.monthlyInstallment;
    final int totalMaturity = customerDeposit + bonusGift;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: scheme.isPopular ? const Color(0xFFC88A35) : const Color(0xFFEFE6DB),
          width: scheme.isPopular ? 1.5 : 1.0,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0E785F3C),
            blurRadius: 14,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: () => _openDetailsSheet(context),
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Header (Coin Thumbnail + Title + Figures + Badge)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Golden Coin Stack Thumbnail
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF2E5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEFE2CF)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/images/gold-coins.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (BuildContext _, Object _, StackTrace? _) => const Icon(
                          Icons.savings_rounded,
                          color: Color(0xFFC88A35),
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            scheme.name,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0A221C),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            durationSub,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF68726E),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 2-Column Metrics Row
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Monthly Investment',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF68726E),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      formattedMonthly,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF121A16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Total Contribution',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF68726E),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      CurrencyFormatter.formatRupees(totalMaturity),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF121A16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Wrap(
                      direction: Axis.vertical,
                      spacing: 4,
                      alignment: WrapAlignment.end,
                      children: <Widget>[
                        if (scheme.isPopular)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF063B2C),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: const Text(
                              'Most Popular',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        if (scheme.durationMonths == 12)
                          const KittyStatusBadge(
                            status: KittyInstallmentStatus.active,
                            customLabel: '11+1 PLAN',
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space14),

                // Benefit-First Mathematics Callout Banner
                _buildBonusMathBanner(
                  customerMonths: customerMonths,
                  bonusMonths: bonusMonths,
                  customerDeposit: customerDeposit,
                  bonusGift: bonusGift,
                  totalMaturity: totalMaturity,
                ),
                const SizedBox(height: AppSpacing.space14),

                // Benefits List
                ...scheme.benefits.take(3).map((String benefit) {
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
                            benefit,
                            style: AppTypography.bodySmall(
                              color: AppColors.warmTaupeBrown,
                            ).copyWith(
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: AppSpacing.space8),

                // View Plan Rules & Details link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _openDetailsSheet(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Text(
                      'View Plan Details & Rules',
                      style: TextStyle(
                        color: AppColors.goldPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    label: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: AppColors.goldPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.space12),

                // Enrollment CTA Button (52px height)
                KittyPrimaryButton(
                  label: _getCtaLabel(),
                  height: 52,
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  onPressed: () => onEnrollTap(scheme),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openDetailsSheet(BuildContext context) {
    if (onDetailsTap != null) {
      onDetailsTap!(scheme);
    } else {
      KittyPlanDetailSheet.show(
        context,
        scheme: scheme,
        onStartKitty: onEnrollTap,
      );
    }
  }

  Widget _buildBonusMathBanner({
    required int customerMonths,
    required int bonusMonths,
    required int customerDeposit,
    required int bonusGift,
    required int totalMaturity,
  }) {
    final String formulaText = scheme.durationMonths == 12
        ? '✦ 11 + 1 SWASTIK BONUS BENEFIT'
        : scheme.durationMonths == 18
            ? '✦ 16 + 2 SWASTIK ROYAL BONUS'
            : '✦ EXPRESS SAVINGS ADVANTAGE';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space12),
      decoration: BoxDecoration(
        color: AppColors.champagneFoil.withValues(alpha: 0.35),
        borderRadius: AppRadius.border12,
        border: Border.all(
          color: AppColors.honeyGoldAccent.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            formulaText,
            style: const TextStyle(
              color: AppColors.deepUmberBronze,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'You Pay ($customerMonths mo)',
                      style: const TextStyle(
                        color: AppColors.warmTaupeBrown,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.formatRupees(customerDeposit),
                      style: const TextStyle(
                        color: AppColors.espressoCharcoal,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '+',
                  style: TextStyle(
                    color: AppColors.goldPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Bonus ($bonusMonths mo)',
                      style: const TextStyle(
                        color: AppColors.primaryEmerald,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '+${CurrencyFormatter.formatRupees(bonusGift)}',
                      style: const TextStyle(
                        color: AppColors.primaryEmerald,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '=',
                  style: TextStyle(
                    color: AppColors.goldPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    const Text(
                      'Total Value',
                      style: TextStyle(
                        color: AppColors.warmTaupeBrown,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.formatRupees(totalMaturity),
                      style: const TextStyle(
                        color: AppColors.deepUmberBronze,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCtaLabel() {
    if (scheme.durationMonths == 12) {
      return 'Start 12-Month Gold Scheme';
    } else if (scheme.durationMonths == 18) {
      return 'Enquire Bridal Gold Scheme';
    } else if (scheme.durationMonths == 6) {
      return 'Start Express Gold Scheme';
    }
    return 'Start Kitty Plan';
  }
}
