import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';

/// Single item descriptor within a [SettingsGroupCard].
class SettingsItemModel {
  const SettingsItemModel({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.badgeText,
    this.badgeColor,
    this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final String? badgeText;
  final Color? badgeColor;
  final VoidCallback? onTap;
  final bool isDestructive;
}

/// A luxury styled settings section container strictly implementing the HTML prototype design:
/// Eyebrow title, crisp rounded card, gold icon bases, badges, and smooth dividers.
class SettingsGroupCard extends StatelessWidget {
  const SettingsGroupCard({
    required this.title,
    required this.items,
    super.key,
  });

  final String title;
  final List<SettingsItemModel> items;

  @override
  Widget build(BuildContext context) {
    const Color cardBg = AppColors.settingsCardBg;
    const Color cardBorder = AppColors.settingsBorder;
    const Color titleColor = AppColors.settingsTextPrimary;
    const Color subColor = AppColors.settingsTextSecondary;
    const Color iconBase = AppColors.settingsIconBg;
    const Color iconColor = AppColors.settingsAccentGold;
    const Color eyebrowColor = AppColors.settingsAccentGold;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Eyebrow section title
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: AppTypography.kickerCaps(
              color: eyebrowColor,
            ).copyWith(
              fontSize: 11,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        // Rounded Settings Card Container
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: AppRadius.border18,
            border: Border.all(color: cardBorder),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: <Widget>[
              for (int i = 0; i < items.length; i++) ...<Widget>[
                _buildItemRow(
                  context: context,
                  item: items[i],
                  titleColor: titleColor,
                  subColor: subColor,
                  iconBase: iconBase,
                  iconColor: iconColor,
                ),
                if (i < items.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.settingsBorder,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemRow({
    required BuildContext context,
    required SettingsItemModel item,
    required Color titleColor,
    required Color subColor,
    required Color iconBase,
    required Color iconColor,
  }) {
    final Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: <Widget>[
          // Icon Container / Squircle (Soft Warm Linen #EAE4D9)
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBase,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: AppColors.settingsBorder,
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                item.icon,
                size: 19,
                color: item.isDestructive ? AppColors.statusErrorText : iconColor,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.space12),

          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: item.isDestructive ? AppColors.statusErrorText : titleColor,
                    height: 1.3,
                  ),
                ),
                if (item.subtitle != null && item.subtitle!.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: subColor,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Trailing action / badge / switch / chevron
          if (item.badgeText != null) ...<Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.settingsBadgeBg,
                borderRadius: AppRadius.border20,
                border: Border.all(
                  color: AppColors.settingsBorder,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 11,
                    color: AppColors.settingsBadgeText,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    item.badgeText!,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.settingsBadgeText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
          ],

          if (item.trailing != null)
            item.trailing!
          else if (item.onTap != null)
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.settingsTextSecondary.withValues(alpha: 0.6),
              size: 20,
            ),
        ],
      ),
    );

    if (item.onTap != null) {
      return InkWell(
        onTap: item.onTap,
        child: content,
      );
    }

    return content;
  }
}
