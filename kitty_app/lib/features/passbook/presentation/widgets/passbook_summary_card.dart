import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/passbook_summary_entity.dart';

/// 3-Pillar summary strip displaying EMIs Paid, Total Contributed, and 24K Gold Accumulated.
class PassbookSummaryCard extends StatelessWidget {
  const PassbookSummaryCard({
    super.key,
    required this.summary,
  });

  final PassbookSummaryEntity summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space8,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space14,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceCardBg,
        borderRadius: AppRadius.border16,
        border: Border.all(
          color: AppColors.surfaceCardBorder,
          width: 1,
        ),
        boxShadow: AppShadows.cardSubtle,
      ),
      child: Row(
        children: <Widget>[
          // Pillar 1: EMIs Paid
          Expanded(
            child: _PillarItem(
              key: const Key('summary_paid_count'),
              label: 'EMIS PAID',
              value: '${summary.monthsPaid} / ${summary.totalMonths}',
              icon: Icons.check_circle_outline_rounded,
              iconColor: AppColors.statusSuccessText,
            ),
          ),

          // Divider 1
          Container(
            width: 1,
            height: 36,
            color: AppColors.warmLinenInset,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),

          // Pillar 2: Total Contributed
          Expanded(
            child: _PillarItem(
              key: const Key('summary_total_paid'),
              label: 'TOTAL PAID',
              value: CurrencyFormatter.formatRupees(summary.totalPaid),
              icon: Icons.account_balance_wallet_outlined,
              iconColor: AppColors.honeyGoldAccent,
            ),
          ),

          // Divider 2
          Container(
            width: 1,
            height: 36,
            color: AppColors.warmLinenInset,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),

          // Pillar 3: 24K Gold Accumulated
          Expanded(
            child: _PillarItem(
              key: const Key('summary_gold_acc'),
              label: '24K GOLD',
              value: '${summary.accumulatedGoldGrams.toStringAsFixed(3)} g',
              icon: Icons.auto_awesome_outlined,
              iconColor: AppColors.honeyGoldAccent,
              valueColor: AppColors.honeyGoldAccent,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillarItem extends StatelessWidget {
  const _PillarItem({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              icon,
              size: 12,
              color: iconColor,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: AppTypography.labelMeta(
                  color: AppColors.textSecondaryMuted,
                ).copyWith(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.cardTitle(
            color: valueColor ?? AppColors.textPrimaryDark,
          ).copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
