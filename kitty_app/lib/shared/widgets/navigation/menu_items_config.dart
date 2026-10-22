import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../features/coin_rates/presentation/screens/coin_rates_screen.dart';

/// Representation of a unified navigation menu item.
class AppNavMenuItem {
  const AppNavMenuItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.routePath,
    this.extra,
    this.badgeText,
    this.badgeColor,
    this.isDestructive = false,
    this.isDividerBefore = false,
  });

  final String id;
  final String title;
  final IconData icon;
  final String routePath;
  final Object? extra;
  final String? badgeText;
  final Color? badgeColor;
  final bool isDestructive;
  final bool isDividerBefore;
}

/// Representation of an approved category in the luxury navigation drawer.
class AppNavCategory {
  const AppNavCategory({
    required this.categoryName,
    required this.items,
  });

  final String categoryName;
  final List<AppNavMenuItem> items;
}

/// Central catalog of application drawer and menu destinations organized by approved categories:
/// 1. KITTY & SAVINGS
/// 2. BULLION
/// 3. ACCOUNT & COMPLIANCE
/// 4. CONCIERGE
abstract final class AppNavMenuConfig {
  static List<AppNavCategory> getCategories({int unreadNotificationsCount = 0}) {
    return <AppNavCategory>[
      const AppNavCategory(
        categoryName: 'KITTY & SAVINGS',
        items: <AppNavMenuItem>[
          AppNavMenuItem(
            id: 'my_kitty',
            title: 'My Kitty',
            icon: Icons.workspace_premium_outlined,
            routePath: RoutePaths.dashboard,
          ),
          AppNavMenuItem(
            id: 'kitty_plans',
            title: 'Kitty Plans',
            icon: Icons.card_giftcard_outlined,
            routePath: RoutePaths.offers,
            badgeText: 'Special',
            badgeColor: AppColors.honeyGoldAccent,
          ),
          AppNavMenuItem(
            id: 'passbook',
            title: 'Savings Passbook',
            icon: Icons.menu_book_outlined,
            routePath: RoutePaths.passbook,
          ),
        ],
      ),
      const AppNavCategory(
        categoryName: 'BULLION',
        items: <AppNavMenuItem>[
          AppNavMenuItem(
            id: 'gold_coins',
            title: 'Gold Coins',
            icon: Icons.monetization_on_outlined,
            routePath: RoutePaths.coinRates,
            extra: CoinMetal.gold,
            badgeText: '24K / 22K',
            badgeColor: AppColors.honeyGoldAccent,
          ),
          AppNavMenuItem(
            id: 'silver_coins',
            title: 'Silver Coins',
            icon: Icons.shield_outlined,
            routePath: RoutePaths.coinRates,
            extra: CoinMetal.silver,
            badgeText: '999 Fine',
            badgeColor: AppColors.honeyGoldAccent,
          ),
        ],
      ),
      AppNavCategory(
        categoryName: 'ACCOUNT & COMPLIANCE',
        items: <AppNavMenuItem>[
          const AppNavMenuItem(
            id: 'profile',
            title: 'Profile',
            icon: Icons.person_outline_rounded,
            routePath: RoutePaths.settings,
          ),
          const AppNavMenuItem(
            id: 'kyc',
            title: 'KYC Compliance',
            icon: Icons.verified_user_outlined,
            routePath: RoutePaths.kyc,
          ),
          const AppNavMenuItem(
            id: 'orders',
            title: 'Orders & Bookings',
            icon: Icons.shopping_bag_outlined,
            routePath: RoutePaths.orders,
          ),
          const AppNavMenuItem(
            id: 'settings',
            title: 'Settings & Security',
            icon: Icons.settings_outlined,
            routePath: RoutePaths.settings,
          ),
          AppNavMenuItem(
            id: 'notifications',
            title: 'Notifications',
            icon: Icons.notifications_outlined,
            routePath: RoutePaths.notifications,
            badgeText: unreadNotificationsCount > 0 ? '$unreadNotificationsCount' : null,
            badgeColor: AppColors.honeyGoldAccent,
          ),
        ],
      ),
      const AppNavCategory(
        categoryName: 'CONCIERGE',
        items: <AppNavMenuItem>[
          AppNavMenuItem(
            id: 'concierge',
            title: 'Concierge & Support',
            icon: Icons.support_agent_rounded,
            routePath: 'concierge',
          ),
        ],
      ),
    ];
  }

  /// Flat catalog of drawer/menu items for legacy compatibility or flat lists.
  static List<AppNavMenuItem> getPrimaryItems({int unreadNotificationsCount = 0}) {
    final List<AppNavMenuItem> items = getCategories(
      unreadNotificationsCount: unreadNotificationsCount,
    ).expand((AppNavCategory c) => c.items).toList();

    items.add(
      const AppNavMenuItem(
        id: 'logout',
        title: 'Log Out of Account',
        icon: Icons.logout_rounded,
        routePath: RoutePaths.login,
        isDestructive: true,
        isDividerBefore: true,
      ),
    );
    return items;
  }
}
