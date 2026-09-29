# Requirements Traceability Matrix (RTM)

## 1. Overview
This matrix maps every requirement extracted from the Kitty App design documents and prototypes to its associated Feature, Screen, UI Component, State, Data Model, API Dependency, and Test Coverage.

---

## 2. Comprehensive Traceability Matrix

| Req ID | Requirement Description | Feature | Screen | UI Component | Frontend State | Data Model | API Dependency | Test Coverage | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **REQ-01** | 3D rotating diamond brand intro sequence | Splash / Loader | `index.html` / Splash | `DiamondCanvasView` | `SplashState.animating` | N/A | Local WebGL / Canvas | Golden / Widget Test | PLANNED |
| **REQ-02** | Select login method (Google vs Phone) | Authentication | `login.html` (View 0) | `BtnGoogle`, `BtnMobileTrigger` | `LoginState.initial` | N/A | N/A | Widget Test | PLANNED |
| **REQ-03** | Enter phone with international country code | Authentication | `login.html` (View 1) | `PhoneInputField`, `CountryDropdown` | `LoginState.phoneInput` | `UserModel` | `POST /api/auth/send-otp` | Phone Validator Unit Test | PLANNED |
| **REQ-04** | 6-digit OTP entry with auto-focus & paste | Authentication | `login.html` (View 2) | `OtpInputGrid`, `OtpBox` | `LoginState.otpVerifying` | `UserModel` | `POST /api/auth/verify-otp` | OTP Unit & Widget Test | PLANNED |
| **REQ-05** | 30s OTP countdown timer with resend link | Authentication | `login.html` (View 2) | `ResendCountdownTimer` | `OtpTimerState` | N/A | `POST /api/auth/send-otp` | Timer Unit Test | PLANNED |
| **REQ-06** | Authenticated success card with Patron Tier | Authentication | `login.html` (View 3) | `SuccessCard`, `TierBadge` | `LoginState.authenticated`| `UserModel.tier` | `POST /api/auth/verify-otp` | Widget Test | PLANNED |
| **REQ-07** | Aadhaar (12-digit) / PAN (10-char) document tabs| KYC Verification| `kyc.html` | `DocSelectorTabs` | `KycState.docType` | `KycInfoModel` | N/A | Tab Switch Widget Test | PLANNED |
| **REQ-08** | Real-time Aadhaar 4-4-4 & PAN uppercase mask | KYC Verification| `kyc.html` | `KycTextInput` | `KycState.maskedNumber` | `KycInfoModel` | N/A | Masking Unit Test | PLANNED |
| **REQ-09** | Camera capture & gallery file upload | KYC Verification| `kyc.html` | `KycDropzoneUpload` | `KycState.fileSelected` | `KycInfoModel` | N/A | Image Picker Stub Test | PLANNED |
| **REQ-10** | Image thumbnail preview with size & delete | KYC Verification| `kyc.html` | `UploadPreviewCard` | `KycState.previewReady` | N/A | N/A | Widget Test | PLANNED |
| **REQ-11** | Statutory RBI & PMLA consent checkbox | KYC Verification| `kyc.html` | `ConsentCheckbox` | `KycState.consentChecked`| N/A | N/A | Widget Test | PLANNED |
| **REQ-12** | KYC submission with reference code feedback | KYC Verification| `kyc.html` | `BtnSubmitKyc`, `SuccessView`| `KycState.submitted` | `KycInfoModel` | `POST /api/users/kyc` | Integration Test | PLANNED |
| **REQ-13** | Top sticky brand header with 3-lines menu | Navigation | App-wide | `HeaderNavBar`, `NavToggleBtn` | N/A | N/A | N/A | Widget Test | PLANNED |
| **REQ-14** | Slide-out luxury navigation drawer with user card | Navigation | App-wide | `LuxuryNavDrawer`, `UserAvatar`| `DrawerState.open` | `UserModel` | N/A | Drawer Interaction Test | PLANNED |
| **REQ-15** | Active kitty privileges summary banner on home | Home | `home.html` | `ActiveKittyBannerCard` | `HomeState.hasPlan` | `DashboardSummaryModel` | `GET /api/memberships/my-dashboard`| Widget Test | PLANNED |
| **REQ-16** | Touch / swipe auto-playing kitty promo carousel | Home | `home.html` | `KittyCarouselTrack`, `Dots` | `CarouselIndexState` | `SchemeModel` | `GET /api/schemes/active` | Widget Drag Test | PLANNED |
| **REQ-17** | Horizontal category scroll track (Rings, Bangles) | Home | `home.html` | `CategoryScrollTrack`, `Pills`| N/A | N/A | N/A | Widget Test | PLANNED |
| **REQ-18** | Curated product grid with wishlist heart toggle | Home | `home.html` | `CuratedProductCard`, `Wishlist`| `WishlistLocalState` | N/A | N/A | Widget Toggle Test | PLANNED |
| **REQ-19** | Gold Rate & Trust strip with live benchmark rates | Home & Header | `home.html`, Header | `TrustRateStrip`, `GoldTicker` | `LiveGoldRateState` | `LiveGoldRateModel` | `GET /api/rates/gold` | Rate Ticker Unit Test | PLANNED |
| **REQ-20** | Active scheme hero card with chit badge (#SW-042)| My Scheme / Dash | `dashboard.html` | `ActiveSchemeHeroCard` | `DashboardState.loaded` | `MembershipModel` | `GET /api/memberships/my-dashboard`| Widget Test | PLANNED |
| **REQ-21** | Circular SVG progress gauge (e.g. 8/12, 67%) | My Scheme / Dash | `dashboard.html` | `CircularProgressGauge` | `DashboardState.progress` | `DashboardSummaryModel` | N/A | Gauge Math Unit Test | PLANNED |
| **REQ-22** | 2x2 statistics grid (Target, Paid, Gold, Gain) | My Scheme / Dash | `dashboard.html` | `FinancialStatCard` (4 cards) | `DashboardState.stats` | `DashboardSummaryModel` | N/A | Stats Calculation Test | PLANNED |
| **REQ-23** | Month 9 Due card with "5 Days Left" countdown | My Scheme / Dash | `dashboard.html` | `SchemeNextEmiCard` | `DashboardState.nextDue` | `DashboardSummaryModel` | N/A | Due Date Helper Test | PLANNED |
| **REQ-24** | Prominent Gold CTA "PAY NEXT EMI (₹5,000) ->" | My Scheme / Dash | `dashboard.html` | `GoldPrimaryButton` | `DashboardState.canPay` | `DashboardSummaryModel` | N/A | Widget Test | PLANNED |
| **REQ-25** | Payment checkout modal with UPI, NetBanking, Card| Payments | Modals | `PaymentCheckoutSheet` | `PaymentModalState` | `PaymentOrderModel` | `POST /api/payments/initiate` | Payment Flow Test | PLANNED |
| **REQ-26** | GoKwik payment gateway invocation & status poll | Payments | Gateway Webview | `GokwikWebview` | `PaymentProcessingState` | `PaymentOrderModel` | `POST /api/payments/webhook` | Webhook Poll Unit Test | PLANNED |
| **REQ-27** | 12-month installment table with status badges | Passbook | `passbook.html` | `PassbookTable`, `Rows` | `PassbookState.loaded` | `PassbookEntryModel` | `GET /api/memberships/my-dashboard`| Table Render Test | PLANNED |
| **REQ-28** | Passbook view mode toggle (Table vs Card view) | Passbook | `passbook.html` | `ViewToggleContainer` | `PassbookViewModeState` | N/A | N/A | Toggle Widget Test | PLANNED |
| **REQ-29** | Digital PDF receipt modal with in-app print trigger| Passbook / Modals| `passbook.html` | `DigitalReceiptModal` | `ReceiptModalState` | `PassbookEntryModel` | Cloudinary PDF link | Print Invocation Test | PLANNED |
| **REQ-30** | Scheme filter tabs (Classic, Express, Bridal) | Kitty Offers | `offers.html` | `OffersFilterTabs` | `OffersFilterState` | `SchemeModel` | `GET /api/schemes/active` | Filter Unit Test | PLANNED |
| **REQ-31** | Scheme perk cards highlighting 1-month free bonus | Kitty Offers | `offers.html` | `OfferPlanCard`, `PerksList` | `OffersState.list` | `SchemeModel` | `GET /api/schemes/active` | Widget Test | PLANNED |
| **REQ-32** | Late-joiner dynamic EMI math calculation | Kitty Offers / Join | Offers / Dashboard | `EnrollmentModal` | `EnrollmentState` | `MembershipModel` | `POST /api/memberships/join` | Dynamic Math Unit Test | PLANNED |
| **REQ-33** | UPI AutoPay & e-Mandate toggle setting | Settings | `settings.html` | `SettingsItem`, `Switch` | `SettingsState.autoPay` | `UserModel` | `PATCH /api/users/settings` | Switch Widget Test | PLANNED |
| **REQ-34** | Nominee registration status display | Settings | `settings.html` | `SettingsItem`, `Badge` | `SettingsState.nominee` | `UserModel` | N/A | Widget Test | PLANNED |
| **REQ-35** | Biometric app lock toggle (Fingerprint / Face ID)| Settings | `settings.html` | `SettingsItem`, `Switch` | `SettingsState.biometric` | Local Secure Storage | Platform `local_auth` | Biometric Stub Test | PLANNED |
| **REQ-36** | Change 4-digit transaction MPIN dialog | Settings | `settings.html` | `MpinDialog` | `MpinState` | Local Secure Storage | N/A | MPIN Dialog Test | PLANNED |
| **REQ-37** | Destructive "Log Out of Account" action with cleanup| Settings | `settings.html` | `BtnLogout` | `AuthState.unauthenticated`| N/A | Local Storage Clear | Logout Integration Test| PLANNED |
| **REQ-38** | [ADDED] Network disconnect detection & offline bar | Offline / Resilience| Global | `OfflineBanner` | `ConnectivityState` | Cached Dashboard Model | Platform Connectivity | Network Change Test | PLANNED |
| **REQ-39** | [ADDED] HTTP 401 token expiry auto-logout intercept | Security | Global | `AuthInterceptor` | `AuthState.sessionExpired` | N/A | Global HTTP Client | Interceptor Unit Test | PLANNED |
| **REQ-40** | [ADDED] Empty state for user with no active scheme | Empty States | Dashboard / Home | `EmptyStateCard` | `DashboardState.empty` | N/A | `GET /api/memberships/my-dashboard`| Empty State Widget Test| PLANNED |
