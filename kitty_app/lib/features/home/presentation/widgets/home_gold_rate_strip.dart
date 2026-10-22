import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/gold_rate_entity.dart';

/// Compact gold rate benchmark and BIS hallmarking trust strip.
class HomeGoldRateStrip extends StatelessWidget {
  const HomeGoldRateStrip({
    super.key,
    this.goldRate,
  });

  final LiveGoldRateEntity? goldRate;

  @override
  Widget build(BuildContext context) {
    final double rate24k = goldRate?.ratePerGram ?? 15268.000;
    final double rate22k = rate24k * (22 / 24);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space8,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space14,
        vertical: AppSpacing.space12,
      ),
      decoration: BoxDecoration(
        color: AppColors.homeNavbarBg,
        borderRadius: AppRadius.border16,
        border: Border.all(
          color: AppColors.homeNavbarBorder,
          width: 1,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x080C2B24),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          // Gold Coin Icon Badge
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.homeCategoryRingBg,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.homeCategoryRingBorder,
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.monetization_on_outlined,
              color: AppColors.homeBrandGold,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.space12),

          // Rates
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  "TODAY'S GOLD RATE (PER G)",
                  style: AppTypography.kickerCaps(
                    color: AppColors.homeBodySubtitle,
                  ).copyWith(letterSpacing: 1.2),
                ),
                const SizedBox(height: 2),
                Row(
                  children: <Widget>[
                    Text(
                      '22K: ${CurrencyFormatter.formatRupees(rate22k.round())}',
                      style: AppTypography.bodySmall(
                        color: AppColors.homePrimaryHeading,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '•',
                      style: TextStyle(
                        color: AppColors.homeBrandGold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '24K: ${CurrencyFormatter.formatRupees(rate24k.round())}',
                      style: AppTypography.bodySmall(
                        color: AppColors.homePrimaryHeading,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // BIS Hallmark Guarantee
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF059669),
                    size: 13,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '100% BIS',
                    style: AppTypography.labelMeta(
                      color: AppColors.homePrimaryHeading,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Hallmarked',
                style: AppTypography.labelMeta(
                  color: AppColors.homeBodySubtitle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
