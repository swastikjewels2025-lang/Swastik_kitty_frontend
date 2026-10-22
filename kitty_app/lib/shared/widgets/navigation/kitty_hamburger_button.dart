import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kitty_app/features/menu/presentation/widgets/kitty_menu_sheet.dart';

/// Reusable top-right Hamburger Menu toggle button.
///
/// Can be placed on any app bar or screen header. When tapped, it displays
/// the approved `dddd/menu.html` navigation sheet overlay.
class KittyHamburgerButton extends StatelessWidget {
  const KittyHamburgerButton({
    super.key,
    this.isLightSurface = true,
    this.onTap,
  });

  /// Whether the button is placed on a light ivory/white surface (default)
  /// or a dark emerald surface.
  final bool isLightSurface;

  /// Optional override for the tap handler. If null, opens `KittyMenuSheet`.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isLightSurface
        ? const Color(0xFFF3EFE6)
        : Colors.white.withValues(alpha: 0.12);

    final Color borderColor = isLightSurface
        ? const Color(0xFFE5DFD3)
        : Colors.white.withValues(alpha: 0.18);

    final Color iconColor = isLightSurface
        ? const Color(0xFF0A221C)
        : Colors.white;

    return Tooltip(
      message: 'Menu',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            if (onTap != null) {
              onTap!();
            } else {
              openKittyMenu(context);
            }
          },
          borderRadius: BorderRadius.circular(20),
          splashColor: const Color(0x1F063B2C),
          highlightColor: const Color(0x0D063B2C),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 1.0),
              boxShadow: isLightSurface
                  ? const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x0A063D2E),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Icon(
                Icons.menu_rounded,
                color: iconColor,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
