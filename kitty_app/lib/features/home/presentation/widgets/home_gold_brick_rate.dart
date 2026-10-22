import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/gold_rate_entity.dart';

/// Premium bullion gold-bar inspired live gold rate widget.
///
/// Embodies the Giri Zevar Mehal stamped bullion aesthetic with beveled edges,
/// hallmark crest branding, live benchmark pulse indicator, and dual 24K & 22K per-gram pricing.
class HomeGoldBrickRate extends StatefulWidget {
  const HomeGoldBrickRate({
    super.key,
    this.goldRate,
    this.onTap,
  });

  final LiveGoldRateEntity? goldRate;
  final VoidCallback? onTap;

  @override
  State<HomeGoldBrickRate> createState() => _HomeGoldBrickRateState();
}

class _HomeGoldBrickRateState extends State<HomeGoldBrickRate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (WidgetsBinding.instance is WidgetsFlutterBinding) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double rate24k = widget.goldRate?.ratePerGram ?? 15268.00;
    final double rate22k = rate24k * (22 / 24);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space8,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: AppRadius.border16,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              // Bullion ingot gradient with subtle metallic luster
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Color(0xFFFFF9ED),
                  Color(0xFFF7EED8),
                  Color(0xFFEDE0C0),
                  Color(0xFFF5E9CE),
                ],
                stops: <double>[0.0, 0.35, 0.7, 1.0],
              ),
              borderRadius: AppRadius.border16,
              border: Border.all(
                color: AppColors.honeyGoldAccent.withValues(alpha: 0.55),
                width: 1.4,
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x126E500C),
                  blurRadius: 14,
                  offset: Offset(0, 4),
                ),
                BoxShadow(
                  color: Color(0x08FFFFFF),
                  blurRadius: 2,
                  offset: Offset(0, -1),
                ),
              ],
            ),
            child: Stack(
              children: <Widget>[
                // Subtle bullion watermark corner accent
                const Positioned(
                  right: -6,
                  bottom: -10,
                  child: Opacity(
                    opacity: 0.07,
                    child: Icon(
                      Icons.shield_rounded,
                      size: 96,
                      color: AppColors.deepUmberBronze,
                    ),
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // 1. Top Ingot Header Row: Hallmark Stamp & Live Pulse
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        // Stamped Bullion Seal
                        Row(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.honeyGoldAccent.withValues(alpha: 0.18),
                                border: Border.all(
                                  color: AppColors.honeyGoldAccent.withValues(alpha: 0.5),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.workspace_premium_rounded,
                                size: 14,
                                color: AppColors.deepUmberBronze,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'SWASTIK 999.9 FINE GOLD',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.1,
                                    color: AppColors.deepUmberBronze,
                                  ),
                                ),
                                SizedBox(height: 1),
                                Text(
                                  'GOVT. APPROVED • BIS HALLMARK CERTIFIED',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.4,
                                    color: AppColors.warmTaupeBrown,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Live Benchmark Indicator Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            borderRadius: AppRadius.border12,
                            border: Border.all(
                              color: AppColors.statusSuccessText.withValues(alpha: 0.35),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              FadeTransition(
                                opacity: _pulseAnimation,
                                child: Container(
                                  width: 6.5,
                                  height: 6.5,
                                  decoration: const BoxDecoration(
                                    color: AppColors.statusSuccessText,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                'LIVE',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                  color: AppColors.statusSuccessText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 2. Dual Ingot Rate Tiles (24K Bullion & 22K Jewellery)
                    Row(
                      children: <Widget>[
                        // 24K Ingot Bar
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.85),
                              borderRadius: AppRadius.border10,
                              border: Border.all(
                                color: AppColors.honeyGoldAccent.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      '24K GOLD',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                        color: AppColors.warmTaupeBrown,
                                      ),
                                    ),
                                    DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: AppColors.champagneFoil,
                                        borderRadius: AppRadius.border6,
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        child: Text(
                                          '99.9%',
                                          style: TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.deepUmberBronze,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${CurrencyFormatter.formatRupees(rate24k.round())} /g',
                                  style: const TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.3,
                                    color: AppColors.espressoCharcoal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // 22K Jewellery Gold Bar
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.85),
                              borderRadius: AppRadius.border10,
                              border: Border.all(
                                color: AppColors.honeyGoldAccent.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      '22K GOLD',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                        color: AppColors.warmTaupeBrown,
                                      ),
                                    ),
                                    DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: AppColors.champagneFoil,
                                        borderRadius: AppRadius.border6,
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        child: Text(
                                          '91.6%',
                                          style: TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.deepUmberBronze,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${CurrencyFormatter.formatRupees(rate22k.round())} /g',
                                  style: const TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.3,
                                    color: AppColors.espressoCharcoal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
