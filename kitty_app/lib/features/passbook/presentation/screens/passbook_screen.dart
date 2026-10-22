import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../shared/widgets/feedback/kitty_empty_state.dart';
import '../../../../shared/widgets/feedback/kitty_error_state.dart';
import '../../domain/entities/passbook_entry_entity.dart';
import '../providers/passbook_controller.dart';
import '../providers/passbook_state.dart';
import '../widgets/passbook_cards_list.dart';
import '../widgets/passbook_controls_row.dart';
import '../widgets/passbook_perks_dialog.dart';
import '../widgets/passbook_skeleton_loader.dart';
import '../widgets/passbook_summary_card.dart';
import '../widgets/passbook_timeline_table.dart';

/// Customer 12-Month Installment Passbook & Ledger screen.
///
/// Features layout switcher (Table View vs Card View), 3-pillar summary strip,
/// installment status badges, receipt routing, and Month 12 bonus perks info.
class PassbookScreen extends ConsumerWidget {
  const PassbookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PassbookState state = ref.watch(passbookControllerProvider);
    final PassbookController controller =
        ref.read(passbookControllerProvider.notifier);

    // Show floating error notification if pull-to-refresh fails while ledger is already visible
    ref.listen<PassbookState>(passbookControllerProvider, (previous, next) {
      if (next.status == PassbookStatus.loaded &&
          next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.statusErrorText,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    final bool canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: AppColors.surfacePageBg,
      appBar: canPop
          ? AppBar(
              backgroundColor: AppColors.surfacePageBg,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                color: AppColors.textPrimaryDark,
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                'Passbook & Statements',
                style: AppTypography.cardTitle(
                  color: AppColors.textPrimaryDark,
                ).copyWith(fontSize: 17),
              ),
              centerTitle: true,
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.surfaceCardBorder,
                ),
              ),
            )
          : null,
      body: SafeArea(
        top: !canPop,
        bottom: false,
        child: switch (state.status) {
          PassbookStatus.initial || PassbookStatus.loading =>
            const PassbookSkeletonLoader(),
          PassbookStatus.empty => _buildEmptyView(context, controller),
          PassbookStatus.error =>
            _buildErrorView(context, state.errorMessage, controller),
          PassbookStatus.loaded || PassbookStatus.refreshing =>
            _buildLoadedView(context, state, controller),
        },
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context, PassbookController controller) {
    return RefreshIndicator(
      onRefresh: () => controller.loadPassbook(refresh: true),
      color: AppColors.goldPrimary,
      backgroundColor: AppColors.surfaceCardBg,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
          KittyEmptyState(
            title: 'No Active Passbook Ledger',
            description:
                'Enroll in a Swastik Gold Scheme to view your monthly installment timeline, gold allocations, and tax receipts.',
            icon: const Icon(
              Icons.menu_book_outlined,
              color: AppColors.goldPrimary,
              size: 32,
            ),
            actionLabel: 'EXPLORE SCHEMES',
            onAction: () => context.push(RoutePaths.offers),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    String? errorMessage,
    PassbookController controller,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: KittyErrorState(
          title: 'Unable to Load Passbook',
          message: errorMessage ??
              'Unable to load your passbook ledger. Please check your connection and try again.',
          retryLabel: 'Try Again',
          onRetry: controller.retry,
        ),
      ),
    );
  }

  Widget _buildLoadedView(
    BuildContext context,
    PassbookState state,
    PassbookController controller,
  ) {
    final String chitToken = state.summary?.chitToken ?? '#SW-042';

    return RefreshIndicator(
      onRefresh: () => controller.loadPassbook(refresh: true),
      color: AppColors.goldPrimary,
      backgroundColor: AppColors.surfaceCardBg,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: <Widget>[
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.space12),
          ),

          // Section Title Row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space16,
                vertical: AppSpacing.space4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Passbook Ledger',
                    style: AppTypography.cardTitle(
                      color: AppColors.textPrimaryDark,
                    ).copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '12-Month Timeline',
                    style: AppTypography.labelMeta(
                      color: AppColors.textSecondaryMuted,
                    ).copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.space4),
          ),

          // 1. Controls Row (Chit Badge & View Switcher)
          SliverToBoxAdapter(
            child: PassbookControlsRow(
              chitToken: chitToken,
              currentMode: state.viewMode,
              onModeChanged: controller.setViewMode,
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.space8),
          ),

          // 2. 3-Pillar Summary Strip
          if (state.summary != null)
            SliverToBoxAdapter(
              child: PassbookSummaryCard(summary: state.summary!),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.space8),
          ),

          // 3. Ledger Items (Table View or Card View)
          if (state.viewMode == PassbookViewMode.table)
            SliverToBoxAdapter(
              child: PassbookTimelineTable(
                entries: state.entries,
                onViewReceipt: (PassbookEntryEntity item) {
                  final String receiptId = item.transactionId ?? 'REC-${item.month}';
                  context.push(RoutePaths.receiptWithId(receiptId), extra: item);
                },
                onPayEmi: (PassbookEntryEntity item) {
                  context.push(RoutePaths.checkout);
                },
                onPerksInfo: () => PassbookPerksDialog.show(context),
              ),
            )
          else
            SliverToBoxAdapter(
              child: PassbookCardsList(
                entries: state.entries,
                onViewReceipt: (PassbookEntryEntity item) {
                  final String receiptId = item.transactionId ?? 'REC-${item.month}';
                  context.push(RoutePaths.receiptWithId(receiptId), extra: item);
                },
                onPayEmi: (PassbookEntryEntity item) {
                  context.push(RoutePaths.checkout);
                },
                onPerksInfo: () => PassbookPerksDialog.show(context),
              ),
            ),

          // Bottom Spacing for smooth navigation dock clearance
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.space64),
          ),
        ],
      ),
    );
  }
}
