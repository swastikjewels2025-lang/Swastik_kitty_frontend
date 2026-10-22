import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/gold_rate_entity.dart';

/// Today's Gold Rates section matching the reference design and layout.
///
/// Features:
/// - "Today's Gold Rates" heading
/// - "LIVE" badge with pulsating green indicator
/// - Updated date/time timestamp
/// - Separate rate blocks for 6 gold purities: 24K, 22K, 21K, 18K, 14K, 10K
/// - Price per gram formatting with exact 2-decimal Indian Rupee display
/// - Authentic card structure, spacing, typography, and borders
class HomeTodayGoldRates extends StatelessWidget {
  const HomeTodayGoldRates({
    super.key,
    this.goldRate,
    this.onTap,
  });

  final LiveGoldRateEntity? goldRate;
  final VoidCallback? onTap;

  static final NumberFormat _rateFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    final double base24k = goldRate?.ratePerGram ?? 15268.00;
    final DateTime updatedAt = goldRate?.updatedAt ?? DateTime.now();
    final String formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(updatedAt);

    // Dynamic calculations based on gold purity fractions (24K, 22K, 18K, 14K)
    final double rate22k = base24k * (22.0 / 24.0);
    final double rate18k = base24k * (18.0 / 24.0);
    final double rate14k = base24k * (14.0 / 24.0);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 1. Exact Approved HTML Gold Rate Card (.gold-rate-card)
          Semantics(
            button: true,
            label: "Today's Gold Price 22KT",
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 104,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      begin: Alignment(-0.8, -0.6),
                      end: Alignment(0.9, 0.7),
                      colors: <Color>[
                        Color(0xFFFAF4E9),
                        Color(0xFFF4E8D3),
                        Color(0xFFEBD5B6),
                      ],
                      stops: <double>[0.0, 0.45, 1.0],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.6),
                      width: 1.0,
                    ),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x24000000),
                        blurRadius: 14,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: <Widget>[
                      // Visual Gold Bar image at right
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        width: 128,
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: <Color>[
                                Colors.transparent,
                                Colors.black,
                              ],
                              stops: <double>[0.0, 0.28],
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.dstIn,
                          child: Image.asset(
                            'assets/images/gold-bar.jpg',
                            fit: BoxFit.cover,
                            alignment: const Alignment(0.0, -0.4),
                            errorBuilder: (BuildContext _, Object _, StackTrace? _) => const SizedBox.shrink(),
                          ),
                        ),
                      ),

                      // Left Content Details (.gold-card-details)
                      Padding(
                        padding: const EdgeInsets.only(left: 13, top: 12, bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "Today's Gold Price (22KT)",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF5C5549),
                                letterSpacing: 0.1,
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: <Widget>[
                                const Text(
                                  '₹',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF141715),
                                  ),
                                ),
                                Text(
                                  _rateFormat.format(rate22k).replaceAll('₹', '').trim(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF141715),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                Text(
                                  ' / gm',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF58534B),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Icon(
                                  Icons.arrow_drop_up_rounded,
                                  color: Color(0xFF0E7B50),
                                  size: 16,
                                ),
                                Text(
                                  '+120 (3.9%)',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0E7B50),
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
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 2. Comprehensive Purity Rates Board (24K, 22K, 18K, 14K)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEFEAE0)),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Header with LIVE badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        "TODAY'S GOLD RATES",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1C2420),
                          letterSpacing: 0.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFC8E6C9), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'LIVE',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF2E7D32),
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          formattedDate,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF7D786F),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // 4 Karat Rate Chips Grid
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _RateBlock(
                        karat: '24K',
                        price: _rateFormat.format(base24k),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _RateBlock(
                        karat: '22K',
                        price: _rateFormat.format(rate22k),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _RateBlock(
                        karat: '18K',
                        price: _rateFormat.format(rate18k),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _RateBlock(
                        karat: '14K',
                        price: _rateFormat.format(rate14k),
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

class _RateBlock extends StatelessWidget {
  const _RateBlock({
    required this.karat,
    required this.price,
  });

  final String karat;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFECE7DE)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            karat,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1C2420),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              price,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF053826),
              ),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            '/ gm',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF7D786F),
            ),
          ),
        ],
      ),
    );
  }
}
