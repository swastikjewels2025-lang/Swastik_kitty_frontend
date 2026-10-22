import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/feedback/kitty_empty_state.dart';
import '../../../home/domain/entities/product_entity.dart';

/// 2-Column Jewellery Catalog Grid with Category Chips and Wishlist actions.
///
/// Matches `.curated-products-grid` in `home.html`.
class OffersCatalogGrid extends StatelessWidget {
  const OffersCatalogGrid({
    super.key,
    required this.products,
    required this.categories,
    required this.selectedCategory,
    required this.wishlistedProductIds,
    required this.onCategorySelected,
    required this.onWishlistTap,
    required this.onProductTap,
  });

  final List<ProductEntity> products;
  final List<String> categories;
  final String selectedCategory;
  final Set<String> wishlistedProductIds;
  final ValueChanged<String> onCategorySelected;
  final ValueChanged<String> onWishlistTap;
  final ValueChanged<ProductEntity> onProductTap;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: <Widget>[
        // Category Chips Bar
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: categories.map((String category) {
                    final bool isSelected =
                        selectedCategory.toLowerCase() == category.toLowerCase();
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.space8),
                      child: GestureDetector(
                        onTap: () => onCategorySelected(category),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? AppColors.deepEmeraldBase : Colors.white,
                            borderRadius: AppRadius.borderPill,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.deepEmeraldBase
                                  : const Color(0xFFE2E8F0),
                              width: 1,
                            ),
                            boxShadow: isSelected
                                ? <BoxShadow>[
                                    BoxShadow(
                                      color: AppColors.deepEmeraldBase
                                          .withValues(alpha: 0.2),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            category,
                            style: AppTypography.bodySmall(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondaryMuted,
                            ).copyWith(
                              fontWeight:
                                  isSelected ? FontWeight.w700 : FontWeight.w600,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.space16),
            ],
          ),
        ),

        // Product Grid or Empty
        if (products.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space32),
              child: KittyEmptyState(
                title: 'No products available',
                description: 'No jewellery found in $selectedCategory.',
              ),
            ),
          )
        else
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 14,
              childAspectRatio: 0.68,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final ProductEntity product = products[index];
                final bool isWishlisted =
                    wishlistedProductIds.contains(product.id);
                return _ProductGridCard(
                  product: product,
                  isWishlisted: isWishlisted,
                  onWishlistTap: () => onWishlistTap(product.id),
                  onTap: () => onProductTap(product),
                );
              },
              childCount: products.length,
            ),
          ),
      ],
    );
  }
}

class _ProductGridCard extends StatelessWidget {
  const _ProductGridCard({
    required this.product,
    required this.isWishlisted,
    required this.onWishlistTap,
    required this.onTap,
  });

  final ProductEntity product;
  final bool isWishlisted;
  final VoidCallback onWishlistTap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.border16,
          border: Border.all(
            color: const Color(0xFFEBECEF),
            width: 1,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF0C2B24).withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Image Stack
            Expanded(
              child: Stack(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: const Color(0xFFF8F9FA),
                      child: Image.asset(
                        product.imageUrl,
                        cacheWidth: 360,
                        cacheHeight: 360,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFF1F5F9),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.diamond_outlined,
                              color: AppColors.goldPrimary,
                              size: 32,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Wishlist Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onWishlistTap,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.92),
                          border: Border.all(
                            color: const Color(0xFFEBECEF),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          isWishlisted
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isWishlisted
                              ? const Color(0xFFE11D48)
                              : AppColors.textSecondaryMuted,
                          size: 16,
                        ),
                      ),
                    ),
                  ),

                  // Making discount chip
                  if (product.makingDiscountPct > 0)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.deepEmeraldBase,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${product.makingDiscountPct.toInt()}% OFF MAKING',
                          style: const TextStyle(
                            color: AppColors.goldPrimary,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content Info Box
            Padding(
              padding: const EdgeInsets.all(AppSpacing.space10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.cardTitle(
                      color: AppColors.textPrimaryDark,
                    ).copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${product.purity} • ${product.weightGrams}g',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall(
                      color: AppColors.textSecondaryMuted,
                    ).copyWith(
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        CurrencyFormatter.formatRupees(
                            product.estimatedPrice),
                        style: AppTypography.bodySmall(
                          color: AppColors.emeraldPrimary,
                        ).copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.goldPrimary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'View',
                          style: TextStyle(
                            color: AppColors.goldPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
