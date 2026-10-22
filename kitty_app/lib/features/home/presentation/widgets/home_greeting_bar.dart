import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/display/kitty_avatar.dart';

/// Top greeting and patron identity banner for the Home screen.
class HomeGreetingBar extends StatelessWidget {
  const HomeGreetingBar({
    super.key,
    required this.userName,
    this.tier = 'Tier 1 Verified Member',
    this.avatarUrl,
    this.onProfileTap,
  });

  final String userName;
  final String tier;
  final String? avatarUrl;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onProfileTap,
      borderRadius: AppRadius.border16,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space8,
        ),
        child: Row(
          children: <Widget>[
            // Patron Avatar
            KittyAvatar(
              imageUrl: avatarUrl,
              initials: userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : 'R',
              size: 46,
              borderColor: AppColors.homeCategoryRingBorder,
            ),
            const SizedBox(width: AppSpacing.space12),

            // Greeting & Patron Tier
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'NAMASTE,',
                    style: AppTypography.kickerCaps(
                      color: AppColors.homeBrandGold,
                    ).copyWith(letterSpacing: 1.8),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    userName,
                    style: AppTypography.cardTitle(
                      color: AppColors.homePrimaryHeading,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Tier Badge Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.homeCategoryRingBg,
                borderRadius: AppRadius.border12,
                border: Border.all(
                  color: AppColors.homeCategoryRingBorder,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.verified_outlined,
                    color: AppColors.homeBrandGold,
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'ROYAL CLUB',
                    style: AppTypography.labelMeta(
                      color: AppColors.homeBrandGold,
                    ).copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
