import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../shared/widgets/feedback/kitty_empty_state.dart';
import '../../../../shared/widgets/feedback/kitty_error_state.dart';
import '../../../../shared/widgets/feedback/kitty_shimmer.dart';
import '../../../../shared/widgets/feedback/kitty_skeleton.dart';
import '../providers/notifications_controller.dart';
import '../providers/notifications_state.dart';
import '../widgets/notification_detail_sheet.dart';
import '../widgets/notification_item_tile.dart';

/// In-App Notifications Center Screen for Swastik Jewellers Kitty App.
///
/// Houses transactional notifications, scheme installment alerts, lucky draw updates,
/// and exclusive patron privileges with local read/unread persistence.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final NotificationsState state = ref.watch(notificationsControllerProvider);
    final NotificationsController controller =
        ref.read(notificationsControllerProvider.notifier);
    const bool isDark = false;
    const Color pageBg = AppColors.homeCanvasBg;
    const Color headerBg = AppColors.homeNavbarBg;
    const Color headerBorder = AppColors.homeNavbarBorder;
    const Color titleColor = AppColors.homePrimaryHeading;

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // 1. Luxury Sticky Top Header
            _buildTopNavBar(
              context: context,
              controller: controller,
              unreadCount: state.unreadCount,
              isMarkingAll: state.isMarkingAllAsRead,
              headerBg: headerBg,
              headerBorder: headerBorder,
              titleColor: titleColor,
              isDark: isDark,
            ),

            // 2. Main Notification Feed View
            Expanded(
              child: _buildBody(
                context: context,
                state: state,
                controller: controller,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavBar({
    required BuildContext context,
    required NotificationsController controller,
    required int unreadCount,
    required bool isMarkingAll,
    required Color headerBg,
    required Color headerBorder,
    required Color titleColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: headerBg,
        border: Border(bottom: BorderSide(color: headerBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Back Button Circle
          GestureDetector(
            key: const Key('btn_notifications_back'),
            onTap: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go(RoutePaths.offers);
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppColors.goldSubtle : const Color(0xFF0C2B24),
                shape: BoxShape.circle,
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x1F0C2B24),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: isDark ? AppColors.goldPrimary : Colors.white,
                ),
              ),
            ),
          ),

          // Title
          Text(
            'Notifications',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: titleColor,
              letterSpacing: 0.5,
            ),
          ),

          // Right Action: "Mark all as read"
          if (unreadCount > 0)
            TextButton.icon(
              key: const Key('btn_mark_all_read'),
              onPressed: isMarkingAll ? null : () => controller.markAllAsRead(),
              icon: Icon(
                Icons.done_all_rounded,
                size: 16,
                color: isDark ? AppColors.goldPrimary : const Color(0xFFB45309),
              ),
              label: Text(
                'Mark read',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.goldPrimary : const Color(0xFFB45309),
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            )
          else
            const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required NotificationsState state,
    required NotificationsController controller,
    required bool isDark,
  }) {
    // 1. Loading State
    if (state.isLoading) {
      return _buildLoadingShimmer(isDark);
    }

    // 2. Error State
    if (state.hasError) {
      return Center(
        child: KittyErrorState(
          title: 'Unable to Load Notifications',
          message: state.errorMessage!,
          onRetry: () => controller.loadNotifications(),
          isDarkSurface: isDark,
        ),
      );
    }

    // 3. Empty State
    if (state.isEmpty) {
      return Center(
        child: KittyEmptyState(
          title: 'No Notifications Yet',
          description:
              'You\'re all caught up! Monthly installment alerts, gold rate updates, and lucky draw announcements will appear here.',
          icon: const Icon(
            Icons.notifications_none_rounded,
            size: 34,
            color: AppColors.goldPrimary,
          ),
          isDarkSurface: isDark,
        ),
      );
    }

    // 4. Notifications Feed
    return RefreshIndicator(
      color: AppColors.goldPrimary,
      backgroundColor: isDark ? AppColors.deepEmeraldBase : Colors.white,
      onRefresh: () => controller.refreshNotifications(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space16,
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.notifications.length + 1,
        itemBuilder: (BuildContext ctx, int index) {
          if (index == 0) {
            return _buildHeaderSummary(state.unreadCount, isDark);
          }

          final notification = state.notifications[index - 1];
          return NotificationItemTile(
            key: Key('notif_tile_${notification.id}'),
            notification: notification,
            isDark: isDark,
            onTap: () {
              controller.markAsRead(notification.id);
              NotificationDetailSheet.show(
                context,
                notification: notification,
                isDark: isDark,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeaderSummary(int unreadCount, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Recent Alerts',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.emeraldTextSubtle
                  : AppColors.textSecondaryMuted,
              letterSpacing: 0.4,
            ),
          ),
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: isDark ? AppColors.goldSubtle : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(AppRadius.radiusPill),
                border: Border.all(
                  color: AppColors.goldBorder.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                '$unreadCount unread',
                style: const TextStyle(
                  color: AppColors.goldPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer(bool isDark) {
    return KittyShimmer(
      isDarkSurface: isDark,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space16,
        ),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        itemBuilder: (BuildContext context, int index) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.space12),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.space16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.emeraldCard : Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.radius14),
              border: Border.all(
                color: isDark
                    ? AppColors.emeraldBorder
                    : AppColors.surfaceCardBorder,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                KittySkeletonBox(
                  width: 42,
                  height: 42,
                  borderRadius: BorderRadius.circular(21),
                  isDarkSurface: isDark,
                ),
                const SizedBox(width: AppSpacing.space14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      KittySkeletonBox(
                        width: 80,
                        height: 12,
                        borderRadius: AppRadius.border6,
                        isDarkSurface: isDark,
                      ),
                      const SizedBox(height: 8),
                      KittySkeletonBox(
                        width: double.infinity,
                        height: 16,
                        borderRadius: AppRadius.border6,
                        isDarkSurface: isDark,
                      ),
                      const SizedBox(height: 8),
                      KittySkeletonBox(
                        width: 200,
                        height: 12,
                        borderRadius: AppRadius.border6,
                        isDarkSurface: isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
