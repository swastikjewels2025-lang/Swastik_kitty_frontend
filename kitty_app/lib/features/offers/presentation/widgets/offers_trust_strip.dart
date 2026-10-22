import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';

/// Trust and security 4-grid strip matching `.offers-trust-strip` in `offers.html`.
class OffersTrustStrip extends StatelessWidget {
  const OffersTrustStrip({super.key});

  static const List<({IconData icon, String title, String subtitle})> _trustItems =
      <({IconData icon, String title, String subtitle})>[
    (
      icon: Icons.verified_outlined,
      title: '100% BIS Hallmarked',
      subtitle: '24K 999 Purity Certified',
    ),
    (
      icon: Icons.shield_outlined,
      title: '100% Insured Vault',
      subtitle: 'Free secure custody storage',
    ),
    (
      icon: Icons.account_balance_wallet_outlined,
      title: 'Zero Hidden Fees',
      subtitle: 'Complete transparency',
    ),
    (
      icon: Icons.storefront_outlined,
      title: 'Flexible Maturity',
      subtitle: 'Redeem anytime in store',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.border16,
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.lock_outline_rounded,
                size: 15,
                color: AppColors.goldPrimary,
              ),
              const SizedBox(width: 6),
              Text(
                'SWASTIK TRUST & SECURITY',
                style: AppTypography.cardTitle(
                  color: AppColors.textPrimaryDark,
                ).copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space12),

          // 2x2 Static Layout
          Row(
            children: <Widget>[
              _buildTrustItem(_trustItems[0]),
              const SizedBox(width: 10),
              _buildTrustItem(_trustItems[1]),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              _buildTrustItem(_trustItems[2]),
              const SizedBox(width: 10),
              _buildTrustItem(_trustItems[3]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrustItem(({IconData icon, String title, String subtitle}) item) {
    return Expanded(
      child: Row(
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFBF8F1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.goldPrimary.withValues(alpha: 0.2),
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              item.icon,
              color: AppColors.goldPrimary,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall(
                    color: AppColors.textPrimaryDark,
                  ).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall(
                    color: AppColors.textSecondaryMuted,
                  ).copyWith(
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
