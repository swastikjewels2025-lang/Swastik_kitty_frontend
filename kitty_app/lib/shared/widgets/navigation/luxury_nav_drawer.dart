import 'package:flutter/material.dart';
import '../../../features/menu/presentation/widgets/kitty_menu_sheet.dart';

/// Luxury slide-out navigation drawer reproducing the approved `dddd/menu.html` design.
class LuxuryNavDrawer extends StatelessWidget {
  const LuxuryNavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Drawer(
      backgroundColor: Color(0xFF063B2C),
      child: SafeArea(
        bottom: false,
        child: KittyMenuSheet(),
      ),
    );
  }
}
