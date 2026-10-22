import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../shared/screens/route_placeholder_screen.dart';

/// Placeholder screen for Passbook tab (Phase 9).
class PassbookPlaceholderScreen extends StatelessWidget {
  const PassbookPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoutePlaceholderScreen(
      title: 'Passbook Ledger',
      phase: 'Phase 9: Passbook',
      routePath: RoutePaths.passbook,
      subtitle: '12-month installment timeline table, PRE_JOIN status nodes, 100% jeweler bonus badges, and digital tax receipts.',
      icon: Icons.menu_book_outlined,
      actionButton: ElevatedButton(
        onPressed: () => context.push(RoutePaths.receiptWithId('REC-10821')),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldPrimary,
          foregroundColor: AppColors.deepEmeraldBase,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.border12),
        ),
        child: const Text('View Sample Digital Receipt (#10821)'),
      ),
    );
  }
}
