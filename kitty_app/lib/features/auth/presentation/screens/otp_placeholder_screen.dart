import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../shared/screens/route_placeholder_screen.dart';

/// Placeholder screen for 6-digit OTP verification view (Phase 5).
class OtpPlaceholderScreen extends ConsumerWidget {
  const OtpPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RoutePlaceholderScreen(
      title: 'OTP Verification View',
      phase: 'Phase 5: Auth',
      routePath: RoutePaths.otp,
      subtitle: '6 individual digit OTP boxes with 30s resend cooldown timer.',
      icon: Icons.pin_outlined,
      actionButton: ElevatedButton(
        onPressed: () async {
          // Provision JWT token into session state
          await ref.read(appAuthStateProvider.notifier).setAuthenticated(
                token: 'mock_jwt_test_token_phase_2',
                userName: 'Rihan',
                userPhone: '+91 98765 43210',
              );
          if (context.mounted) {
            await context.push(RoutePaths.authSuccess);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldPrimary,
          foregroundColor: AppColors.deepEmeraldBase,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.border12),
        ),
        child: const Text('Verify OTP & Enter App'),
      ),
    );
  }
}
