import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';

/// Navigation item model for the 4 primary tabs.
class _DdddNavItem {
  const _DdddNavItem({
    required this.label,
    required this.activeSvg,
    required this.inactiveSvg,
    this.tintActive = false,
  });

  final String label;
  final String activeSvg;
  final String inactiveSvg;
  final bool tintActive;
}

/// Approved 4-Tab Bottom Navigation Bar matching Kitty luxury visual language.
///
/// Exactly 4 canonical tabs:
/// 1. Gold Plans (`assets/icons/plans-active.svg` / `assets/icons/plans-nav.svg`)
/// 2. My Plan (`assets/icons/my-plan-nav.svg`)
/// 3. Instagram (`assets/icons/instagram.svg`)
/// 4. Jewellery (`assets/icons/jewellery-nav.svg`)
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<_DdddNavItem> _items = <_DdddNavItem>[
    _DdddNavItem(
      label: 'Gold Plans',
      activeSvg: 'assets/icons/plans-active.svg',
      inactiveSvg: 'assets/icons/plans-nav.svg',
    ),
    _DdddNavItem(
      label: 'My Plan',
      activeSvg: 'assets/icons/my-plan-nav.svg',
      inactiveSvg: 'assets/icons/my-plan-nav.svg',
      tintActive: true,
    ),
    _DdddNavItem(
      label: 'Instagram',
      activeSvg: 'assets/icons/instagram.svg',
      inactiveSvg: 'assets/icons/instagram.svg',
      tintActive: true,
    ),
    _DdddNavItem(
      label: 'Jewellery',
      activeSvg: 'assets/icons/jewellery-nav.svg',
      inactiveSvg: 'assets/icons/jewellery-nav.svg',
      tintActive: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(
          top: BorderSide(
            color: Color(0xFFEFEAE0),
            width: 1.0,
          ),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 54,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List<Widget>.generate(
              _items.length,
              (int index) {
                final _DdddNavItem item = _items[index];
                final bool isActive = currentIndex == index;

                return Expanded(
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onTap(index);
                    },
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: Center(
                            child: SvgPicture.asset(
                              isActive ? item.activeSvg : item.inactiveSvg,
                              width: 22,
                              height: 22,
                              colorFilter: item.tintActive
                                  ? ColorFilter.mode(
                                      isActive
                                          ? AppColors.primaryEmerald
                                          : const Color(0xFF77726A),
                                      BlendMode.srcIn,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                            color: isActive
                                ? AppColors.primaryEmerald
                                : const Color(0xFF77726A),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
