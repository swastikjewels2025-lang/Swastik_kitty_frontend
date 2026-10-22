import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

/// Model representing a quick action shortcut item.
class QuickActionItem {
  const QuickActionItem({
    required this.title,
    this.icon,
    this.svgAsset,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final IconData? icon;
  final String? svgAsset;
  final VoidCallback onTap;
  final String? subtitle;
}

/// Fast action shortcut row matching the exact approved HTML quick-actions design.
///
/// Features circular gold icons (.action-icon-circle: 48x48, #F7EFE3 background,
/// #EADBCA border, subtle shadow) and clean 10.5px typography (#38322B).
class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({
    super.key,
    required this.actions,
  });

  final List<QuickActionItem> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: actions.map((QuickActionItem action) {
          return Expanded(
            child: Semantics(
              button: true,
              label: action.title,
              child: InkWell(
                onTap: action.onTap,
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Circular Icon Avatar matching .action-icon-circle
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFF7EFE3),
                          border: Border.all(
                            color: const Color(0xFFEADBCA),
                            width: 1,
                          ),
                          boxShadow: const <BoxShadow>[
                            BoxShadow(
                              color: Color(0x14B4966E),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: action.svgAsset != null
                              ? SvgPicture.asset(
                                  action.svgAsset!,
                                  width: 22,
                                  height: 22,
                                )
                              : Icon(
                                  action.icon ?? Icons.star_rounded,
                                  color: AppColors.htmlEmeraldBase,
                                  size: 22,
                                ),
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Label matching .action-label
                      Text(
                        action.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF38322B),
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

