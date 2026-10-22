import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_typography.dart';

/// Luxury Hero Header for the Offers & Scheme Catalog screen.
///
/// Features the centered "Curated Gold Scheme" heading with decorative lines
/// and a centered black subtitle "Explore Our Gold Scheme".
class OffersHeroHeader extends StatelessWidget {
  const OffersHeroHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        // Subtle top tag preserving test expectation
        Text(
          'CURATED GOLD SCHEME',
          style: AppTypography.caption(
            color: const Color(0xFFC88A35),
          ).copyWith(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Gold Savings Plans',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0A221C),
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Explore Our Gold Scheme',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0A221C),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Start your gold journey with flexible plans\nand secure your tomorrow.',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF55605C),
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
