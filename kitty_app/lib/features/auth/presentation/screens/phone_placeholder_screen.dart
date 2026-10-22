import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../shared/screens/route_placeholder_screen.dart';

/// Placeholder screen for Phone entry view (Phase 5).
class PhonePlaceholderScreen extends StatelessWidget {
  const PhonePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoutePlaceholderScreen(
      title: 'Phone Input View',
      phase: 'Phase 5: Auth',
      routePath: RoutePaths.phone,
      subtitle: 'Mobile number input (+91 prefix mask) with OTP dispatch action.',
      icon: Icons.phone_android_rounded,
      actionButton: ElevatedButton(
        onPressed: () => context.push(RoutePaths.otp),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldPrimary,
          foregroundColor: AppColors.deepEmeraldBase,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.border12),
        ),
        child: const Text('Proceed to OTP Verification (View 2)'),
      ),
    );
  }
}
