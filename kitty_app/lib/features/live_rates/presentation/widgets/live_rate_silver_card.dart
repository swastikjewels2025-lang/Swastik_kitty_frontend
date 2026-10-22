import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

/// Dedicated Silver Rate Card for the Live Rates screen.
///
/// Pure bullion silver presentation:
/// - 999 Fine Silver banner
/// - Price per 10 Grams and Price per 1 Gram
/// - Strictly NO gold-karat selector
/// - Gracefully handles missing/unavailable silver data
class LiveRateSilverCard extends StatelessWidget {
  const LiveRateSilverCard({
    super.key,
    this.silverRatePerGram,
  });

  final double? silverRatePerGram;

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = silverRatePerGram != null && silverRatePerGram! > 0;
    final double ratePerGram = silverRatePerGram ?? 0.0;
    final double ratePer10g = ratePerGram * 10;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: AppRadius.border16,
        border: Border.all(
          color: AppColors.surfaceCardBorder,
          width: 1.0,
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
          // Top Row: Silver Badge + Hallmark Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(AppRadius.radiusPill),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Text(
                        'SILVER 999',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '99.9% Fine Bullion Silver',
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
                      Icons.shield_outlined,
                      size: 11,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'ASSAY 999',
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

          const SizedBox(height: 14),

          // Price Presentation
          if (!isAvailable) ...<Widget>[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Silver market rate temporarily unavailable',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedSlateGray,
                ),
              ),
            ),
          ] else ...<Widget>[
            Row(
              children: <Widget>[
                // Per 10 Grams (Standard Indian Bullion Bar Benchmark)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'PER 10 GRAMS',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppColors.mutedSlateGray,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _currencyFormat.format(ratePer10g),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.espressoCharcoal,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: const Color(0xFFECE7DE),
                ),
                const SizedBox(width: 16),
                // Per 1 Gram
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'PER 1 GRAM',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppColors.mutedSlateGray,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _currencyFormat.format(ratePerGram),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.espressoCharcoal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
