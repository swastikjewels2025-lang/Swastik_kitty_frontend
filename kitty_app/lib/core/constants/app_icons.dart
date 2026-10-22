import 'package:flutter/material.dart';

/// Centralized icon design tokens for Kitty App.
///
/// Follows the approved redesign audit:
/// - Uses standard Flutter Material rounded icons (`Icons.*_rounded`)
///   for soft luxury aesthetics.
/// - Zero external icon dependencies.
abstract final class AppIcons {
  // ---------------------------------------------------------------------------
  // Canonical Primary Navigation Icons
  // ---------------------------------------------------------------------------

  /// Home destination icon (Tab 0).
  static const IconData home = Icons.home_rounded;
  static const IconData homeOutlined = Icons.home_outlined;

  /// Live Rates destination icon (Top strip / rates board).
  static const IconData liveRates = Icons.trending_up_rounded;
  static const IconData currencyRupee = Icons.currency_rupee_rounded;

  /// My Kitty wallet / active plans destination (Tab 1).
  static const IconData myKitty = Icons.account_balance_wallet_rounded;
  static const IconData myKittyOutlined = Icons.account_balance_wallet_outlined;

  /// Kitty Plans savings / schemes catalog destination (Tab 2).
  static const IconData kittyPlans = Icons.savings_rounded;
  static const IconData kittyPlansOutlined = Icons.savings_outlined;

  /// Gold Valuation Calculator destination (Tab 3).
  static const IconData calculator = Icons.calculate_rounded;
  static const IconData calculatorOutlined = Icons.calculate_outlined;

  /// Jewellery showroom web bridge destination (Tab 4).
  static const IconData jewellery = Icons.diamond_rounded;
  static const IconData jewelleryOutlined = Icons.diamond_outlined;

  /// Bullion & Gold Coins icon (Hamburger -> Bullion).
  static const IconData coins = Icons.monetization_on_rounded;
  static const IconData coinsOutlined = Icons.monetization_on_outlined;

  /// Navigation drawer hamburger icon.
  static const IconData menu = Icons.menu_rounded;

  // ---------------------------------------------------------------------------
  // Common Action & Utility Icons
  // ---------------------------------------------------------------------------

  /// Search icon.
  static const IconData search = Icons.search_rounded;

  /// Close / dismiss icon.
  static const IconData close = Icons.close_rounded;

  /// Backward navigation arrow.
  static const IconData back = Icons.arrow_back_rounded;

  /// Forward chevron arrow.
  static const IconData forward = Icons.arrow_forward_ios_rounded;

  /// Refresh / retry icon.
  static const IconData refresh = Icons.refresh_rounded;

  /// Notifications bell.
  static const IconData notifications = Icons.notifications_rounded;
  static const IconData notificationsOutlined = Icons.notifications_outlined;

  /// User profile badge.
  static const IconData profile = Icons.person_rounded;
  static const IconData profileOutlined = Icons.person_outlined;

  /// Filter / adjust icon.
  static const IconData filter = Icons.tune_rounded;

  /// Calendar / due date icon.
  static const IconData calendar = Icons.calendar_today_rounded;

  /// Passbook transaction history icon.
  static const IconData history = Icons.history_rounded;

  /// Digital receipt icon.
  static const IconData receipt = Icons.receipt_long_rounded;

  /// Physical showroom / store icon.
  static const IconData store = Icons.storefront_rounded;

  /// Phone call concierge icon.
  static const IconData phone = Icons.phone_rounded;

  /// Chat / messaging concierge icon.
  static const IconData whatsapp = Icons.chat_bubble_outline_rounded;

  /// Help and FAQ icon.
  static const IconData help = Icons.help_outline_rounded;

  /// Informational tooltip icon.
  static const IconData info = Icons.info_outline_rounded;

  /// Warning alert icon.
  static const IconData warning = Icons.warning_amber_rounded;

  /// Error / failure alert icon.
  static const IconData error = Icons.error_outline_rounded;

  /// Success checkmark badge.
  static const IconData check = Icons.check_circle_rounded;

  /// Token / Kitty number tag icon.
  static const IconData tag = Icons.tag;

  /// Shield / verified security icon.
  static const IconData shield = Icons.verified_user_rounded;

  /// Lock icon for OTP / PIN.
  static const IconData lock = Icons.lock_rounded;
}
