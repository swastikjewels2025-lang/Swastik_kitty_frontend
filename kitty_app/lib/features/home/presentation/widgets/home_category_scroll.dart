import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/display/kitty_section_header.dart';

/// Category model with icon/image asset mapping.
class CategoryItemData {
  const CategoryItemData({
    required this.name,
    required this.assetImage,
  });

  final String name;
  final String assetImage;
}

/// Horizontal scrollable category pill selector matching the luxury prototype.
class HomeCategoryScroll extends StatelessWidget {
  const HomeCategoryScroll({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.onViewAllTap,
  });

  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback? onViewAllTap;

  static const List<CategoryItemData> defaultCategoryItems = <CategoryItemData>[
    CategoryItemData(name: 'All', assetImage: 'assets/images/cat_necklace.jpg'),
    CategoryItemData(name: 'Rings', assetImage: 'assets/images/prod_solitaire_ring.jpg'),
    CategoryItemData(name: 'Earrings', assetImage: 'assets/images/cat_earrings.jpg'),
    CategoryItemData(name: 'Necklaces', assetImage: 'assets/images/cat_necklace.jpg'),
    CategoryItemData(name: 'Bangles', assetImage: 'assets/images/prod_twisted_bangle.jpg'),
    CategoryItemData(name: 'Bracelets', assetImage: 'assets/images/card_gold_bracelet.png'),
    CategoryItemData(name: 'Pendants', assetImage: 'assets/images/prod_pear_pendant.jpg'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
          child: KittySectionHeader(
            title: 'SHOP BY CATEGORY',
            eyebrow: 'CURATED COLLECTIONS',
            actionLabel: 'View All →',
            onAction: onViewAllTap,
            isDarkSurface: false,
          ),
        ),
        const SizedBox(height: AppSpacing.space12),

        // Horizontal Track
        SizedBox(
          height: 104,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
            scrollDirection: Axis.horizontal,
            itemCount: defaultCategoryItems.length,
            separatorBuilder: (BuildContext context, int index) => const SizedBox(width: AppSpacing.space14),
            itemBuilder: (BuildContext context, int index) {
              final CategoryItemData item = defaultCategoryItems[index];
              final bool isSelected = selectedCategory.toLowerCase() == item.name.toLowerCase();

              return InkWell(
                onTap: () => onCategorySelected(item.name),
                borderRadius: AppRadius.border16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Circular Ring Frame
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 64,
                      height: 64,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? AppColors.homeCategoryRingBg : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? AppColors.homeBrandGold : AppColors.homeCategoryRingBorder,
                          width: isSelected ? 2.0 : 1.2,
                        ),
                        boxShadow: isSelected
                            ? <BoxShadow>[
                                BoxShadow(
                                  color: AppColors.homeBrandGold.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          item.assetImage,
                          cacheWidth: 160,
                          cacheHeight: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                            return Container(
                              color: AppColors.homeCategoryRingBg,
                              child: const Icon(
                                Icons.diamond_outlined,
                                color: AppColors.homeBrandGold,
                                size: 24,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Label Text
                    Text(
                      item.name,
                      style: AppTypography.labelMeta(
                        color: isSelected ? AppColors.homeBrandGold : AppColors.homePrimaryHeading,
                      ).copyWith(
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
