# UI Component Architecture

## 1. Overview
This document specifies the reusable component catalog extracted from the Kitty App UI prototypes (`home.html`, `dashboard.html`, `passbook.html`, `login.html`, `kyc.html`, `settings.html`).

Components are designed to be framework-agnostic, providing exact parameter specifications, variants, and states to avoid duplication during Flutter or Web implementation.

---

## 2. Reusable Component Inventory

### 2.1 Navigation & App Bars

#### Component 1: `HeaderNavBar`
* **Purpose:** Universal top sticky brand header providing brand identity and menu access.
* **Where Used:** Home, Dashboard, Passbook, Offers, Settings.
* **Props / Parameters:**
  - `logoAsset`: String (Default: `assets/swastiklogo.svg`)
  - `showBack`: Boolean (If true, renders circular back button instead of logo; used in Settings/KYC)
  - `title`: String? (Optional centered screen title, e.g. "Settings")
  - `onBack`: VoidCallback?
  - `onMenuTap`: VoidCallback (Triggers navigation drawer)
* **Variants:**
  - `Standard`: Logo on left, 3-lines menu on right.
  - `WithBack`: Circular back button on left, Title center, 3-lines menu on right.
* **States:** Default, Scrolled (adds subtle drop shadow and border).

---

#### Component 2: `LuxuryNavDrawer`
* **Purpose:** Modal slide-out navigation menu for rapid top-level feature routing.
* **Where Used:** App-wide (opened from `HeaderNavBar`).
* **Props / Parameters:**
  - `currentUser`: UserModel (Renders avatar, patron name, and chit number)
  - `activeRoute`: String (Highlights current active destination)
  - `onNavigate`: Function(String route)
  - `onClose`: VoidCallback
* **Items Rendered:** Home, My Scheme, Passbook & Statements, Kitty Offers & Schemes, Curated Collections, Settings, KYC Verification, Concierge Support.

---

### 2.2 Hero & Financial Presentation Cards

#### Component 3: `ActiveSchemeHeroCard`
* **Purpose:** High-impact hero card displaying active kitty status, installment rate, and progress gauge.
* **Where Used:** Dashboard (`dashboard.html`), Home (`home.html`).
* **Props / Parameters:**
  - `schemeName`: String (e.g. "Swastik Suvarna Varsha")
  - `chitToken`: String (e.g. "#SW-042")
  - `monthlyInstallment`: Double
  - `monthsPaid`: Int
  - `totalMonths`: Int
  - `jewelerBonusText`: String (e.g. "1 Bonus Month Free")
* **Sub-Components:**
  - `CircularProgressGauge`: SVG / CustomPainter circular gauge ($r=66$, fraction `8 / 12`, percentage `67%`).
  - `SchemeStatusPill`: Green active pulsing dot + "ACTIVE SCHEME".
* **States:** Active, Due, Fully Paid.

---

#### Component 4: `FinancialStatCard`
* **Purpose:** Displays a single financial metric within the 2x2 dashboard statistics grid.
* **Where Used:** Dashboard (`dashboard.html`).
* **Props / Parameters:**
  - `icon`: Widget / SvgPicture (Target, Wallet, Gold Bars, Bar Chart)
  - `label`: String (Uppercase multi-line title, e.g. "SCHEME TARGET")
  - `value`: String (Formatted currency/weight, e.g. "₹60,000", "5.482 g")
  - `deltaPct`: Double? (Optional gain percentage, e.g. `+2.59%`)
  - `isGain`: Boolean? (Renders green for positive, red for negative)
* **Variants:** Currency value, Gold weight value, Percentage return value.

---

### 2.3 Passbook & Transaction Ledger

#### Component 5: `PassbookTableRow`
* **Purpose:** Standardized row representing a single month's savings installment in Table View.
* **Where Used:** Passbook (`passbook.html`).
* **Props / Parameters:**
  - `monthNumber`: Int (1 to 12)
  - `monthLabel`: String ("Month 1", "Month 12")
  - `amount`: Double (₹5,000)
  - `status`: Enum (`PAID`, `CURRENT`, `UPCOMING`, `BONUS`)
  - `paidDate`: String? ("15 Jan 2026")
  - `goldGrams`: Double? (0.702 g)
  - `paymentMethod`: String? ("UPI (GPay)", "Cash")
  - `transactionId`: String? ("TXN-SW-10821")
  - `onViewReceipt`: VoidCallback?
  - `onPayNow`: VoidCallback?
* **States:**
  - `PAID`: Displays green pill + "View Receipt" secondary button.
  - `CURRENT`: Amber highlight row + "Pay Now" CTA button.
  - `UPCOMING`: Muted grey text + "Scheduled" label.
  - `BONUS`: Yellow highlight row + "100% Free Jeweler Bonus" label.

---

#### Component 6: `PassbookCardNode`
* **Purpose:** Mobile-optimized vertical timeline node representing an installment in Card View.
* **Where Used:** Passbook (`passbook.html` when Card View toggle is active).
* **Props / Parameters:** Same as `PassbookTableRow`.
* **Variants:** Compact card with left timeline indicator bar.

---

### 2.4 Buttons & Action Triggers

#### Component 7: `GoldPrimaryButton`
* **Purpose:** High-prominence luxury call-to-action button.
* **Where Used:** "PAY NEXT EMI", "Submit KYC", "Enter Kitty Vault", "Verify & Continue".
* **Props / Parameters:**
  - `label`: String
  - `icon`: Widget?
  - `isLoading`: Boolean (Replaces text with centered gold/white spinner)
  - `isEnabled`: Boolean
  - `onPressed`: VoidCallback
  - `fullWidth`: Boolean (Default: true)
* **States:** Default, Hover, Pressed (scale 0.97), Disabled (muted gray background), Loading.

---

#### Component 8: `SecondaryOutlineButton`
* **Purpose:** Clean, neutral action button.
* **Where Used:** "View Receipt", "Print Receipt", "Choose File".
* **Props / Parameters:**
  - `label`: String
  - `icon`: Widget?
  - `onPressed`: VoidCallback

---

### 2.5 Form Controls & Inputs

#### Component 9: `PhoneInputField`
* **Purpose:** International telephone entry with country code picker and validation.
* **Where Used:** Login (`login.html`).
* **Props / Parameters:**
  - `selectedCountry`: CountryCode (Default: `+91` India)
  - `onCountryChanged`: Function(CountryCode)
  - `controller`: TextEditingController
  - `errorText`: String?
  - `onChanged`: Function(String)
  - `onClear`: VoidCallback

---

#### Component 10: `OtpInputGrid`
* **Purpose:** 6-box segmented OTP verification code input.
* **Where Used:** Login (`login.html` - View 2).
* **Props / Parameters:**
  - `length`: Int (Default: 6)
  - `onCompleted`: Function(String pin)
  - `onChanged`: Function(String pin)
  - `hasError`: Boolean
* **Behaviors:** Auto-advances to next box on input, returns to previous on backspace, supports full paste of 6-digit SMS text.

---

#### Component 11: `KycDropzoneUpload`
* **Purpose:** Media capture dropzone supporting camera and gallery file uploads with live preview.
* **Where Used:** KYC Verification (`kyc.html`).
* **Props / Parameters:**
  - `selectedFile`: File?
  - `onTakePhoto`: VoidCallback
  - `onChooseFile`: VoidCallback
  - `onRemoveFile`: VoidCallback
  - `supportedFormats`: List<String> (JPG, PNG, WEBP, PDF)
  - `maxSizeMb`: Int (10)
* **States:** Empty dropzone state, File selected with thumbnail preview card, Upload progress state.

---

### 2.6 Modals, Sheets & Overlays

#### Component 12: `PaymentCheckoutSheet`
* **Purpose:** Modal bottom sheet for selecting payment method and initiating installment payments.
* **Where Used:** Dashboard, Home, Passbook.
* **Props / Parameters:**
  - `amount`: Double
  - `monthNumber`: Int
  - `selectedMethod`: PaymentMethodEnum (UPI, NetBanking, Card)
  - `onMethodSelect`: Function(PaymentMethodEnum)
  - `onConfirmPayment`: VoidCallback
  - `onClose`: VoidCallback

---

#### Component 13: `DigitalReceiptModal`
* **Purpose:** Official digital tax and gold invoice modal view with print capability.
* **Where Used:** Passbook, Dashboard.
* **Props / Parameters:**
  - `transaction`: PassbookEntryModel
  - `membership`: MembershipModel
  - `onPrint`: VoidCallback
  - `onDownloadPdf`: VoidCallback
  - `onClose`: VoidCallback

---

### 2.7 Feedback, Skeletons & Empty States

#### Component 14: `EmptyStateCard`
* **Purpose:** Displays friendly, illustrative guidance when no records exist.
* **Where Used:**
  - No Active Scheme: Home / Dashboard when user hasn't enrolled in a kitty.
  - No Transactions: Passbook when ledger is empty.
  - Search/Filter Empty: Kitty offers when filters yield no matches.
* **Props / Parameters:**
  - `icon`: Widget (Jewelry box, empty ledger, or sparkle illustration)
  - `title`: String
  - `subtitle`: String
  - `actionLabel`: String?
  - `onAction`: VoidCallback?

---

#### Component 15: `DashboardSkeletonLoader`
* **Purpose:** Shimmer placeholder matching exact dashboard card geometry during initial API load.
* **Where Used:** Dashboard, Home, Passbook.
* **Behaviors:** Subtle pulsing champagne/gray shimmer animation without layout shift.
