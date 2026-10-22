import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/dashboard_summary_entity.dart';

/// Luxury Next EMI Installment Card with due date countdown and payment action button.
class DashboardNextEmiCard extends StatelessWidget {
  const DashboardNextEmiCard({
    super.key,
    required this.dashboard,
    required this.onPayTap,
  });

  final DashboardSummaryEntity dashboard;
  final VoidCallback onPayTap;

  @override
  Widget build(BuildContext context) {
    final NextInstallmentEntity? next = dashboard.nextInstallment;
    final bool isCompleted = dashboard.isCompleted || (next == null && (dashboard.monthsPaid ?? 0) >= (dashboard.totalMonths ?? 12));

    if (isCompleted) {
      return Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space8,
        ),
        padding: const EdgeInsets.all(AppSpacing.space16),
        decoration: BoxDecoration(
          color: AppColors.emeraldCard,
          borderRadius: AppRadius.border20,
          border: Border.all(
            color: AppColors.goldBorder.withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x33051C16),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.goldPrimary.withValues(alpha: 0.15),
                border: Border.all(
                  color: AppColors.goldBorder.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.verified_outlined,
                  color: AppColors.goldLight,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.space14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'All EMIs Completed ✨',
                    style: AppTypography.cardTitle(
                      color: Colors.white,
                    ).copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Your gold scheme is mature and ready for fine jewellery delivery.',
                    style: AppTypography.bodySmall(
                      color: const Color(0xFF8EAA9E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final int nextMonth = next?.month ?? ((dashboard.monthsPaid ?? 8) + 1);
    final int amount = next?.amount ?? (dashboard.customMonthlyEmi ?? 5000);
    final String dueDateStr = next != null
        ? DateFormatter.formatUtcToIst(next.dueDate)
        : '15 Sep 2026';
    final int daysRemaining = next?.daysRemaining ?? 5;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space8,
      ),
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: AppColors.emeraldCard,
        borderRadius: AppRadius.border20,
        border: Border.all(
          color: AppColors.goldBorder.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x33051C16),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Top Row: Calendar Badge & Info
          Row(
            children: <Widget>[
              // Calendar Circle
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.goldPrimary.withValues(alpha: 0.15),
                  border: Border.all(
                    color: AppColors.goldBorder.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.calendar_month_outlined,
                    color: AppColors.goldLight,
                    size: 22,
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.space14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Month $nextMonth Installment Due',
                      style: AppTypography.cardTitle(
                        color: Colors.white,
                      ).copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.access_time,
                          color: AppColors.goldLight,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Due by $dueDateStr ',
                          style: AppTypography.labelMeta(
                            color: const Color(0xFF8EAA9E),
                          ),
                        ),
                        Text(
                          '($daysRemaining Days Left)',
                          style: AppTypography.labelMeta(
                            color: AppColors.goldLight,
                          ).copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.space16),

          // Pay CTA Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPayTap,
              borderRadius: AppRadius.border14,
              child: Ink(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.space14,
                  horizontal: AppSpacing.space16,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.primaryEmerald,
                  borderRadius: AppRadius.border14,
                  boxShadow: AppShadows.ctaEmerald,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'PAY NEXT EMI (${CurrencyFormatter.formatRupees(amount)})',
                      style: AppTypography.bodyBold(
                        color: Colors.white,
                      ).copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
