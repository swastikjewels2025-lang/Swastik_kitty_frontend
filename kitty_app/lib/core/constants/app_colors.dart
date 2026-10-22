import 'package:flutter/material.dart';

/// Centralized color design tokens for Kitty App.
///
/// Implements the Royal Indian Heritage Luxury palette with:
/// - Primary Accent: Deep Emerald Green (#063D2E)
/// - Secondary Accent: Vibrant Emerald (#0A6B4F)
/// - Luxury Accent: Rich Antique Gold (#D4A34A)
/// - Base / Canvas: Warm Pearl / Off-White (#F9F7F2)
/// - Card Surface: Pure White (#FFFFFF)
/// - Text Primary: Deep Forest / Charcoal (#18231E)
/// - Text Secondary: Muted Slate Gray (#6E7A75)
/// - Inactive Nav: Muted Gray (#8C9691)
abstract final class AppColors {
  // ---------------------------------------------------------------------------
  // Canonical Redesign Palette (User-Specified)
  // ---------------------------------------------------------------------------

  // HTML Design System Exact Tokens (from dddd/css/style.css & plans.css)
  static const Color htmlEmeraldDeep = Color(0xFF022318);
  static const Color htmlEmeraldBase = Color(0xFF053826);
  static const Color htmlEmeraldLight = Color(0xFF07432E);
  static const Color htmlEmeraldAccent = Color(0xFF0A6B48);
  static const Color htmlEmeraldTrend = Color(0xFF0E7B50);
  static const Color htmlEmeraldDark = Color(0xFF063B2C);

  static const Color htmlGoldIcon = Color(0xFF9A7342);
  static const Color htmlGoldBorder = Color(0xFFEADBCA);
  static const Color htmlGoldBgCircle = Color(0xFFF7EFE3);
  static const Color htmlGoldBadge = Color(0xFFE6A838);
  static const Color htmlGoldSoft = Color(0xFFF9F2E4);
  static const Color htmlDotGold = Color(0xFFC88A35);

  static const Color htmlBgCanvas = Color(0xFFFAF7F2);
  static const Color htmlBgMobile = Color(0xFFFAF7F2);
  static const Color htmlCardWhite = Color(0xFFFFFFFF);
  static const Color htmlBorderSubtle = Color(0xFFEFEAE0);
  static const Color htmlTabInactiveBg = Color(0xFFF3EDE4);

  static const Color htmlTextHeader = Color(0xFFFFFFFF);
  static const Color htmlTextHeaderSub = Color(0xFFA3C5B5);
  static const Color htmlTextPrimary = Color(0xFF1C2420);
  static const Color htmlTextSecondary = Color(0xFF7D786F);
  static const Color htmlTextPlaceholder = Color(0xFF8E9591);
  static const Color htmlTextBullets = Color(0xFF374841);
  static const Color htmlTextMuted = Color(0xFF68726E);

  /// Primary Accent: Deep Emerald Green (#063B2C) matching Gold Plans CTA buttons.
  /// Main buttons ("Select a Plan", "Book"), active toggle state pills.
  static const Color primaryEmerald = Color(0xFF063B2C);

  /// Secondary Accent: Vibrant Emerald (#0A6B4F).
  /// Live indicators, status tags ("Active", "Verified"), icons.
  static const Color vibrantEmerald = Color(0xFF0A6B4F);

  /// Luxury Accent: Rich Warm Gold (#C88A35 / #D4A34A).
  /// Gold bullets, header logo, gold rates tag, premium badges.
  static const Color richAntiqueGold = Color(0xFFC88A35);

  /// Base / Canvas: Warm Pearl / Light Parchment (#FAF7F2).
  /// App main background canvas across entire Kitty App (Source of truth: Gold Plans page).
  static const Color warmPearl = Color(0xFFFAF7F2);

  /// Card Surface: Pure White (#FFFFFF).
  /// All plan cards, product cards, list items, and input boxes.
  static const Color pureWhite = Color(0xFFFFFFFF);

  /// Text Primary: Deep Forest / Charcoal (#0A221C).
  /// Headings, amounts, and main titles (Source of truth: Gold Plans page).
  static const Color deepForestCharcoal = Color(0xFF0A221C);

  /// Text Secondary: Muted Slate Gray (#68726E).
  /// Subtitles, labels, timestamps, transaction IDs.
  static const Color mutedSlateGray = Color(0xFF68726E);

  /// Inactive Tab / Neutral Muted Gray (#8C9691).
  /// Inactive bottom bar tabs, neutral icons.
  static const Color mutedNavGray = Color(0xFF8C9691);

  // ---------------------------------------------------------------------------
  // Canonical Semantic Tokens (Phase 2 Design System Foundation)
  // ---------------------------------------------------------------------------

  /// Semantic primary brand token (Deep Emerald Green #063B2C).
  static const Color primary = primaryEmerald;

  /// Semantic primary container token (Dark Emerald CTA #063B2C).
  static const Color primaryContainer = emeraldPrimary;

  /// Semantic surface token (Crisp Pure White #FFFFFF).
  static const Color surface = pureWhite;

  /// Semantic surface variant token (Soft Warm Linen Inset #F3EDE4).
  static const Color surfaceVariant = Color(0xFFF3EDE4);

  /// Semantic page background canvas token (Warm Pearl #FAF7F2).
  static const Color background = warmPearl;

  /// Semantic primary high-contrast text token (#0A221C).
  static const Color textPrimary = deepForestCharcoal;

  /// Semantic secondary muted text token (#68726E).
  static const Color textSecondary = mutedSlateGray;

  /// Semantic tertiary muted/disabled token (#8C9691).
  static const Color textMuted = mutedNavGray;

  /// Semantic border token for cards and inputs (#EFE6DB).
  static const Color border = surfaceCardBorder;

  /// Semantic success state token (#0A6B4F).
  static const Color success = vibrantEmerald;

  /// Semantic warning state token (#D97706).
  static const Color warning = statusWarningText;

  /// Semantic error state token (#DC2626).
  static const Color error = statusErrorText;

  /// Semantic info / identity verification state token (#2563EB).
  static const Color info = Color(0xFF2563EB);

  /// Semantic luxury gold token (#C88A35).
  static const Color gold = richAntiqueGold;

  /// Semantic precious silver token (#94A3B8).
  static const Color silver = Color(0xFF94A3B8);

  // ---------------------------------------------------------------------------
  // Brand Emerald & Royal Green Palette (Migrated to Gold Plans Luxury System)
  // ---------------------------------------------------------------------------

  /// Canvas background for Splash, Login, and all screens (#FAF7F2).
  /// Migrated globally to Gold Plans canvas background.
  static const Color deepEmeraldBase = warmPearl;

  /// Luxury white card and container surface (#FFFFFF).
  static const Color emeraldCard = pureWhite;

  /// Alternate subtle card surface (#FAF8F5).
  static const Color emeraldCardAlt = Color(0xFFFAF8F5);

  /// Brand primary dark green used for CTAs and active filter buttons (#063B2C).
  static const Color emeraldPrimary = primaryEmerald;

  /// Deep container surface matching warm parchment (#FAF7F2).
  static const Color emeraldContainer = warmPearl;

  /// Secondary muted text and labels (#68726E).
  static const Color emeraldTextSubtle = mutedSlateGray;

  /// Muted labels (#8E9591).
  static const Color emeraldTextMuted = Color(0xFF8E9591);

  /// Accent border (#EFE6DB).
  static const Color emeraldBorder = Color(0xFFEFE6DB);

  // ---------------------------------------------------------------------------
  // Brand Rich Antique Gold Palette
  // ---------------------------------------------------------------------------

  /// Primary luxury antique gold for logos, active badges, and key accents (#D4A34A).
  static const Color goldPrimary = richAntiqueGold;

  /// Secondary gold accent (#D4A34A).
  static const Color goldAccent = richAntiqueGold;

  /// Gradient start for luxury CTAs / accents (#E4BA60).
  static const Color goldGradientStart = Color(0xFFE4BA60);

  /// Gradient end for luxury CTAs / accents (#C79438).
  static const Color goldGradientEnd = Color(0xFFC79438);

  /// Light champagne gold for subtle highlights (#E6CA87).
  static const Color goldLight = Color(0xFFE6CA87);

  /// Frosted champagne gold background for chips and icons (12% opacity).
  static const Color goldSubtle = Color(0x1FD4A34A);

  /// Subtle gold border for badges and frames (28% opacity).
  static const Color goldBorder = Color(0x47D4A34A);

  // ---------------------------------------------------------------------------
  // Canvas & Light Surfaces (Warm Pearl #F9F7F2 & Pure White #FFFFFF)
  // ---------------------------------------------------------------------------

  /// Warm Pearl / Off-White (#F9F7F2): Full-screen base / canvas behind cards.
  static const Color alabasterSilk = warmPearl;

  /// Pure White (#FFFFFF): Product cards, list items, input boxes.
  static const Color creamIvoryCard = pureWhite;

  /// Soft Warm Inset (#F0EBE1): Subtle inner box around stat metrics.
  static const Color warmLinenInset = Color(0xFFF0EBE1);

  /// Rich Antique Gold (#D4A34A): Accent icons, progress rings, and highlights.
  static const Color honeyGoldAccent = richAntiqueGold;

  /// Champagne Gold Foil (#F6E7C8): Tag pills, 24K price banner pill, badges.
  static const Color champagneFoil = Color(0xFFF6E7C8);

  /// Deep Forest Charcoal (#18231E): High-contrast numbers, headings, main titles.
  static const Color espressoCharcoal = deepForestCharcoal;

  /// Muted Slate Gray (#6E7A75): Labels, subtitles, timestamps.
  static const Color warmTaupeBrown = mutedSlateGray;

  /// Primary Action Dark / Emerald (#063D2E): CTAs and main buttons.
  static const Color deepUmberBronze = primaryEmerald;

  // ---------------------------------------------------------------------------
  // Settings & Warm Luxury Palette
  // ---------------------------------------------------------------------------

  /// Warm Pearl screen base background (#F9F7F2).
  static const Color settingsBg = warmPearl;

  /// Pure White profile card, settings group cards background (#FFFFFF).
  static const Color settingsCardBg = pureWhite;

  /// Soft Warm Inset icon boxes (#F0EBE1).
  static const Color settingsIconBg = warmLinenInset;

  /// Primary text & headings (#18231E).
  static const Color settingsTextPrimary = deepForestCharcoal;

  /// Secondary & subtitle captions (#6E7A75).
  static const Color settingsTextSecondary = mutedSlateGray;

  /// Section titles & accents (#D4A34A).
  static const Color settingsAccentGold = richAntiqueGold;

  /// Vibrant Mint Tint (#E7F3EE): Status pill background (Registered, Verified).
  static const Color settingsBadgeBg = Color(0xFFE7F3EE);

  /// Vibrant Emerald (#0A6B4F): Status pill text and checkmark.
  static const Color settingsBadgeText = vibrantEmerald;

  /// Subtle light border (#ECE7DE): Divider lines and 1px subtle borders.
  static const Color settingsBorder = Color(0xFFECE7DE);

  // ---------------------------------------------------------------------------
  // Luxury Design Tokens mapped to Fresh Luxury Palette
  // ---------------------------------------------------------------------------

  /// Canvas background canvas matching Warm Pearl (#F9F7F2).
  static const Color homeCanvasBg = warmPearl;

  /// Top luxury navbar & product card background matching Pure White (#FFFFFF).
  static const Color homeNavbarBg = pureWhite;

  /// Header & footer border matching subtle divider (#ECE7DE).
  static const Color homeNavbarBorder = Color(0xFFECE7DE);

  /// Primary heading font color matching Deep Forest Charcoal (#18231E).
  static const Color homePrimaryHeading = deepForestCharcoal;

  /// Body & subtitle font color matching Muted Slate Gray (#6E7A75).
  static const Color homeBodySubtitle = mutedSlateGray;

  /// Brand gold accent matching Rich Antique Gold (#D4A34A).
  static const Color homeBrandGold = richAntiqueGold;

  /// Brand gold hover (#C49339).
  static const Color homeBrandGoldHover = Color(0xFFC49339);

  /// Category ring background matching Pure White (#FFFFFF).
  static const Color homeCategoryRingBg = pureWhite;

  /// Category ring border (#ECE7DE).
  static const Color homeCategoryRingBorder = Color(0xFFECE7DE);

  /// Product card background matching Pure White (#FFFFFF).
  static const Color homeProductCardBg = pureWhite;

  /// Product card border (#ECE7DE).
  static const Color homeProductCardBorder = Color(0xFFECE7DE);

  /// Promo banner surface matching Pure White (#FFFFFF).
  static const Color homePromoBannerEmerald = pureWhite;

  /// Promo button matching Deep Emerald Green (#063D2E).
  static const Color homePromoGoldenBtn = primaryEmerald;

  // ---------------------------------------------------------------------------
  // Refined Light Surface Palette (Passbook & Settings)
  // ---------------------------------------------------------------------------

  /// Soft modern Warm Pearl page background canvas (#F9F7F2).
  static const Color surfacePageBg = warmPearl;

  /// Crisp Pure White container card background (#FFFFFF).
  static const Color surfaceCardBg = pureWhite;

  /// Subtle modern warm border for cards and inputs (#EFE6DB matching Gold Plans).
  static const Color surfaceCardBorder = Color(0xFFEFE6DB);

  /// Secondary modern border (#EFE6DB).
  static const Color surfaceCardBorderAlt = Color(0xFFEFE6DB);

  /// Table row separator and section divider (#EFEAE0).
  static const Color surfaceDivider = Color(0xFFEFEAE0);

  // ---------------------------------------------------------------------------
  // Neutral Text Palette
  // ---------------------------------------------------------------------------

  /// Primary high-contrast text on light cards (#18231E Deep Forest Charcoal).
  static const Color textPrimaryDark = deepForestCharcoal;

  /// Subtitles, helper text, and timestamps on light cards (#6E7A75 Muted Slate Gray).
  static const Color textSecondaryMuted = mutedSlateGray;

  /// Tertiary placeholder and disabled text (#8C9691 Muted Nav Gray).
  static const Color textTertiary = mutedNavGray;

  /// Crisp white text on dark emerald cards (#FFFFFF).
  static const Color textPrimaryLight = Color(0xFFFFFFFF);

  /// Soft off-white text for luxury dark surfaces (#FAF8F2).
  static const Color textPrimaryLightOff = Color(0xFFFAF8F2);

  /// Secondary perk descriptions and labels on dark cards (#8CA59B).
  static const Color textSecondaryLight = Color(0xFF8CA59B);

  /// Light secondary label on dark cards (#D1DCD6).
  static const Color textSecondaryLightAlt = Color(0xFFD1DCD6);

  // ---------------------------------------------------------------------------
  // Status & Lifecycle Colors
  // ---------------------------------------------------------------------------

  /// Green tint pill background for PAID / Verified (#E7F3EE).
  static const Color statusSuccessBg = Color(0xFFE7F3EE);

  /// Vibrant Emerald text and icon for success state (#0A6B4F).
  static const Color statusSuccessText = vibrantEmerald;

  /// Emerald border for verified / paid pills (rgba(10, 107, 79, 0.25)).
  static const Color statusSuccessBorder = Color(0x400A6B4F);

  /// Amber highlight background for CURRENT due month (#FFFBEB).
  static const Color statusWarningBg = Color(0xFFFFFBEB);

  /// Amber text for current due month and warnings (#D97706).
  static const Color statusWarningText = Color(0xFFD97706);

  /// Dark amber text (#B45309).
  static const Color statusWarningTextAlt = Color(0xFFB45309);

  /// Amber border for warning badges (#FDE68A).
  static const Color statusWarningBorder = Color(0xFFFDE68A);

  /// Yellow highlight background for 12th month bonus deposit (#FEFCE8).
  static const Color statusBonusBg = Color(0xFFFEFCE8);

  /// Bonus text color (#CA8A04).
  static const Color statusBonusText = Color(0xFFCA8A04);

  /// Red background for form errors, failed payments, and destructive actions (#FEF2F2).
  static const Color statusErrorBg = Color(0xFFFEF2F2);

  /// Red text for errors and destructive actions (#DC2626).
  static const Color statusErrorText = Color(0xFFDC2626);

  /// Red border for error banners (#FECACA).
  static const Color statusErrorBorder = Color(0xFFFECACA);

  // ---------------------------------------------------------------------------
  // Gradients
  // ---------------------------------------------------------------------------

  /// Primary Deep Emerald button and CTA gradient.
  static const LinearGradient emeraldPrimaryGradient = LinearGradient(
    colors: <Color>[Color(0xFF094E3B), primaryEmerald],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Rich Antique Gold button and CTA gradient.
  static const LinearGradient goldPrimaryGradient = LinearGradient(
    colors: <Color>[goldGradientStart, goldGradientEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Deep emerald luxury card gradient.
  static const LinearGradient emeraldHeroGradient = LinearGradient(
    colors: <Color>[emeraldCard, primaryEmerald],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Light gold accent gradient.
  static const LinearGradient goldCardGradient = LinearGradient(
    colors: <Color>[goldLight, richAntiqueGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
