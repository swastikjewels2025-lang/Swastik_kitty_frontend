import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

/// Individual Karat Rate Card for the dedicated Live Rates screen.
///
/// Features:
/// - Karat badge (24K, 22K, 18K, 14K)
/// - Purity description (e.g. 99.9% Pure Gold)
/// - Exact 2-decimal Indian Rupee price per gram
/// - Optional rate change delta indicator (▲ / ▼)
/// - Authentic luxury styling matching Phase 2 tokens
class LiveRateKaratCard extends StatelessWidget {
  const LiveRateKaratCard({
    super.key,
    required this.karat,
    required this.purityLabel,
    required this.ratePerGram,
    this.changeRupees,
    this.changePct,
    this.isUp,
    this.hallmarkBadge = 'BIS 999',
    this.isFeatured = false,
  });

  final String karat;
  final String purityLabel;
  final double ratePerGram;
  final double? changeRupees;
  final double? changePct;
  final bool? isUp;
  final String hallmarkBadge;
  final bool isFeatured;

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    final String formattedPrice = _currencyFormat.format(ratePerGram);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: AppRadius.border16,
        border: Border.all(
          color: isFeatured
              ? AppColors.honeyGoldAccent.withValues(alpha: 0.5)
              : AppColors.surfaceCardBorder,
          width: isFeatured ? 1.5 : 1.0,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0A063D2E),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Top Row: Karat Badge + Hallmark Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isFeatured
                            ? AppColors.primaryEmerald
                            : const Color(0xFFFBF9F5),
                        borderRadius: BorderRadius.circular(AppRadius.radiusPill),
                        border: Border.all(
                          color: isFeatured
                              ? AppColors.primaryEmerald
                              : const Color(0xFFECE7DE),
                        ),
                      ),
                      child: Text(
                        karat,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isFeatured ? Colors.white : AppColors.deepForestCharcoal,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        purityLabel,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mutedSlateGray,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF9F5),
                  borderRadius: BorderRadius.circular(AppRadius.radiusPill),
                  border: Border.all(color: const Color(0xFFECE7DE)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(
                      Icons.verified_rounded,
                      size: 11,
                      color: Color(0xFF059669),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      hallmarkBadge,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepForestCharcoal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Price & Movement Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Text(
                    formattedPrice,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.espressoCharcoal,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '/ GRAM',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mutedSlateGray,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),

              // Movement indicator if available
              if (changeRupees != null && changeRupees != 0.0) ...<Widget>[
                Builder(
                  builder: (context) {
                    final bool positive = (isUp ?? (changeRupees! >= 0));
                    final Color deltaColor =
                        positive ? const Color(0xFF2E7D32) : const Color(0xFFB71C1C);
                    final String arrow = positive ? '▲' : '▼';
                    final String changeText =
                        '$arrow ₹${changeRupees!.abs().toStringAsFixed(2)}';

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: positive
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(AppRadius.radiusPill),
                      ),
                      child: Text(
                        changeText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: deltaColor,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
