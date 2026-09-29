# Frontend UI/UX Design System Specification — Kitty App

**Project**: Swastik Jewellers Kitty App (Sub-Brand: Kitty Vault)  
**Primary Codebase**: `D:\kitty_app\`  
**Document Status**: Synchronized with Current Implementation  
**Last Audit Date**: 2026-09-23  

---

## 1. Dual-Surface Luxury Design Philosophy

The Kitty App visual architecture is organized around a **Dual-Surface Luxury Paradigm** that resolves the conflict between royal sensory brand prestige and daytime financial legibility:

```text
┌────────────────────────────────────────────────────────┐
│ SURFACE 1: DEEP EMERALD HERITAGE (#05241C)            │
│ Royal Indian Heritage, High-Security, High-Prestige   │
│ Used on: Splash, Login, KYC, Checkout Modals, Drawer   │
└────────────────────────────────────────────────────────┘
                           ▲
                           │ Contextual Transition
                           ▼
┌────────────────────────────────────────────────────────┐
│ SURFACE 2: WARM LUXURY ALABASTER (#FAF7F2)            │
│ Daytime Financial Clarity, Tactile Warmth, Legibility │
│ Used on: Home, Passbook, Coins, Jewellery, Calculator  │
└────────────────────────────────────────────────────────┘
```

---

## 2. Color System & Design Tokens (`AppColors`)

### 2.1 Surface 1: Brand Emerald & Royal Green Palette
| Token Name | Hex Code | Visual Application |
| :--- | :--- | :--- |
| `deepEmeraldBase` | `#05241C` | Full-screen background for Splash, Login, and KYC screens. |
| `emeraldCard` | `#092B22` | Glassmorphic card surface on dark emerald views. |
| `emeraldCardAlt` | `#0B3026` | Alternate nested card background. |
| `emeraldPrimary` | `#064E3B` | Active filter buttons, tab indicators. |
| `emeraldContainer` | `#0C2B24` | Circular icon backdrops and container surfaces. |
| `emeraldTextSubtle`| `#9FB8AE` | Secondary labels and captions on dark emerald cards. |
| `emeraldBorder` | `rgba(16, 185, 129, 0.20)` | Subtle emerald card borders and separator lines. |

### 2.2 Royal Indian Heritage Luxury Palette (Standard Color Tokens)
| Token Name | Hex Code | Visual Application |
| :--- | :--- | :--- |
| `primaryEmerald` | `#063D2E` | Deep royal emerald for brand identity, primary CTA buttons, active state indicators. |
| `vibrantEmerald` | `#0A6B4F` | Vibrant jewel emerald for positive accents, live indicators, focused highlights. |
| `richAntiqueGold` | `#D4A34A` | Rich antique gold for luxury accents, bullion highlights, badges, trend curves. |
| `warmPearlCanvas` | `#F9F7F2` | Warm pearl background canvas for clean daytime readability and organic luxury feel. |
| `pureWhite` | `#FFFFFF` | Crisp pure white surface for elevated cards, rate blocks, and interactive modals. |
| `deepForestCharcoal` | `#18231E` | Deep forest charcoal for high-contrast primary typography and numbers. |
| `mutedSlateGray` | `#6E7A75` | Refined muted slate gray for secondary metadata, timestamps, and captions. |

### 2.3 Legacy Supporting Color Tokens
| Token Name | Hex Code | Visual Application |
| :--- | :--- | :--- |
| `honeyGoldAccent` | `#DCA237` | Warm gold button accents, secondary highlights, circular gauge arc. |
| `creamIvoryCard` | `#F4F0EA` | Soft cream ivory card fill. |
| `warmLinenInset` | `#EDE8DF` | Subtle inner inset container for metrics and toggles. |
| `surfaceCardBorder` | `#ECE7DE` | Subtle card borders for soft depth. |

---

## 3. Typography Architecture (`AppTypography` & `GoogleFonts.plusJakartaSans`)

The app enforces a clean, contemporary luxury typography hierarchy standardized globally across all screens using **Plus Jakarta Sans**:

```text
Plus Jakarta Sans (Sans-Serif) ──► Universal Typography Engine
                                   - Display & Hero Headlines (w700 / w800)
                                   - Section Titles & Card Headings (w600 / w700)
                                   - Financial Ledgers, Rates & Currency (w700 / w800)
                                   - Body Text, Captions & Meta Labels (w400 / w500 / w600)
```

| Text Style Method | Font Family | Size | Weight | Tracking | Primary Usage |
| :--- | :--- | :-: | :-: | :-: | :--- |
| `displayBrand()` | Plus Jakarta Sans | 24px | 800 (ExtraBold) | -0.3px | Brand titles, modal headers, major rates |
| `heroTitle()` | Plus Jakarta Sans | 20px | 700 (Bold) | -0.2px | Section hero banners, trend headers |
| `displaySubtitle()` | Plus Jakarta Sans | 17px | 600 (SemiBold) | 0.0px | Sub-headlines, card titles |
| `cardTitle()` | Plus Jakarta Sans | 16px | 700 (Bold) | 0.0px | Rate blocks, coin row labels, card titles |
| `sectionHeading()` | Plus Jakarta Sans | 15px | 600 (SemiBold) | 0.0px | Section headers, table column titles |
| `bodyBold()` | Plus Jakarta Sans | 14px | 700 (Bold) | +0.1px | CTA buttons, active selection labels |
| `bodyRegular()` | Plus Jakarta Sans | 14px | 400 (Regular) | 0.0px | Descriptive text, terms, modal bodies |
| `caption()` | Plus Jakarta Sans | 12px | 500 (Medium) | 0.0px | Supporting text, timestamps, subtitles |
| `kickerCaps()` | Plus Jakarta Sans | 11px | 700 (Bold) | +1.2px | Uppercase section kickers, status pills |
| `labelMeta()` | Plus Jakarta Sans | 10px | 600 (SemiBold) | +0.5px | Unit specifiers (`/ GRAM`), bottom dock labels |

---

## 4. Spacing, Corner Radius & Elevations

### 4.1 Spacing Scale (`AppSpacing`)
* `space4` (4px), `space8` (8px), `space12` (12px), `space14` (14px), `space16` (16px), `space20` (20px), `space24` (24px), `space32` (32px), `space64` (64px).

### 4.2 Corner Radius Scale (`AppRadius`)
* `border4` (4px), `border8` (8px), `border12` (12px), `border16` (16px — standard card), `border20` (20px — modals and buttons), `border32` (32px — pills and badges).

### 4.3 Shadow & Elevation System
* **Dark Surface Elevation**: Specular top hairline border (`1px` with `goldBorder`) paired with dual ambient drop shadow:
  ```dart
  BoxShadow(color: Color(0x33000000), blurRadius: 18, offset: Offset(0, 8))
  ```
* **Warm Luxury Card Elevation**: Subtle warm drop shadow:
  ```dart
  BoxShadow(color: Color(0x062B2521), blurRadius: 10, offset: Offset(0, 3))
  ```

---

## 5. Motion, Physics & Micro-Animations

1. **Hardware-Accelerated 3D Diamond Particle Canvas (`Diamond3dPainter`)**:
   - Renders 24-frame diamond facet rotation with depth-sorted vertex shading on Splash.
2. **Smooth Startup & Crest Dissolution Transition**:
   - Immediate non-blank root canvas (`#05241C`) eliminates white/unpainted first frames.
   - Refined scale trajectory ($0.95 \rightarrow 1.15$) with gentle opacity dissolution into the central Swastik brand crest.
3. **3D Multi-Gem Constellation (`JewelryConstellationPainter`)**:
   - Renders orbiting solitaire diamonds, rings, and bangles with starlight sparkles on Login and KYC screens. Continuous 24-second parametric rotation loop.
4. **Circular Installment Gauge (`KittyCircularProgressGauge`)**:
   - Animates sweep angle from 0° to target arc over 800ms using `Curves.easeOutCubic`.
5. **Card Entrance Transitions**:
   - Fast luxury ease (260ms, `Cubic(0.16, 1.0, 0.3, 1.0)`): Cards scale from 0.97 to 1.0 while fading and translating 12px upward.
6. **OTP Shake Animation**:
   - On invalid submission, triggers a 400ms damped sinusoidal horizontal shake ($\pm 8$px) accompanied by system haptic feedback.
7. **Store Video Pulsing Play Button**:
   - Continuous 2-second breathing pulse animation (scale 0.95 to 1.08) inviting interaction.

---

---

## 6. Granular Component Design Specifications (2026-09-27)

### 6.1 Top Header (`HeaderNavBar`)
* **Live Gold Rate Ticker**: Compact pill aligned to the **LEFT** of the header (`fontSize: 11px`, `fontWeight: w900`, pulsating green indicator).
* **Brand Logo**: Authentic Swastik Jewellers SVG crest positioned in the **CENTER**.
* **Action Controls**: Aligned to the **RIGHT** featuring the Notification Bell (with unread badge counter) and the Hamburger Menu navigation button (`Icons.menu_rounded`).

### 6.2 Gold Offers Carousel (`HomeOffersCarousel`)
* **Prominent Banner Height**: Increased to **265px** vertical height to grant banners commanding presence while ensuring zero viewport overflow on mobile displays.
* **Auto-Scroll Engine**: Periodic 5-second automatic sliding animation with smooth cubic easing.
* **Luxury Visual Styling**: `BoxFit.cover` photography, dark gradient scrim (`Colors.black` 82% at base), white title typography, and gold "Explore Plan" / "Enrol Plan" pills.

### 6.3 Live Gold & Silver Rate Carousel (`HomeGoldSilverRateCarousel`)
* **Emerald Rate Surface**: Deep emerald gradient card (`#042D22` to `#084837`) with gold accent borders.
* **Auto-Rotating Carousel**: Smoothly transitions between live benchmark prices for **Gold 24K (999)** and **999 Fine Silver** with live 24-hour delta indicators and chevron controls.

### 6.4 Explore Our Jewellery (`HomeJewelleryCollections`)
* **Circular Presentation**: Circular category cards with subtle gold rim borders showcasing curated jewelry categories (Rings, Earrings, Bangles, Necklaces, etc.).

### 6.5 Home Quick Actions (`HomeSchemeCoinsQuickActions`)
* **Layered Geometry**: Emerald background card with two floating circular icon buttons (`width: 58`, `height: 58`) positioned half-in, half-out of the top edge.
* **Unified Iconography**: Clean, modern icons belonging to the same icon family: `Icons.workspace_premium_outlined` for Gold Scheme and `Icons.monetization_on_outlined` for Coins.

### 6.6 Bullion Coin Table (`CoinRatesScreen`)
* **Dual Metal Selector**: High-contrast tab toggle between Gold Coins and Silver Coins.
* **Unified Table**: Rows displaying `GM | PURITY | PRICE` with dedicated right-aligned "Book Now" buttons.
* **Dynamic Karat Selector**: 24K / 22K selector displayed dynamically ONLY for Gold; strictly hidden for Silver.
* **Custom Coins**: Centered Karat and weight chips with input placeholder `"Enter custom grams"`.

### 6.7 Frosted Glass Bottom Navigation Dock (`AppBottomNavBar`)
* **5 Dedicated Luxury Tabs**:
  1. Home: `Icons.home_outlined` (inactive) / `Icons.home_rounded` (active)
  2. Coins: `Icons.monetization_on_outlined` (inactive) / `Icons.monetization_on_rounded` (active)
  3. Jewellery: `Icons.diamond_outlined` (inactive) / `Icons.diamond_rounded` (active)
  4. My Scheme: `Icons.workspace_premium_outlined` (inactive) / `Icons.workspace_premium_rounded` (active)
  5. Menu: `Icons.menu_rounded` (inactive) / `Icons.menu_open_rounded` (active)
* **Smart Active-State Capsule**:
  - Highlights exclusively the tab matching the active route.
  - When the patron navigates to off-dock routes (`/passbook`, `/settings`, `/calculator`, `/offers`, etc.), the indicator capsule smoothly fades out (`opacity: 0.0`), preventing any false highlight of the Home tab.

### 6.8 Notifications Styling (`NotificationsScreen`, `NotificationItemTile`)
* **Gold Scheme Heading**: The "GOLD SCHEME" heading label is explicitly styled with canonical honey gold (`AppColors.honeyGoldAccent` / `#D4A34A`).
* **Clean Modern Icons**:
  - Transaction: `Icons.payments_rounded`
  - Gold Scheme: `Icons.workspace_premium_rounded`
  - Privilege / Offer: `Icons.loyalty_rounded`
  - Security / Vault: `Icons.verified_user_rounded`
  - Notice / Unknown: `Icons.notifications_active_rounded`

### 6.9 Streamlined Settings & Security (`SettingsScreen`)
* **Focused Experience**: Theme, Appearance, and Language options have been **completely removed**.
* **Primary Capabilities**: Patron profile overview, UPI AutoPay toggle, Biometric Login toggle, 4-digit MPIN modal, Nominee Details modal, and BIS 24K Hallmarking legal terms.

