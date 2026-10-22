import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../shared/screens/route_placeholder_screen.dart';

/// Placeholder screen for Auth Success confirmation view (Phase 5).
class AuthSuccessPlaceholderScreen extends StatelessWidget {
  const AuthSuccessPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoutePlaceholderScreen(
      title: 'Authentication Success',
      phase: 'Phase 5: Auth',
      routePath: RoutePaths.authSuccess,
      subtitle: 'Confirmation card with patron name, loyalty badge, and continue button.',
      icon: Icons.check_circle_outline_rounded,
      actionButton: ElevatedButton(
        onPressed: () => context.go(RoutePaths.offers),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldPrimary,
          foregroundColor: AppColors.deepEmeraldBase,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.border12),
        ),
        child: const Text('Continue to Swastik Vault'),
      ),
    );
  }
}
