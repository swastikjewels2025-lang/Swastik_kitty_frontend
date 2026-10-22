import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_section_heading.dart';

/// Category model representing a circular jewellery category collection.
class JewelleryCategoryItem {
  const JewelleryCategoryItem({
    required this.id,
    required this.name,
    required this.assetImage,
  });

  final String id;
  final String name;
  final String assetImage;
}

/// Editorial circular jewellery collections showcase section for the Home screen.
///
/// Features a centered luxury header and horizontal circular category avatars
/// (Rings, Earrings, Necklaces, Pendants, Bracelets, Bangles) with gold ring borders.
class HomeJewelleryCollections extends StatelessWidget {
  const HomeJewelleryCollections({
    super.key,
    required this.onCategoryTap,
    this.onViewAllTap,
  });

  final ValueChanged<String> onCategoryTap;
  final VoidCallback? onViewAllTap;

  static const List<JewelleryCategoryItem> categories = <JewelleryCategoryItem>[
    JewelleryCategoryItem(
      id: 'rings',
      name: 'Rings',
      assetImage: 'assets/images/ring.jpg',
    ),
    JewelleryCategoryItem(
      id: 'earrings',
      name: 'Earrings',
      assetImage: 'assets/images/earrings.jpg',
    ),
    JewelleryCategoryItem(
      id: 'necklaces',
      name: 'Necklaces',
      assetImage: 'assets/images/necklace.jpg',
    ),
    JewelleryCategoryItem(
      id: 'chains',
      name: 'Chains',
      assetImage: 'assets/images/chain.jpg',
    ),
    JewelleryCategoryItem(
      id: 'gold-coins',
      name: 'Gold Coins',
      assetImage: 'assets/images/gold-coins.jpg',
    ),
    JewelleryCategoryItem(
      id: 'gold-bar',
      name: 'Gold Bar',
      assetImage: 'assets/images/gold-bar.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Luxury Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const HomeSectionHeading(title: 'Curated Masterpieces'),
                  const SizedBox(height: 2),
                  Text(
                    'Explore Our Jewellery',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1C2420),
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
              if (onViewAllTap != null)
                InkWell(
                  onTap: onViewAllTap,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      'View All',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0A6B48),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Horizontal Scroll of Collections (.collections-carousel)
        SizedBox(
          height: 108,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(width: 10),
            itemBuilder: (BuildContext context, int index) {
              final JewelleryCategoryItem category = categories[index];

              return InkWell(
                onTap: () => onCategoryTap(category.name),
                borderRadius: BorderRadius.circular(11),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // 76x76 Collection Image Wrapper (.collection-image-wrapper)
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8EFE3),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: const Color(0xFFECE1D1),
                          width: 1,
                        ),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        category.assetImage,
                        fit: BoxFit.cover,
                        errorBuilder: (
                          BuildContext context,
                          Object error,
                          StackTrace? stackTrace,
                        ) {
                          return const Center(
                            child: Icon(
                              Icons.diamond_outlined,
                              color: Color(0xFF9A7342),
                              size: 26,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Collection Label (.collection-label)
                    Text(
                      category.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF3C3630),
                      ),
                      textAlign: TextAlign.center,
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
