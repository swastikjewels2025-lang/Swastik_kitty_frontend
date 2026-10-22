import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized typography definitions for Kitty App.
///
/// Implements the unified brand typography using [Plus Jakarta Sans]
/// consistently across all screens (Coin Rates, Home, Jewellery, Calculator, Menu, My Scheme, etc.):
/// - Clean, modern, premium geometric sans-serif with high legibility for luxury jewellery fintech.
abstract final class AppTypography {
  // ---------------------------------------------------------------------------
  // Canonical Semantic Typography (Phase 2 Design System Foundation)
  // ---------------------------------------------------------------------------

  /// Semantic display text style (24px, Bold).
  static TextStyle display({Color color = AppColors.textPrimaryDark}) =>
      displayBrand(color: color);

  /// Semantic headline text style (22px, Bold).
  static TextStyle headline({Color color = AppColors.textPrimaryDark}) =>
      heroTitle(color: color);

  /// Semantic card/screen title (17px, Bold).
  static TextStyle title({Color color = AppColors.textPrimaryDark}) =>
      cardTitle(color: color);

  /// Semantic section title (15px, SemiBold).
  static TextStyle sectionTitle({Color color = AppColors.textPrimaryDark}) =>
      sectionHeading(color: color);

  /// Semantic primary body text (14px, Bold).
  static TextStyle body({Color color = AppColors.textPrimaryDark}) =>
      bodyBold(color: color);

  /// Semantic regular body text (13.5px, Medium).
  static TextStyle bodyMedium({Color color = AppColors.textSecondaryMuted}) =>
      bodyRegular(color: color);

  /// Semantic label text (11.5px, SemiBold).
  static TextStyle label({Color color = AppColors.textSecondaryMuted}) =>
      labelMeta(color: color);

  /// Semantic button text style (14px, ExtraBold).
  static TextStyle button({Color color = AppColors.textPrimaryLight}) =>
      buttonGoldCta(color: color);

  /// HTML Design System Serif Heading (Playfair Display)
  static TextStyle playfair({
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.w700,
    Color color = AppColors.htmlTextPrimary,
    double? height,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.playfairDisplay(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  // ---------------------------------------------------------------------------
  // Display & Hero Titles (Plus Jakarta Sans - Premium Brand Display)
  // ---------------------------------------------------------------------------

  /// Section titles and scheme branding names (24px, Bold, Tracking: -0.2px).
  static TextStyle displayBrand({
    Color color = AppColors.textPrimaryDark,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.25,
      letterSpacing: -0.2,
      color: color,
    );
  }

  /// Active scheme pass title and hero banners (22px, Bold, Tracking: -0.2px).
  static TextStyle heroTitle({
    Color color = AppColors.textPrimaryLight,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      height: 1.30,
      letterSpacing: -0.2,
      color: color,
    );
  }

  /// Secondary luxury subtitle (17px, SemiBold).
  static TextStyle displaySubtitle({
    Color color = AppColors.goldPrimary,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      height: 1.30,
      letterSpacing: 0.1,
      color: color,
    );
  }

  // ---------------------------------------------------------------------------
  // Headings & Card Titles (Plus Jakarta Sans)
  // ---------------------------------------------------------------------------

  /// Card title and screen sub-headers (17px, Bold, Tracking: 0.0px).
  static TextStyle cardTitle({
    Color color = AppColors.textPrimaryDark,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      height: 1.35,
      letterSpacing: 0.0,
      color: color,
    );
  }

  /// Section heading (15px, SemiBold).
  static TextStyle sectionHeading({
    Color color = AppColors.textPrimaryDark,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 1.35,
      color: color,
    );
  }

  // ---------------------------------------------------------------------------
  // Body Text & Button Labels (Plus Jakarta Sans)
  // ---------------------------------------------------------------------------

  /// Primary button labels and table text (14px, Bold, Tracking: +0.2px).
  static TextStyle bodyBold({
    Color color = AppColors.textPrimaryDark,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      height: 1.40,
      letterSpacing: 0.2,
      color: color,
    );
  }

  /// Descriptions, financial notes, and general body copy (13.5px, Medium).
  static TextStyle bodyRegular({
    Color color = AppColors.textSecondaryMuted,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 13.5,
      fontWeight: FontWeight.w500,
      height: 1.50,
      letterSpacing: 0.0,
      color: color,
    );
  }

  /// Compact body text for secondary notes (12px, Regular).
  static TextStyle bodySmall({
    Color color = AppColors.textSecondaryMuted,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.40,
      color: color,
    );
  }

  /// Caption and helper text (11px, Regular).
  static TextStyle caption({
    Color color = AppColors.textSecondaryMuted,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      height: 1.35,
      color: color,
    );
  }

  // ---------------------------------------------------------------------------
  // Labels, Meta, & Badges (Plus Jakarta Sans)
  // ---------------------------------------------------------------------------

  /// Table headers and secondary stats labels (11.5px, SemiBold, Tracking: +0.6px).
  static TextStyle labelMeta({
    Color color = AppColors.textSecondaryMuted,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 11.5,
      fontWeight: FontWeight.w600,
      height: 1.30,
      letterSpacing: 0.6,
      color: color,
    );
  }

  /// Eyebrow badges and uppercase chips (10px, ExtraBold, Tracking: +1.5px).
  static TextStyle kickerCaps({
    Color color = AppColors.goldPrimary,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 10,
      fontWeight: FontWeight.w800,
      height: 1.20,
      letterSpacing: 1.5,
      color: color,
    );
  }

  /// Primary gold CTA uppercase button text (14px, ExtraBold, Tracking: +1.0px).
  static TextStyle buttonGoldCta({
    Color color = AppColors.emeraldCard,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w800,
      height: 1.20,
      letterSpacing: 1.0,
      color: color,
    );
  }

  /// Financial currency and amount display (20px, Bold, Tracking: -0.4px).
  static TextStyle amountDisplay({
    Color color = AppColors.textPrimaryDark,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.20,
      letterSpacing: -0.4,
      color: color,
    );
  }
}
