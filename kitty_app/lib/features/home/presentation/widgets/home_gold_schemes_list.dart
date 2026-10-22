import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Gold Savings Schemes section matching exact HTML index.html (.gold-schemes-section).
///
/// Features:
/// - "Gold Schemes" Playfair Display header with [View All]
/// - 6M Plan (Popular badge), 9M Plan, 11M Plan cards
/// - 44x44 #FAF2E5 badge, #ECE4D8 borders, 18px radius
/// - #063B2C [Select] action buttons
class HomeGoldSchemesList extends StatelessWidget {
  const HomeGoldSchemesList({
    super.key,
    required this.onSelectPlan,
    required this.onViewAll,
  });

  final ValueChanged<int> onSelectPlan;
  final VoidCallback onViewAll;

  static const List<_SchemeItem> _schemes = <_SchemeItem>[
    _SchemeItem(
      months: 6,
      badgeText: '6M',
      title: '6 Month Plan',
      isPopular: true,
      monthlyText: '₹5,000 / mo • Total ₹30,000',
    ),
    _SchemeItem(
      months: 9,
      badgeText: '9M',
      title: '9 Month Plan',
      isPopular: false,
      monthlyText: '₹5,000 / mo • Total ₹45,000',
    ),
    _SchemeItem(
      months: 11,
      badgeText: '11M',
      title: '11 Month Plan',
      isPopular: false,
      monthlyText: '₹5,000 / mo • Total ₹55,000',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Gold Schemes',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C2420),
                  letterSpacing: -0.1,
                ),
              ),
              InkWell(
                onTap: onViewAll,
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

          const SizedBox(height: 8),

          // Schemes List
          Column(
            children: _schemes.map((_SchemeItem scheme) {
              return Container(
                margin: const EdgeInsets.only(bottom: 11),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFECE4D8),
                    width: 1,
                  ),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x05000000),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onSelectPlan(scheme.months),
                    borderRadius: BorderRadius.circular(18),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          // Left: 44x44 Month Badge + Title/Subtitle
                          Expanded(
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFAF2E5),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFEFE2CF),
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      scheme.badgeText,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF9C5F05),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Flexible(
                                            child: Text(
                                              scheme.title,
                                              style: GoogleFonts.playfairDisplay(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF121A16),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (scheme.isPopular) ...<Widget>[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 7,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF063B2C),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: const Text(
                                                'Popular',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        scheme.monthlyText,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12.5,
                                          color: const Color(0xFF68726E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Right: Select Button
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF063B2C),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Select',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SchemeItem {
  const _SchemeItem({
    required this.months,
    required this.badgeText,
    required this.title,
    required this.isPopular,
    required this.monthlyText,
  });

  final int months;
  final String badgeText;
  final String title;
  final bool isPopular;
  final String monthlyText;
}
