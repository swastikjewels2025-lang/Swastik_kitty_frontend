import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';

/// Trust and Statutory Guarantees footer bar for the Kitty Dashboard.
class DashboardTrustBar extends StatelessWidget {
  const DashboardTrustBar({super.key});

  @override
  Widget build(BuildContext context) {
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
        color: Colors.white,
        borderRadius: AppRadius.border16,
        border: Border.all(
          color: const Color(0xFFEAECEF),
          width: 1,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0A0C2B24),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: <Widget>[
          Expanded(
            child: _TrustItem(
              icon: Icons.percent,
              label: 'Zero\nconvenience fee',
            ),
          ),
          _ItemDivider(),
          Expanded(
            child: _TrustItem(
              icon: Icons.water_drop_outlined,
              label: 'Instant 24K\ngold credit',
            ),
          ),
          _ItemDivider(),
          Expanded(
            child: _TrustItem(
              icon: Icons.verified_user_outlined,
              label: 'Secure &\nverified',
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  const _TrustItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFBF8F1),
            border: Border.all(
              color: const Color(0xFFEAECEF),
              width: 1,
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              color: const Color(0xFFCCA043),
              size: 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            style: AppTypography.kickerCaps(
              color: const Color(0xFF4B5563),
            ).copyWith(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              height: 1.25,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ItemDivider extends StatelessWidget {
  const _ItemDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: const Color(0xFFEAECEF),
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
