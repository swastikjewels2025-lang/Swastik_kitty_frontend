# Kitty App Phase-Wise Implementation Plan (Execution Blueprint)

**Project**: Swastik Jewellers Kitty App  
**Document Status**: Official Phase-Wise Execution Blueprint  
**Effective Date**: 2026-09-29  
**Canonical Path**: `KITTY FRONTEND/KITTY DOCS/07_Phases/KITTY_APP_PHASE_WISE_IMPLEMENTATION_PLAN.md`  
**Execution Rule**: **Implementation must proceed strictly phase-by-phase. No phase may begin until its prerequisites and acceptance gates are verified.**

---

## 1. Executive Summary & Readiness Verdict

Following the comprehensive Documentation Consolidation and Architecture Audit, the Kitty App redesign requirements have been mapped against the existing Flutter codebase (80 test suites, 9-branch StatefulShellRoute, Riverpod architecture).

### Overall Readiness Verdict: `PARTIAL / NOT READY FOR IMMEDIATE MASS-EXECUTION`
* **Track 1 (Client-Side Redesign — Phases 1 to 7)** is **READY FOR IMPLEMENTATION** upon resolving the Home vs. Tab 0 Navigation layout decision. It has zero backend blocking dependencies and operates entirely on existing repositories and local mocks.
* **Track 2 (Advanced Kitty Backend Features — Phases 8 to 11)** is **BLOCKED BY BACKEND IMPLEMENTATION & BUSINESS DECISIONS** (requires new endpoints for real-time number slot locking, multi-month payments, and multi-scheme dashboard).
* **Track 3 (Future Token Reservation & Early Settlement)** is **BLOCKED BY POLICY SIGN-OFF** (requires business rules for ₹100 token refundability and 12th-month bonus eligibility upon early payment).

This document serves as the exhaustive, dependency-sequenced engineering specification to execute the redesign safely without breaking existing authentication, KYC, GoKwik checkout, or passbook functionality.

---

## 2. Current Architecture Baseline & State Map

The current implementation in `D:\kitty_app` consists of:

| Architectural Component | Current Implementation | Files / Locations |
| :--- | :--- | :--- |
| **Routing Engine** | `go_router: ^14.8.1` with `StatefulShellRoute.indexedStack` managing 9 branch navigators. | `lib/core/routing/app_router.dart`, `route_paths.dart`, `route_names.dart` |
| **Bottom Navigation Dock** | 5-item frosted glass dock: `Home (0)`, `Coins (1)`, `Jewellery (2)`, `My Scheme (3)`, `Menu (4)`. | `lib/shared/widgets/navigation/app_bottom_nav_bar.dart` |
| **Drawer Navigation** | `LuxuryNavDrawer` providing duplicate access to Profile, Home, Schemes, Passbook, Orders, KYC, Settings. | `lib/shared/widgets/navigation/luxury_nav_drawer.dart` |
| **State Management** | `flutter_riverpod: ^2.6.1` with `StateNotifier` controllers for auth, home, dashboard, checkout, passbook, kyc. | `lib/features/*/presentation/providers/` |
| **Home Screen** | Dense 6-section layout: Gold rate strip, active scheme card, 12 mock jewellery items, coins carousel, store video, footer. | `lib/features/home/presentation/screens/home_screen.dart` |
| **Dashboard / My Scheme** | Single-scheme view with circular progress gauge, 4 numeric stat tiles, and small "Upcoming Installment" tap target. | `lib/features/dashboard/presentation/screens/dashboard_screen.dart` |
| **Kitty Plans / Offers** | List of scheme cards with basic duration and bonus text; enrol button opens plain amount dialog. | `lib/features/offers/presentation/screens/offers_screen.dart` |
| **Kitty Number Selection** | **Non-existent in current app**. Number assignment is implicit or handled offline. | None (Requires new feature module). |
| **Payment Flow** | Single-month payment only (`int monthFor`). Wires to GoKwik payment gateway via `gokwik_gateway_screen.dart`. | `lib/features/checkout/`, `lib/features/payment_gateway/` |
| **Live Rates** | Displayed as a small scrolling strip inside Home; coin rates displayed on separate `/coin-rates` screen. | `lib/features/home/`, `lib/features/coin_rates/` |
| **Calculator** | Modal sheet / sub-screen accessible from Menu with "Shop by Gram" and "Shop by Money". | `lib/features/calculator/presentation/screens/calculator_screen.dart` |
| **Jewellery Showcase** | Local Flutter widget list with 12 mock jewellery pieces (disconnected from live inventory). | `lib/features/jewellery/presentation/screens/jewellery_screen.dart` |
| **Authentication & KYC** | Complete phone/OTP flow with biometric setup and statutory Aadhaar/PAN image upload. | `lib/features/auth/`, `lib/features/kyc/` |

---

## 3. Master List of Approved Redesign Requirements

1. **Navigation**:
   - 5 canonical bottom navigation destinations: `Live Rates`, `My Kitty`, `Kitty Plans`, `Calculator`, `Jewellery`.
   - Complete removal of redundant Tab 4 "Menu" from the bottom bar.
   - Relocation of "Coins" (Bullion booking) from bottom bar into the Hamburger Drawer.
   - Comprehensive restructuring of `LuxuryNavDrawer` into 4 logical patron categories.
2. **Home Screen**:
   - Live gold rate top benchmark strip (24K & 22K per gram with live clock).
   - High-contrast Active My Kitty card featuring an unmistakable, full-width `[ PAY ₹5,000 NOW ]` primary CTA.
   - First-time saver state ("Start Your Kitty Journey") when patron has zero active schemes.
   - Special Kitty Privileges & Offers carousel (highlighting the 11+1 bonus month advantage).
   - 3 large, accessible Quick-Action cards: `Start Kitty`, `Gold Calculator`, `Showroom Jewellery`.
   - Concierge assistance & 1-tap showroom phone/WhatsApp dialer.
3. **My Kitty Dashboard**:
   - Simplification of financial metrics: Clear 12-dot or linear installment progress tracker.
   - Renaming "EMI / Target Amount" to intuitive terms: "Monthly Payment", "Total Gold Goal".
   - Direct secondary action: `[ Pay 2+ Months ]` and `[ View Passbook → ]`.
   - Support for multiple active concurrent Kitties via horizontal card swipe.
4. **Kitty Plans (Gold Schemes)**:
   - Benefit-first scheme cards showing monthly contribution, total tenure, and Swastik bonus contribution.
   - Clear visual math: *"You pay 11 months (₹55,000), Swastik adds 1 month (₹5,000) = ₹60,000 Jewellery"*.
   - Slide-up Kitty details sheet with plain-language rules, eligibility, and redemption guidelines.
5. **Kitty Number Selection (Slot Booking)**:
   - Interactive visual grid showing available, held, and booked numbers (e.g. 01 to 50 / 100).
   - Multi-modal state indicators (distinct color, shape, and text badge) ensuring accessibility for colorblind/elderly users.
   - Search filter for auspicious/lucky numbers (e.g., "07", "21", "51").
6. **Payment Experience**:
   - Multi-month installment selector (e.g. 1 Month, 2 Months, 3 Months, or All Remaining Months).
   - Total amount auto-calculation with zero confusing surcharges.
   - Full remaining balance settlement option for patrons wishing to complete plan early.
   - Preservation of existing GoKwik UPI/Card gateway and status polling reconciliation loop.
7. **Live Rates Screen**:
   - Clean, focused live rates board: 24K, 22K, 18K, 14K Gold + 999 Silver rate per gram.
   - Last updated timestamp with 1-tap manual refresh.
   - Complete removal of coin purchase forms from this screen.
8. **Gold Valuation Calculator**:
   - Dedicated full screen with "By Weight (Grams)" and "By Budget (Rupees)" modes.
   - Karat selector (24K, 22K, 18K) with 3-decimal precision for gold weight.
   - Clear output card showing estimated gold weight or total value.
   - Direct conversion CTA: `[ Start Kitty with this Budget ]`.
9. **Jewellery Web Experience**:
   - Official Swastik Jewellers catalog embedded via `webview_flutter`.
   - Native luxury header with loading progress bar, reload button, and Android hardware back-button interceptor.
10. **Language & Terminology Simplification**:
    - Complete purge of confusing jargon ("Bullion", "Assay", "Chit Token", "EMI", "Pre-Join").
    - Adoption of warm, universally understood terms ("Gold Rate", "Monthly Payment", "My Kitty", "Savings Passbook").
11. **Accessibility & State Handling**:
    - Minimum 52px touch targets across all interactive buttons.
    - 4.5:1 minimum AAA contrast ratio for gold and emerald text elements.
    - Human error states with "Retry" buttons and friendly empty states with active CTAs.

---

## 4. Requirement Traceability Matrix

| Requirement | Current Implementation | Files / Modules Affected | Frontend Scope | Backend Scope | DB Scope | Payment Impact | Business Rule | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **5-Tab Navigation** | 5 tabs with duplicate Menu & Coins | `app_router.dart`, `app_bottom_nav_bar.dart` | Restructure shell branches & icons | None | None | None | None | **Ready** |
| **Coins to Drawer** | Bottom tab 1 | `luxury_nav_drawer.dart`, `coin_rates_screen.dart` | Add drawer tile; keep existing route | None | None | None | None | **Ready** |
| **Home Redesign** | Dense storefront | `home_screen.dart`, widgets in `features/home` | Reorder hierarchy; prominent Pay CTA | None | None | None | None | **Ready** |
| **Dedicated Rates** | Ticker in Home | `coin_rates_screen.dart` or new `live_rates_screen.dart` | Clean rate board for 24K/22K/18K/14K/Silver | None | None | None | None | **Ready** |
| **My Kitty Dashboard** | 4 small metric tiles | `dashboard_screen.dart`, `dashboard_hero_card.dart` | Prominent Pay Now, simplified progress | None | None | None | None | **Ready** |
| **Kitty Plans Redesign**| Plain offer cards | `offers_screen.dart`, `offers_scheme_card.dart` | Benefit-first cards, bonus math callout | None | None | None | None | **Ready** |
| **Calculator Tab** | Modal overlay | `calculator_screen.dart` | Full tab; 3-decimal weight; Start Kitty CTA | None | None | None | None | **Ready** |
| **Jewellery WebView** | Mock widget grid | `jewellery_screen.dart` | Embed WebViewWidget with Swastik URL | None | None | None | Domain whitelist | **Ready** |
| **Kitty Number Matrix** | Offline / None | New `kitty_number_picker_sheet.dart`, `offers` | Interactive grid (Available, Held, Booked) | Slot API | Status fields | None | Hold duration | **Blocked** |
| **Multi-Month Pay** | Single month only | `checkout_screen.dart`, `i_payment_repository.dart` | 1, 2, 3 month radio/counter selector | Array of months | Ledger update | Multiplied total | Bonus impact | **Blocked** |
| **Full Balance Pay** | None | `checkout_screen.dart`, `payment_dto.dart` | Full balance payoff option | Settlement API | Maturity status | Gateway order | 12th mo rule | **Blocked** |
| **Multi-Kitty Swipe** | Single entity | `dashboard_controller.dart`, `dashboard_screen.dart` | Horizontal card carousel | Array of schemes| User-scheme rel | Specific ID pay | Max plans limit | **Blocked** |
| **Future Token Booking**| None | New reservation sheet in `offers` | ₹100 deposit flow with lucky number | Reservation API | Temp hold schema| ₹100 deposit order | Refund policy | **Blocked** |

---

## 5. Dependency & Prerequisite Mapping

Requirements are strictly categorized by their blocking external dependencies:

### Category A: Pure Frontend (Zero Backend Dependency — Execute First)
These phases use existing endpoints (`/api/v1/schemes`, `/api/v1/dashboard`, `/api/v1/gold-rates`), local mocks, and local state:
1. Navigation dock & drawer realignment.
2. Terminology simplification & design token contrast audit.
3. Home screen layout overhaul & 1-tap Pay Now card.
4. Dedicated Live Rates board.
5. Kitty Plans benefit-focused cards & details sheet.
6. Gold Valuation Calculator tab & conversion CTA.
7. Showroom Jewellery live in-app WebView.
8. Accessibility, friendly error states & skeleton loaders.

### Category B: Backend API Required (Mock First, Integrate When Ready)
Requires updates to Node.js / Express backend (`Swastik_kitty_backend`):
1. `GET /api/v1/schemes/:id/available-numbers` & `POST /api/v1/schemes/join` (accepting `selectedNumber`).
2. `POST /api/v1/payments/create-order` (accepting `months: [9, 10]` array).
3. `GET /api/v1/schemes/my-schemes` (returning `List<DashboardSummaryEntity>`).
4. `GET /api/v1/schemes/memberships/:id/settlement-summary` (full remaining balance breakdown).

### Category C: Database Required (MongoDB Schema Updates)
Documented in `05_Backend/BACKEND_DATABASE_CHANGES_V2.md`:
1. `KittyNumber` collection or schema field inside `Scheme` with states (`AVAILABLE`, `HELD`, `BOOKED`, `RESERVED`).
2. `membershipId` indexing to support 1-to-many relationship with user phone/ID.
3. Installment payment log supporting multi-month batch transaction records.

### Category D: Payment Gateway Required (GoKwik API Updates)
1. Order creation endpoint must calculate dynamic amount: `months.length * scheme.monthlyAmount`.
2. Webhook handler must mark multiple monthly installments as `PAID` in a single atomic database transaction.

### Category E: Business Decisions Required (Blocked on Executive Approval)
1. **Kitty Number Hold Duration**: How long is a selected number locked while patron is on checkout screen? *(Recommended: 15 minutes)*.
2. **Multi-Month Advance Payment Policy**: Does paying 3 months ahead allow skipping the next 3 calendar months, or does it accelerate maturity date? *(Recommended: Shifts next due date forward by N months)*.
3. **Full Remaining Balance & 12th Month Bonus**: If a patron pays all remaining months in Month 8, is the 12th month bonus credited immediately, or only upon reaching the 12th calendar month? *(Statutory Chit Fund / Gold Scheme legal compliance applies)*.
4. **₹100 Future Reservation Deposit**: Is the ₹100 deposit refundable if the customer does not join? How is it adjusted against Month 1? *(Must have signed written policy before coding)*.

---

## 6. Risk Register

| Risk ID | Risk Description | Severity | Impacted Area | Mitigation Strategy |
| :---: | :--- | :---: | :--- | :--- |
| **RSK-01** | Bottom nav restructure breaks active `StatefulShellRoute` tab state. | High | Navigation / Core | Update shell branch indices in lockstep with `app_bottom_nav_bar.dart` and maintain existing URL paths. |
| **RSK-02** | Home screen missing from bottom dock confuses patrons. | High | UX / Discovery | Keep Tab 0 as Home with prominent Live Rate strip, OR clearly anchor Home via top Swastik logo. |
| **RSK-03** | Multi-month payment order rejected by existing backend (`monthFor: int`). | Critical | Checkout / Revenue | Guard multi-month UI behind a feature flag; fall back to single month if backend v2 is unavailable. |
| **RSK-04** | Race condition: Two patrons pick the same lucky Kitty number simultaneously. | High | Kitty Number Selection | Implement optimistic local locking with 15-minute backend reservation timeout. |
| **RSK-05** | In-app WebView gets rejected by Apple App Store (Guideline 4.2 Minimum Functionality). | Medium | Jewellery Tab | Wrap WebView in native luxury chrome with store locator, favorites, and share actions. |
| **RSK-06** | Hardware back-button on Android exits app unexpectedly from sub-tabs. | Medium | Navigation / Android | Implement `PopScope` root handler routing back to Tab 0 before application exit. |

---

## 7. Open Architectural Decisions

### Open Decision 1: Home Screen Placement in Bottom Navigation
* **Why Needed**: The UX audit proposal defines 5 bottom tabs: `Live Rates`, `My Kitty`, `Kitty Plans`, `Calculator`, `Jewellery`. Home is described in Section 5 with high priority.
* **Option A**: Tab 0 is **Home** (incorporating Today's Live Rates strip at top, Active Kitty card, Offers carousel, and Quick Actions). Live Rates detail page is opened from the strip.
* **Option B**: Tab 0 is **Live Rates** (pure rates board), Tab 1 is **My Kitty**, Tab 2 is **Kitty Plans**, Tab 3 is **Calculator**, Tab 4 is **Jewellery**. Home is accessed via the Swastik logo in HeaderNavBar.
* **Recommendation**: **Option A**. Indian jewellery patrons expect a central Home hub. Tapping Tab 0 should show Home with Live Rates as the top hero strip.

### Open Decision 2: Backend Mocking vs. Live Staging for Number Booking
* **Why Needed**: Backend endpoints for number selection (`GET /api/v1/schemes/:id/available-numbers`) are not yet deployed.
* **Option A**: Wait for backend team to deploy before starting Phase 8.
* **Option B**: Build a robust `MockSchemeRepository` extension generating realistic slot matrices (1 to 50) with simulated availability and 15-minute local locks.
* **Recommendation**: **Option B**. Allows frontend UI/UX completion and full test coverage without blocking on backend sprint cycles.

---

## 8. Master Phase Breakdown & Implementation Sequence

```
[PHASE 0: DOCUMENTATION, AUDIT & CONTRACT FREEZE] -> COMPLETED
   │
   ▼
[TRACK 1: CLIENT-SIDE UX & NAVIGATION — ZERO BACKEND BLOCKERS]
├── PHASE 1: Navigation Architecture & Shell Reorganization
├── PHASE 2: Terminology Simplification & Design Token Alignment
├── PHASE 3: Home Screen Redesign (Kitty-First Hub & 1-Tap Pay)
├── PHASE 4: Dedicated Live Rates Screen & Bullion Uncluttering
├── PHASE 5: Kitty Plans (Gold Schemes) Benefit-First Presentation
├── PHASE 6: Gold Valuation Calculator Screen & Conversion Flow
└── PHASE 7: Showroom Jewellery In-App Web Bridge
   │
   ▼
[TRACK 2: ADVANCED KITTY FEATURES & BACKEND V2 INTEGRATION]
├── PHASE 8: Interactive Kitty Number (Slot) Selection Matrix
├── PHASE 9: Guided "Start Kitty" Multi-Step Enrollment Flow
├── PHASE 10: Multi-Month Installment Payment Engine
└── PHASE 11: Multi-Scheme Dashboard Management
   │
   ▼
[TRACK 3: SECONDARY FEATURES, POLISH & PRODUCTION RELEASE]
├── PHASE 12: Coins & Bullion Drawer Repositioning Polish
├── PHASE 13: Accessibility, Friendly Error & Empty State Hardening
└── PHASE 14: Comprehensive Regression, Security & Release QA
```

---

## 9. Detailed Phase Specifications (Execution-Ready)

### PHASE 1 — Navigation Architecture & Shell Reorganization
* **Objective**: Restructure application shell from legacy 9-branch/confusing 5-dock layout to the approved 5-tab Kitty-first dock and restructured luxury drawer.
* **Scope**: Update `route_paths.dart`, `route_names.dart`, `app_router.dart`, `app_bottom_nav_bar.dart`, and `luxury_nav_drawer.dart`.
* **Files Expected to Change**:
  - `lib/core/routing/route_paths.dart`
  - `lib/core/routing/route_names.dart`
  - `lib/core/routing/app_router.dart`
  - `lib/shared/widgets/navigation/app_bottom_nav_bar.dart`
  - `lib/shared/widgets/navigation/app_shell_scaffold.dart`
  - `lib/shared/widgets/navigation/luxury_nav_drawer.dart`
* **Files NOT to Change**: `lib/features/auth/*`, `lib/features/checkout/*`, `lib/features/kyc/*`.
* **Prerequisites**: Phase 0 completion.
* **Dependencies**: Frontend Only (Zero Backend, Zero DB, Zero Payment).
* **UI/UX Reference**: Section 4 of Redesign Audit.
* **Acceptance Criteria**:
  1. Bottom nav displays exactly 5 tabs: `Home` (or `Live Rates`), `My Kitty`, `Kitty Plans`, `Calculator`, `Jewellery`.
  2. Tab 4 "Menu" is completely removed from the bottom dock.
  3. Header hamburger button slides out `LuxuryNavDrawer` reliably.
  4. Drawer contains 4 categories: Kitty & Savings, Bullion & Orders (Coins), Account & Compliance, Concierge.
  5. Back button on Android navigates to Tab 0 before exiting app.
* **Testing Requirements**:
  - Update `test/widget/navigation/app_bottom_nav_bar_test.dart`.
  - Update `test/widget/navigation/luxury_nav_drawer_test.dart`.
  - Update `test/widget/routing/app_router_test.dart`.
* **Regression Checks**: Deep links to `/home`, `/dashboard`, `/passbook`, `/offers` must continue functioning.
* **Git Commit**: `feat(kitty): phase 1 - navigation architecture & shell reorganization`

---

### PHASE 2 — Terminology Simplification & Design Token Alignment
* **Objective**: Replace technical/corporate financial jargon across all UI text with warm, simple, universally understood terms; ensure minimum 52px touch targets and AAA contrast.
* **Scope**: Update labels, text constants, and theme typography across core widgets.
* **Files Expected to Change**:
  - `lib/core/constants/app_colors.dart`
  - `lib/core/constants/app_dimensions.dart`
  - `lib/core/constants/app_typography.dart`
  - `lib/shared/widgets/buttons/kitty_primary_button.dart`
  - `lib/shared/widgets/display/kitty_section_header.dart`
* **Files NOT to Change**: Backend DTO field names, API contracts.
* **Prerequisites**: Phase 1.
* **Dependencies**: Frontend Only.
* **UI/UX Reference**: Section 10 & 14 of Redesign Audit.
* **Acceptance Criteria**:
  1. "EMI" replaced with "Monthly Payment" across all screens.
  2. "Target Amount" replaced with "Total Gold Goal".
  3. "Chit Token" replaced with "Kitty ID".
  4. All primary action buttons have a minimum physical height of 52px.
  5. Text contrast on gold/emerald surfaces meets WCAG AAA standards.
* **Testing Requirements**:
  - Widget tests for button sizes and typography rendering.
* **Regression Checks**: Ensure no backend serialization keys are altered while updating presentation text.
* **Git Commit**: `style(kitty): phase 2 - terminology simplification & design token alignment`

---

### PHASE 3 — Home Screen Redesign (Kitty-First Hub & 1-Tap Pay)
* **Objective**: Overhaul Home screen into an actionable Kitty hub featuring today's gold rate strip, prominent Active Kitty Card with 1-tap Pay Now, special Kitty privileges carousel, and 3 quick-action cards.
* **Scope**: Redesign `home_screen.dart` and its sub-widgets.
* **Files Expected to Change**:
  - `lib/features/home/presentation/screens/home_screen.dart`
  - `lib/features/home/presentation/widgets/home_gold_rate_strip.dart`
  - `lib/features/home/presentation/widgets/home_active_kitty_card.dart`
  - `lib/features/home/presentation/widgets/home_offers_carousel.dart`
  - `lib/features/home/presentation/widgets/home_quick_actions.dart`
* **Files NOT to Change**: `lib/features/home/data/*` (repositories remain intact).
* **Prerequisites**: Phase 1, Phase 2.
* **Dependencies**: Frontend Only (Consumes existing `homeControllerProvider` and `dashboardControllerProvider`).
* **UI/UX Reference**: Section 5 of Redesign Audit.
* **Acceptance Criteria**:
  1. Top fold features live gold rate strip (24K & 22K per gram with live clock).
  2. Active Kitty Card prominently displays installment progress and a full-width `[ PAY ₹5,000 NOW ]` CTA.
  3. Tapping `[ PAY NOW ]` opens payment checkout directly (2 taps to payment confirmation).
  4. Users with zero active schemes see welcoming "Start Your Kitty Journey" card with benefits.
  5. Quick action cards link to Start Kitty, Calculator, and Showroom Jewellery.
* **Testing Requirements**:
  - Update `test/widget/home/home_screen_test.dart`.
  - Verify zero-scheme empty state and active-scheme populated state.
* **Regression Checks**: Live rate polling and gold trend data binding must remain unaffected.
* **Git Commit**: `feat(kitty): phase 3 - home screen redesign with 1-tap pay hero`

---

### PHASE 4 — Dedicated Live Rates Screen & Bullion Uncluttering
* **Objective**: Provide an uncluttered, dedicated Live Rates board displaying 24K, 22K, 18K, 14K Gold and 999 Silver prices per gram with last updated timestamp and refresh button.
* **Scope**: Create or update live rates presentation screen; remove coin purchasing forms from rate view.
* **Files Expected to Change**:
  - `lib/features/coin_rates/presentation/screens/coin_rates_screen.dart` (or new `live_rates_screen.dart`)
  - `lib/features/coin_rates/presentation/providers/coin_rates_controller.dart`
* **Prerequisites**: Phase 1, Phase 2.
* **Dependencies**: Frontend Only.
* **UI/UX Reference**: Section 9.1 of Redesign Audit.
* **Acceptance Criteria**:
  1. Clean rates board showing 24K, 22K, 18K, 14K Gold & Silver rates.
  2. Last updated timestamp displayed with pull-to-refresh / tap-to-refresh.
  3. Bullion coin booking widgets removed from this screen (moved to Hamburger -> Coins).
* **Testing Requirements**:
  - Widget test for rate board rendering and rate calculation accuracy.
* **Regression Checks**: Existing bullion booking flow must remain fully functional when accessed via drawer.
* **Git Commit**: `feat(kitty): phase 4 - dedicated live rates board`

---

### PHASE 5 — Kitty Plans (Gold Schemes) Benefit-First Presentation
* **Objective**: Redesign Kitty Plans catalog into clean, benefit-focused cards highlighting Swastik's 11+1 bonus contribution and slide-up scheme details sheet.
* **Scope**: Redesign `offers_screen.dart` and `offers_scheme_card.dart`.
* **Files Expected to Change**:
  - `lib/features/offers/presentation/screens/offers_screen.dart`
  - `lib/features/offers/presentation/widgets/offers_scheme_card.dart`
  - `lib/features/offers/presentation/widgets/offers_product_detail_sheet.dart`
* **Prerequisites**: Phase 1, Phase 2.
* **Dependencies**: Frontend Only (Consumes existing `ISchemeRepository`).
* **UI/UX Reference**: Section 4.1 & 12 of Redesign Audit.
* **Acceptance Criteria**:
  1. Plan card highlights: Monthly amount, total months (e.g. 11+1), Swastik bonus contribution.
  2. Bonus math clearly stated: *"Pay ₹55,000 across 11 months, Get ₹60,000 Jewellery"*.
  3. Tapping a card opens slide-up detail sheet with redemption rules and plain-language FAQ.
  4. Primary `[ Start Kitty ]` CTA initiates the enrollment flow.
* **Testing Requirements**:
  - Update `test/widget/offers/offers_screen_test.dart`.
* **Regression Checks**: Existing scheme filtering by duration must continue working.
* **Git Commit**: `feat(kitty): phase 5 - kitty plans benefit-first presentation`

---

### PHASE 6 — Gold Valuation Calculator Screen & Conversion Flow
* **Objective**: Elevate the Gold Calculator to a first-class screen with "By Weight" and "By Budget" modes, 3-decimal precision, and direct "Start Kitty with this Budget" conversion CTA.
* **Scope**: Refactor `calculator_screen.dart` from modal overlay into full-fledged screen.
* **Files Expected to Change**:
  - `lib/features/calculator/presentation/screens/calculator_screen.dart`
  - `lib/features/calculator/presentation/widgets/calculator_input_card.dart`
* **Prerequisites**: Phase 1, Phase 2.
* **Dependencies**: Frontend Only.
* **UI/UX Reference**: Section 9.2 of Redesign Audit.
* **Acceptance Criteria**:
  1. Two clear tabs: "By Weight (Grams)" and "By Budget (Rupees)".
  2. Karat selector: 24K, 22K, 18K.
  3. Weight input supports up to 3 decimal places (e.g. 12.450 g).
  4. Output card calculates real-time estimate based on live rates.
  5. Action button below result: `[ Start Kitty with this Budget ]` opens Kitty Plans filtered to closest monthly budget.
* **Testing Requirements**:
  - Unit tests for valuation math across karats and weights.
  - Widget tests for input switching and validation.
* **Regression Checks**: Verify dynamic rate sync with `homeControllerProvider`.
* **Git Commit**: `feat(kitty): phase 6 - gold valuation calculator screen & conversion flow`

---

### PHASE 7 — Showroom Jewellery In-App Web Bridge
* **Objective**: Replace static 12-item mock jewellery grid with official Swastik Jewellers catalog embedded via `webview_flutter` inside a luxury native container.
* **Scope**: Refactor `jewellery_screen.dart` to host `WebViewWidget` with luxury app bar, loading progress bar, reload button, and back-button pop interceptor.
* **Files Expected to Change**:
  - `lib/features/jewellery/presentation/screens/jewellery_screen.dart`
* **Prerequisites**: Phase 1, Phase 2.
* **Dependencies**: Frontend Only (`webview_flutter: ^4.14.1` already installed in `pubspec.yaml`).
* **UI/UX Reference**: Section 8 of Redesign Audit.
* **Acceptance Criteria**:
  1. Official Swastik website URL loads securely in-app.
  2. Linear progress bar shows page loading status.
  3. Luxury app bar features reload button and store phone shortcut.
  4. Android back button navigates internal web history before popping the screen.
  5. Graceful offline/network error banner with retry button.
* **Testing Requirements**:
  - Widget test with mocked `WebViewController`.
* **Regression Checks**: Deep link navigation to `/jewellery` works seamlessly.
* **Git Commit**: `feat(kitty): phase 7 - showroom jewellery in-app web bridge`

---

### PHASE 8 — Interactive Kitty Number (Slot) Selection Matrix
* **Objective**: Build the guided Kitty Number picker grid showing available, held, and booked numbers (01 to 50/100) with multi-modal visual accessibility indicators and lucky number search.
* **Scope**: Create `lib/features/offers/presentation/widgets/kitty_number_picker_sheet.dart`, update scheme models and repositories.
* **Files Expected to Change**:
  - `lib/features/offers/domain/entities/scheme_entity.dart`
  - `lib/features/offers/domain/repositories/i_scheme_repository.dart`
  - `lib/features/offers/data/repositories/mock_scheme_repository.dart`
  - `lib/features/offers/presentation/widgets/kitty_number_picker_sheet.dart`
* **Prerequisites**: Phase 5.
* **Dependencies**: Backend API Required (Mocked in Frontend first per Open Decision 2).
* **UI/UX Reference**: Section 6 of Redesign Audit.
* **Acceptance Criteria**:
  1. Grid shows numbers with triple-encoding: Color + Icon/Shape + Text Badge (`Available`, `Selected`, `Booked`).
  2. Lucky number search filter finds specific numbers immediately.
  3. Selecting a number locks it locally and passes `selectedNumber` to enrollment summary.
  4. Already booked numbers cannot be tapped (haptic rejection).
* **Testing Requirements**:
  - Unit tests for slot availability filtering.
  - Widget tests for grid tap selection and accessibility semantics.
* **Regression Checks**: Existing scheme enrollment without number selection must remain backwards compatible.
* **Git Commit**: `feat(kitty): phase 8 - interactive kitty number slot matrix`

---

### PHASE 9 — Guided "Start Kitty" Multi-Step Enrollment Flow
* **Objective**: Unify Scheme selection, Number picking, Patron details confirmation, and Month 1 checkout into a seamless 3-step wizard.
* **Scope**: Implement `start_kitty_flow_sheet.dart` connecting Kitty Plans to Checkout.
* **Files Expected to Change**:
  - `lib/features/offers/presentation/widgets/offers_enrollment_dialog.dart`
  - `lib/features/checkout/presentation/screens/checkout_screen.dart`
* **Prerequisites**: Phase 5, Phase 8.
* **Dependencies**: Frontend + Mocked Backend.
* **UI/UX Reference**: Section 6.3 of Redesign Audit.
* **Acceptance Criteria**:
  1. Step 1: Confirm monthly amount and tenure.
  2. Step 2: Choose lucky Kitty number.
  3. Step 3: Review summary (Month 1 due = ₹5,000) -> Tap `[ Pay ₹5,000 & Activate Kitty ]`.
  4. Handoff seamlessly into `CheckoutScreen` with scheme details.
* **Testing Requirements**:
  - Integration widget test spanning Start Kitty wizard through Checkout.
* **Regression Checks**: Direct checkout for existing installments must remain intact.
* **Git Commit**: `feat(kitty): phase 9 - guided start kitty multi-step enrollment flow`

---

### PHASE 10 — Multi-Month Installment Payment Engine
* **Objective**: Allow patrons to select and pay multiple months at once (e.g. 1 Month, 2 Months, 3 Months, or Full Balance) in a single checkout order.
* **Scope**: Update `IPaymentRepository`, `PaymentDto`, `CheckoutScreen`, and `PaymentCheckoutModal`.
* **Files Expected to Change**:
  - `lib/features/checkout/domain/repositories/i_payment_repository.dart`
  - `lib/features/checkout/data/dtos/payment_dto.dart`
  - `lib/features/checkout/data/repositories/mock_payment_repository.dart`
  - `lib/features/checkout/presentation/providers/payment_controller.dart`
  - `lib/features/checkout/presentation/screens/checkout_screen.dart`
  - `lib/features/checkout/presentation/widgets/payment_checkout_modal.dart`
* **Prerequisites**: Phase 3, Phase 1.
* **Dependencies**: Backend API + Gateway Update (Mocked first).
* **UI/UX Reference**: Section 7 of Redesign Audit & `05_Backend/BACKEND_MULTI_MONTH_PAYMENT_SPEC_V1.md`.
* **Acceptance Criteria**:
  1. Segmented pill selector: `1 Month (₹5,000)` | `2 Months (₹10,000)` | `3 Months (₹15,000)` | `All Remaining`.
  2. Total payable amount updates dynamically with zero hidden fees.
  3. Order creation sends `months: [9, 10]` to repository.
  4. Successful payment updates passbook and dashboard for all selected months.
* **Testing Requirements**:
  - Unit tests for multi-month order total calculation.
  - Widget tests for month selector interaction and checkout handoff.
* **Regression Checks**: Single-month standard payment must continue working identically.
* **Git Commit**: `feat(kitty): phase 10 - multi-month installment payment engine`

---

### PHASE 11 — Multi-Scheme Dashboard Management
* **Objective**: Upgrade the My Kitty dashboard to support patrons holding multiple concurrent active Kitty schemes via horizontal card swipe.
* **Scope**: Update `dashboard_controller.dart`, `dashboard_screen.dart`, and repository interfaces.
* **Files Expected to Change**:
  - `lib/features/dashboard/domain/repositories/i_dashboard_repository.dart`
  - `lib/features/dashboard/data/repositories/mock_dashboard_repository.dart`
  - `lib/features/dashboard/presentation/providers/dashboard_controller.dart`
  - `lib/features/dashboard/presentation/screens/dashboard_screen.dart`
* **Prerequisites**: Phase 3, Phase 10.
* **Dependencies**: Backend API Required (`05_Backend/BACKEND_MULTI_KITTY_SPEC_V1.md`).
* **UI/UX Reference**: Section 16 of Redesign Audit.
* **Acceptance Criteria**:
  1. Dashboard displays horizontal swipeable cards when patron has >1 active scheme.
  2. Each card shows distinct Kitty ID, installment count, and dedicated `[ PAY NOW ]` CTA.
  3. Tapping Pay Now on Card 2 passes specific `membershipId` to checkout.
  4. Smooth page-indicator dots denote current card index.
* **Testing Requirements**:
  - Unit tests for multi-scheme state mapping.
  - Widget tests for horizontal card paging and scheme selection.
* **Regression Checks**: Patrons with exactly 1 scheme see a single stationary hero card without indicator clutter.
* **Git Commit**: `feat(kitty): phase 11 - multi-scheme dashboard management`

---

### PHASE 12 — Coins & Bullion Drawer Repositioning Polish
* **Objective**: Verify and polish the Gold & Silver coin booking flow when launched from Hamburger Drawer -> Bullion & Coins.
* **Scope**: Review `coin_rates_screen.dart` routes, drawer menu item, and booking confirmation.
* **Files Expected to Change**:
  - `lib/features/coin_rates/presentation/screens/coin_rates_screen.dart`
  - `lib/shared/widgets/navigation/luxury_nav_drawer.dart`
* **Prerequisites**: Phase 1, Phase 4.
* **Dependencies**: Frontend Only.
* **Acceptance Criteria**:
  1. Hamburger drawer tile "Gold & Silver Coins" navigates cleanly to `/coin-rates`.
  2. 1gm to 10gm coin selector, live pricing, and booking flow function with zero regression.
  3. Clean header with back-arrow returning to previous shell tab.
* **Testing Requirements**:
  - Widget test for drawer to coin rates navigation flow.
  - Regression test for coin booking API call.
* **Regression Checks**: Existing coin order creation and order history tracking must remain fully functional.
* **Git Commit**: `feat(kitty): phase 12 - coins & bullion drawer repositioning polish`

---

### PHASE 13 — Accessibility, Friendly Error & Empty State Hardening
* **Objective**: Implement human-centered error messages, friendly empty states with active CTAs, skeleton loaders, and verified accessibility standards.
* **Scope**: Update feedback widgets, error interceptors, and empty state cards.
* **Files Expected to Change**:
  - `lib/shared/widgets/feedback/kitty_empty_state.dart`
  - `lib/shared/widgets/feedback/kitty_error_state.dart`
  - `lib/features/dashboard/presentation/widgets/dashboard_skeleton_loader.dart`
  - `lib/features/passbook/presentation/widgets/passbook_skeleton_loader.dart`
* **Prerequisites**: Phases 1 through 12.
* **Dependencies**: Frontend Only.
* **UI/UX Reference**: Section 13 & 14 of Redesign Audit.
* **Acceptance Criteria**:
  1. Zero raw technical errors (no DioException strings or HTTP status codes shown to user).
  2. Every error state features a friendly explanation and prominent `[ Try Again ]` button.
  3. Empty passbook displays encouraging message: *"Your payments will appear here as soon as you make your first deposit"*.
  4. Screen readers announce button semantics and Kitty states clearly.
* **Testing Requirements**:
  - Unit tests for error mapping.
  - Widget tests verifying empty and error states across all tabs.
* **Regression Checks**: Ensure retry buttons cleanly trigger controller refresh hooks.
* **Git Commit**: `feat(kitty): phase 13 - accessibility, error & empty state hardening`

---

### PHASE 14 — Comprehensive Regression, Security & Release QA
* **Objective**: Execute end-to-end regression validation across all 80+ existing test suites and complete new widget tests; verify security and release build integrity.
* **Scope**: Full test execution, static analysis, Android release APK build verification.
* **Files Expected to Change**:
  - Test suites in `test/unit/`, `test/widget/`, `test/integration/`.
* **Prerequisites**: All preceding phases.
* **Dependencies**: All.
* **Acceptance Criteria**:
  1. `flutter analyze` passes with zero errors and zero warnings.
  2. All unit, widget, and integration tests pass with 100% success rate.
  3. Zero regressions in Authentication (JWT, OTP, Biometric lock).
  4. Zero regressions in KYC statutory document upload.
  5. Zero regressions in GoKwik checkout launch and receipt PDF generation.
* **Testing Requirements**:
  - Run full automated test suite: `flutter test`.
* **Regression Checks**: Complete end-to-end customer journey from login to payment receipt.
* **Git Commit**: `test(kitty): phase 14 - comprehensive regression, security & release qa`

---

## 10. Phase Execution Lifecycle & Quality Gate

To guarantee stability, every future phase must strictly adhere to this 9-step execution cycle:

```
[1. READ PHASE SPEC] -> [2. INSPECT CODEBASE] -> [3. CREATE CHECKLIST]
         │
         ▼
[4. IMPLEMENT ONLY SCOPE] -> [5. RUN STATIC ANALYSIS] -> [6. RUN AUTOMATED TESTS]
         │
         ▼
[7. MANUAL EMULATOR RUN] -> [8. UPDATE PHASE REPORT] -> [9. GIT ATOMIC COMMIT]
```

Under no circumstances may multiple phases be combined into a single monolithic commit.

---

## 11. Definition of Done (DoD)

A phase is considered **DONE** only when:
1. All acceptance criteria for the phase are verified and met.
2. `flutter analyze` reports zero errors and zero warnings on modified files.
3. Relevant unit and widget tests are created/updated and passing.
4. Existing regression check suite passes without failures.
5. `Phase_X_Completion_Report.md` is created in `KITTY FRONTEND/KITTY DOCS/07_Phases/`.
6. Atomic Git commit is created matching the defined convention: `type(kitty): phase X - <description>`.
