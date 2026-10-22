import 'package:flutter/material.dart';

/// Centralized 4px base-grid layout spacing constants for Kitty App.
abstract final class AppSpacing {
  /// 2px - Ultra micro spacing
  static const double space2 = 2.0;

  /// 4px - Micro spacing between icon and badge text
  static const double space4 = 4.0;

  /// 6px - Small micro gap
  static const double space6 = 6.0;

  /// 8px - Small gap between related vertical elements
  static const double space8 = 8.0;

  /// 10px - Compact element spacing
  static const double space10 = 10.0;

  /// 12px - Medium gap between list items / sub-sections
  static const double space12 = 12.0;

  /// 14px - Intermediate form padding
  static const double space14 = 14.0;

  /// 16px - Base layout spacing / screen horizontal padding
  static const double space16 = 16.0;

  /// 20px - Extended container padding
  static const double space20 = 20.0;

  /// 24px - Large section gap
  static const double space24 = 24.0;

  /// 28px - Extended section gap
  static const double space28 = 28.0;

  /// 32px - Extra large hero/footer separation
  static const double space32 = 32.0;

  /// 48px - Major screen block separator
  static const double space48 = 48.0;

  /// 64px - Extended bottom dock clearance
  static const double space64 = 64.0;

  // ---------------------------------------------------------------------------
  // EdgeInsets Shortcuts
  // ---------------------------------------------------------------------------

  /// EdgeInsets.all(4.0)
  static const EdgeInsets all4 = EdgeInsets.all(space4);

  /// EdgeInsets.all(8.0)
  static const EdgeInsets all8 = EdgeInsets.all(space8);

  /// EdgeInsets.all(12.0)
  static const EdgeInsets all12 = EdgeInsets.all(space12);

  /// EdgeInsets.all(14.0)
  static const EdgeInsets all14 = EdgeInsets.all(space14);

  /// EdgeInsets.all(16.0)
  static const EdgeInsets all16 = EdgeInsets.all(space16);

  /// EdgeInsets.all(20.0)
  static const EdgeInsets all20 = EdgeInsets.all(space20);

  /// EdgeInsets.all(24.0)
  static const EdgeInsets all24 = EdgeInsets.all(space24);

  /// Standard screen edge horizontal padding (16px)
  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(horizontal: space16);

  /// Standard screen padding (16px horizontal, 20px vertical)
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: space16, vertical: space20);
}

/// Centralized border radius design tokens for Kitty App.
abstract final class AppRadius {
  /// 6px - Progress bars, inner pill tags
  static const double radius6 = 6.0;

  /// 8px - Badges, small chips, pill tags
  static const double radius8 = 8.0;

  /// 10px - Secondary buttons, thumbnail cards
  static const double radius10 = 10.0;

  /// 12px - Input fields, sub-cards, toggle switches, OTP boxes
  static const double radius12 = 12.0;

  /// 14px - Primary CTA buttons
  static const double radius14 = 14.0;

  /// 16px - Large CTA buttons and bottom sheet top corners
  static const double radius16 = 16.0;

  /// 18px - Passbook table container and primary cards
  static const double radius18 = 18.0;

  /// 20px - Scheme hero card and modal wrappers
  static const double radius20 = 20.0;

  /// 28px - Container wrap cards on tablet / expanded screens
  static const double radius28 = 28.0;

  /// 999px - Status pills, filter chips, circular avatar rings
  static const double radiusPill = 999.0;

  // ---------------------------------------------------------------------------
  // BorderRadius Shortcuts
  // ---------------------------------------------------------------------------

  /// BorderRadius.circular(6.0)
  static const BorderRadius border6 = BorderRadius.all(Radius.circular(radius6));

  /// BorderRadius.circular(8.0)
  static const BorderRadius border8 = BorderRadius.all(Radius.circular(radius8));

  /// BorderRadius.circular(10.0)
  static const BorderRadius border10 = BorderRadius.all(Radius.circular(radius10));

  /// BorderRadius.circular(12.0)
  static const BorderRadius border12 = BorderRadius.all(Radius.circular(radius12));

  /// BorderRadius.circular(14.0)
  static const BorderRadius border14 = BorderRadius.all(Radius.circular(radius14));

  /// BorderRadius.circular(16.0)
  static const BorderRadius border16 = BorderRadius.all(Radius.circular(radius16));

  /// BorderRadius.circular(18.0)
  static const BorderRadius border18 = BorderRadius.all(Radius.circular(radius18));

  /// BorderRadius.circular(20.0)
  static const BorderRadius border20 = BorderRadius.all(Radius.circular(radius20));

  /// BorderRadius.circular(999.0)
  static const BorderRadius borderPill = BorderRadius.all(Radius.circular(radiusPill));

  /// Modal bottom sheet top rounded corners (20px)
  static const BorderRadius modalTop = BorderRadius.vertical(top: Radius.circular(radius20));
}
