# Phase 5 Completion Report — Coins Experience Redesign (Gold & Silver Coins)

**Project**: Swastik Jewellers Kitty App  
**Phase**: Phase 5 of 10  
**Status**: COMPLETED & VERIFIED  
**Date**: 2026-09-29  

---

## 1. Objective

The objective of Phase 5 was to redesign the **Coins Experience** around two distinct product categories:
* **Gold Coins**
* **Silver Coins**

Strict architectural principles enforced:
1. **Drawer-Accessible Bullion Flow**: Kept off the bottom dock navigation, accessible exclusively via `LuxuryNavDrawer -> Bullion -> Gold Coins / Silver Coins`.
2. **Gold Coins Focus**: Predefined bullion weights strictly tailored to the approved 5g, 6g, and 7g denominations. 1g–4g and arbitrary weights removed from the primary table.
3. **Silver Independence**: Silver coins strictly omit all gold-karat selectors (24K, 22K, 18K, 14K), displaying 999 Fine Bullion Silver purity.
4. **Table-Style Layout & Book Now**: Compact, scannable table layout with direct `Book Now` CTA on every row, preserving bullion details and adding bookings to `OrdersController`.
5. **No Interference with Live Rates or Home**: Live Rates (`/live-rates`) and Home (`/home`) remain completely unchanged.

---

## 2. Coins Before vs. Coins After

| Attribute | Before (Legacy) | After (Phase 5 Redesign) |
| :--- | :--- | :--- |
| **Navigation Dock** | Competed as Bottom Tab 1 | **Drawer-Exclusive**: Located cleanly in Hamburger Menu -> BULLION |
| **Top Category Selector** | Basic tabs or mixed view | **Segmented Pill Selector**: Clear `[ GOLD COIN ]` / `[ SILVER COIN ]` with emerald active fill and accessibility semantics |
| **Gold Coins Table** | Scattered denominations (1g to 100g) with redundant Karat sub-lines | **Unified Table**: Focused 5g, 6g, 7g standard rows showing `Weight`, `Purity`, `Price`, and prominent `Book Now` CTA button |
| **Silver Coins Table** | Confused with gold purity or showed gold karats | **Dedicated Silver Rows**: 5g, 6g, 7g showing 999 Fine Bullion Silver, with zero karat controls |
| **Karat Selection** | Mixed globally and in rows | **Clean Separation**: Dynamic 24K, 22K, 18K, 14K selector strictly in Custom Gold Coin configuration; completely hidden for Silver |
| **Custom Coin Configurator** | Cluttered sliders | **Centered Luxury Section**: Headed by `──── CUSTOM COIN SELECTION ────`, side-by-side Karat/Weight chips, custom grams input, estimated price, and Book CTA |
| **Coin Calculator** | Full screen or mixed with Live Rates banner | **Dedicated Modal Popup**: Launched via top `[Calculator]` button, close icon (×) + bottom `Close` button, 3-decimal precision, zero live rates duplication |
| **Loading & Error** | Blank or partial rendering | **CoinsSkeletonLoader** shimmer skeleton + **KittyErrorState** with retry CTA |

---

## 3. Gold Coins Implementation

- **Predefined Weights**: Strictly `5 GM`, `6 GM`, `7 GM` (`GOLD COIN 999 5 GM`, `GOLD COIN 999 6 GM`, `GOLD COIN 999 7 GM`).
- **Purity Subtitle**: `24K (999) • BIS Hallmarked`.
- **Row Structure**: `PRODUCT (GM + Purity)` | `PRICE` | `[Book Now]`.
- **Booking Modal**: Displays weight, purity, BIS certification, total price, and allows immediate confirmation adding to `OrdersController` (`OrderCategory.coins`).

---

## 4. Silver Coins Implementation

- **Predefined Weights**: `5 GM`, `6 GM`, `7 GM` (`SILVER COIN 999 5 GM`, `SILVER COIN 999 6 GM`, `SILVER COIN 999 7 GM`).
- **Purity Subtitle**: `999 Fine Bullion Silver`.
- **Karat Exclusion**: Metallurgy of silver does not utilize karats. Karat selection is completely hidden in both standard table and custom selection (displaying `Select Purity` with `999 Fine`).
- **Booking Modal**: Displays weight, 999 Fine purity, anti-tarnish blister seal certification, total price, and confirmed booking.

---

## 5. Gold Karat Handling

- Supported purities in Custom Gold Coin configurator:
  - **24K**: 99.9% Pure Investment Bullion (1.0 fraction)
  - **22K**: 91.6% Pure Traditional Gold (22/24 fraction)
  - **18K**: 75.0% Fine Setting Gold (18/24 fraction)
  - **14K**: 58.5% Fine Gold (14/24 fraction)
- Switching between categories cleanly resets state (`_selectedGoldKarat = GoldKarat.k24;`) to eliminate stale cross-category values.

---

## 6. Coin Table & Book Now Flow

- Table header: `PRODUCT` (left) and `PRICE` (right, aligned with action buttons).
- Each row provides:
  - Weight and product name (`GOLD COIN 999 5 GM`)
  - Hallmark purity subtitle
  - Real-time calculated price
  - High-prominence `Book Now` pill button (`AppColors.honeyGoldAccent`)
- Tapping either the row or `Book Now` opens the luxury `AlertDialog`:
  - Validates grams, purity, and certification
  - Summarizes total amount
  - Adds booking into `OrdersController` with unique booking ID
  - Shows floating confirmation SnackBar

---

## 7. Custom Coin Flow

- Heading: `HomeSectionHeading(title: 'Custom Coin Selection')` (`──── CUSTOM COIN SELECTION ────`).
- Quick Preset Chips:
  - For Gold: Karat (24K, 22K, 18K, 14K) and Weight (8gm, 9gm, 10gm, 11gm)
  - For Silver: Purity (999 Fine) and Weight (8gm, 9gm, 10gm, 11gm)
- Custom Input: Numeric textfield with label `ENTER CUSTOM WEIGHT` supporting arbitrary decimal values (e.g., `7.5`, `12`, `25`).
- Real-time dynamic estimation box updating per-gram benchmark rate and total price.
- `Book [X]gm [Gold/Silver] Coin` button opening booking confirmation dialog.

---

## 8. Calculator Modal Popup

- Launched via prominent `[Calculator]` action button next to the category switcher.
- Modal bottom sheet (`CalculatorScreen.showAsModal(context)`) with top cross icon (`Icons.close_rounded`) and bottom `Close` button.
- 3-decimal precision formatting (`#,##0.000`).
- Strictly excludes duplicate Live Rates banners/cards to keep focus on pure valuation calculation.

---

## 9. API & Pricing Logic

- Reused existing data pipeline:
  - `homeControllerProvider` (`IGoldRateRepository` -> `LiveGoldRateEntity`)
  - Live 24K benchmark: `ratePerGram`
  - Live Silver benchmark: `silverRatePerGram`
- Pricing calculation rules:
  - Gold: `grams * (rate24k * purityFraction) + assayFee`
  - Silver: `grams * silverRate + assayFee`
- 60-second TTL caching prevents repeated API hits.
- Manual pull-to-refresh (`RefreshIndicator`) supported on the CustomScrollView.

---

## 10. Loading, Error & Empty States

1. **Loading State**: [`CoinsSkeletonLoader`](file:///d:/kitty_app/lib/features/coin_rates/presentation/widgets/coins_skeleton_loader.dart) displays shimmer placeholders for title, selector tabs, table header, 3 coin rows, and custom configuration card.
2. **Error State**: Displays [`KittyErrorState`](file:///d:/kitty_app/lib/shared/widgets/feedback/kitty_error_state.dart) (`Unable to Load Coin Rates`) with a `RETRY` button triggering `loadHomeData(force: true)`.
3. **Empty Data Handling**: If individual purities or rates are missing, fallbacks prevent crashes and maintain layout integrity.

---

## 11. Navigation Integration

- **Route Constant**: `RoutePaths.coinRates` (`/coin-rates`).
- **Router Configuration**: [`app_router.dart`](file:///d:/kitty_app/lib/core/routing/app_router.dart) supports `initialMetal` from `state.extra` or `state.uri.queryParameters['metal']`.
- **Drawer Integration**:
  - `LuxuryNavDrawer` passes `item.extra` to `context.go()`.
  - Drawer item `Gold Coins` opens `CoinRatesScreen(initialMetal: CoinMetal.gold)`.
  - Drawer item `Silver Coins` opens `CoinRatesScreen(initialMetal: CoinMetal.silver)`.
- **Bottom Navigation**: All 5 canonical tabs (`Home`, `My Kitty`, `Kitty Plans`, `Calculator`, `Jewellery`) remain 100% intact.

---

## 12. Accessibility & Responsive Verification

- **Semantics**: Added accessibility labels and `selected: isSelected` to Category tabs, Book Now buttons, and Custom Coin selector chips.
- **Responsiveness**: Sized table row content dynamically with `mainAxisSize: MainAxisSize.min` and flexible padding, eliminating `RenderFlex` overflows on compact screens.
- **Touch Targets**: All buttons meet minimum 44px/48px touch targets.

---

## 13. Files Changed & Created

### New Files
- [`lib/features/coin_rates/presentation/widgets/coins_skeleton_loader.dart`](file:///d:/kitty_app/lib/features/coin_rates/presentation/widgets/coins_skeleton_loader.dart)
- [`docs/07_Phases/Phase_05_Completion_Report.md`](file:///d:/kitty_app/docs/07_Phases/Phase_05_Completion_Report.md)

### Modified Files
- [`lib/features/coin_rates/presentation/screens/coin_rates_screen.dart`](file:///d:/kitty_app/lib/features/coin_rates/presentation/screens/coin_rates_screen.dart) — Added initialMetal, loading/error states, pull-to-refresh, table Book Now CTAs, and semantic accessibility.
- [`lib/shared/widgets/navigation/menu_items_config.dart`](file:///d:/kitty_app/lib/shared/widgets/navigation/menu_items_config.dart) — Added extra parameter to AppNavMenuItem and configured Gold/Silver items.
- [`lib/shared/widgets/navigation/luxury_nav_drawer.dart`](file:///d:/kitty_app/lib/shared/widgets/navigation/luxury_nav_drawer.dart) — Forwarded item.extra during drawer navigation.
- [`lib/core/routing/app_router.dart`](file:///d:/kitty_app/lib/core/routing/app_router.dart) — Passed initialMetal from route state to CoinRatesScreen.
- [`test/widget/coin_rates/coin_rates_screen_test.dart`](file:///d:/kitty_app/test/widget/coin_rates/coin_rates_screen_test.dart) — Added 4 new widget tests covering Book Now row buttons, initialMetal: silver, skeleton loading, and error state retry.

---

## 14. Verification & Test Results

### 1. Coin Rates Widget Tests (7/7 Passed)
```bash
flutter test test/widget/coin_rates/coin_rates_screen_test.dart
00:02 +7: All tests passed!
```
- Test 1: Renders Gold & Silver tabs, Gold starts from 5g without 1g-4g, and Karat is hidden for Silver — **PASSED**
- Test 2: Custom weight input field allows entering arbitrary decimal weight and updates booking — **PASSED**
- Test 3: Tapping Calculator button opens Calculator as a modal popup overlay with close controls and no live rates — **PASSED**
- Test 4: Each table row clearly displays Weight, Purity, Price, and Book Now button — **PASSED**
- Test 5: Opening with initialMetal: CoinMetal.silver starts with Silver Coins active and Karat hidden — **PASSED**
- Test 6: Renders skeleton loader during loading state — **PASSED**
- Test 7: Renders error state when rates fail and allows retry — **PASSED**

### 2. Regression Suites (13/13 Passed)
```bash
flutter test test/widget/routing/app_router_test.dart test/widget/navigation/luxury_nav_drawer_test.dart test/widget/live_rates/ test/widget/home/home_screen_test.dart
00:08 +13: All tests passed!
```

### 3. Static Analysis
```bash
flutter analyze
No issues found! (ran in 4.6s)
```
**0 errors, 0 warnings, 0 lints**.

---

## 15. Deferred Work

Per the approved roadmap:
- **Phase 6**: Kitty Number selection grid (01 to 50) and enrollment handoff.
- **Phase 7**: Multi-month payment selector in Checkout.
- **Phase 8**: In-app WebView for Showroom Jewellery.
- **Phase 9**: Secondary features polish (Orders & KYC drawer links).
- **Phase 10**: Full regression verification & accessibility audit.

---

## 16. Git Status & Readiness

```text
git status
```
All Phase 5 changes are verified, clean, and ready.
Per instructions, execution has stopped prior to `git commit` awaiting user review.
