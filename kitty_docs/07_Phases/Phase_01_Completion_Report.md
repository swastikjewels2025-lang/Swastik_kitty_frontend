# Phase 1 Completion Report: Navigation Architecture & Shell Reorganization

## 1. Objective
Bring the application's navigation architecture in line with the approved 5-canonical destination navigation model (Option A: Home remains the primary landing destination) while preserving all existing functionality outside this phase.

---

## 2. Scope Implemented
- Restructured `StatefulShellRoute` from legacy 9-branch configuration to the canonical 5-branch layout.
- Restructured `AppBottomNavBar` to display exactly 5 approved destinations: **Home**, **My Kitty**, **Kitty Plans**, **Calculator**, and **Jewellery**.
- Completely removed **Coins** and **Menu** tabs from the bottom navigation dock.
- Relocated bullion coin purchase and rates to the navigation drawer.
- Reorganized `LuxuryNavDrawer` and `AppNavMenuConfig` into the 4 approved categories:
  1. **KITTY & SAVINGS** (My Kitty, Kitty Plans, Savings Passbook)
  2. **BULLION** (Gold Coins, Silver Coins)
  3. **ACCOUNT & COMPLIANCE** (Profile, KYC Compliance, Orders & Bookings, Settings & Security, Notifications)
  4. **CONCIERGE** (Concierge & Support modal with helpline, WhatsApp, and email)
- Reassigned supporting/off-dock screens (`/coin-rates`, `/passbook`, `/settings`, `/menu`) as top-level routes under `rootNavigatorKey`.
- Preserved Android hardware back button handler to close drawer or return to Tab 0 (Home) before app exit.
- Updated and verified the full widget test suite (151 passing tests) and confirmed zero static analysis issues.

---

## 3. Navigation Before
```text
Bottom Navigation Dock (5 tabs):
├── 0. Home
├── 1. Coins (Bullion rates & purchase)
├── 2. Jewellery (Showcase)
├── 3. My Scheme (Dashboard)
└── 4. Menu (Duplicate drawer links & settings)

Shell Branches (9 branches):
Branch 0: /home
Branch 1: /coin-rates
Branch 2: /jewellery
Branch 3: /dashboard
Branch 4: /menu
Branch 5: /calculator
Branch 6: /passbook
Branch 7: /offers
Branch 8: /settings
```

---

## 4. Navigation After
```text
Bottom Navigation Dock (5 canonical destinations):
├── 0. Home (HomeScreen)
├── 1. My Kitty (DashboardScreen)
├── 2. Kitty Plans (OffersScreen)
├── 3. Calculator (CalculatorScreen)
└── 4. Jewellery (JewelleryScreen)

Shell Branches (5 canonical branches):
Branch 0: /home -> HomeScreen
Branch 1: /dashboard -> DashboardScreen
Branch 2: /offers -> OffersScreen
Branch 3: /calculator -> CalculatorScreen
Branch 4: /jewellery -> JewelleryScreen

Top-Level Stack & Drawer Routes:
├── /coin-rates -> CoinRatesScreen (Accessible via Drawer Bullion section)
├── /passbook -> PassbookScreen (Accessible via Drawer & Dashboard action)
├── /settings -> SettingsScreen (Accessible via Drawer Account section)
├── /menu -> MenuScreen (Deep-link compatibility)
├── /orders -> OrdersScreen
├── /notifications -> NotificationsScreen
├── /kyc -> KycScreen
├── /checkout -> CheckoutScreen
├── /receipt/:id -> ReceiptScreen
└── /gokwik-gateway -> GokwikGatewayScreen
```

---

## 5. Files Changed
1. `lib/shared/widgets/navigation/app_bottom_nav_bar.dart`
   - Replaced legacy 5-tab list with Home, My Kitty, Kitty Plans, Calculator, Jewellery.
   - Added `maxLines: 1` and `TextOverflow.ellipsis` to labels to ensure robust rendering across all mobile form factors.
2. `lib/shared/widgets/navigation/app_shell_scaffold.dart`
   - Updated `_resolveBottomNavIndex` to map 0: `/home`, 1: `/dashboard`, 2: `/offers`, 3: `/calculator`, 4: `/jewellery`.
   - Updated `_onBottomNavTapped` to handle smooth branch switching.
3. `lib/core/routing/app_router.dart`
   - Pruned unused navigator keys (`_coinRatesNavigatorKey`, `_menuNavigatorKey`, `_passbookNavigatorKey`, `_settingsNavigatorKey`).
   - Restructured `StatefulShellRoute` indexedStack to 5 canonical branches.
   - Registered `/coin-rates`, `/passbook`, `/settings`, and `/menu` as top-level stack routes under `rootNavigatorKey`.
4. `lib/core/routing/route_paths.dart`
   - Formally updated and documented shell tab groupings vs. drawer & supporting stack routes.
5. `lib/shared/widgets/navigation/menu_items_config.dart`
   - Introduced `AppNavCategory` model.
   - Defined `AppNavMenuConfig.getCategories(...)` with 4 approved categories: KITTY & SAVINGS, BULLION, ACCOUNT & COMPLIANCE, CONCIERGE.
   - Preserved `getPrimaryItems(...)` for compatibility.
6. `lib/shared/widgets/navigation/luxury_nav_drawer.dart`
   - Restructured UI to render section headings for each approved category.
   - Added Concierge modal bottom sheet with toll-free helpline, WhatsApp, and priority email.
   - Structured logout action with confirmation dialog.
7. `test/widget/navigation/app_bottom_nav_bar_test.dart`
   - Updated widget tests to assert presence of 5 approved tabs and absence of Coins, Menu, and KYC.
8. `test/widget/navigation/luxury_nav_drawer_test.dart`
   - Updated widget tests to assert 4 categories, Gold Coins, Silver Coins, account features, and concierge modal.
9. `test/widget/routing/app_router_test.dart`
   - Updated declarative navigation tests to verify 5-branch switching and drawer route accessibility.
10. `test/widget/routing/all_routes_and_links_test.dart`
    - Updated bottom nav and drawer link tests to match new terminology.
11. `test/widget/menu/menu_screen_test.dart`
    - Updated assertions to match categorized drawer items.

---

## 6. Routes Changed
| Route Path | Old Placement | New Placement | Screen |
| :--- | :--- | :--- | :--- |
| `/home` | Shell Branch 0 | Shell Branch 0 | `HomeScreen` |
| `/dashboard` | Shell Branch 3 | Shell Branch 1 ("My Kitty") | `DashboardScreen` |
| `/offers` | Shell Branch 7 | Shell Branch 2 ("Kitty Plans") | `OffersScreen` |
| `/calculator` | Shell Branch 5 | Shell Branch 3 ("Calculator") | `CalculatorScreen` |
| `/jewellery` | Shell Branch 2 | Shell Branch 4 ("Jewellery") | `JewelleryScreen` |
| `/coin-rates` | Shell Branch 1 | Top-Level Route (Drawer Bullion) | `CoinRatesScreen` |
| `/passbook` | Shell Branch 6 | Top-Level Route (Drawer Savings) | `PassbookScreen` |
| `/settings` | Shell Branch 8 | Top-Level Route (Drawer Account) | `SettingsScreen` |
| `/menu` | Shell Branch 4 | Top-Level Route (Fallback) | `MenuScreen` |

---

## 7. Drawer Changes
- Categorized into 4 clear patron pillars:
  - **KITTY & SAVINGS**: My Kitty, Kitty Plans, Savings Passbook
  - **BULLION**: Gold Coins, Silver Coins (both linking to `/coin-rates` with full booking capabilities preserved)
  - **ACCOUNT & COMPLIANCE**: Profile, KYC Compliance, Orders & Bookings, Settings & Security, Notifications
  - **CONCIERGE**: Concierge & Support modal with Swastik toll-free helpline (`1800-SWASTIK`), WhatsApp assistance, and email support
- Retained bottom "Log Out of Account" destructive action with confirmation prompt.

---

## 8. Tests
- **Navigation Tests** (`test/widget/navigation/`): **PASSED** (all 5-tab, icon, and drawer tests)
- **Routing Tests** (`test/widget/routing/`): **PASSED** (all 5-branch switching, auth guards, and drawer tests)
- **Widget Test Suite** (`test/widget/`): **151 of 151 PASSED** (100% pass rate)

---

## 9. flutter analyze Result
```text
Analyzing kitty_app...
No issues found! (ran in 4.7s)
```
0 errors, 0 warnings, 0 lints.

---

## 10. Manual Verification Checklist
- [x] Bottom nav displays exactly 5 tabs: Home | My Kitty | Kitty Plans | Calculator | Jewellery.
- [x] Coins tab removed from bottom nav; accessible via Drawer under BULLION.
- [x] Menu tab removed from bottom nav; Drawer accessible via Header menu icon on all shell tabs.
- [x] Tapping My Kitty navigates to DashboardScreen.
- [x] Tapping Kitty Plans navigates to OffersScreen.
- [x] Tapping Calculator navigates to CalculatorScreen.
- [x] Tapping Jewellery navigates to JewelleryScreen.
- [x] Tapping Home navigates to HomeScreen.
- [x] Drawer slide-out works with brand header, patron profile, and 4 categories.
- [x] Drawer Gold Coins and Silver Coins open CoinRatesScreen.
- [x] Drawer KYC Compliance opens KycScreen.
- [x] Drawer Orders & Bookings opens OrdersScreen.
- [x] Drawer Settings & Security opens SettingsScreen.
- [x] Drawer Concierge & Support opens VIP Concierge modal.

---

## 11. Regression Checks
- [x] Authentication flows (Login -> Phone -> OTP -> Profile -> AuthSuccess -> Home) verified intact.
- [x] Deep links to `/home`, `/dashboard`, `/passbook`, `/offers`, `/coin-rates`, `/calculator`, `/jewellery` verified intact.
- [x] Android hardware back-button handler verified intact (closes drawer, or navigates back to Tab 0 before app exit).
- [x] Checkout and payment modal entry points from Dashboard and Passbook verified intact.
- [x] Existing uncommitted files and protected areas (`features/auth/*`, `features/checkout/*`, `features/kyc/*`, `pubspec.yaml`) remained untouched.

---

## 12. Git Status
Only Phase 1-scoped files modified/added:
- `lib/core/routing/route_paths.dart`
- `lib/core/routing/route_names.dart`
- `lib/core/routing/app_router.dart`
- `lib/shared/widgets/navigation/app_bottom_nav_bar.dart`
- `lib/shared/widgets/navigation/app_shell_scaffold.dart`
- `lib/shared/widgets/navigation/luxury_nav_drawer.dart`
- `lib/shared/widgets/navigation/menu_items_config.dart`
- `test/widget/navigation/app_bottom_nav_bar_test.dart`
- `test/widget/navigation/luxury_nav_drawer_test.dart`
- `test/widget/routing/app_router_test.dart`
- `test/widget/routing/all_routes_and_links_test.dart`
- `test/widget/menu/menu_screen_test.dart`

---

## 13. Git Commit
Prepared commit message:
`feat(kitty): phase 1 - navigation architecture & shell reorganization`

---

## 14. Known Limitations
None within the Phase 1 scope. Navigation architecture and shell routing are fully stable.

---

## 15. Deferred Work (Belongs to Later Phases)
- **Phase 2**: Terminology simplification across screens (purge of legacy jargon throughout feature UI).
- **Phase 3**: Home screen redesign (prominent Pay CTA, live benchmark gold strip, Kitty-first quick actions).
- **Phase 4**: Dedicated Live Rates board redesign.
- **Phase 5**: Kitty Plans benefit-first cards and bonus math presentation.
- **Phase 6**: Gold Valuation Calculator redesign (3-decimal precision, Karat selector, Start Kitty conversion CTA).
- **Phase 7**: Showroom Jewellery in-app WebView bridge.
- **Phases 8–11**: Interactive Kitty Number slot picker, guided Start Kitty flow, multi-month installment payments, multi-scheme dashboard.
