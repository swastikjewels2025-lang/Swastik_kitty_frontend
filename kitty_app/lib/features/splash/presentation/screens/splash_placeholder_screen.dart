import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../shared/screens/route_placeholder_screen.dart';

/// Placeholder screen for Splash view (Phase 5).
class SplashPlaceholderScreen extends ConsumerWidget {
  const SplashPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RoutePlaceholderScreen(
      title: 'Splash Screen',
      phase: 'Phase 5: Auth',
      routePath: RoutePaths.splash,
      subtitle: '3D faceted crystal diamond animation loader and session verification.',
      icon: Icons.diamond_rounded,
      actionButton: ElevatedButton(
        onPressed: () {
          final AppAuthState auth = ref.read(appAuthStateProvider);
          if (auth.isAuthenticated) {
            context.go(RoutePaths.offers);
          } else {
            context.go(RoutePaths.login);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldPrimary,
          foregroundColor: AppColors.deepEmeraldBase,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.border12),
        ),
        child: const Text('Proceed Past Splash'),
      ),
    );
  }
}
