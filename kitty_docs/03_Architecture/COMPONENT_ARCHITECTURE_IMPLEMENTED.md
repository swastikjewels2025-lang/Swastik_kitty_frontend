# Reusable Component Architecture — Kitty App

**Project**: Swastik Jewellers Kitty App (Sub-Brand: Kitty Vault)  
**Primary Codebase**: `D:\kitty_app\`  
**Document Status**: Synchronized with Current Implementation  
**Last Audit Date**: 2026-09-23  

---

## 1. Component Hierarchy & System Overview

All reusable UI components are encapsulated under `lib/shared/widgets/` and domain feature widget folders, engineered for zero unwanted rebuilds, responsive touch targets ($\ge 48$px), and luxury visual aesthetics.

---

## 2. Master Reusable Component Catalog

### 2.1 Navigation & Shell Components

#### `AppBottomNavBar`
* **File**: `lib/shared/widgets/navigation/app_bottom_nav_bar.dart`
* **Purpose**: Fixed bottom frosted-glass navigation dock.
* **Items (5 Destinations)**:
  1. Home (`Icons.home_outlined` / active: `Icons.home_rounded`)
  2. Coins (`Icons.monetization_on_outlined` / active: `Icons.monetization_on_rounded`)
  3. Jewellery (`Icons.diamond_outlined` / active: `Icons.diamond_rounded`)
  4. My Scheme (`Icons.workspace_premium_outlined` / active: `Icons.workspace_premium_rounded` — opens Dashboard / Active Kitty Plan)
  5. Menu (`Icons.menu_rounded` / active: `Icons.menu_open_rounded` — opens Fullscreen Menu)
* **Styling & Smart Indicator**: `BackdropFilter(sigma: 18)`, `pureWhite` background with 94% opacity, sliding emerald indicator capsule (`#18063D2E`). Indicator capsule opacity dynamically fades to 0.0 for off-dock destinations (`/passbook`, `/settings`, `/calculator`, `/offers`, etc.), guaranteeing zero false active highlights.

#### `HeaderNavBar`
* **File**: `lib/shared/widgets/navigation/header_nav_bar.dart`
* **Purpose**: Sticky luxury top application header.
* **Elements**:
  - **Left**: Live 24K gold rate ticker pill (`24K: ₹15,268/g`) with pulsating green status indicator.
  - **Center**: Authentic Swastik Jewellers brand crest (`assets/icons/swastiklogo.svg`).
  - **Right**: Notification Bell with unread badge counter (`NotificationBellBadge`) and 3-lines hamburger menu toggle (`Icons.menu_rounded`) opening the navigation drawer.

#### `LuxuryNavDrawer`
* **File**: `lib/shared/widgets/navigation/luxury_nav_drawer.dart`
* **Purpose**: Slide-out navigation drawer with high-prestige branding.
* **Elements**:
  - Patron Profile Card: Circular initial avatar, customer name, and phone number (Tier 1 badge removed).
  - Primary Navigation Links: Home, My Kitty Scheme, Passbook Ledger, Kitty Offers & Plans, Notifications (with unread badge), KYC Compliance, Settings & Security, and Log Out.

---

### 2.2 Home Page Components

#### `HomeOffersCarousel`
* **File**: `lib/features/home/presentation/widgets/home_offers_carousel.dart`
* **Purpose**: Top promotional banner carousel showcasing active schemes and offers.
* **Features**:
  - Positioned immediately beneath the header for maximum initial impact.
  - Elevated vertical height of **265px** providing generous breathing room for high-res imagery and legible typography.
  - Automatic periodic 5-second animated sliding with cubic transition curves.

#### `HomeGoldSilverRateCarousel`
* **File**: `lib/features/home/presentation/widgets/home_gold_silver_rate_carousel.dart`
* **Purpose**: Prominent royal emerald live rate card with auto-rotating carousel functionality.
* **Features**:
  - Alternates automatically between **Gold 24K (999)** and **999 Fine Silver** live benchmark rates.
  - Real-time rate data with 24h delta, chevron navigation arrows, and direct navigation to Coins.

#### `HomeJewelleryCollections`
* **File**: `lib/features/home/presentation/widgets/home_jewellery_collections.dart`
* **Purpose**: Circular curated category showcase.
* **Features**:
  - 6 circular category items (Rings, Earrings, Bangles, Necklaces, etc.) with gold rim borders and "View All" trigger to showroom.

#### `HomeSchemeCoinsQuickActions`
* **File**: `lib/features/home/presentation/widgets/home_scheme_coins_quick_actions.dart`
* **Purpose**: Dual quick action access to Gold Scheme and Coins.
* **Features**:
  - Deep emerald background card with 2 circular icon buttons floating half-in, half-out of the container.
  - Clean, modern iconography from the unified icon family: `Icons.workspace_premium_outlined` (Gold Scheme) and `Icons.monetization_on_outlined` (Coins).

#### `HomeGoldPriceTrend`
* **File**: `lib/features/home/presentation/widgets/home_gold_price_trend.dart`
* **Purpose**: Interactive gold rate trend visualization.
* **Features**:
  - Custom canvas painter (`_GoldTrendChartPainter`) plotting cubic bezier splines with gradient fills.
  - Interactive timeframe switcher: 1W, 1M, 6M, 1Y, 5Y.
  - 24K gain/loss indicator pill with percentage change.
  - 3 purity curves: 24K (dark gold solid), 22K (tan gold solid), 18K (rust-red dashed).
  - Y-axis price guidelines and X-axis formatted date intervals.

#### `HomeFooter`
* **File**: `lib/features/home/presentation/widgets/home_footer.dart`
* **Purpose**: Clean, elegant luxury footer.
* **Features**:
  - Navigation links: About Us, Contact Us, Privacy Policy, Terms of Use, Disclaimer.
  - Subtle divider line and copyright notice (`© 2026 Gold Calculator India · All rights reserved`).

---

### 2.3 Valuation & Transactional Components (2026-09-24)

#### `CalculatorScreen`
* **File**: `lib/features/calculator/presentation/screens/calculator_screen.dart`
* **Purpose**: Dedicated gold valuation calculator accessible via bottom dock.
* **Features**:
  - "Shop by Gram" and "Shop by Money" reactive mode switchers.
  - Karat selection chips (24K, 22K, 18K).
  - Dynamic computation card (Weight $\leftrightarrow$ Rate $\leftrightarrow$ Total Valuation).
  - Defensive states: Empty state, active calculation, invalid input, zero handling, decimals, and soft keyboard dismissal.

#### `PickCashSheet`
* **File**: `lib/features/checkout/presentation/widgets/pick_cash_sheet.dart`
* **Purpose**: Dedicated luxury bottom sheet for doorstep cash pickup collection.
* **Features**:
  - Pre-populates patron name, phone, email, and installment amount.
  - Address, city, and 6-digit postal pincode input fields with form validation.
  - Preferred pickup slot selector chips (Morning, Afternoon, Evening).
  - PMLA statutory compliance validation (under ₹2,00,000 ceiling).
  - Confirmation outcome card with pickup reference code (`PCK-XXXXXX`) and 6-digit physical handover OTP.


---

### 2.3 Progress & Metrics Components

#### `KittyCircularProgressGauge`
* **File**: `lib/shared/widgets/progress/kitty_circular_progress_gauge.dart`
* **Purpose**: Animated circular progress gauge displaying installment completion.
* **Props**: `completedMonths` (int), `totalMonths` (int), `radius` (double), `strokeWidth` (double).
* **Physics**: Sweeps from 0° to target arc over 800ms using `Curves.easeOutCubic`.

#### `PassbookSummaryCard`
* **File**: `lib/features/passbook/presentation/widgets/passbook_summary_card.dart`
* **Purpose**: 3-pillar metric summary strip for the Passbook ledger.
* **Pillars**:
  1. Total Deposited (₹40,000)
  2. Bonus Gold Accrued (5.482g)
  3. Next Due Date (15 Oct 2026)

#### `PassbookControlsRow`
* **File**: `lib/features/passbook/presentation/widgets/passbook_controls_row.dart`
* **Purpose**: Segmented control switcher between **Table View** and **Card View**.

---

### 2.4 Transaction & Receipt Components

#### `DigitalReceiptModal` / `ReceiptScreen`
* **File**: `lib/features/receipt/presentation/widgets/digital_receipt_modal.dart`
* **Purpose**: Parameterized official GST tax invoice voucher.
* **Elements**:
  - Tax invoice number, GSTIN, HSN gold bullion code.
  - Patron details, scheme membership ID, chit token (`#SW-042`).
  - Transaction reference number, bank payment gateway mode, paid date/time.
  - Swastik Jewellers official watermark verification stamp.
  - Action buttons: "Print Receipt" (triggers native printing) and "Close".

---

### 2.5 3D Procedural Canvas Engines

#### `Diamond3dPainter`
* **File**: `lib/features/splash/presentation/widgets/diamond_3d_painter.dart`
* **Purpose**: CustomPainter rendering 3D rotating diamond particle physics on the splash screen without external 3D engine overhead.

#### `JewelryConstellationPainter`
* **File**: `lib/features/auth/presentation/widgets/jewelry_constellation_painter.dart`
* **Purpose**: Continuous 24-second parametric rotation loop rendering solitaire diamond rings, bangles, and starburst sparkles on the Login and KYC screens.

---

### 2.6 Universal Feedback & Button Components

| Component | Location | Variants / States |
| :--- | :--- | :--- |
| `KittyPrimaryButton` | `lib/shared/widgets/buttons/kitty_primary_button.dart` | Default, Loading (gold spinner), Disabled. |
| `KittyEmptyState` | `lib/shared/widgets/feedback/kitty_empty_state.dart` | Configurable icon, title, description, and action button. |
| `KittyErrorState` | `lib/shared/widgets/feedback/kitty_error_state.dart` | Dark & Light surface variants with retry callback. |
| `KittyShimmer` | `lib/shared/widgets/feedback/kitty_shimmer.dart` | Metallic gold shimmering skeleton placeholder. |
