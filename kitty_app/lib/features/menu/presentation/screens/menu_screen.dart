import 'package:flutter/material.dart';
import '../widgets/kitty_menu_sheet.dart';

/// Fullscreen Menu Route Screen for `RoutePaths.menu` reproducing `dddd/menu.html`.
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF063B2C),
      body: SafeArea(
        bottom: false,
        child: KittyMenuSheet(),
      ),
    );
  }
}
