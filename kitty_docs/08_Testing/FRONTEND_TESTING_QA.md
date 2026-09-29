# Frontend Testing & QA Master Specification — Kitty App

**Project**: Swastik Jewellers Kitty App (Sub-Brand: Kitty Vault)  
**Primary Codebase**: `D:\kitty_app\`  
**Document Status**: Synchronized with Current Implementation  
**Last Audit Date**: 2026-09-23  

---

## 1. Automated Test Suite Metrics & Verification

The Kitty App client is validated by **356 automated tests** (100% passing):

```text
┌────────────────────────────────────────────────────────┐
│ MASTER TEST EXECUTION SUMMARY (2026-09-24)             │
│ Total Tests Executed:     356                          │
│ Tests Passed:             356 (100%)                   │
│ Tests Failed:             0                            │
│ Static Analysis:          0 Errors, 0 Warnings, 0 Lints│
│                           ("No issues found! in 3.8s") │
├────────────────────────────────────────────────────────┤
│ BREAKDOWN:                                             │
│ 1. Unit Tests:            231 tests                    │
│ 2. Widget Tests:          108 tests                    │
│ 3. Integration Tests:      17 tests                    │
└────────────────────────────────────────────────────────┘
```

---

## 2. Test Suite Architecture (`test/`)

```text
D:\kitty_app\test\
├── unit/                                  # 231 Unit Tests
│   ├── config/                            # AppConfig, environment variables
│   ├── errors/                            # AppException mapping
│   ├── formatters/                        # Currency, Date, and Phone formatters
│   ├── models/                            # JSON deserialization & defensive fallbacks
│   ├── checkout/                          # PaymentController, PaymentChannel enum
│   ├── auth/                              # AuthController, Instagram SSO abstraction
│   └── routing/                           # Route paths, URI generation
│
├── widget/                                # 108 Widget & Screen Tests
│   ├── auth/                              # LoginScreen (Instagram SSO), OtpScreen
│   ├── checkout/                          # CheckoutScreen, method selection, Pick Cash
│   ├── coin_rates/                        # CoinRatesScreen (Gold/Silver, 1g-5g, Karats)
│   ├── components/                        # Badges, buttons, circular gauge
│   ├── dashboard/                         # DashboardHeroCard, stats grid, next EMI
│   ├── feedback/                          # Empty state, error state, shimmer
│   ├── home/                              # HomeScreen, top offers carousel, Active plan CTA
│   ├── jewellery/                         # JewelleryScreen, authentic photo cards
│   ├── kyc/                               # KycScreen, document tabs, consent box
│   ├── navigation/                        # AppBottomNavBar (4 tabs), HeaderNavBar (L/R)
│   ├── notifications/                     # NotificationsScreen, unread badges
│   ├── offers/                            # OffersScreen (Jewellery removed)
│   ├── passbook/                          # PassbookScreen, table view, cards list
│   ├── receipt/                           # ReceiptScreen, digital tax voucher
│   ├── routing/                           # AppRouter, route guards, deep links
│   └── splash/                            # SplashScreen, emerald canvas, smooth diamond
│
└── integration/                           # 17 Live Backend Integration Tests
    ├── auth_integration_test.dart        # End-to-end OTP login against server
    ├── schemes_integration_test.dart     # Scheme enrollment & passbook retrieval
    ├── payments_integration_test.dart    # Order creation & verification polling
    └── kyc_integration_test.dart         # Document upload against server
```

---

## 3. Dedicated Test Suites for New Features

### 3.1 Coin Rates Screen Test Suite (`test/widget/coin_rates/`)
* **Test Cases**:
  - Verifies 1g to 10g coin pricing matches `grams * benchmarkRate + assayFee`.
  - Verifies selecting 20g, 50g, 100g bulk chips updates the computed price.
  - Verifies custom gram input validation (rejects $<11$g and $>1000$g).
  - Verifies tapping "Book Coin" renders the booking confirmation dialog.

### 3.2 Jewellery Catalog Test Suite (`test/widget/jewellery/`)
* **Test Cases**:
  - Verifies toggling between "Gold Jewellery" and "Diamond Jewellery" switches displayed items.
  - Verifies tapping category chips (Rings, Pendants, Necklace, etc.) filters the item grid.
  - Verifies reservation dialog trigger displays item specifications.

### 3.3 Menu Screen Test Suite (`test/widget/menu/`)
* **Test Cases**:
  - Verifies all 7 navigation items render with matching icons and titles.
  - Verifies tapping each navigation link triggers correct `context.go()` destination.
  - Verifies tapping "Log Out" renders the confirmation modal.

### 3.4 Store Video Section Test Suite (`test/widget/home/home_store_video_section_test.dart`)
* **Test Cases**:
  - Verifies play/pause button toggles video playback state.
  - Verifies mute button toggles audio state.
  - Verifies video upload button renders file picker action.
