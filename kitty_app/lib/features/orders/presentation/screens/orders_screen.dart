import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../shared/widgets/navigation/kitty_hamburger_button.dart';
import '../../domain/entities/order_booking_entity.dart';
import '../providers/orders_controller.dart';

/// Screen displaying the patron's order and booking history.
///
/// If the patron has no orders or bookings yet, displays an elegant, simple empty state:
/// "You haven’t booked or ordered anything yet." with a "Continue Shopping" button
/// redirecting to the Home page.
/// Once an order/booking is placed, displays the actual order and booking cards.
class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  int _selectedTabIndex = 0;

  static const List<String> _tabs = <String>[
    'All Bookings',
    'Coins',
    'Jewellery',
    'Gold Schemes',
  ];

  @override
  Widget build(BuildContext context) {
    final List<OrderBookingEntity> orders = ref.watch(ordersControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.homeCanvasBg,
      appBar: AppBar(
        backgroundColor: AppColors.creamIvoryCard,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppColors.espressoCharcoal,
          tooltip: 'Back',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RoutePaths.offers);
            }
          },
        ),
        title: Text(
          'My Bookings',
          style: AppTypography.cardTitle(
            color: AppColors.espressoCharcoal,
          ).copyWith(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        actions: const <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: KittyHamburgerButton(isLightSurface: true),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.warmLinenInset,
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: orders.isEmpty
            ? _buildEmptyState(context)
            : _buildOrdersContent(context, orders),
      ),
    );
  }

  /// Clean, minimal empty state per specification:
  /// "You haven’t booked or ordered anything yet."
  /// with "Continue Shopping" button redirecting to Home.
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space24,
          vertical: AppSpacing.space32,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Elegant Emblem
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.champagneFoil,
                border: Border.all(
                  color: AppColors.honeyGoldAccent.withValues(alpha: 0.40),
                  width: 1.5,
                ),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x0A063D2E),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 38,
                color: AppColors.honeyGoldAccent,
              ),
            ),

            const SizedBox(height: AppSpacing.space24),

            // Simple Empty State Message
            Text(
              "You haven't booked anything yet.",
              textAlign: TextAlign.center,
              style: AppTypography.cardTitle(
                color: AppColors.espressoCharcoal,
              ).copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
            ),

            const SizedBox(height: AppSpacing.space24),

            // Continue Shopping CTA Button
            SizedBox(
              width: 200,
              height: AppDimensions.primaryButtonHeight,
              child: Semantics(
                button: true,
                label: 'Continue Shopping',
                child: ElevatedButton(
                  key: const Key('orders_continue_shopping_btn'),
                  onPressed: () => context.go(RoutePaths.offers),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryEmerald,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.border12,
                    ),
                  ),
                  child: const Text(
                    'Continue Shopping',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Rendered list of actual user orders & bookings.
  Widget _buildOrdersContent(
    BuildContext context,
    List<OrderBookingEntity> orders,
  ) {
    final List<OrderBookingEntity> filteredOrders = _filterOrders(orders);

    return Column(
      children: <Widget>[
        // Filter Tabs
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: AppColors.creamIvoryCard,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List<Widget>.generate(_tabs.length, (int index) {
                final bool isSelected = _selectedTabIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                    },
                    borderRadius: AppRadius.border12,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryEmerald
                            : AppColors.warmPearl,
                        borderRadius: AppRadius.border12,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryEmerald
                              : AppColors.surfaceCardBorder,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _tabs[index],
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppColors.deepForestCharcoal,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),

        const Divider(height: 1, color: AppColors.warmLinenInset),

        // Orders List
        Expanded(
          child: filteredOrders.isEmpty
              ? Center(
                  child: Text(
                    'No ${_tabs[_selectedTabIndex]} found.',
                    style: AppTypography.bodySmall(
                      color: AppColors.warmTaupeBrown,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.space16),
                  itemCount: filteredOrders.length,
                  separatorBuilder: (BuildContext _, int index) =>
                      const SizedBox(height: AppSpacing.space12),
                  itemBuilder: (BuildContext ctx, int index) {
                    final OrderBookingEntity item = filteredOrders[index];
                    return _buildOrderCard(context, item);
                  },
                ),
        ),
      ],
    );
  }

  List<OrderBookingEntity> _filterOrders(List<OrderBookingEntity> orders) {
    if (_selectedTabIndex == 0) return orders;
    if (_selectedTabIndex == 1) {
      return orders
          .where((o) => o.category == OrderCategory.coins)
          .toList();
    }
    if (_selectedTabIndex == 2) {
      return orders
          .where((o) => o.category == OrderCategory.jewellery)
          .toList();
    }
    if (_selectedTabIndex == 3) {
      return orders
          .where((o) => o.category == OrderCategory.schemes)
          .toList();
    }
    return orders;
  }

  Widget _buildOrderCard(BuildContext context, OrderBookingEntity item) {
    return Container(
      padding: AppSpacing.all16,
      decoration: BoxDecoration(
        color: AppColors.creamIvoryCard,
        borderRadius: AppRadius.border16,
        border: Border.all(color: AppColors.surfaceCardBorder),
        boxShadow: AppShadows.cardSubtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header Row: ID and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                item.id,
                style: AppTypography.kickerCaps(
                  color: AppColors.honeyGoldAccent,
                ).copyWith(fontWeight: FontWeight.w700, fontSize: 11),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0x18063D2E),
                  borderRadius: AppRadius.border12,
                  border: Border.all(
                    color: AppColors.primaryEmerald.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  item.status,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryEmerald,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Title & Description
          Text(
            item.title,
            style: AppTypography.cardTitle(
              color: AppColors.espressoCharcoal,
            ).copyWith(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 3),
          Text(
            item.description,
            style: AppTypography.bodySmall(
              color: AppColors.warmTaupeBrown,
            ).copyWith(fontSize: 12),
          ),

          const SizedBox(height: 12),

          // Footer: Amount and Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                item.formattedAmount,
                style: AppTypography.bodyBold(
                  color: AppColors.primaryEmerald,
                ).copyWith(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Swastik Concierge: 1800-SWASTIK'),
                      backgroundColor: AppColors.espressoCharcoal,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.headset_mic_outlined, size: 14),
                label: const Text('Support'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.honeyGoldAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  textStyle: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
