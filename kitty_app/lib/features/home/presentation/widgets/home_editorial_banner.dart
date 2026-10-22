import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';

/// Editorial luxury collection campaign banner ("The Everyday Gold Edit").
class HomeEditorialBanner extends StatelessWidget {
  const HomeEditorialBanner({
    super.key,
    required this.onExploreTap,
  });

  final VoidCallback onExploreTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space10,
      ),
      height: 210,
      decoration: BoxDecoration(
        borderRadius: AppRadius.border20,
        border: Border.all(
          color: AppColors.goldBorder.withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x38000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.border20,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // Campaign Background Image
            Image.asset(
              'assets/images/campaign_emerald_necklace.jpg',
              cacheWidth: 800,
              fit: BoxFit.cover,
              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                return Container(
                  color: AppColors.deepEmeraldBase,
                  child: const Center(
                    child: Icon(
                      Icons.diamond_outlined,
                      color: AppColors.goldPrimary,
                      size: 48,
                    ),
                  ),
                );
              },
            ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.88),
                  ],
                  stops: const <double>[0.1, 0.4, 1.0],
                ),
              ),
            ),

            // Text and CTA Box
            Padding(
              padding: const EdgeInsets.all(AppSpacing.space16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: const BoxDecoration(
                      color: AppColors.champagneFoil,
                      borderRadius: AppRadius.border6,
                    ),
                    child: Text(
                      'EXCLUSIVE EDIT',
                      style: AppTypography.labelMeta(
                        color: AppColors.deepUmberBronze,
                      ).copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Headline
                  Text(
                    'The Everyday Gold Edit',
                    style: AppTypography.heroTitle(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Subtitle
                  Text(
                    'Handcrafted 22K daily-wear essentials crafted for eternal elegance.',
                    style: AppTypography.bodySmall(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // CTA Button
                  InkWell(
                    onTap: onExploreTap,
                    borderRadius: AppRadius.border10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: const BoxDecoration(
                        color: AppColors.honeyGoldAccent,
                        borderRadius: AppRadius.border10,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'EXPLORE COLLECTION',
                            style: AppTypography.labelMeta(
                              color: AppColors.deepUmberBronze,
                            ).copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: AppColors.deepUmberBronze,
                          ),
                        ],
                      ),
                    ),
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
