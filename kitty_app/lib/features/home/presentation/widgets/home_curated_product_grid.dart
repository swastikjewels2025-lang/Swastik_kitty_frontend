import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/display/kitty_section_header.dart';
import '../../domain/entities/product_entity.dart';

/// 2-Column luxury jewellery product showcase matching the approved prototype.
class HomeCuratedProductGrid extends StatefulWidget {
  const HomeCuratedProductGrid({
    super.key,
    required this.products,
    required this.onProductTap,
    this.onViewAllTap,
  });

  final List<ProductEntity> products;
  final ValueChanged<ProductEntity> onProductTap;
  final VoidCallback? onViewAllTap;

  @override
  State<HomeCuratedProductGrid> createState() => _HomeCuratedProductGridState();
}

class _HomeCuratedProductGridState extends State<HomeCuratedProductGrid> {
  final Set<String> _wishlist = <String>{};

  static const List<Map<String, dynamic>> _fallbackProducts = <Map<String, dynamic>>[
    <String, dynamic>{
      'id': 'p1',
      'title': 'Aaradhya Diamond Solitaire',
      'purity': '18K Yellow Gold • VVS Diamond',
      'price': 48250,
      'asset': 'assets/images/prod_solitaire_ring.jpg',
    },
    <String, dynamic>{
      'id': 'p2',
      'title': 'Ananya Emerald Pear Pendant',
      'purity': '22K Hallmark Gold • Zambian Emerald',
      'price': 36800,
      'asset': 'assets/images/prod_pear_pendant.jpg',
    },
    <String, dynamic>{
      'id': 'p3',
      'title': 'Mayuri Royal Polki Jhumkas',
      'purity': '22K Handcrafted Kundan & Pearls',
      'price': 64500,
      'asset': 'assets/images/cat_earrings.jpg',
    },
    <String, dynamic>{
      'id': 'p4',
      'title': 'Aditi Twisted Heritage Kada',
      'purity': '22K Pure Hallmark Yellow Gold',
      'price': 52900,
      'asset': 'assets/images/prod_twisted_bangle.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final bool hasLiveProducts = widget.products.isNotEmpty;
    final int count = hasLiveProducts ? widget.products.length : _fallbackProducts.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
          child: KittySectionHeader(
            title: 'CURATED FOR YOU',
            eyebrow: 'HANDCRAFTED LUXURY',
            actionLabel: 'View All →',
            onAction: widget.onViewAllTap,
            isDarkSurface: false,
          ),
        ),
        const SizedBox(height: AppSpacing.space12),

        // Grid (2 Columns)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double itemWidth = (constraints.maxWidth - AppSpacing.space12) / 2;

              return Wrap(
                spacing: AppSpacing.space12,
                runSpacing: AppSpacing.space14,
                children: List<Widget>.generate(count, (int index) {
                  final ProductEntity? product = hasLiveProducts ? widget.products[index] : null;
                  final Map<String, dynamic> fallback = _fallbackProducts[index % _fallbackProducts.length];

                  final String id = product?.id ?? fallback['id'] as String;
                  final String title = product?.title ?? fallback['title'] as String;
                  final String purity = product != null
                      ? '${product.purity} • ${product.weightGrams}g'
                      : fallback['purity'] as String;
                  final int price = product?.estimatedPrice ?? fallback['price'] as int;
                  String assetImage = product?.imageUrl ?? fallback['asset'] as String;
                  if (!assetImage.startsWith('assets/images/') && assetImage.startsWith('assets/')) {
                    assetImage = assetImage.replaceFirst('assets/', 'assets/images/');
                  }
                  final String fallbackAsset = fallback['asset'] as String;
                  final bool isWishlisted = _wishlist.contains(id);

                  return SizedBox(
                    width: itemWidth,
                    child: _buildProductCard(
                      id: id,
                      title: title,
                      purity: purity,
                      price: price,
                      assetImage: assetImage,
                      fallbackAsset: fallbackAsset,
                      isWishlisted: isWishlisted,
                      onTap: () {
                        if (product != null) {
                          widget.onProductTap(product);
                        } else if (widget.onViewAllTap != null) {
                          widget.onViewAllTap!();
                        }
                      },
                      onWishlistToggle: () {
                        setState(() {
                          if (isWishlisted) {
                            _wishlist.remove(id);
                          } else {
                            _wishlist.add(id);
                          }
                        });
                      },
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard({
    required String id,
    required String title,
    required String purity,
    required int price,
    required String assetImage,
    required String fallbackAsset,
    required bool isWishlisted,
    required VoidCallback onTap,
    required VoidCallback onWishlistToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.homeNavbarBg,
        borderRadius: AppRadius.border16,
        border: Border.all(
          color: AppColors.homeProductCardBorder,
          width: 1,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0A0C2B24),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Image Container + Floating Wishlist Heart
          Stack(
            children: <Widget>[
              Container(
                height: 112,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.warmLinenInset,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.radius16),
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: Center(
                  child: ClipRRect(
                    borderRadius: AppRadius.border10,
                    child: Image.asset(
                      assetImage,
                      cacheWidth: 320,
                      cacheHeight: 320,
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                        return Image.asset(
                          fallbackAsset,
                          cacheWidth: 320,
                          cacheHeight: 320,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Floating Wishlist Heart Button
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onWishlistToggle,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isWishlisted ? AppColors.statusErrorText : AppColors.goldLight,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Info Box
          Padding(
            padding: const EdgeInsets.all(AppSpacing.space10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: AppTypography.bodySmall(
                    color: AppColors.homePrimaryHeading,
                  ).copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  purity,
                  style: AppTypography.labelMeta(
                    color: AppColors.homeBodySubtitle,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Price Row + View Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        CurrencyFormatter.formatRupees(price),
                        style: AppTypography.bodyBold(
                          color: AppColors.homeBrandGold,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: onTap,
                      borderRadius: AppRadius.border6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.homeCategoryRingBg,
                          borderRadius: AppRadius.border6,
                          border: Border.all(
                            color: AppColors.homeCategoryRingBorder,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'View',
                          style: AppTypography.labelMeta(
                            color: AppColors.homeBrandGold,
                          ).copyWith(fontWeight: FontWeight.w700),
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
    );
  }
}
