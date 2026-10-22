import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/routing/route_paths.dart';

/// Screen displayed when an unrecognized route path is requested.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({
    super.key,
    this.requestedPath,
  });

  final String? requestedPath;

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
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.statusErrorBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.statusErrorText, width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.statusErrorText,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.space24),
                Text(
                  '404 — Page Not Found',
                  style: AppTypography.displaySubtitle(
                    color: isDark ? AppColors.textPrimaryLight : AppColors.textPrimaryDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.space8),
                Text(
                  'The requested destination does not exist or has been moved.',
                  style: AppTypography.bodyRegular(
                    color: isDark ? AppColors.emeraldTextSubtle : AppColors.textSecondaryMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (requestedPath != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.space16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.emeraldCard : AppColors.surfaceCardBg,
                      borderRadius: AppRadius.border10,
                      border: Border.all(
                        color: isDark ? AppColors.emeraldBorder : AppColors.surfaceCardBorder,
                      ),
                    ),
                    child: Text(
                      requestedPath!,
                      style: AppTypography.labelMeta(
                        color: isDark ? AppColors.textPrimaryLight : AppColors.textPrimaryDark,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.space32),
                ElevatedButton.icon(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(RoutePaths.offers);
                    }
                  },
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Return to Safety'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldPrimary,
                    foregroundColor: AppColors.emeraldCard,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.border12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
