import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/buttons/kitty_primary_button.dart';

/// Modal dialog explaining the Month 12 100% Jeweler Bonus Deposit privilege.
class PassbookPerksDialog extends StatelessWidget {
  const PassbookPerksDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => const PassbookPerksDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.border20),
      backgroundColor: AppColors.surfaceCardBg,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Gold Star Circle
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.statusBonusBg,
                border: Border.all(
                  color: AppColors.goldPrimary.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.card_giftcard,
                  color: AppColors.goldPrimary,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space16),

            // Title
            Text(
              '100% Jeweler Bonus Deposit',
              style: AppTypography.cardTitle(
                color: AppColors.textPrimaryDark,
              ).copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space8),

            // Subtitle
            Text(
              'Month 12 is completely sponsored by Swastik Jewellers upon regular completion of your 11 monthly installments.',
              style: AppTypography.bodySmall(
                color: AppColors.textSecondaryMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space16),

            // Perks List Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.space14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: AppRadius.border12,
                border: Border.all(
                  color: AppColors.surfaceCardBorder,
                  width: 1,
                ),
              ),
              child: const Column(
                children: <Widget>[
                  _PerkRow(
                    text: 'Full 1-month installment deposit credited free',
                  ),
                  SizedBox(height: 8),
                  _PerkRow(
                    text: 'Instant 24K pure hallmark gold allocation for Month 12',
                  ),
                  SizedBox(height: 8),
                  _PerkRow(
                    text: 'Flat 25% waiver on jewelry making charges upon maturity',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space24),

            // Dismiss Button
            SizedBox(
              width: double.infinity,
              child: KittyPrimaryButton(
                label: 'Understood',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerkRow extends StatelessWidget {
  const _PerkRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          '✦ ',
          style: TextStyle(
            color: AppColors.goldPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall(
              color: AppColors.textPrimaryDark,
            ).copyWith(fontSize: 11.5),
          ),
        ),
      ],
    );
  }
}
