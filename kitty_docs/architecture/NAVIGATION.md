# Application Navigation Architecture

## 1. Overview
This document specifies the routing table, navigation hierarchy, route guards, deep linking schemes, modal presentations, and back-button behavior for the Swastik Jewel Kitty App.

---

## 2. Master Route Table

| Route Path | Screen / View | Type | Access Level | Description & Parameters |
| :--- | :--- | :--- | :--- | :--- |
| `/splash` | Splash Screen | Full Screen | Public | Initial entry route. 3D Diamond animation & session verification. |
| `/auth/login` | Login Screen | Full Screen | Public (Guest only) | View 0: Initial choice (Google SSO vs Mobile Number). |
| `/auth/phone` | Phone Input View | Sub-View / Stack | Public (Guest only) | View 1: Mobile phone entry with country code selector. |
| `/auth/otp` | OTP Verification View| Sub-View / Stack | Public (Guest only) | View 2: 6-digit OTP entry with resend countdown timer. |
| `/auth/success` | Auth Success View | Sub-View / Stack | Public | View 3: Success confirmation card with user tier. |
| `/kyc` | KYC Verification Screen | Stack Route | Protected (JWT) | Document selection (Aadhaar/PAN), camera upload, statutory consent. |
| `/home` | Home Screen | Top-Level Screen | Protected (JWT) | Brand showcase, promo carousel, category pills, curated catalog. |
| `/dashboard` | My Scheme Screen | Top-Level Screen | Protected (JWT) | Core active kitty pass, circular progress gauge, 2x2 stats, pay CTA. |
| `/passbook` | Passbook Screen | Top-Level Screen | Protected (JWT) | 12-month installment table/card view, transaction details, receipt buttons. |
| `/offers` | Kitty Offers Screen | Top-Level Screen | Protected (JWT) | Curated savings schemes, benefit highlights, plan enrollment. |
| `/settings` | Settings Screen | Top-Level Screen | Protected (JWT) | AutoPay toggle, Nominee, MPIN, Biometric lock, language, logout. |
| `/receipt/:id` | Digital Receipt Modal | Modal / Overlay | Protected (JWT) | Official tax invoice view with print and Cloudinary PDF download. |
| `/checkout` | Payment Checkout Modal| Modal / Sheet | Protected (JWT) | Select payment method (UPI, NetBanking, Card), initiate GoKwik. |
| `/gokwik-gateway`| GoKwik Webview Screen | Full Screen Webview| Protected (JWT) | Third-party payment gateway orchestration with return callbacks. |

---

## 3. Navigation Hierarchy & Route Tree

```
Root Navigator
│
├── [Public Branch]
│   ├── /splash (Initial Route)
│   └── /auth
│       ├── /auth/login (Initial choices)
│       ├── /auth/phone
│       ├── /auth/otp
│       └── /auth/success
│
└── [Protected Branch] (Requires valid JWT in SecureStorage)
    │
    ├── /kyc (Mandatory for unverified users entering schemes)
    │
    ├── Main Shell (With Shared Top Bar & Navigation Drawer)
    │   ├── /home (Tab 1 / Default Home)
    │   ├── /dashboard (Tab 2 / My Scheme)
    │   ├── /passbook (Tab 3 / Statements & Ledger)
    │   ├── /offers (Tab 4 / Discover Schemes)
    │   └── /settings (Account, Security, Legal)
    │
    ├── Modal & Sheet Overlays
    │   ├── Payment Modal (/checkout)
    │   ├── Receipt Modal (/receipt/:id)
    │   └── Scheme Enrollment Modal (/offers/enroll/:schemeId)
    │
    └── Full Screen Overlays
        └── /gokwik-gateway (Isolated Webview Host)
```

---

## 4. Route Guards & Protection Rules

### 4.1 Unauthenticated Guard (`GuestOnlyGuard`)
* **Target Routes:** `/auth/login`, `/auth/phone`, `/auth/otp`.
* **Rule:** If the user already possesses a valid, non-expired JWT session, navigating to `/auth/*` automatically redirects to `/home` or `/dashboard`.

### 4.2 Authenticated Guard (`AuthGuard`)
* **Target Routes:** `/home`, `/dashboard`, `/passbook`, `/offers`, `/settings`, `/kyc`, `/checkout`.
* **Rule:** If no valid session token exists in `SecureStorage`, or if an API returns HTTP 401 Unauthorized, immediate redirect to `/auth/login` is enforced, clearing all cached state.

### 4.3 KYC Compliance Guard (`KycRequiredGuard`)
* **Target Actions:** "PAY NEXT EMI" and "ENROL PLAN".
* **Rule:** If `user.kycStatus === 'PENDING'` or `'REJECTED'`, the app intercepts the action and presents an informational bottom sheet: *"KYC Verification Required: Statutory RBI & PMLA compliance requires document verification before transaction processing."* The user is provided a direct link to `/kyc`.

---

## 5. Drawer & Modal Navigation Behavior

### 5.1 Slide-Out Luxury Navigation Drawer (`#home-nav-drawer`)
* **Invocation:** Tapping the 3-lines hamburger icon on the sticky header of any main screen (`home`, `dashboard`, `passbook`, `offers`, `settings`).
* **Backdrop Interaction:** Tapping the blurred backdrop (`#nav-drawer-backdrop`) or pressing the hardware/gesture Back button smoothly closes the drawer.
* **Selection Behavior:** Tapping an item closes the drawer first, then navigates to the target route using an animated transition.

### 5.2 Modals & Bottom Sheets
* **Payment Modal (`#payment-modal`):**
  - Slides in from bottom with frosted dark emerald backdrop.
  - Can be dismissed via close button (`X`), backdrop tap, or Back gesture without cancelling active background operations.
* **Digital Receipt Modal (`#receipt-modal`):**
  - Displays printable paper invoice layout.
  - Includes action buttons: "Print Receipt" (triggers native print spooler) and "Done" (closes modal).

---

## 6. Android Hardware Back Button & Gesture Handling

1. **When a Modal or Drawer is Open:**
   - Pressing Back closes the topmost overlay (Drawer, Modal, or Sheet) without exiting the underlying screen.
2. **When on Sub-Views (Phone Input, OTP Input, KYC, Settings):**
   - Pressing Back navigates to the immediate parent view (e.g., OTP View -> Phone Input View; Settings -> Home).
3. **When on Main Screens (Dashboard, Passbook, Offers, Settings):**
   - Pressing Back returns the user to the `/home` screen.
4. **When on `/home`:**
   - Standard "Double-tap back to exit application" toast confirmation prevents accidental app closure.

---

## 7. Deep Linking & Notification Redirection Scheme

The app registers the custom URI scheme `swastikjewel://` and universal HTTPS links:

| Deep Link Pattern | Target Destination | Handling Logic |
| :--- | :--- | :--- |
| `swastikjewel://scheme/my-dashboard` | `/dashboard` | Directs user to active scheme and triggers dashboard refresh. |
| `swastikjewel://passbook` | `/passbook` | Opens 12-month installment ledger. |
| `swastikjewel://passbook/receipt/:txnId`| `/passbook` + Open Receipt Modal | Loads passbook and immediately opens receipt modal for transaction `txnId`. |
| `swastikjewel://payment/callback?status=success&orderId=...` | `/dashboard` | Return hook from external payment app; initiates status verification. |
| `swastikjewel://offers` | `/offers` | Directs user to curated kitty plans. |
| `swastikjewel://kyc` | `/kyc` | Directs user to KYC verification screen. |

---

## 8. Logout Navigation & Session Cleanup
When the user taps "Log Out of Account" in `settings.html`:
1. System displays a native confirmation dialog: *"Are you sure you want to sign out?"*
2. Upon confirmation:
   - Call `SwastikAuth.logout()`.
   - Clear `swastik_jwt_token` and `swastik_user_profile` from `SecureStorage`.
   - Reset all Riverpod state providers.
   - Clear client navigation history stack.
   - Route user to `/auth/login` with an informational toast notification.
