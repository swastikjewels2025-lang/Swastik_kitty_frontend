import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../shared/screens/route_placeholder_screen.dart';

/// Placeholder screen for Home tab (Phase 7).
class HomePlaceholderScreen extends StatelessWidget {
  const HomePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoutePlaceholderScreen(
      title: 'Home Screen',
      phase: 'Phase 7: Home',
      routePath: RoutePaths.home,
      subtitle: 'Brand retail showcase, promotional hero carousel, live gold rate ticker, and curated jewellery catalog.',
      icon: Icons.storefront_outlined,
      actionButton: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () => context.go(RoutePaths.dashboard),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
              foregroundColor: AppColors.deepEmeraldBase,
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.border12),
            ),
            child: const Text('View Active Scheme Pass'),
          ),
          OutlinedButton(
            onPressed: () => context.push(RoutePaths.offers),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.goldPrimary,
              side: const BorderSide(color: AppColors.goldPrimary),
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.border12),
            ),
            child: const Text('Discover Gold Schemes'),
          ),
        ],
      ),
    );
  }
}
