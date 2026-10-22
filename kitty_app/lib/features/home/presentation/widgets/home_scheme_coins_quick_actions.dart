import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

/// Quick Action section offering direct access to "Gold Scheme" and "Coins".
///
/// Designed in accordance with the layered reference layout:
/// - Green background begins at the horizontal midpoint of the circular icons
/// - Circular icons float half-in, half-out of the top edge of the green container
/// - White typography labels positioned cleanly inside the green area
/// - Strictly 2 options: "Gold Scheme" and "Coins"
class HomeSchemeCoinsQuickActions extends StatelessWidget {
  const HomeSchemeCoinsQuickActions({
    super.key,
    required this.onGoldSchemeTap,
    required this.onCoinsTap,
  });

  final VoidCallback onGoldSchemeTap;
  final VoidCallback onCoinsTap;

  static const double _circleDiameter = 58.0;
  static const double _halfCircle = _circleDiameter / 2; // 29.0

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space4,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          // 1. Emerald Green Background Card (Starts at midpoint of the circles)
          Container(
            margin: const EdgeInsets.only(top: _halfCircle),
            padding: const EdgeInsets.only(
              top: _halfCircle + 6,
              bottom: 12,
              left: 12,
              right: 12,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryEmerald,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Color(0xFF042D22),
                  Color(0xFF063D2E),
                  Color(0xFF084837),
                ],
              ),
              borderRadius: AppRadius.border18,
              border: Border.all(
                color: AppColors.richAntiqueGold.withValues(alpha: 0.35),
                width: 1.2,
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x24063D2E),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                // Gold Scheme Label
                Expanded(
                  child: InkWell(
                    onTap: onGoldSchemeTap,
                    borderRadius: AppRadius.border8,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'Gold Scheme',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),

                // Subtle vertical divider between the two options
                Container(
                  width: 1,
                  height: 22,
                  color: Colors.white.withValues(alpha: 0.18),
                ),

                // Coins Label
                Expanded(
                  child: InkWell(
                    onTap: onCoinsTap,
                    borderRadius: AppRadius.border8,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'Coins',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Circular Icon Buttons (Positioned so the green card starts at their halfway line)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: _CircleIconButton(
                      icon: Icons.workspace_premium_outlined,
                      onTap: onGoldSchemeTap,
                    ),
                  ),
                ),
                const SizedBox(width: 1),
                Expanded(
                  child: Center(
                    child: _CircleIconButton(
                      icon: Icons.monetization_on_outlined,
                      onTap: onCoinsTap,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.richAntiqueGold.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x2B000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            color: AppColors.primaryEmerald,
            size: 28,
          ),
        ),
      ),
    );
  }
}
