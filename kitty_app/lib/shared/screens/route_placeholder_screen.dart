import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

/// Reusable branded placeholder widget for routes pending feature screen implementation.
class RoutePlaceholderScreen extends StatelessWidget {
  const RoutePlaceholderScreen({
    required this.title,
    required this.phase,
    required this.routePath,
    super.key,
    this.subtitle,
    this.icon = Icons.diamond_outlined,
    this.actionButton,
  });

  final String title;
  final String phase;
  final String routePath;
  final String? subtitle;
  final IconData icon;
  final Widget? actionButton;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.deepEmeraldBase : AppColors.surfacePageBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Luxury Emblem
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.goldSubtle,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.goldBorder, width: 1.5),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: AppColors.goldPrimary,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.space20),

                // Title
                Text(
                  title,
                  style: AppTypography.displaySubtitle(
                    color: isDark ? AppColors.textPrimaryLight : AppColors.textPrimaryDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.space8),

                // Subtitle
                Text(
                  subtitle ?? 'This screen is planned for upcoming development.',
                  style: AppTypography.bodyRegular(
                    color: isDark ? AppColors.emeraldTextSubtle : AppColors.textSecondaryMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.space24),

                // Phase & Route Meta Card
                Container(
                  padding: AppSpacing.all16,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.emeraldCard : AppColors.surfaceCardBg,
                    borderRadius: AppRadius.border14,
                    border: Border.all(
                      color: isDark ? AppColors.emeraldBorder : AppColors.surfaceCardBorder,
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.goldSubtle,
                              borderRadius: AppRadius.border20,
                              border: Border.all(color: AppColors.goldBorder),
                            ),
                            child: Text(
                              phase,
                              style: AppTypography.kickerCaps(
                                color: AppColors.goldPrimary,
                              ),
                            ),
                          ),
                          Text(
                            routePath,
                            style: AppTypography.labelMeta(
                              color: isDark
                                  ? AppColors.textPrimaryLight
                                  : AppColors.textPrimaryDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                if (actionButton != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.space24),
                  actionButton!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
