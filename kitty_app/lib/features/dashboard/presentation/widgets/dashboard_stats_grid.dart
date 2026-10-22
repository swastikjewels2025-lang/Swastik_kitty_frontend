import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/dashboard_summary_entity.dart';

/// 2x2 Financial and Gold Vault Statistics Grid for the Kitty Dashboard.
class DashboardStatsGrid extends StatelessWidget {
  const DashboardStatsGrid({
    super.key,
    required this.dashboard,
  });

  final DashboardSummaryEntity dashboard;

  @override
  Widget build(BuildContext context) {
    final int targetAmount = dashboard.targetAmount ?? 60000;
    final int totalPaid = dashboard.totalPaidAmount ?? (dashboard.monthsPaid ?? 8) * (dashboard.customMonthlyEmi ?? 5000);
    final int currentValuation = dashboard.currentValuation ?? 41036;
    final double goldGrams = dashboard.accumulatedGoldGrams ?? 5.482;
    final double gainPct = dashboard.valuationGainPct ?? 2.59;
    final bool isPositiveGain = gainPct >= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space4,
      ),
      child: Column(
        children: <Widget>[
          // Row 1: Scheme Target & Paid So Far
          Row(
            children: <Widget>[
              Expanded(
                child: _StatCard(
                  icon: Icons.track_changes_outlined,
                  label: 'SCHEME TARGET',
                  value: CurrencyFormatter.formatRupees(targetAmount),
                ),
              ),
              const SizedBox(width: AppSpacing.space12),
              Expanded(
                child: _StatCard(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'PAID SO FAR',
                  value: CurrencyFormatter.formatRupees(totalPaid),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.space12),

          // Row 2: Accumulated 24K Gold & Current Valuation
          Row(
            children: <Widget>[
              Expanded(
                child: _StatCard(
                  icon: Icons.auto_awesome_outlined,
                  label: 'ACCUMULATED\n24K GOLD',
                  value: CurrencyFormatter.formatRupees(currentValuation),
                  subtitle: '${goldGrams.toStringAsFixed(3)} g',
                ),
              ),
              const SizedBox(width: AppSpacing.space12),
              Expanded(
                child: _StatCard(
                  icon: Icons.trending_up,
                  label: 'CURRENT\nVALUATION',
                  value: '${isPositiveGain ? '+' : ''}${gainPct.toStringAsFixed(2)}%',
                  valueColor: isPositiveGain ? const Color(0xFF059669) : AppColors.statusErrorText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space14,
        vertical: AppSpacing.space14,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF042D22),
            Color(0xFF063D2E),
            Color(0xFF084837),
          ],
        ),
        borderRadius: AppRadius.border18,
        border: Border.all(
          color: AppColors.richAntiqueGold.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x33063D2E),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Circular Icon Container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF04281E),
              border: Border.all(
                color: AppColors.richAntiqueGold.withValues(alpha: 0.35),
                width: 1,
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x1A063D2E),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                color: AppColors.honeyGoldAccent,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.space10),

          // Content Text Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  label,
                  style: AppTypography.kickerCaps(
                    color: AppColors.honeyGoldAccent,
                  ).copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: AppTypography.cardTitle(
                    color: valueColor ?? Colors.white,
                  ).copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...<Widget>[
                  const SizedBox(height: 1),
                  Text(
                    subtitle!,
                    style: AppTypography.labelMeta(
                      color: AppColors.goldLight,
                    ).copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
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
