import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../features/menu/presentation/widgets/kitty_menu_sheet.dart';
import '../../../features/notifications/presentation/providers/notifications_controller.dart';

/// Sticky luxury top application header matching the approved Swastik prototype.
///
/// Features the authentic Swastik Jewellers brand crest at the extreme left,
/// notifications bell with unread badge, and the navigation drawer hamburger toggle.
class HeaderNavBar extends StatelessWidget implements PreferredSizeWidget {
  const HeaderNavBar({
    super.key,
    this.onMenuPressed,
    this.unreadNotificationsCount,
    @Deprecated('Gold rate ticker removed from header') this.goldRate24k,
  });

  /// Callback to open the slide-out luxury navigation drawer.
  final VoidCallback? onMenuPressed;

  /// Optional override for unread transactional notifications count.
  final int? unreadNotificationsCount;

  /// Deprecated benchmark rate; header no longer displays ticker pill.
  final double? goldRate24k;

  @override
  Size get preferredSize => const Size.fromHeight(66);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.homeNavbarBg,
        border: Border(
          bottom: BorderSide(
            color: AppColors.homeNavbarBorder,
            width: 1,
          ),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x0D063D2E),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Extreme Left: Authentic Swastik Jewellers Brand Logo
              GestureDetector(
                key: const Key('swastik_header_logo'),
                onTap: () => context.go(RoutePaths.offers),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: SvgPicture.asset(
                    'assets/icons/swastiklogo.svg',
                    height: 38,
                    fit: BoxFit.contain,
                    semanticsLabel: 'Swastik Jewellers',
                  ),
                ),
              ),

              // Right: Notification Bell + Hamburger Navigation Toggle Button
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Tooltip(
                    message: 'Notifications',
                    child: InkWell(
                      onTap: () => context.push(RoutePaths.notifications),
                      borderRadius: AppRadius.border20,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: <Widget>[
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.homeNavbarBg,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.homeNavbarBorder,
                                width: 1,
                              ),
                              boxShadow: const <BoxShadow>[
                                BoxShadow(
                                  color: Color(0x0D063D2E),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.notifications_none_rounded,
                                color: AppColors.homePrimaryHeading,
                                size: 20,
                              ),
                            ),
                          ),
                          Positioned(
                            right: -2,
                            top: -2,
                            child: NotificationBellBadge(unreadCountOverride: unreadNotificationsCount),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space8),
                  Tooltip(
                    message: 'Open Menu',
                    child: InkWell(
                      onTap: onMenuPressed ?? () => openKittyMenu(context),
                      borderRadius: AppRadius.border20,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.homeNavbarBg,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.homeNavbarBorder,
                            width: 1,
                          ),
                          boxShadow: const <BoxShadow>[
                            BoxShadow(
                              color: Color(0x0D063D2E),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.menu_rounded,
                            color: AppColors.homePrimaryHeading,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Isolated notification count badge widget to prevent full app shell rebuilds.
class NotificationBellBadge extends ConsumerWidget {
  const NotificationBellBadge({super.key, this.unreadCountOverride});

  final int? unreadCountOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int count = unreadCountOverride ?? ref.watch(unreadNotificationsCountProvider);
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        color: AppColors.honeyGoldAccent,
        shape: BoxShape.circle,
      ),
      constraints: const BoxConstraints(
        minWidth: 14,
        minHeight: 14,
      ),
      child: Center(
        child: Text(
          '$count',
          style: const TextStyle(
            color: AppColors.deepUmberBronze,
            fontSize: 8.5,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
      ),
    );
  }
}
