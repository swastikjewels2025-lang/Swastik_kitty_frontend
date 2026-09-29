# Screen Flow & Granular Screen Inventory — Kitty App

**Project**: Swastik Jewellers Kitty App (Sub-Brand: Kitty Vault)  
**Primary Codebase**: D:\kitty_app\  
**Document Status**: SUPERSEDED  
**SUPERSEDED BY**: INFORMATION_ARCHITECTURE_V2.md & KITTY_USER_FLOWS_V2.md  
**Last Audit Date**: 2026-09-29  

> [!NOTE]
> **STATUS: SUPERSEDED (PRESERVED FOR HISTORICAL CONTEXT)**  
> This V1 screen flow inventory has been superseded by [INFORMATION_ARCHITECTURE_V2.md](file:///D:/kitty_frontend/kitty_docs/02_UX_UI/INFORMATION_ARCHITECTURE_V2.md) and [KITTY_USER_FLOWS_V2.md](file:///D:/kitty_frontend/kitty_docs/02_UX_UI/KITTY_USER_FLOWS_V2.md). Do not delete.

---

## 1. Master Screen Inventory

The application currently comprises 18 dedicated screen and modal surfaces:

```text
Authentication Stack:
  â”œâ”€â”€ /splash                     [SplashScreen]
  â”œâ”€â”€ /auth/login                 [LoginScreen]
  â”œâ”€â”€ /auth/phone                 [PhoneScreen]
  â”œâ”€â”€ /auth/otp                   [OtpScreen]
  â”œâ”€â”€ /auth/profile               [RegisterProfileScreen]
  â””â”€â”€ /auth/success               [AuthSuccessScreen]

Application Shell Branches (StatefulShellRoute):
  â”œâ”€â”€ /home                       [HomeScreen] (Branch 0 â€” Bottom Nav Tab 0 "Home")
  â”œâ”€â”€ /coin-rates                 [CoinRatesScreen] (Branch 1 â€” Bottom Nav Tab 1 "Coins")
  â”œâ”€â”€ /jewellery                  [JewelleryScreen] (Branch 2 â€” Bottom Nav Tab 2 "Jewellery")
  â”œâ”€â”€ /dashboard                  [DashboardScreen / My Scheme] (Branch 3 â€” Bottom Nav Tab 3 "My Scheme")
  â”œâ”€â”€ /menu                       [MenuScreen] (Branch 4 â€” Bottom Nav Tab 4 "Menu")
  â”œâ”€â”€ /calculator                 [CalculatorScreen] (Coins Page & Direct Link)
  â”œâ”€â”€ /passbook                   [PassbookScreen] (Drawer Destination & Direct Link)
  â”œâ”€â”€ /offers                     [OffersScreen] (Drawer Destination & Direct Link)
  â””â”€â”€ /settings                   [SettingsScreen] (Drawer Destination & Direct Link)

Modal & Top-Level Stack Routes:
  â”œâ”€â”€ /kyc                        [KycScreen]
  â”œâ”€â”€ /checkout                   [CheckoutScreen & PickCashSheet]
  â”œâ”€â”€ /receipt/:id                [ReceiptScreen]
  â”œâ”€â”€ /notifications              [NotificationsScreen]
  â””â”€â”€ /gokwik-gateway             [GoKwikGatewayScreen]
```

---

## 2. Granular Screen Specifications

### 2.1 Splash Screen (`/splash`)
* **Class**: `SplashScreen` (`lib/features/splash/presentation/screens/splash_screen.dart`)
* **Entry Point**: App launch, deep link without session, or route reset.
* **Exit Points**:
  - `/home`: Valid authenticated session exists and KYC is compliant.
  - `/kyc`: Valid session exists but statutory KYC is pending.
  - `/auth/login`: No active session or token has expired.
* **Key Components**: Emerald background canvas root (`AppColors.emeraldDeep`), `Diamond3dPainter` (hardware-accelerated canvas particle system), Swastik Jewellers crest logo, gold progress indicator.
* **Current Behavior**: Renders on an immediate solid deep emerald background eliminating blank white frames. Diamond performs a gentle breathing scale (0.95 to 1.15) and smoothly dissolves into the central Swastik brand crest while resolving session credentials from `SecureStorageService`.

---

### 2.2 Login Screen (`/auth/login`)
* **Class**: `LoginScreen` (`lib/features/auth/presentation/screens/login_screen.dart`)
* **Entry Point**: App launch without session, logout action from Settings.
* **Exit Points**:
  - `/auth/phone`: Patron clicks "Continue with Mobile Number".
  - `/auth/success`: Patron completes Instagram SSO authentication abstraction.
* **Key Components**: `JewelryConstellationPainter` (3D rotating solitaire and bangle background), damask wallpaper texture, glassmorphic card container, "Continue with Instagram" branded button with royal gradient icon, "Or" divider, Mobile auth button.
* **Current Behavior**: Multi-step container supporting both Instagram SSO abstraction (`authController.loginWithInstagram()`) and mobile OTP authentication.

---

### 2.3 Mobile Phone Screen (`/auth/phone`)
* **Class**: `PhoneScreen` (`lib/features/auth/presentation/screens/phone_screen.dart`)
* **Entry Point**: Clicked "Continue with Mobile Number" on Login screen.
* **Exit Points**:
  - `/auth/otp`: Successful OTP dispatch.
  - `/auth/login`: Back arrow pressed.
* **Key Components**: Country code selector (+91 India default), 10-digit phone field with auto-spacing (`XXXXX XXXXX`), clear button, "Send OTP" CTA.
* **Current Behavior**: Dispatches `POST /api/v1/auth/send-otp`. Disables CTA until 10 valid digits are entered.

---

### 2.4 OTP Verification Screen (`/auth/otp`)
* **Class**: `OtpScreen` (`lib/features/auth/presentation/screens/otp_screen.dart`)
* **Entry Point**: Dispatched OTP from Phone screen.
* **Exit Points**:
  - `/auth/profile`: Unregistered new user needing profile completion.
  - `/auth/success`: Existing verified user with complete profile.
  - `/auth/phone`: Edit mobile number tapped.
* **Key Components**: 6-cell PIN input grid, resend timer countdown (30s), error shake animation, "Verify OTP" button.
* **Current Behavior**: In sandbox/mock mode, testing OTP `123456` verifies immediately. On error, triggers haptic feedback and card shake.

---

### 2.5 Register Profile Screen (`/auth/profile`)
* **Class**: `RegisterProfileScreen` (`lib/features/auth/presentation/screens/register_profile_screen.dart`)
* **Entry Point**: Successful OTP verification for first-time user.
* **Exit Points**:
  - `/auth/success`: Profile submitted successfully.
* **Key Components**: Full Name field, Email Address field, City field, "Complete Registration" luxury CTA.
* **Current Behavior**: Persists profile details in `SecureStorageService` and updates Riverpod `appAuthStateProvider`.

---

### 2.6 Home Screen (`/home` â€” Shell Tab 0)
* **Class**: `HomeScreen` (`lib/features/home/presentation/screens/home_screen.dart`)
* **Entry Point**: Main app entry post-authentication; Bottom Dock Tab 0.
* **Exit Points**:
  - `/offers` or `/dashboard`: Scheme banners or quick actions tapped.
  - `/coin-rates`: Live rate card or coins quick action tapped.
  - `/jewellery`: Category rings/earrings tapped.
* **Key Components**:
  1. `HeaderNavBar`: Sticky header with left-aligned 24K gold rate ticker pill, centered Swastik SVG logo, right-aligned notification bell with badge counter, and hamburger drawer trigger.
  2. `HomeOffersCarousel`: Promotional scheme banners positioned immediately below the header with an increased vertical height of **265px** for prominent luxury presence without viewport overflow. Auto-scrolls every 5 seconds.
  3. `HomeGoldSilverRateCarousel`: Royal emerald card automatically rotating live benchmark rates between **Gold 24K (999)** and **999 Fine Silver** with smooth transitions and chevron manual controls.
  4. `HomeJewelleryCollections`: Circular curated masterpieces showcase (Rings, Earrings, Bangles, Necklaces, etc.) with gold accent border rings.
  5. `HomeSchemeCoinsQuickActions`: Clean emerald container with 2 floating circular icon buttons (`Icons.workspace_premium_outlined` for Gold Scheme and `Icons.monetization_on_outlined` for Coins) belonging to the same unified icon family.
  6. `HomeGoldPriceTrend`: Multi-line interactive trend chart with 1W, 1M, 6M, 1Y, 5Y timeframe selector, 24K, 22K, 18K curves, price guidelines, and gradient fills.
  7. `HomeFooter`: Clean luxury footer with About Us, Contact Us, Privacy Policy, Terms of Use, and copyright notice (`Â© 2026 Gold Calculator India Â· All rights reserved`).
* **States**:
  - *Loading*: `HomeSkeletonLoader` with gold shimmer.
  - *Error*: `KittyErrorState` with retry button.
  - *Loaded*: Smooth pull-to-refresh custom scroll view.

---

### 2.7 Coin Rates Screen (`/coin-rates` â€” Shell Tab 1)
* **Class**: `CoinRatesScreen` (`lib/features/coin_rates/presentation/screens/coin_rates_screen.dart`)
* **Entry Point**: Bottom Dock Tab 1.
* **Key Components**:
  - Top action bar featuring segmented Gold/Silver selector and prominent **Calculator** action button.
  - Predefined coins in a **Unified Table Layout**: `GM | PURITY | PRICE`, with a dedicated "Book Now" button on the right side of each row.
  - **Custom Gold Coin Selection**:
    - Heading placed outside the card, centered horizontally above it.
    - Centered 24K / 22K Karat selectors (redundant "Select Karat" sub-heading removed).
    - Centered Weight selector chips.
    - Custom grams input box with placeholder strictly reading `"Enter custom grams"`.
  - Karat selector hidden for Silver coins.
  - Booking confirmation dialog with showroom concierge booking trigger.
* **User Actions**: Switch between Gold and Silver; tap "Book Now"; open Calculator; configure custom weight and purity.

---

### 2.8 Jewellery Screen (`/jewellery` â€” Shell Tab 2)
* **Class**: `JewelleryScreen` (`lib/features/jewellery/presentation/screens/jewellery_screen.dart`)
* **Entry Point**: Bottom Dock Tab 2.
* **Key Components**:
  - Authentic showroom photography with smooth fade-in loading and graceful fallback.
  - Metal Type dropdown cards: **Gold Jewellery** (22K 916) vs **Diamond Jewellery** (Natural VVS-EF).
  - 6 category chips: Rings, Pendants, Necklace, Earrings, Bangles, Bracelets.
  - 2-column item grid with purity, weight, pricing, and "Best Seller" badges.
  - Reservation enquiry dialog with showroom WhatsApp concierge.

---

### 2.9 Dashboard Screen (`/dashboard` â€” Shell Tab 3 "Offers / My Scheme")
* **Class**: `DashboardScreen` (`lib/features/dashboard/presentation/screens/dashboard_screen.dart`)
* **Entry Point**: Bottom Dock Tab 3 ("Offers"), Navigation Drawer, or Home scheme cards.
* **Key Components**:
  - `DashboardHeroCard`: Circular SVG progress gauge, total saved, accrued gold weight.
  - `DashboardStatsGrid`: 2x2 grid (Months Paid, Jeweler Bonus, Next Due, Total Goal).
  - `DashboardNextEmiCard`: Upcoming installment countdown and one-tap checkout button.
  - `Passbook Link Card`: Quick navigation row to `/passbook`.

---

### 2.10 Menu Screen (`/menu` â€” Shell Tab 4 "Menu")
* **Class**: `MenuScreen` (`lib/features/menu/presentation/screens/menu_screen.dart`)
* **Entry Point**: Bottom Dock Tab 4 ("Menu").
* **Key Components**:
  - Fullscreen modern luxury menu exposing all options normally found in the luxury drawer.
  - Patron profile card, KYC status badge, My Schemes, Passbook, Notifications, Settings, and WhatsApp Concierge.

---

### 2.11 Calculator Screen (`/calculator`)
* **Class**: `CalculatorScreen` (`lib/features/calculator/presentation/screens/calculator_screen.dart`)
* **Entry Point**: Coins Page Calculator Button, or direct route.
* **Key Components**:
  - Dual Input Modes: **Shop by Gram** and **Shop by Money**.
  - Purity selector chips: 24K (Pure Gold), 22K (916 Hallmarked), 18K (Diamond Jewellery).
  - Real-time valuation output card displaying Applied Rate, Weight in Grams, and Total Valuation in INR.
  - Clear/reset button and soft keyboard dismissal on background tap.
---

### 2.12 Passbook Screen (`/passbook`)
* **Class**: `PassbookScreen` (`lib/features/passbook/presentation/screens/passbook_screen.dart`)
* **Entry Point**: Navigation Drawer or Dashboard passbook link.
* **Key Components**:
  - `PassbookSummaryCard`: 3 pillars (Total Deposited, Accrued Gold, Next Due Date).
  - `PassbookControlsRow`: Segmented switcher between **Table View** and **Card View**.
  - `PassbookTimelineTable`: 12-month installment table with receipt action triggers.
  - `PassbookCardsList`: Touch-optimized vertical stack of installment cards.
  - `PassbookPerksDialog`: Modal explaining Month 12 jeweler bonus terms.

---

### 2.12 KYC Screen (`/kyc` â€” Modal & Drawer Route)
* **Class**: `KycScreen` (`lib/features/kyc/presentation/screens/kyc_screen.dart`)
* **Entry Point**: Navigation Drawer, KYC reminder banner on Home, or Auth Guard redirect.
* **Key Components**:
  - 3D rotating jewelry constellation canvas (`JewelryConstellationPainter`).
  - Document Tab Switcher: **Aadhaar Card** vs **PAN Card**.
  - `KycDocNumberField`: Document number input with auto-formatting and masking.
  - `KycUploadCard`: Front & Back document image picker (Camera or Gallery).
  - `KycConsentCheckbox`: Statutory consent checkbox required under UIDAI and PMLA guidelines.
  - `KycStatusViews`: Verification status states (`NOT_SUBMITTED`, `PENDING`, `VERIFIED`, `REJECTED`).

---

### 2.13 Checkout Screen (`/checkout`)
* **Class**: `CheckoutScreen` (`lib/features/checkout/presentation/screens/checkout_screen.dart`)
* **Entry Point**: "Pay Installment" button on Home, Dashboard, or Passbook.
* **Key Components**:
  - Pre-filled installment context (Membership ID, Chit Token, Month number, Due Amount).
  - Interactive Payment Method Selector: UPI, Net Banking, Card, Pick Cash with active border/glow feedback.
  - GoKwik payment integration bridge for online methods.
  - `PickCashSheet`: Dedicated modal sheet for doorstep cash pickup with address validation, slot selection, and handover OTP.
  - Animated live reconciliation polling overlay (5 attempts $\times$ 3s).
  - Cancelation protection dialog: Warns user if attempting back button while bank verification is active.
  - Success outcome view with direct link to view digital tax receipt.

---

### 2.14 Digital Receipt Screen / Modal (`/receipt/:id`)
* **Class**: `ReceiptScreen` (`lib/features/receipt/presentation/screens/receipt_screen.dart`)
* **Entry Point**: Clicked "Receipt" in Passbook or "View Receipt" following checkout success.
* **Key Components**:
  - Tax invoice number, GSTIN, HSN gold bullion code.
  - Customer name, membership ID, chit token (`#SW-042`).
  - Payment mode (UPI/Card/NetBanking/Cash), transaction reference number, timestamp.
  - Official Swastik Jewellers watermark verification stamp.
  - Print / PDF export action buttons.

---

### 2.15 Settings Screen (`/settings`)
* **Class**: `SettingsScreen` (`lib/features/settings/presentation/screens/settings_screen.dart`)
* **Entry Point**: Navigation Drawer, Menu Screen, or direct route.
* **Key Components**:
  - **Patron Profile Card**: Shows full name, phone number, and verified tier chip.
  - **Security & Payments**: UPI AutoPay toggle switch, Biometric Login toggle switch, MPIN configuration modal dialog.
  - **Nominee Details**: Full name, relationship, and contact modal.
  - **Statutory & Legal**: Gold Scheme Terms, BIS 24K Hallmarking compliance modal.
  - **Session Management**: Secure logout action button with confirmation dialog.
* **Important Note**: Theme, Appearance, and Language options are **completely removed** to maintain an uncluttered focus on financial security and statutory compliance.

---

### 2.16 Notifications Screen (`/notifications`)
* **Class**: `NotificationsScreen` (`lib/features/notifications/presentation/screens/notifications_screen.dart`)
* **Entry Point**: Notification bell icon in header, Navigation Drawer, or Menu Screen.
* **Key Components**:
  - **Header Summary**: Unread count badge and "Mark All Read" action button.
  - **Category Tabs**: Filter by All, Scheme Alerts, and Privileges.
  - **Notification Tile Styling**:
    - **Gold Scheme Category**: Heading text rendered in canonical honey gold (`AppColors.honeyGoldAccent`).
    - **Modern Relevant Iconography**:
      - Transaction: `Icons.payments_rounded`
      - Gold Scheme: `Icons.workspace_premium_rounded`
      - Privileges / Offers: `Icons.loyalty_rounded`
      - Security / Vault: `Icons.verified_user_rounded`
      - Notice: `Icons.notifications_active_rounded`
  - **Interactive Detail Sheet**: Tapping any notification opens `NotificationDetailSheet`, marks the item as read, and displays deep link navigation actions (e.g. checkout, passbook).

