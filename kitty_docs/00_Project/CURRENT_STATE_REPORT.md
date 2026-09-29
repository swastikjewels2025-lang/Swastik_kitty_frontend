# CURRENT STATE REPORT — KITTY APP

**Project**: Swastik Jewellers Digital Gold Savings App (Kitty Vault)  
**Flutter Workspace**: `D:\kitty_app\`  
**Backend Workspace**: `D:\Kitty_backend\Swastik_kitty_backend\`  
**UI Reference**: `D:\ui design\`  
**Audit & Report Date**: 2026-09-23  
**Status**: Synchronized with Current Implementation  

---

## 1. Current Application Overview

The **Swastik Jewel Kitty App** is an enterprise-grade mobile application built using **Flutter (Dart 3.x / Flutter 3.22+)** for iOS, Android, and Web. 

The application serves as a luxury omnichannel jewelry and digital gold savings platform for **Swastik Jewellers** (Lucknow, India). It provides patrons with:
* Transparent 12-month gold kitty / chit savings schemes (e.g. 11+1 jeweler bonus month schemes).
* Real-time 24K 999 investment-grade gold coin rate tracking and bulk coin booking.
* An interactive showroom jewelry catalog spanning Gold and Diamond collections.
* Bank-grade passbook installment tracking with digital GST tax invoice receipts.
* Direct in-app payment processing via GoKwik UPI/Card/NetBanking checkout.
* Statutory compliance onboarding with UIDAI-compliant Aadhaar and PAN verification under Indian precious metal regulations (BUDS Act 2019, PMLA Rule 9).

---

## 2. Current Screen List

The application features 14 primary screens and major modal interfaces:

| # | Screen Name | Route Path | File Location | Key Purpose |
| :-: | :--- | :--- | :--- | :--- |
| 1 | **Splash Screen** | `/splash` | `lib/features/splash/presentation/screens/splash_screen.dart` | Seamless cold-launch brand sequence with zero blank frame, smooth 3D diamond rotation and dissolution, and auth session recovery. |
| 2 | **Login Screen** | `/auth/login` | `lib/features/auth/presentation/screens/login_screen.dart` | Multi-step authentication view offering "Continue with Instagram" and Mobile Number OTP login. |
| 3 | **Phone Entry Screen** | `/auth/phone` | `lib/features/auth/presentation/screens/phone_screen.dart` | Mobile input with country selector dropdown, 10-digit auto-formatting, and validation. |
| 4 | **OTP Verification Screen** | `/auth/otp` | `lib/features/auth/presentation/screens/otp_screen.dart` | 6-digit auto-advancing OTP input grid with shake animation on error and resend countdown timer. |
| 5 | **Register Profile Screen** | `/auth/profile` | `lib/features/auth/presentation/screens/register_profile_screen.dart` | First-time patron onboarding form collecting Full Name, Email Address, and City. |
| 6 | **Auth Success Screen** | `/auth/success` | `lib/features/auth/presentation/screens/auth_success_screen.dart` | Welcome splash displaying patron tier badge and "Enter Vault" CTA. |
| 7 | **Home Screen** | `/home` | `lib/features/home/presentation/screens/home_screen.dart` | High-fidelity luxury feed: Top Gold Offers carousel (height 265px), Live Gold/Silver Rate carousel, circular curated jewellery collections, Gold Scheme & Coins quick actions, interactive Gold Price Trend chart, and clean luxury footer. |
| 8 | **Coin Rates Screen** | `/coin-rates` | `lib/features/coin_rates/presentation/screens/coin_rates_screen.dart` | Unified table layout (`GM \| PURITY \| PRICE`), right-aligned "Book Now" buttons, prominent Calculator button, and centered Custom Gold Coin configurator. |
| 9 | **Jewellery Screen** | `/jewellery` | `lib/features/jewellery/presentation/screens/jewellery_screen.dart` | Interactive jewelry catalog with authentic product photography, loading state, error fallbacks, and Gold & Diamond dropdown cards across 6 categories. |
| 10 | **Calculator Screen** | `/calculator` | `lib/features/calculator/presentation/screens/calculator_screen.dart` | Dedicated gold valuation calculator accessible directly from Coins page and route paths; features "Shop by Gram" and "Shop by Money" modes with 24K, 22K, 18K purities. |
| 11 | **KYC Screen** | `/kyc` | `lib/features/kyc/presentation/screens/kyc_screen.dart` | High-security identity verification with 3D jewel constellation background, Aadhaar/PAN upload, and statutory consent. |
| 12 | **Menu Screen** | `/menu` | `lib/features/menu/presentation/screens/menu_screen.dart` | Fullscreen modern luxury menu providing direct access to all drawer destinations, scheme tracking, passbook, and settings. |
| 13 | **Dashboard Screen** | `/dashboard` | `lib/features/dashboard/presentation/screens/dashboard_screen.dart` | In-depth active scheme tracker (Bottom Nav Tab 3 "My Scheme") with circular SVG progress gauge, 2x2 stats grid, and next EMI countdown. |
| 14 | **Passbook Screen** | `/passbook` | `lib/features/passbook/presentation/screens/passbook_screen.dart` | 12-month installment ledger with Table vs Card switcher, 3-pillar summary card, and digital receipt actions. |
| 15 | **Offers Screen** | `/offers` | `lib/features/offers/presentation/screens/offers_screen.dart` | Dedicated Kitty Savings Schemes catalog (Suvarna Varsha 11+1, Dhanvarsha, Express) with duration filters and enrollment dialog. |
| 16 | **Settings Screen** | `/settings` | `lib/features/settings/presentation/screens/settings_screen.dart` | Patron account management, UPI AutoPay toggle, MPIN setup, Biometric auth, Nominee details, and legal compliance (Theme, Appearance, and Language completely removed). |
| 17 | **Notifications Screen** | `/notifications` | `lib/features/notifications/presentation/screens/notifications_screen.dart` | Transactional alerts, scheme reminders with honey gold heading, modern relevant icons, and unread badge tracking. |
| 18 | **Checkout Screen** | `/checkout` | `lib/features/checkout/presentation/screens/checkout_screen.dart` | Luxury payment modal with fixed method switching, Instant UPI, Net Banking, Cards, and Doorstep Pick Cash with dedicated logistics sheet. |
| 19 | **Receipt Screen / Modal** | `/receipt/:id` | `lib/features/receipt/presentation/screens/receipt_screen.dart` | Official tax receipt with GSTIN, HSN codes, official watermark stamp, print trigger, and PDF viewer. |

---

## 3. Current Navigation & App Shell Architecture

The application implements a multi-tier navigation model managed by **GoRouter 14.x**:

1. **Root Authentication Guards**:
   - `isInitial` $\rightarrow$ `/splash`
   - `isUnauthenticated` $\rightarrow$ `/auth/login` (blocks protected tabs)
   - `isAuthenticated && !isKycVerified` $\rightarrow$ Enforces redirect to `/kyc` (with bypass for initial `/auth/profile` and `/auth/success`)
   - `isAuthenticated && isKycVerified` $\rightarrow$ Redirects auth URLs to `/home` and permits access to all protected screens.

2. **Persistent Application Shell (`AppShellScaffold`)**:
   - Built on `StatefulShellRoute.indexedStack` to preserve scroll offsets and widget state across tabs.
   - **Sticky Top Header (`HeaderNavBar`)**: Fixed at top; features Swastik SVG brand crest, left-aligned live 24K gold rate pill (`24K: ₹15,268/g`), and right-aligned notification bell and 3-lines menu hamburger toggle.
   - **Slide-out Drawer (`LuxuryNavDrawer`)**: Features Patron profile card, active status badges, and primary navigation links.
   - **Frosted Glass Bottom Navigation Dock (`AppBottomNavBar`)**: 5 primary consumer tabs:
     - Tab 0: **Home** (`/home`, `Icons.home_outlined` / `Icons.home_rounded`)
     - Tab 1: **Coins** (`/coin-rates`, `Icons.monetization_on_outlined` / `Icons.monetization_on_rounded`)
     - Tab 2: **Jewellery** (`/jewellery`, `Icons.diamond_outlined` / `Icons.diamond_rounded`)
     - Tab 3: **My Scheme** (`/dashboard`, `Icons.workspace_premium_outlined` / `Icons.workspace_premium_rounded`)
     - Tab 4: **Menu** (`/menu`, `Icons.menu_rounded` / `Icons.menu_open_rounded`)
   - **Smart Indicator Capsule**:
     - Highlights the active tab when on tabs 0-4.
     - When navigating to off-dock routes (`/passbook`, `/settings`, `/calculator`, `/offers`, etc.), the indicator capsule automatically fades out (`opacity: 0.0`), preventing any false highlight of the Home tab.
   - **Android Hardware Back-Button Handling (`PopScope`)**:
     - Closes the drawer if open.
     - Navigates back to Tab 0 (Home) if on another tab before confirming app exit.

---

## 4. Current Major Features

1. **Top Gold Offers Carousel**:
   - Prominent scheme banner carousel positioned directly below the header with an elevated vertical height of **265px** for enhanced visual stature without layout overflow.
2. **Live Gold / Silver Rate Carousel**:
   - Elevated royal emerald card automatically alternating between real-time **Gold 24K (999)** and **999 Fine Silver** benchmark rates with chevrons and direct navigation to Coins.
3. **Explore Our Jewellery Showcase**:
   - Circular curated category cards with gold accent rims linking to the fine jewellery catalog.
4. **Gold Scheme + Coins Quick Action Card**:
   - High-contrast emerald card featuring floating circular icon buttons with modern, clean iconography (`Icons.workspace_premium_outlined` and `Icons.monetization_on_outlined`).
5. **Gold Price Trend Graph**:
   - Multi-line interactive trend chart with 1W, 1M, 6M, 1Y, 5Y timeframe selector, 24K/22K/18K curves, and gradient fills.
6. **Bullion & Coin Rate Card (Unified Table)**:
   - Unified table layout: `GM | PURITY | PRICE` with right-aligned "Book Now" buttons.
   - Centered Custom Gold Coin Selection with strict `"Enter custom grams"` placeholder.
   - Prominent Calculator action button in the top bar beside the metal selector.
7. **Digital Kitty Savings Tracker**:
   - Real-time tracking of 12-month schemes with circular progress gauge.
   - 11+1 jeweler bonus month reward visualization.
   - Direct integration via Bottom Nav Tab 3 ("My Scheme").
8. **Passbook & Tax Invoices**:
   - Detailed ledger with dual Table / Card view modes.
   - Official downloadable and printable digital GST receipts with verification watermarks.
9. **Streamlined Settings**:
   - Theme, Appearance, and Language completely removed. Focused on UPI AutoPay, Biometric Login, 4-digit MPIN security, Nominee details, and BIS 24K Hallmarking compliance.
10. **Refined Notifications**:
    - Centralized alerts with Gold Scheme heading in canonical honey gold (`AppColors.honeyGoldAccent`) and clean, modern icons tailored to each notification type.
7. **Payment Pipeline & Pick Cash**:
   - Seamless checkout supporting Instant UPI, Net Banking (40+ banks), Debit/Credit Cards, and Doorstep Pick Cash.
   - Fixed selection bug: patrons can clearly tap, view active selection state, and switch between channels before continuing.
   - Dedicated "Pick Cash" form prefilling patron details, capturing address, city, 6-digit pincode, preferred pickup slot, and issuing 4-digit handover OTP.
   - Automated 5-poll background reconciliation loop for online gateways.
8. **Statutory KYC Compliance**:
   - UIDAI-compliant Aadhaar and PAN verification with document number masking and consent capture.

---

## 5. Current UI & Visual Architecture

The UI architecture implements a **Dual-Surface Luxury Design System**:

* **Surface 1: Deep Emerald Heritage (`#05241C`)**:
  - Used for Splash, Login, KYC, Checkout Modals, and the Luxury Nav Drawer.
  - Features damask background wallpaper, ambient radial glow orbs, specular hairline gold borders, and hardware-accelerated 3D procedural canvas animations (`Diamond3dPainter`, `JewelryConstellationPainter`).
* **Surface 2: Warm Luxury Alabaster (`#FAF7F2`)**:
  - Used for customer daytime feeds: Home, Passbook, Menu, and Settings.
  - Palette: Warm Alabaster Silk (`#FAF7F2`), Polished Cream Ivory (`#F4F0EA`), Soft Warm Linen (`#EDE8DF`), Rich Warm Ochre (`#DCA237`), Champagne Gold Foil (`#F3E0B5`), and Espresso Charcoal (`#2B2521`).
* **Typography Tokens**:
  - Headings & Brand Identity: **Cinzel** (Google Fonts serif).
  - Editorial Accents: **Playfair Display**.
  - Numbers, Controls, and Body Text: **Montserrat** / **Plus Jakarta Sans**.

---

## 6. Current Frontend Architecture

```text
D:\kitty_app\lib\
├── app/                  # Application bootstrap and global wrappers
├── core/                 # Shared infrastructure
│   ├── config/           # AppConfig (mock/dev/staging/prod), AppConstants, AppEnvironment
│   ├── constants/        # AppColors (Emerald & Warm palettes), AppTypography, AppSpacing
│   ├── errors/           # AppException and failure mappings
│   ├── enums/            # Domain enums with defensive .unknown deserializers
│   ├── mock/             # MockFixtures (static JSON data for all 18 endpoints)
│   ├── network/          # DioClient with auth, logging, and 15s timeout interceptors
│   ├── providers/        # Global authStateProvider and app theme providers
│   ├── routing/          # AppRouter (GoRouter), RoutePaths, RouteNames, RouteTransitions
│   ├── storage/          # SecureStorageService (Android KeyStore AES-256 GCM)
│   ├── theme/            # AppTheme dark & light theme definitions
│   └── utils/            # Currency, Date, and Phone formatters
├── features/             # Feature-first domain modules
│   ├── auth/             # Login, Phone, OTP, Register Profile, Success, Constellation Painter
│   ├── checkout/         # Payment checkout bottom sheet and reconciliation
│   ├── coin_rates/       # 24K coin rates, blister pack costs, bulk booking dialog
│   ├── dashboard/        # Scheme dashboard, circular gauge, hero card, next EMI card
│   ├── home/             # Home feed, store video section, curated grid, gold rate strip
│   ├── jewellery/        # Fine jewelry catalog, gold & diamond tabs, category filters
│   ├── kyc/              # Aadhaar/PAN upload, document masking, statutory consent
│   ├── menu/             # Fullscreen Warm Luxury menu page
│   ├── notifications/    # In-app notifications feed, badges, and detail sheets
│   ├── offers/           # Scheme plans, enrollment dialog, duration tabs
│   ├── passbook/         # 12-month installment table/card ledger, perks dialog
│   ├── payment_gateway/  # GoKwik webview bridge
│   ├── receipt/          # Digital tax invoice receipt modal and PDF export
│   ├── settings/         # Profile card, MPIN, Biometrics, Nominee, Compliance modal
│   └── splash/           # 3D diamond canvas loader and session initializer
└── shared/               # Reusable widgets (badges, buttons, display, feedback, navigation)
```

---

## 7. Current Mock & API Dependencies

The application is completely decoupled from backend deployment via `AppConfig.useMockApi`:

* **When `USE_MOCK_API=true` (Default in Debug & Sandbox)**:
  - Repositories return realistic mock data from `lib/core/mock/mock_fixtures.dart`.
  - Testing OTP `123456` authenticates immediately.
  - Active scheme `#SW-042` with 8 installments paid and ₹40,000 deposited is pre-populated.
  - KYC submission auto-transitions to `PENDING` with reference ID.
  - GoKwik checkout simulates successful webhook callback and receipt generation.
* **When `USE_MOCK_API=false` (Production & Live Staging)**:
  - Connects to backend server via `baseUrl` (`http://10.0.2.2:5000` in Dev, `https://api.swastikjewel.com` in Prod).
  - All 18 endpoints conform strictly to the Frozen Backend Contract v1.0.

---

## 8. Differences From Original Implementation Plan

1. **Navigation Structure**: Bottom dock transformed from 4 tabs (`Home`, `Dashboard`, `Offers`, `Settings`) to 5 items (`Home`, `Coin Rates`, `Jewellery`, `KYC`, `Menu`).
2. **New Standalone Screens**: Added `CoinRatesScreen` (`/coin-rates`), `JewelleryScreen` (`/jewellery`), `MenuScreen` (`/menu`), and `RegisterProfileScreen` (`/auth/profile`).
3. **Home Experience**: Enhanced with interactive `HomeStoreVideoSection` and curated 2-column product grid.
4. **Aesthetics & Tokens**: Added the Warm Luxury Palette (`#FAF7F2`, `#F4F0EA`, `#DCA237`, etc.) to complement the Deep Emerald Heritage palette.
5. **Passbook Flexibility**: Added instant Table vs Card view switcher and 3-pillar metric summary card.

---

## 9. Documentation Files Updated

The following 23 master documentation files have been created/updated to represent the current application:

1. [`docs/CURRENT_STATE_CHANGELOG.md`](file:///d:/ui%20design/docs/CURRENT_STATE_CHANGELOG.md) — *NEW: Complete difference changelog*
2. [`docs/CURRENT_STATE_REPORT.md`](file:///d:/ui%20design/docs/CURRENT_STATE_REPORT.md) — *NEW: Current state audit report (this document)*
3. [`docs/01_PRD.md`](file:///d:/ui%20design/docs/01_PRD.md) — *Updated with new screens, navigation dock, and features*
4. [`docs/02_PRODUCT_FLOW.md`](file:///d:/ui%20design/docs/02_PRODUCT_FLOW.md) — *Updated with 5-step auth, coin booking, and video tour*
5. [`docs/03_SCREEN_FLOW.md`](file:///d:/ui%20design/docs/03_SCREEN_FLOW.md) — *Updated with all 14 screens and routes*
6. [`docs/04_FRONTEND_UI_UX_SPECIFICATION.md`](file:///d:/ui%20design/docs/04_FRONTEND_UI_UX_SPECIFICATION.md) — *Updated with Warm Luxury & Emerald dual palettes*
7. [`docs/05_FRONTEND_ARCHITECTURE.md`](file:///d:/ui%20design/docs/05_FRONTEND_ARCHITECTURE.md) — *Updated with Flutter MVVM, Riverpod, and feature structure*
8. [`docs/06_COMPONENT_ARCHITECTURE.md`](file:///d:/ui%20design/docs/06_COMPONENT_ARCHITECTURE.md) — *Updated with new widgets (BottomNav, Header, Video, Coins)*
9. [`docs/07_FRONTEND_DATA_AND_API_CONTRACT.md`](file:///d:/ui%20design/docs/07_FRONTEND_DATA_AND_API_CONTRACT.md) — *Updated with coin and jewelry endpoints*
10. [`docs/08_FRONTEND_STATE_MANAGEMENT.md`](file:///d:/ui%20design/docs/08_FRONTEND_STATE_MANAGEMENT.md) — *Updated with Riverpod providers and controllers*
11. [`docs/09_FRONTEND_BUSINESS_RULES.md`](file:///d:/ui%20design/docs/09_FRONTEND_BUSINESS_RULES.md) — *Updated with coin booking and KYC rules*
12. [`docs/10_AUTHENTICATION_FRONTEND_FLOW.md`](file:///d:/ui%20design/docs/10_AUTHENTICATION_FRONTEND_FLOW.md) — *Updated with Google SSO and profile onboarding*
13. [`docs/11_PAYMENT_FRONTEND_FLOW.md`](file:///d:/ui%20design/docs/11_PAYMENT_FRONTEND_FLOW.md) — *Updated with GoKwik flow and reconciliation polling*
14. [`docs/12_NOTIFICATION_FRONTEND_FLOW.md`](file:///d:/ui%20design/docs/12_NOTIFICATION_FRONTEND_FLOW.md) — *Updated with notifications screen and header badges*
15. [`docs/13_CRM_FRONTEND_INTEGRATION.md`](file:///d:/ui%20design/docs/13_CRM_FRONTEND_INTEGRATION.md) — *Updated with showroom sync and cash payments*
16. [`docs/14_LOADING_ERROR_EMPTY_STATES.md`](file:///d:/ui%20design/docs/14_LOADING_ERROR_EMPTY_STATES.md) — *Updated with state matrix across all 14 screens*
17. [`docs/15_RESPONSIVE_DESIGN_SPECIFICATION.md`](file:///d:/ui%20design/docs/15_RESPONSIVE_DESIGN_SPECIFICATION.md) — *Updated with mobile, tablet, and web specs*
18. [`docs/16_ACCESSIBILITY_REQUIREMENTS.md`](file:///d:/ui%20design/docs/16_ACCESSIBILITY_REQUIREMENTS.md) — *Updated with contrast audit and screen reader tags*
19. [`docs/17_FRONTEND_TESTING_QA.md`](file:///d:/ui%20design/docs/17_FRONTEND_TESTING_QA.md) — *Updated with 346 automated tests and new widget test suites*
20. [`docs/18_FRONTEND_ENVIRONMENT_CONFIGURATION.md`](file:///d:/ui%20design/docs/18_FRONTEND_ENVIRONMENT_CONFIGURATION.md) — *Updated with Dart defines and AppConfig*
21. [`docs/19_BACKEND_HANDOFF.md`](file:///d:/ui%20design/docs/19_BACKEND_HANDOFF.md) — *Updated with frozen backend contracts and handoff notes*
22. [`docs/20_DOCUMENTATION_INDEX.md`](file:///d:/ui%20design/docs/20_DOCUMENTATION_INDEX.md) — *Master index updated*
23. [`docs/21_OPEN_QUESTIONS.md`](file:///d:/ui%20design/docs/21_OPEN_QUESTIONS.md) — *Catalog of business questions requiring merchant confirmation*

#### Legal & Compliance Specifications Synchronized (`docs/LEGAL_COMPLIANCE/`):
24. `01_LEGAL_COMPLIANCE_REQUIREMENTS.md` (BUDS Act 2019, Chit Funds Act, Companies Act Sec 73)
25. `02_PRIVACY_POLICY_REQUIREMENTS.md` (DPDPA 2023 consent notices and storage rules)
26. `03_TERMS_CONDITIONS_REQUIREMENTS.md` (Jewellery advance purchase agreements)
27. `04_PAYMENT_REFUND_CANCELLATION_REQUIREMENTS.md` (RBI e-mandate rules and cancellation policies)
28. `05_KYC_CONSENT_REQUIREMENTS.md` (PMLA Rule 9 and UIDAI Aadhaar masking)
29. `06_CONSUMER_DISCLOSURE_REQUIREMENTS.md` (BIS 999 hallmarking and IBJA daily rates)
30. `07_DATA_PROTECTION_REQUIREMENTS.md` (AES-256 KeyStore hygiene and TLS rules)
31. `08_LEGAL_LAUNCH_CHECKLIST.md` (30-point statutory pre-launch sign-off checklist)

---

## 10. New Frontend API & Backend Requirements (Handoff)

> [!IMPORTANT]
> The frontend implementation strictly maintained the boundary of a pure client application. The following endpoints represent **FRONTEND REQUIREMENTS FOR FUTURE BACKEND** to replace mock abstractions:

1. **Coins Bullion Rates & Inventory API**:
   - `GET /api/v1/bullion/rates?metal=gold,silver`: Stream or polled spot rate per gram for 24K 999 Gold and 999 Fine Silver.
   - `GET /api/v1/bullion/coins`: Returns coin denominations (1g, 2g, 3g, 4g, 5g, 10g), blister pack assay packaging status, and stock availability.
2. **Gold Valuation Calculator Benchmark API**:
   - `GET /api/v1/calculator/benchmark-rates`: Live benchmark prices across 24K (999), 22K (916), and 18K (750) purities and prevailing retail making charge tiers.
3. **Doorstep Cash Pickup ("PICK CASH") Ingestion API**:
   - `POST /api/v1/payments/cash-pickup`: Accepts `CashPickupRequest` payload (JSON schema detailed in `19_BACKEND_HANDOFF.md`) containing patron details, address, city, 6-digit pincode, slot, active scheme token, installment amount, and handover OTP.
   - `GET /api/v1/payments/cash-pickup/status/:requestId`: Polling endpoint returning executive assignment and collection status (`SCHEDULED`, `ASSIGNED`, `COLLECTED`, `CREDITED`).
4. **Meta / Instagram OAuth Exchange API**:
   - `POST /api/v1/auth/instagram/callback`: Accepts authorization code from Meta OAuth dialog, exchanges with Graph API for access token, extracts patron ID/email, and mints 30-day Swastik JWT.

---

## 11. Assets Required (Asset Dependencies)

* **Authentic Gold Chain Bracelet Photography**:
  - The repository currently contains authentic studio photography for rings, necklaces, pendants, earrings, and bangles.
  - Authentic high-resolution photography for chain bracelets (`card_gold_bracelet`) is currently missing from local assets and is mapped to existing approved product assets.
  - **Action Required**: Professional photography team must supply authentic, high-res photos for chain bracelets (aspect ratio 4:3, minimum 800x600, web-optimized JPEG).

---

## 12. Legal / Compliance Considerations

The newly introduced features require the following legal and regulatory reviews by Swastik Jewellers' legal counsel:

1. **Doorstep Cash Collection Limits (PMLA & Income Tax Sec 269ST)**:
   - Cash transactions in India are capped at ₹1,99,999 per patron per day.
   - Mandatory PAN collection and verification must be enforced for cash pickups exceeding ₹50,000 per transaction.
2. **Physical Verification Safeguards**:
   - The 4-digit handover OTP issued to patrons must be securely validated by the field representative before cash custody transfer.
   - GPS geotagging and digital receipt generation must be issued to the patron's registered phone upon pickup.
3. **Precious Metal Weight & Karat Disclosures**:
   - Karat purity badges (24K 999 vs 22K 916) comply with Bureau of Indian Standards (BIS) Hallmarking Order 2021.
   - Dynamic hiding of Karat selectors for silver coins ensures patrons are not misled regarding silver purity designations.
4. **Valuation Calculator Disclosures**:
   - Calculator results are indicative market estimates and include clear statutory disclosures stating that making charges, GST (3%), and hallmark fees are confirmed upon physical invoice issuance.
5. **Instagram OAuth Privacy Disclosures**:
   - Instagram SSO requires privacy policy disclosures clarifying what Meta user data (public profile, username) is collected in compliance with Digital Personal Data Protection Act (DPDPA 2023).

---

## 13. Known Issues & Limitations

1. **Instagram Live OAuth**:
   - The frontend implements the branded UI and authentication state abstraction (`loginWithInstagram`). Live production SSO requires registering a Meta Developer App, whitelisting OAuth redirect URIs, and backend token exchange.
2. **Doorstep Cash Pickup Backend Processing**:
   - The frontend cleanly captures and validates pickup logistics, formats the JSON contract, and transitions to a verified reference state (`PCK-XXXXXX`). Server-side route assignment and CRM dispatch require backend implementation.
3. **Video Upload Persistence**:
   - Administrative showroom video upload stores preview assets in memory during the active session. Long-term CDN persistence requires backend S3/Cloudinary ingestion endpoints.

---

## 14. Final Certification

* **Backend Code**: Untouched & Unmodified (`Zero backend code, databases, or server logic created or modified`).
* **Frontend Architecture**: Riverpod 2.x MVVM, GoRouter 14.x declarative routing, and dual-surface luxury design system preserved and extended.
* **Current Application State**: Fully compiled, tested, and synchronized across code, tests, and documentation.
