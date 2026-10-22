import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../shared/screens/route_placeholder_screen.dart';

/// Placeholder screen for Statutory KYC Compliance (Phase 6).
class KycPlaceholderScreen extends StatelessWidget {
  const KycPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoutePlaceholderScreen(
      title: 'Statutory KYC Verification',
      phase: 'Phase 6: KYC',
      routePath: RoutePaths.kyc,
      subtitle: 'Aadhaar (12 digits) / PAN document selection, camera/gallery upload (Max 10MB), consent checkbox, and status review.',
      icon: Icons.verified_user_outlined,
      actionButton: ElevatedButton.icon(
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(RoutePaths.offers);
          }
        },
        icon: const Icon(Icons.check_rounded, size: 18),
        label: const Text('Back to Home'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldPrimary,
          foregroundColor: AppColors.deepEmeraldBase,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.border12),
        ),
      ),
    );
  }
}
