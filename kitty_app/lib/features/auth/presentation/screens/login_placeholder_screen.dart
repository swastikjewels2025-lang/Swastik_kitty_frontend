import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../shared/screens/route_placeholder_screen.dart';

/// Placeholder screen for Login method selection view (Phase 5).
class LoginPlaceholderScreen extends ConsumerWidget {
  const LoginPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RoutePlaceholderScreen(
      title: 'Login Screen',
      phase: 'Phase 5: Auth',
      routePath: RoutePaths.login,
      subtitle: 'Choice between Mobile Phone OTP Login and Google SSO.',
      icon: Icons.lock_outline_rounded,
      actionButton: Column(
        children: <Widget>[
          ElevatedButton(
            onPressed: () => context.push(RoutePaths.phone),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
              foregroundColor: AppColors.deepEmeraldBase,
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.border12),
            ),
            child: const Text('Enter Mobile Number (View 1)'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () async {
              // Direct simulated test login for shell navigation verification
              await ref.read(appAuthStateProvider.notifier).setAuthenticated(
                    token: 'mock_jwt_test_token_phase_2',
                    userName: 'Patron',
                    userPhone: '+91 90000 00000',
                  );
              if (context.mounted) {
                context.go(RoutePaths.offers);
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.goldPrimary,
              side: const BorderSide(color: AppColors.goldPrimary),
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.border12),
            ),
            child: const Text('Simulate Sandbox Login (Token Provisioned)'),
          ),
        ],
      ),
    );
  }
}
