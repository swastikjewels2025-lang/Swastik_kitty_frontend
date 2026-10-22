import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../auth/domain/entities/user_entity.dart';

/// Luxury Customer Profile Card displayed at the top of the Settings & Profile screen.
/// Strictly presents canonical fields from [UserEntity]: Name, Phone, Email, Tier, KYC status.
class PatronProfileCard extends StatelessWidget {
  const PatronProfileCard({
    required this.user,
    super.key,
  });

  final UserEntity? user;

  @override
  Widget build(BuildContext context) {
    final String name = user?.name.isNotEmpty == true ? user!.name : 'Patron';
    final String phone = user?.phone.isNotEmpty == true ? user!.phone : '+91 98765 43210';
    final String? email = user?.email;
    final String tier = user?.tier.isNotEmpty == true ? user!.tier : 'Tier 1 Verified Member';
    final bool isKycVerified = user?.kyc.isVerified == true;

    const Color cardBg = AppColors.settingsCardBg;
    const Color cardBorder = AppColors.settingsBorder;
    const Color iconBg = AppColors.settingsIconBg;
    const Color accentGold = AppColors.settingsAccentGold;

    return Container(
      padding: AppSpacing.all16,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.border20,
        border: Border.all(color: cardBorder),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          // Royal Monogram Avatar Squircle / Circle
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
              border: Border.all(
                color: accentGold.withValues(alpha: 0.6),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'P',
                style: AppTypography.displaySubtitle(
                  color: accentGold,
                ).copyWith(fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.space14),

          // User Metadata Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.settingsTextPrimary,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (isKycVerified)
                      const Tooltip(
                        message: 'KYC Verified Patron',
                        child: Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: AppColors.settingsBadgeText,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  phone,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.settingsTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (email != null && email.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.settingsTextSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: AppColors.settingsBadgeBg,
                    borderRadius: AppRadius.border12,
                    border: Border.all(
                      color: AppColors.settingsBorder,
                    ),
                  ),
                  child: Text(
                    tier,
                    style: AppTypography.kickerCaps(
                      color: AppColors.settingsBadgeText,
                    ).copyWith(fontSize: 9.5, letterSpacing: 0.5, fontWeight: FontWeight.w700),
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
