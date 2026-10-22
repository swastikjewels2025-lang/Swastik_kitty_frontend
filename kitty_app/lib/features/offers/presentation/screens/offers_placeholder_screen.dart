import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../shared/screens/route_placeholder_screen.dart';

/// Placeholder screen for Offers tab (Phase 10).
class OffersPlaceholderScreen extends StatelessWidget {
  const OffersPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoutePlaceholderScreen(
      title: 'Gold Offers & Schemes',
      phase: 'Phase 10: Offers',
      routePath: RoutePaths.offers,
      subtitle: 'Curated 11+1 gold savings schemes (Suvarna Varsha, Dhanvriddhi), late-joiner dynamic EMI calculators, and instant enrollment.',
      icon: Icons.card_giftcard_rounded,
      actionButton: ElevatedButton(
        onPressed: () => context.push(RoutePaths.kyc),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldPrimary,
          foregroundColor: AppColors.deepEmeraldBase,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.border12),
        ),
        child: const Text('Complete KYC to Enroll in Plan'),
      ),
    );
  }
}
