# Kitty App Implementation Plan V2 (Dependency-Aware Master Roadmap)

**Project**: Swastik Jewellers Kitty App  
**Document Status**: Official Frontend Implementation Plan & Roadmap (V2)  
**Effective Date**: 2026-09-29  
**Execution Rule**: **Implementation must NOT begin until this plan is formally reviewed and approved.**  

---

## 1. Roadmap Architecture & Dependency Logic

The implementation roadmap is structured around a strict **dependency-first sequencing model**:
* **Track 1 (Phases 1 through 6)**: Pure frontend UX simplification. Relies **100% on existing APIs and local mocks**. Zero backend blocking. Can begin immediately upon approval.
* **Track 2 (Phases 7 through 10)**: Advanced Kitty features requiring backend endpoints (real-time slot locking, multi-month payments, multi-kitty dashboard). Wires into backend staging as APIs become available.
* **Track 3 (Phase 11)**: Advanced business policies (₹100 token deposit, early balance settlement) awaiting executive policy sign-off.
* **Track 4 (Phases 12 & 13)**: Secondary feature polish, comprehensive QA, accessibility audit, and regression testing.

```
PHASE 0: Documentation & Contract Freeze [COMPLETED]
   │
   ▼
[TRACK 1: CLIENT-SIDE UX — ZERO BACKEND BLOCKERS]
├── PHASE 1: Navigation Architecture (5 Bottom Tabs + Hamburger Drawer)
├── PHASE 2: Terminology Simplification & Accessibility Hardening
├── PHASE 3: Home Screen Redesign (Kitty-First Hierarchy + 1-Tap Pay Hero)
├── PHASE 4: Dedicated Live Rates Tab (Uncluttered Bullion Board)
├── PHASE 5: Kitty Plans Redesign (Curated Cards + 11+1 Bonus Math)
└── PHASE 6: Jewellery In-App Web Bridge (Official Swastik Live WebView)
   │
   ▼
[TRACK 2: BACKEND V2 API INTEGRATION]
├── PHASE 7: Kitty Number Availability & Real-Time Slot Matrix
├── PHASE 8: Guided "Start Kitty" Flow (Amount $\rightarrow$ Number $\rightarrow$ Month 1 Checkout)
├── PHASE 9: Multi-Month Payment Expansion (Consecutive Months Order Engine)
└── PHASE 10: Multiple Active Kitties Management (Horizontal Swiper & Isolation)
   │
   ▼
[TRACK 3: BUSINESS POLICY FEATURES (CONTINGENT ON SIGN-OFF)]
└── PHASE 11: Future Lucky Number Reservation (₹100 Token Deposit Model)
   │
   ▼
[TRACK 4: HARDENING & QA]
├── PHASE 12: Coins Repositioning & Secondary Features Polish (Drawer links)
└── PHASE 13: Full Regression, Security & Accessibility QA
```

---

## Phase 0: Documentation, Contracts & Architecture Freeze

* **Objective**: Establish the master documentation, backend requirement specifications, and API contracts.
* **Why this phase exists**: Prevents code rework and misaligned assumptions between frontend and backend teams.
* **Prerequisites**: UX Redesign Audit approval.
* **Backend Dependency**: None (documentation only).
* **Frontend Dependency**: None (zero production code modified).
* **Deliverables**: 17 comprehensive specification documents under [`/docs/`](file:///D:/kitty_frontend/kitty_docs/).
* **Git Strategy**: `docs: define Kitty App v2 UX and backend requirements`.

---

## Phase 1: Navigation Architecture (5 Bottom Tabs + Hamburger Drawer)

* **Objective**: Restructure app shell from the confusing V1 layout to the approved 5-tab Kitty-first dock.
* **Why this phase exists**: Removes the duplicate 5th bottom tab "Menu", moves Coins into the hamburger drawer, and positions Live Rates and Kitty Plans into the bottom dock.
* **Prerequisites**: Phase 0 completion.
* **Backend Dependency**: **Zero**. Existing routes and shell controllers used.
* **Frontend Dependency**: None.
* **Files Likely Affected**:
  - `lib/core/routing/route_paths.dart`
  - `lib/core/routing/route_names.dart`
  - `lib/core/routing/app_router.dart`
  - `lib/shared/widgets/navigation/app_bottom_nav_bar.dart`
  - `lib/shared/widgets/navigation/app_shell_scaffold.dart`
  - `lib/shared/widgets/navigation/luxury_nav_drawer.dart`
* **New Files Likely Required**: None.
* **UI Changes**:
  - Bottom bar displays: `Live Rates` | `My Kitty` | `Kitty Plans` | `Calculator` | `Jewellery`.
  - Hamburger drawer displays: Patron Card, Savings History, Coins, Orders, KYC, Settings, Help & Support.
* **Acceptance Criteria**:
  - Tab 0 opens Live Rates.
  - Tab 1 opens My Kitty dashboard.
  - Tab 2 opens Kitty Plans catalog.
  - Tab 3 opens Calculator.
  - Tab 4 opens Jewellery.
  - Top-right hamburger icon reliably slides out luxury drawer.
  - Hardware back button on Android returns to Tab 0 before exiting app.
* **Testing**: Widget test `app_bottom_nav_bar_test.dart` and `app_router_test.dart`.
* **Regression Risks**: Shell index mismatch during deep-link navigation.

---

## Phase 2: Terminology Simplification & Accessibility Hardening

* **Objective**: Systematically replace confusing financial jargon across the app and enforce AAA accessibility.
* **Why this phase exists**: Ensures elderly and first-time smartphone users can understand every screen without assistance.
* **Prerequisites**: Phase 1.
* **Backend Dependency**: **Zero**. String and token updates only.
* **Frontend Dependency**: Theme and typography constants.
* **Files Likely Affected**:
  - `lib/core/constants/app_typography.dart`
  - `lib/core/constants/app_colors.dart`
  - `lib/core/constants/app_dimensions.dart`
  - `lib/shared/widgets/buttons/kitty_primary_button.dart`
  - `lib/shared/widgets/badges/kitty_chit_token_pill.dart`
* **UI Changes**:
  - Minimum touch target height strictly set to **52px**.
  - All labels updated: "Installment" $\rightarrow$ "Monthly Payment", "Chit Token" $\rightarrow$ "Kitty Number", "Dashboard" $\rightarrow$ "My Kitty", "Passbook Ledger" $\rightarrow$ "Savings History".
  - Multi-modal status badges (Icon + Text + Color) across all cards.
* **Acceptance Criteria**:
  - Zero text smaller than 12px.
  - Contrast ratio between text and surface $\ge 7:1$ (AAA).
  - All critical buttons accessible to elderly fingers.
* **Testing**: Automated WCAG contrast test suite.

---

## Phase 3: Home Screen Redesign (Kitty-First Launchpad)

* **Objective**: Transform Home screen from a generic jewellery storefront into an actionable Kitty hub.
* **Why this phase exists**: Delivers the primary product goal: user understands their Kitty status within 3 seconds.
* **Prerequisites**: Phase 1 & 2.
* **Backend Dependency**: **Zero**. Consumes existing `homeControllerProvider` and `dashboardControllerProvider`.
* **Files Likely Affected**:
  - `lib/features/home/presentation/screens/home_screen.dart`
  - `lib/features/home/presentation/widgets/home_active_kitty_card.dart`
  - `lib/features/home/presentation/widgets/home_gold_silver_rate_carousel.dart`
  - `lib/features/home/presentation/widgets/home_offers_carousel.dart`
  - `lib/features/home/presentation/widgets/home_quick_actions.dart`
* **New Files Likely Required**:
  - `lib/features/home/presentation/widgets/home_live_rate_ticker_strip.dart`
  - `lib/features/home/presentation/widgets/home_new_saver_onboarding_card.dart`
* **UI Changes**:
  - Top fold: Clean compact Live Rate strip (24K & 22K per gram).
  - Hero fold: Prominent Active Kitty Card with huge `[ PAY ₹5,000 NOW ]` button.
  - First-time user fold: "Start Your Gold Savings Journey" card with benefits.
  - 3 large Quick-Action tiles: Start Kitty, Calculator, Showroom Jewellery.
* **Acceptance Criteria**:
  - Existing patron can tap `[ Pay Now ]` on Home and land directly in checkout (1-tap access).
  - Unauthenticated / zero-scheme patron sees welcoming onboarding hero.
* **Testing**: `home_screen_test.dart` gold widget tests.

---

## Phase 4: Dedicated Live Rates Tab

* **Objective**: Create a pure, ultra-readable daily bullion rate card under Tab 0.
* **Why this phase exists**: Gives patrons instant access to today's gold rate without being pushed into coin buying.
* **Prerequisites**: Phase 1.
* **Backend Dependency**: **Zero**. Uses existing `GET /api/v1/market/rates`.
* **Files Likely Affected**:
  - `lib/features/coin_rates/presentation/screens/coin_rates_screen.dart`
* **New Files Likely Required**:
  - `lib/features/live_rates/presentation/screens/live_rates_screen.dart`
  - `lib/features/live_rates/presentation/widgets/live_rate_karat_card.dart`
* **UI Changes**:
  - Clean cards for 24K, 22K, 18K, 14K Gold and 999 Silver.
  - Official timestamp: *"Market rate updated at 10:30 AM today"*.
  - Direct action: `[ Calculate Gold Value ]` transfers to Calculator tab.
* **Acceptance Criteria**:
  - Screen renders within 200ms using cached rates if offline.
  - Pull-to-refresh triggers live rate re-fetch.
* **Testing**: Widget test `live_rates_screen_test.dart`.

---

## Phase 5: Kitty Plans (Gold Schemes) Redesign

* **Objective**: Redesign `/offers` into an intuitive Kitty savings catalog with simple visual math.
* **Why this phase exists**: Replaces dense insurance-style text cards with transparent savings benefits.
* **Prerequisites**: Phase 2.
* **Backend Dependency**: **Zero**. Consumes existing `GET /api/v1/schemes/catalog`.
* **Files Likely Affected**:
  - `lib/features/offers/presentation/screens/offers_screen.dart`
  - `lib/features/offers/presentation/widgets/offers_scheme_card.dart`
  - `lib/features/offers/presentation/widgets/offers_duration_tabs.dart`
* **New Files Likely Required**:
  - `lib/features/offers/presentation/widgets/kitty_plan_benefit_tile.dart`
  - `lib/features/offers/presentation/widgets/kitty_plan_details_sheet.dart`
* **UI Changes**:
  - Prominent monthly amounts (e.g. `₹5,000 / month`).
  - Clear bonus badge: `✦ 1 Month ₹5,000 Bonus Paid by Swastik`.
  - Prominent CTA: `[ View Details & Start Kitty ]`.
* **Acceptance Criteria**:
  - Tap on card opens simple slide-up plan details sheet.
  - Tap on Start Kitty navigates into guided enrollment.
* **Testing**: `offers_screen_test.dart`.

---

## Phase 6: Showroom Jewellery In-App Web Bridge

* **Objective**: Embed official Swastik Jewellers live web catalog inside Tab 4 of the bottom bar.
* **Why this phase exists**: Replaces static 12-item mock catalog with hundreds of real showroom pieces without rebuilding e-commerce.
* **Prerequisites**: Phase 1.
* **Backend Dependency**: **Zero**. Connects to official web URL (`https://swastikjewel.in`).
* **Files Likely Affected**:
  - `lib/features/jewellery/presentation/screens/jewellery_screen.dart`
* **New Files Likely Required**:
  - `lib/features/jewellery/presentation/widgets/jewellery_webview_scaffold.dart`
* **UI Changes**:
  - Embedded `WebViewWidget` using existing `webview_flutter: ^4.14.1`.
  - Luxury top sub-bar with Swastik crest, reload button, and WhatsApp concierge.
  - Thin gold progress bar during web page loading.
* **Acceptance Criteria**:
  - Hardware back-button navigates web history; pops back to Home when at root.
  - Offline banner displayed gracefully if internet drops.
* **Testing**: `jewellery_screen_test.dart`.

---

## Phase 7: Backend Contract Integration: Kitty Numbers & Availability

* **Objective**: Implement and integrate the real-time Kitty Number availability matrix (01–50).
* **Why this phase exists**: Replicates the authentic Indian Kitty number selection experience.
* **Prerequisites**: Backend Milestone 1 deployment to Staging (`GET /api/v1/schemes/:id/numbers`).
* **Backend Dependency**: **High**. Requires `scheme_slots` table and atomic locking.
* **Frontend Dependency**: Phase 5.
* **Files Likely Affected**:
  - `lib/features/offers/data/repositories/scheme_repository_impl.dart`
  - `lib/features/offers/domain/repositories/i_scheme_repository.dart`
* **New Files Likely Required**:
  - `lib/features/kitty_numbers/domain/entities/kitty_slot_entity.dart`
  - `lib/features/kitty_numbers/presentation/providers/kitty_numbers_controller.dart`
  - `lib/features/kitty_numbers/presentation/widgets/kitty_number_grid.dart`
* **Acceptance Criteria**:
  - Real-time grid displays 50 numbers with accurate states (`Available`, `Booked`, `Selected`).
  - Search box filters lucky numbers instantly.
  - 409 Conflict handled gracefully with toast: *"Number just taken. Please pick another."*
* **Testing**: Unit test `kitty_numbers_controller_test.dart` and mock concurrency test.

---

## Phase 8: Guided "Start Kitty" Flow

* **Objective**: Build the 3-step enrollment flow: Amount $\rightarrow$ Lucky Number $\rightarrow$ Month 1 Payment.
* **Why this phase exists**: Replaces the basic text input dialog with a joyful, guided onboarding experience.
* **Prerequisites**: Phase 5 & 7.
* **Backend Dependency**: `POST /api/v1/schemes/enroll` with `selectedNumber`.
* **Files Likely Affected**:
  - `lib/features/offers/presentation/widgets/offers_enrollment_dialog.dart` (Superseded)
* **New Files Likely Required**:
  - `lib/features/start_kitty/presentation/screens/start_kitty_flow_screen.dart`
  - `lib/features/start_kitty/presentation/widgets/step_amount_selector.dart`
  - `lib/features/start_kitty/presentation/widgets/step_number_picker.dart`
  - `lib/features/start_kitty/presentation/widgets/step_order_summary.dart`
* **Acceptance Criteria**:
  - Step 1: Select monthly payment (`₹2,000` | `₹5,000` | `₹10,000`).
  - Step 2: Pick number from grid.
  - Step 3: Seamless handoff to Checkout Screen with pre-filled Month 1 order.
* **Testing**: Integration test `start_kitty_flow_test.dart`.

---

## Phase 9: Multi-Month Payment Expansion

* **Objective**: Enable patrons to pay 2, 3, or multiple consecutive installments in one transaction.
* **Why this phase exists**: Eliminates the frustration of paying multiple months via separate transactions.
* **Prerequisites**: Backend Milestone 2 deployment (`POST /payments/create-order` with `months: [9, 10]`).
* **Backend Dependency**: **High**. Multi-month order engine and passbook allocation.
* **Files Likely Affected**:
  - `lib/features/checkout/presentation/screens/checkout_screen.dart`
  - `lib/features/checkout/presentation/widgets/payment_checkout_modal.dart`
  - `lib/features/checkout/presentation/providers/payment_controller.dart`
  - `lib/features/checkout/domain/repositories/i_payment_repository.dart`
* **New Files Likely Required**:
  - `lib/features/checkout/presentation/widgets/multi_month_selector_sheet.dart`
* **Acceptance Criteria**:
  - User can toggle: `Pay 1 Month (₹5,000)` vs `Pay 2 Months (₹10,000)` vs `Pay 3 Months (₹15,000)`.
  - Authoritative total calculated by backend.
  - Single GoKwik checkout transaction.
  - Both months marked as `PAID` in passbook upon success.
* **Testing**: `payment_controller_test.dart` multi-month test suite.

---

## Phase 10: Multiple Active Kitties Management

* **Objective**: Allow patrons holding multiple concurrent Kitty schemes to view and manage each independently.
* **Why this phase exists**: Supports affluent savers who maintain plans for multiple family members.
* **Prerequisites**: Backend Milestone 3 deployment (`GET /schemes/my-schemes` array response).
* **Backend Dependency**: **Medium**. Multi-scheme array response.
* **Files Likely Affected**:
  - `lib/features/dashboard/presentation/screens/dashboard_screen.dart`
  - `lib/features/dashboard/presentation/providers/dashboard_controller.dart`
* **New Files Likely Required**:
  - `lib/features/dashboard/presentation/widgets/multi_kitty_carousel.dart`
* **Acceptance Criteria**:
  - Horizontal swipe cards display each active scheme with its individual token, progress, and due date.
  - Tapping `[Pay Now]` operates strictly on the active visible card.
* **Testing**: `multi_kitty_dashboard_test.dart`.

---

## Phase 11: Future Lucky Number Reservation (Contingent on Sign-off)

* **Objective**: Build the ₹100 token deposit flow for reserving numbers in upcoming seasonal groups.
* **Why this phase exists**: Provides VIP patrons first pick of auspicious numbers.
* **Prerequisites**: Formal management sign-off on `BR-03`, `BR-04`, `BR-05` in [`KITTY_BUSINESS_RULES_PENDING_V1.md`](file:///D:/kitty_frontend/kitty_docs/KITTY_BUSINESS_RULES_PENDING_V1.md).
* **Backend Dependency**: `scheme_reservations` collection and token payment order API.
* **Files Likely Affected**:
  - `lib/features/offers/presentation/screens/offers_screen.dart`
* **New Files Likely Required**:
  - `lib/features/reservation/presentation/widgets/future_number_reservation_dialog.dart`
* **Acceptance Criteria**:
  - User selects upcoming festive group, picks lucky number, and pays ₹100.
  - Status reflects as `RESERVED` with expiry countdown.
* **Testing**: `reservation_flow_test.dart`.

---

## Phase 12: Coins & Secondary Features Polish

* **Objective**: Polish bullion coin booking, orders history, KYC, settings, and concierge support inside the hamburger drawer.
* **Why this phase exists**: Ensures secondary features remain 100% functional without competing with primary Kitty tabs.
* **Prerequisites**: Phase 1.
* **Backend Dependency**: **Zero**. Existing bullion and KYC APIs.
* **Files Likely Affected**:
  - `lib/features/coin_rates/presentation/screens/coin_rates_screen.dart`
  - `lib/features/orders/presentation/screens/orders_screen.dart`
  - `lib/features/kyc/presentation/screens/kyc_screen.dart`
  - `lib/features/settings/presentation/screens/settings_screen.dart`
* **Acceptance Criteria**:
  - Coins screen accessible via Hamburger Menu $\rightarrow$ Coins.
  - Full coin configurator (5g, 6g, 7g) and booking dialog work seamlessly.
  - Doorstep cash pickup ("Pick Cash") operational.
* **Testing**: `coin_rates_screen_test.dart` and `orders_screen_test.dart`.

---

## Phase 13: Full Regression, Security & Accessibility QA

* **Objective**: Execute comprehensive end-to-end verification across mobile devices and platforms.
* **Why this phase exists**: Guarantees zero regressions in authentication, payments, KYC, storage, or offline states.
* **Prerequisites**: Phases 1 through 12.
* **Scope of Testing**:
  1. **Authentication**: Mobile + 6-digit OTP, session restoration, 30-day token persistence.
  2. **Payment Gateway**: GoKwik WebView flow, polling loop, UPI intent launch, cancellation protection.
  3. **Offline & Network Drop**: Graceful banners, cached live rates, retry buttons.
  4. **Accessibility**: Screen reader semantics, minimum 52px touch targets, AAA contrast.
  5. **Regression Verification**: 350+ automated unit and widget test cases passing.
* **Acceptance Criteria**:
  - 100% test pass rate.
  - Zero critical crashes on Android (API 26–35) and iOS (15–18).
  - Google Play Pre-launch report clean.
