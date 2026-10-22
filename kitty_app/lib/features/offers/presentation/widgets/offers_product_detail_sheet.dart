import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/buttons/kitty_primary_button.dart';
import '../../../home/domain/entities/product_entity.dart';

/// Modal bottom sheet showcasing detailed product specifications and showroom enquiry.
class OffersProductDetailSheet extends StatelessWidget {
  const OffersProductDetailSheet({
    super.key,
    required this.product,
    required this.isWishlisted,
    required this.onWishlistToggle,
  });

  final ProductEntity product;
  final bool isWishlisted;
  final VoidCallback onWishlistToggle;

  static Future<void> show(
    BuildContext context, {
    required ProductEntity product,
    required bool isWishlisted,
    required VoidCallback onWishlistToggle,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) => OffersProductDetailSheet(
        product: product,
        isWishlisted: isWishlisted,
        onWishlistToggle: onWishlistToggle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceCardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Top Drag Handle & Close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary.withValues(alpha: 0.12),
                      borderRadius: AppRadius.borderPill,
                    ),
                    child: Text(
                      product.category.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.goldPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textSecondaryMuted),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space14),

              // Product Image Hero
              ClipRRect(
                borderRadius: AppRadius.border20,
                child: Container(
                  width: double.infinity,
                  height: 220,
                  color: const Color(0xFFF1F5F9),
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: Image.asset(
                          product.imageUrl,
                          cacheWidth: 600,
                          cacheHeight: 600,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFF1F5F9),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.diamond_outlined,
                                color: AppColors.goldPrimary,
                                size: 48,
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: onWishlistToggle,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.95),
                              boxShadow: const <BoxShadow>[
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: isWishlisted ? const Color(0xFFE11D48) : AppColors.textSecondaryMuted,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space16),

              // Title and Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      product.title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    CurrencyFormatter.formatRupees(product.estimatedPrice),
                    style: AppTypography.cardTitle(color: AppColors.emeraldPrimary).copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space8),

              // Specifications Pill Strip
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _buildSpecPill('Purity', product.purity),
                  _buildSpecPill('Weight', '${product.weightGrams} g'),
                  if (product.makingDiscountPct > 0)
                    _buildSpecPill('Scheme Perk', '${product.makingDiscountPct.toInt()}% Off Making'),
                ],
              ),
              const SizedBox(height: AppSpacing.space16),

              // Kitty Member Benefit Box
              Container(
                padding: const EdgeInsets.all(AppSpacing.space12),
                decoration: BoxDecoration(
                  color: const Color(0xFF061F18),
                  borderRadius: AppRadius.border12,
                  border: Border.all(
                    color: AppColors.goldPrimary.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.card_giftcard_rounded, color: AppColors.goldPrimary, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Redeemable with your Swastik Gold Scheme balance at 0% making charges upon maturity.',
                        style: AppTypography.bodySmall(color: const Color(0xFFFDE68A)).copyWith(
                          fontSize: 11.5,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space20),

              // Showroom Enquiry CTA (Strictly No Checkout/Payment)
              SizedBox(
                width: double.infinity,
                child: KittyPrimaryButton(
                  label: 'Enquire at Showroom',
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.deepEmeraldBase,
                        content: Text(
                          'Showroom concierge notified for ${product.title}. Our jewelry advisor will assist you.',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecPill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        '$label: $value',
        style: AppTypography.bodySmall(color: AppColors.textPrimaryDark).copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
