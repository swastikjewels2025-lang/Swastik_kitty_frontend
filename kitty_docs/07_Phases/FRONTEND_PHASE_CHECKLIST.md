# Frontend Phase Implementation Checklist

> **Kitty App (Swastik Jewellers — Sub-Brand: Kitty Vault)**  
> *Practical Execution Checklist for Flutter Frontend Development*

---

## PHASE 0 — Project Audit & Setup Readiness
- [ ] Verify Flutter 3.22+ environment: `flutter doctor -v` passes cleanly
- [ ] Configure Flutter workspace directory within project tree
- [ ] Configure Android `minSdkVersion: 23`, `compileSdkVersion: 34`, `targetSdkVersion: 34`
- [ ] Configure iOS deployment target: iOS 14.0+
- [ ] Populate `pubspec.yaml` with core dependencies (`flutter_riverpod`, `go_router`, `dio`, `flutter_secure_storage`, `google_fonts`, `intl`, `image_picker`, `flutter_svg`, `webview_flutter`, `local_auth`)
- [ ] Setup assets directory hierarchy (`assets/images/`, `assets/icons/`, `assets/mocks/`)
- [ ] Setup strict static analysis rules in `analysis_options.yaml`
- [ ] Verify clean build: `flutter build apk --debug` executes without errors

---

## PHASE 1 — Core Foundation & Infrastructure
- [ ] Implement design tokens: `AppColors` (Deep Emerald `#05241C`, Metallic Gold `#C59B27`, Slate, Off-White)
- [ ] Implement typography: `AppTypography` (`Cinzel` for branding, `Plus Jakarta Sans` for body/numbers)
- [ ] Implement layout dimensions: `AppSpacing`, `AppRadius`, `AppElevations`
- [ ] Implement dual-surface themes: `AppTheme.darkTheme` and `AppTheme.lightTheme`
- [ ] Implement environment config: `AppEnvironment` and `AppConfig` with `--dart-define` support
- [ ] Implement secure storage: `SecureStorageService` wrapping `FlutterSecureStorage`
- [ ] Implement HTTP client: `DioClient` with 15s timeout and structured interceptors
- [ ] Implement interceptors: `AuthInterceptor` (Bearer token & 401 handling), `LoggingInterceptor`, `ErrorInterceptor`
- [ ] Implement error taxonomy: `AppException` mapping HTTP statuses (400, 401, 403, 404, 409, 422, 429, 500)
- [ ] Implement utilities: `CurrencyFormatter` (Indian Rupee `₹5,000`), `DateFormatter` (UTC to IST conversion)
- [ ] Implement connectivity detection: `ConnectivityService` broadcast stream
- [ ] Write and pass unit tests for formatters and error interceptors

---

## PHASE 2 — Routing & Application Shell
- [ ] Configure `GoRouter` with typed `AppRoute` definitions
- [ ] Implement route redirect guard inspecting `authNotifierProvider`
- [ ] Implement `AppShellScaffold` with persistent header, drawer, and bottom navigation
- [ ] Implement sticky header (`HeaderNavBar`) with gold rate ticker strip and drawer toggle
- [ ] Implement luxury navigation drawer (`LuxuryNavDrawer`) with user avatar and menu links
- [ ] Implement bottom navigation bar (`AppBottomNavBar`) with 4 tabs (Home, My Kitty, Offers, Settings)
- [ ] Configure modal routes for KYC, checkout bottom sheet, and PDF receipt preview
- [ ] Implement Android physical back button handler
- [ ] Write and pass widget tests for route guards and tab switching

---

## PHASE 3 — Shared Design System & Reusable Components
- [ ] Implement primary button: `GoldPrimaryButton` with loading spinner and disabled state
- [ ] Implement secondary button: `LuxuryOutlineButton` and `GhostButton`
- [ ] Implement text input: `AppTextField` with floating label and error helper text
- [ ] Implement phone field: `PhoneInputField` with fixed `+91` flag badge
- [ ] Implement OTP box: `OtpBox` with single-digit auto-focus
- [ ] Implement cards: `LuxuryCard`, `EmeraldSurfaceCard`, `WhiteLedgerCard`
- [ ] Implement badges: `StatusBadge` supporting `PAID`, `CURRENT`, `UPCOMING`, `BONUS`, `PRE_JOIN`
- [ ] Implement amount displays: `CurrencyText`, `GoldWeightText` (3 decimal places)
- [ ] Implement feedback widgets: `AppShimmer`, `EmptyStateCard`, `ErrorStateCard`, `OfflineBanner`
- [ ] Implement dialogs: `AppConfirmationDialog`, `AppBottomSheetContainer`
- [ ] Implement gauge widget: `CircularProgressGauge` (animating 8/12 progress fraction)
- [ ] Write and pass widget tests for all shared UI components

---

## PHASE 4 — Mock API & Data Foundation
- [ ] Implement DTOs with JSON serialization: `UserDto`, `KycDto`, `SchemeDto`, `MembershipDto`, `PassbookItemDto`, `PaymentOrderDto`, `GoldRateDto`
- [ ] Implement domain entities: `User`, `KycInfo`, `Scheme`, `Membership`, `DashboardSummary`, `PassbookItem`, `GoldRate`
- [ ] Implement DTO $\leftrightarrow$ Domain mappers with defensive null-safety and `.unknown` enum fallbacks
- [ ] Implement abstract repository interfaces: `IAuthRepository`, `IKycRepository`, `ISchemeRepository`, `IMembershipRepository`, `IPaymentRepository`, `IRateRepository`
- [ ] Copy approved mock JSON fixtures into `assets/mocks/`:
  - [ ] `auth_verify_success.json` (User Rihan, Tier 1, Chit #SW-042)
  - [ ] `dashboard_active_suvarna.json` (₹60,000 target, 8/12 paid, 5.482g gold, ₹41,036 valuation)
  - [ ] `schemes_active.json` (Suvarna Varsha 12-month, Wedding Collection)
  - [ ] `rates_gold.json` (₹7,485.50/g 24K, ₹6,860.00/g 22K)
- [ ] Implement mock repositories with simulated latency (600ms) and failure flags: `MockAuthRepository`, `MockMembershipRepository`, etc.
- [ ] Configure Riverpod provider toggles based on `AppConfig.useMockApi`
- [ ] Write and pass unit tests for all DTO mappers and mock data deserialization

---

## PHASE 5 — Splash & Authentication Flow
- [ ] Implement `SplashScreen` with 3D diamond brand intro asset
- [ ] Implement lightweight session check: verify stored JWT in `FlutterSecureStorage`
- [ ] Implement `LoginScreen` with Google sign-in placeholder and phone number input
- [ ] Implement 10-digit Indian phone number validator
- [ ] Implement `OtpVerificationScreen` with 6 auto-advancing digit input boxes
- [ ] Implement OTP clipboard auto-paste listener
- [ ] Implement 30-second countdown timer with "Resend OTP" trigger
- [ ] Implement `AuthNotifier` managing auth lifecycle (`unauthenticated`, `loading`, `otpSent`, `authenticated`)
- [ ] Implement 30-day JWT token and user profile persistence in `SecureStorageService`
- [ ] Implement `AuthSuccessCard` with member Patron Tier badge before navigating to Dashboard
- [ ] Wire up 401 HTTP response interceptor to auto-purge storage and redirect to Login
- [ ] Write and pass unit and widget tests for auth state and screen transitions

---

## PHASE 6 — Statutory KYC Verification Flow
- [ ] Implement `KycScreen` matching `kyc.html` styling
- [ ] Implement document selector tabs (`AADHAAR` vs `PAN`)
- [ ] Implement dynamic input masking: Aadhaar (`XXXX XXXX XXXX`) and PAN (`ABCDE1234F`)
- [ ] Implement `ImagePickerService` supporting camera capture and gallery selection
- [ ] Implement client-side file constraints: $\le 10\text{ MB}$, allowed formats (JPEG, PNG, PDF)
- [ ] Implement upload thumbnail preview card with file size and remove action
- [ ] Implement statutory RBI & PMLA consent checkbox
- [ ] Implement `KycNotifier` handling upload progress, multipart submission, and error handling
- [ ] Implement KYC status cards: reference code code display, "Under Verification" badge, "Verification Failed" banner
- [ ] Write and pass widget tests for KYC form validation and upload previews

---

## PHASE 7 — Home & Product Discovery
- [ ] Implement `HomeScreen` matching `home.html` layout
- [ ] Implement `TrustRateStrip` sticky bar rendering live 24K & 22K gold rates per gram and % change
- [ ] Implement `ActiveKittyBannerCard` conditionally rendered if user has active enrollment
- [ ] Implement `KittyCarouselTrack` auto-playing promotional banner slider with indicator dots
- [ ] Implement `CategoryScrollTrack` horizontal category pills (Rings, Bangles, Coins, Bridal)
- [ ] Implement `CuratedProductGrid` displaying jewelry items with price and purity tags
- [ ] Implement wishlist heart button toggle with local state persistence
- [ ] Implement pull-to-refresh updating gold rates and promotional feed
- [ ] Write and pass widget tests for carousel swipe, wishlist toggle, and rate strip

---

## PHASE 8 — Kitty / Scheme Dashboard
- [ ] Implement `DashboardScreen` reproducing `dashboard.html` luxury styling
- [ ] Implement `ActiveSchemeHeroCard` with chit token badge (`#SW-042`) and commitment target
- [ ] Implement `CircularProgressGauge` animating to paid fraction ($8/12 = 67\%$)
- [ ] Implement 2x2 `FinancialStatGrid`: Target (`₹60,000`), Paid (`₹40,000`), Gold (`5.482 g`), Valuation (`₹41,036`)
- [ ] Implement `SchemeNextEmiCard` displaying upcoming installment, due date, and "5 Days Left" warning pill
- [ ] Implement prominent Gold CTA button `"PAY NEXT EMI (₹5,000) ->"`
- [ ] Implement KYC compliance guard: prompt KYC bottom sheet if user is unverified
- [ ] Implement `EmptyDashboardView` for users with zero active schemes, prompting enrollment
- [ ] Implement `DashboardNotifier` managing `AsyncValue<DashboardSummary>`
- [ ] Write and pass unit tests verifying dashboard values match backend authoritatively

---

## PHASE 9 — 12-Month Passbook & Installment Ledger
- [ ] Implement `PassbookScreen` using Surface Light (`#F8F9FA`) design system
- [ ] Implement `PassbookViewToggle` switching between Timeline Table view and Card view
- [ ] Implement `PassbookTimelineTable` rendering all 12 monthly installment nodes
- [ ] Implement installment status mapping:
  - [ ] `PAID`: Green badge, transaction ID, gold weight, active "Receipt" button
  - [ ] `CURRENT`: Amber highlight card, due date, active "Pay Now" button
  - [ ] `UPCOMING`: Muted row with scheduled calendar date
  - [ ] `BONUS`: Gold star badge and "100% Jeweler Bonus Deposit" note for Month 12
  - [ ] `PRE_JOIN`: Muted row with lock icon: *"Joined Month N (Excluded from balance)"*
- [ ] Implement "View Receipt" button callback routing to Digital Receipt modal
- [ ] Implement pull-to-refresh re-fetching ledger records
- [ ] Write and pass widget tests verifying all 12 rows, `PRE_JOIN` display, and receipt action

---

## PHASE 10 — Offers & Scheme Catalog
- [ ] Implement `OffersScreen` matching `offers.html`
- [ ] Implement `OffersFilterTabs` (Classic 12-Month, Express 6-Month, Royal Bridal)
- [ ] Implement `OfferPlanCard` displaying scheme duration, monthly EMI, and enrollment ratio
- [ ] Implement `PerksBulletList` highlighting 1-month bonus and making-charge discounts
- [ ] Implement "Enrol Now" button opening `EnrollmentModal`
- [ ] In `EnrollmentModal`, display dynamic late-joiner EMI notice if joining after Month 1
- [ ] Implement scheme enrollment calling `IMembershipRepository.joinScheme()`
- [ ] On enrollment success, show celebration dialog and route to Dashboard
- [ ] Write and pass widget tests for filter tabs and enrollment modal

---

## PHASE 11 — Payment Gateway Orchestration & Polling
- [ ] Implement `PaymentCheckoutSheet` bottom sheet displaying EMI breakdown (`₹5,000`)
- [ ] Implement `initiatePayment()` call retrieving GoKwik gateway `orderId`
- [ ] Implement `GokwikWebviewScreen` loading gateway checkout URL in sandboxed WebView
- [ ] Intercept gateway return redirect URLs to cleanly close WebView
- [ ] Implement `PaymentPollingNotifier` polling `GET /api/v1/payments/status/:orderId`:
  - [ ] Poll interval: 2.5 seconds, max 5 attempts
  - [ ] While `PENDING`: show shimmer indicator *"Verifying payment with bank..."*
  - [ ] When `SUCCESS`: show green checkmark animation, refresh Dashboard & Passbook
  - [ ] If timeout: show pending verification banner
- [ ] Enforce rule: Client never assumes payment success without backend verification
- [ ] Write and pass unit tests for polling loop, status success, and timeout handling

---

## PHASE 12 — Settings & Security Profile
- [ ] Implement `SettingsScreen` matching `settings.html`
- [ ] Implement Profile Header displaying member name, masked phone, and verified tier
- [ ] Implement UPI AutoPay & e-Mandate toggle setting
- [ ] Implement Nominee Details status row
- [ ] Implement Biometric App Lock toggle using `local_auth` (Fingerprint / Face ID)
- [ ] Implement "Change 4-Digit MPIN" trigger opening `MpinDialog`
- [ ] Implement App Language selector
- [ ] Implement "Log Out of Account" destructive confirmation dialog:
  - [ ] Clear tokens from `FlutterSecureStorage`
  - [ ] Reset all Riverpod providers
  - [ ] Navigate to `/auth/login`
- [ ] Write and pass widget tests for logout purge and biometric settings

---

## PHASE 13 — Digital Receipts & PDF Modal
- [ ] Implement `DigitalReceiptModal` bottom sheet reproducing receipt in `passbook.html`
- [ ] Render transaction metadata: Txn ID, date/time in IST, amount (`₹5,000`), gold weight (`0.702 g`)
- [ ] Implement "Download / Print PDF" button consuming Cloudinary `receiptUrl`
- [ ] Implement in-app PDF preview or URL launcher
- [ ] Implement fallback state when receipt URL is still generating
- [ ] Write and pass widget tests for receipt formatting and download actions

---

## PHASE 14 — In-App Notifications
- [ ] Implement `NotificationsScreen` accessible via top header bell icon
- [ ] Implement `NotificationItemTile` with badges (Payment, Gold Rate, Winner, EMI Due)
- [ ] Implement read/unread visual styling (unread highlighted with subtle gold dot)
- [ ] Implement "Mark all as read" header action
- [ ] Implement deep link navigation from notification tap to destination screens
- [ ] Implement empty state card when notifications list is empty
- [ ] Write and pass widget tests for read state toggling and deep linking

---

## PHASE 15 — Global Production States & Edge Cases
- [ ] Verify shimmer skeletons on all data-driven screens (`HomeScreen`, `DashboardScreen`, `PassbookScreen`, `OffersScreen`)
- [ ] Implement dedicated empty state cards for all zero-data scenarios
- [ ] Implement global `OfflineBanner` displaying when network connection drops
- [ ] Implement retry buttons on all `ErrorStateCard` instances invoking provider invalidation
- [ ] Test edge cases: 2G cellular latency, expired JWT auto-logout, unverified KYC guards
- [ ] Write and pass widget tests for error retry and offline banner animation

---

## PHASE 16 — Real Staging Backend Integration
- [ ] Update `app_config.dart`: set `useMockApi = false` and set Staging Base URL
- [ ] Verify DNS, TLS/HTTPS handshake, and NGINX reverse proxy connectivity
- [ ] Execute live OTP dispatch (`POST /api/v1/auth/send-otp`) to test phone
- [ ] Execute live OTP verification (`POST /api/v1/auth/verify-otp`) receiving real 30-day JWT
- [ ] Verify Bearer token header injection on all subsequent staging requests
- [ ] Upload real test Aadhaar image $\le 10\text{ MB}$ (`POST /api/v1/users/kyc`) to Cloudinary
- [ ] Load live active schemes (`GET /api/v1/schemes/active`)
- [ ] Enroll in scheme and verify dynamic EMI (`POST /api/v1/memberships/join`)
- [ ] Load active dashboard metrics (`GET /api/v1/memberships/my-dashboard`)
- [ ] Initiate GoKwik sandbox order (`POST /api/v1/payments/initiate`)
- [ ] Execute test payment and verify polling reconciliation (`GET /api/v1/payments/status/:orderId`)

---

## PHASE 17 — Joint Integration Testing & Contract Verification
- [ ] Validate HTTP Status Contract: `400` validation, `401` logout, `403` KYC block, `409` duplicate pay, `429` rate limit
- [ ] Verify GoKwik webhook ACID transaction updating payment status to `SUCCESS` and incrementing total paid
- [ ] Verify Cloudinary PDF receipt generation and download
- [ ] Verify zero contract deviations; resolve defects without altering frozen contract v1.0
- [ ] Formally sign off on `BACKEND_INTEGRATION_DEFINITION_OF_DONE.md`

---

## PHASE 18 — Security Hardening & Performance Optimization
- [ ] Perform binary scan verifying zero hardcoded secrets, API keys, or tokens in source
- [ ] Verify all JWT tokens stored strictly in Android KeyStore / iOS Keychain
- [ ] Verify PII stripping in all production release logs (`kReleaseMode`)
- [ ] Profile rendering performance using Flutter DevTools: verify 60 FPS scrolling
- [ ] Eliminate unnecessary widget rebuilds using Riverpod `select`
- [ ] Verify bundled APK download size $\le 25\text{ MB}$
- [ ] Configure disk and memory caching for all network jewelry images

---

## PHASE 19 — Comprehensive Multi-Device QA Suite
- [ ] Execute complete unit test suite (`flutter test test/unit/`): $>90\%$ coverage on data/domain
- [ ] Execute complete widget test suite (`flutter test test/widget/`)
- [ ] Execute end-to-end integration test (`flutter test integration_test/`)
- [ ] Test on small Android screen (5.5", 720x1280)
- [ ] Test on standard Android screen (6.5", 1080x2400)
- [ ] Test on large screen / tablet viewport
- [ ] Verify zero layout overflows with system accessibility font scaling set to $1.5\times$

---

## PHASE 20 — Release Engineering & Store Preparation
- [ ] Configure Production API Base URL in `app_config.dart`
- [ ] Ensure mock mode is permanently disabled in release build target
- [ ] Generate release Android Keystore (`key.jks`) and configure Gradle signing
- [ ] Configure production app launcher icon with Swastik emblem using `flutter_launcher_icons`
- [ ] Configure native Android 12+ splash screen using `flutter_native_splash`
- [ ] Set release version: `version: 1.0.0+1`
- [ ] Configure runtime permissions in `AndroidManifest.xml` (Camera, Internet, Biometrics)
- [ ] Build release Android App Bundle: `flutter build appbundle --release`
- [ ] Build release iOS Archive: `flutter build ipa --release`
- [ ] Perform final physical device smoke test on signed release build
