import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/badges/kitty_chit_token_pill.dart';
import '../../../../shared/widgets/progress/kitty_circular_progress_gauge.dart';
import '../../domain/entities/dashboard_summary_entity.dart';

/// Luxury emerald hero card showcasing the patron's active gold scheme,
/// target, paid amount, monthly installment, upcoming installment, and progress gauge.
class DashboardHeroCard extends StatelessWidget {
  const DashboardHeroCard({
    super.key,
    required this.dashboard,
    this.onPayTap,
  });

  final DashboardSummaryEntity dashboard;
  final VoidCallback? onPayTap;

  @override
  Widget build(BuildContext context) {
    final int monthsPaid = dashboard.monthsPaid ?? 0;
    final int totalMonths = dashboard.totalMonths ?? 12;
    final int monthlyEmi = dashboard.customMonthlyEmi ?? 5000;
    final int remainingPayable = dashboard.remainingMonthsPayable;
    final String rawSchemeName = dashboard.schemeName ?? 'Swastik Swarna Varsha';
    // Remove bracketed text completely: e.g. "Swastik Suvarna Varsha (12-Month Gold Scheme)" -> "Swastik Suvarna Varsha"
    final String cleanSchemeName = rawSchemeName
        .replaceAll(RegExp(r'\s*\([^)]*\)'), '')
        .trim();
    final String chitToken = dashboard.chitToken ?? '#SW-042';

    final int targetAmount = dashboard.targetAmount ?? (totalMonths * monthlyEmi);
    final int totalPaid = dashboard.totalPaidAmount ?? (monthsPaid * monthlyEmi);
    final int nextDueMonth = dashboard.nextInstallment?.month ??
        (monthsPaid < totalMonths ? monthsPaid + 1 : totalMonths);
    final String upcomingInstallmentText =
        dashboard.isCompleted ? 'Completed' : 'Month $nextDueMonth Due';

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
          width: 1.0,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0D063D2E),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 1. Scheme Title & Token Pill Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        cleanSchemeName,
                        style: AppTypography.cardTitle(
                          color: AppColors.espressoCharcoal,
                        ).copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$totalMonths-Month Gold Scheme',
                        style: AppTypography.bodySmall(
                          color: AppColors.honeyGoldAccent,
                        ).copyWith(fontSize: 11.5, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.space8),
                KittyChitTokenPill(
                  token: chitToken,
                  isDarkSurface: false,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.space14),

            // 2. Four Scheme Metrics: Scheme Target, Paid So Far, Monthly Installment, Upcoming Installment
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space14,
                vertical: AppSpacing.space12,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryEmerald,
                borderRadius: AppRadius.border16,
                border: Border.all(
                  color: AppColors.richAntiqueGold.withValues(alpha: 0.30),
                  width: 1,
                ),
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _buildMetricTile(
                          label: 'SCHEME TARGET',
                          value: CurrencyFormatter.formatRupees(targetAmount),
                          icon: Icons.track_changes_outlined,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 38,
                        color: AppColors.richAntiqueGold.withValues(alpha: 0.25),
                        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.space8),
                      ),
                      Expanded(
                        child: _buildMetricTile(
                          label: 'PAID SO FAR',
                          value: CurrencyFormatter.formatRupees(totalPaid),
                          icon: Icons.account_balance_wallet_outlined,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.richAntiqueGold.withValues(alpha: 0.2),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _buildMetricTile(
                          label: 'MONTHLY INSTALLMENT',
                          value: CurrencyFormatter.formatRupees(monthlyEmi),
                          icon: Icons.calendar_today_outlined,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 38,
                        color: AppColors.richAntiqueGold.withValues(alpha: 0.25),
                        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.space8),
                      ),
                      Expanded(
                        child: InkWell(
                          key: const Key('dashboard_hero_pay_upcoming_emi'),
                          onTap: onPayTap,
                          borderRadius: AppRadius.border8,
                          child: _buildMetricTile(
                            label: 'UPCOMING INSTALLMENT',
                            value: upcomingInstallmentText,
                            icon: Icons.event_available_outlined,
                            isHighlight: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.space14),

            // 3. Warm Progress Panel: EMIs Completed, EMIs to Pay, Bonus Month, Circular Gauge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space16,
                vertical: AppSpacing.space14,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryEmerald,
                borderRadius: AppRadius.border20,
                border: Border.all(
                  color: AppColors.richAntiqueGold.withValues(alpha: 0.30),
                  width: 1,
                ),
              ),
              child: Row(
                children: <Widget>[
                  // Circular Gauge
                  KittyCircularProgressGauge(
                    currentValue: monthsPaid,
                    totalValue: totalMonths,
                    size: 92,
                    strokeWidth: 7.5,
                    subtitle: 'EMIS PAID',
                    isDarkSurface: true,
                  ),

                      // Vertical Divider
                      Container(
                        width: 1,
                        height: 54,
                        color: AppColors.richAntiqueGold.withValues(alpha: 0.25),
                        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
                      ),

                      // Progress Summary & Gift Badge
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    '$monthsPaid EMIs Completed',
                                    style: AppTypography.cardTitle(
                                      color: Colors.white,
                                    ).copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    remainingPayable > 0
                                        ? '$remainingPayable EMIs to Pay'
                                        : (dashboard.isCompleted ? 'Completed' : '1 EMI to Pay'),
                                    style: AppTypography.bodySmall(
                                      color: Colors.white70,
                                    ).copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '✧ 1 Bonus Month Free',
                                    style: AppTypography.labelMeta(
                                      color: AppColors.honeyGoldAccent,
                                    ).copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Gift Icon Circle
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.honeyGoldAccent.withValues(alpha: 0.15),
                                    border: Border.all(
                                      color: AppColors.honeyGoldAccent.withValues(alpha: 0.4),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.card_giftcard,
                                      color: AppColors.honeyGoldAccent,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'BONUS\nMONTH',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.kickerCaps(
                                    color: AppColors.honeyGoldAccent,
                                  ).copyWith(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                if (!dashboard.isCompleted && onPayTap != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.space12),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      key: const Key('dashboard_hero_pay_selected_btn'),
                      onPressed: onPayTap,
                      icon: const Icon(
                        Icons.bolt_rounded,
                        size: 18,
                        color: AppColors.primaryEmerald,
                      ),
                      label: Text(
                        'PAY SELECTED (${CurrencyFormatter.formatRupees(dashboard.nextInstallment?.amount ?? monthlyEmi)})',
                        style: const TextStyle(
                          color: AppColors.primaryEmerald,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.honeyGoldAccent,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.border12,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    bool isHighlight = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              icon,
              size: 12,
              color: isHighlight ? AppColors.honeyGoldAccent : AppColors.honeyGoldAccent.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: AppTypography.kickerCaps(
                  color: AppColors.honeyGoldAccent,
                ).copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: AppTypography.cardTitle(
            color: isHighlight ? AppColors.honeyGoldAccent : Colors.white,
          ).copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
