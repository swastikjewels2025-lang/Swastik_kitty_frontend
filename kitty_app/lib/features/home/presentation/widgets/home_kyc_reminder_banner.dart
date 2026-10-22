import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';

/// Contextual statutory KYC compliance reminder banner shown when KYC is pending or incomplete.
class HomeKycReminderBanner extends StatelessWidget {
  const HomeKycReminderBanner({
    super.key,
    required this.onVerifyTap,
    this.isRejected = false,
  });

  final VoidCallback onVerifyTap;
  final bool isRejected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space6,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space14,
        vertical: AppSpacing.space10,
      ),
      decoration: BoxDecoration(
        color: isRejected
            ? AppColors.statusErrorBg
            : AppColors.homeCategoryRingBg,
        borderRadius: AppRadius.border12,
        border: Border.all(
          color: isRejected
              ? AppColors.statusErrorBorder
              : AppColors.homeCategoryRingBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isRejected
                  ? AppColors.statusErrorBorder
                  : AppColors.homeCategoryRingBorder.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isRejected
                  ? Icons.error_outline_rounded
                  : Icons.shield_outlined,
              color: isRejected ? AppColors.statusErrorText : AppColors.homeBrandGold,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.space10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  isRejected ? 'KYC Verification Needed' : 'Statutory KYC Pending',
                  style: AppTypography.bodySmall(
                    color: AppColors.homePrimaryHeading,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  isRejected
                      ? 'Please re-upload your document to enable payouts.'
                      : 'Complete your 1-min KYC to activate full scheme maturity.',
                  style: AppTypography.labelMeta(
                    color: AppColors.homeBodySubtitle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.space8),
          InkWell(
            onTap: onVerifyTap,
            borderRadius: AppRadius.border10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isRejected ? AppColors.statusErrorText : AppColors.homeBrandGold,
                borderRadius: AppRadius.border10,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'VERIFY',
                    style: AppTypography.labelMeta(
                      color: Colors.white,
                    ).copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
