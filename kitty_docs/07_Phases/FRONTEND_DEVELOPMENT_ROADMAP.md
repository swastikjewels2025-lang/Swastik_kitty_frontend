# Frontend Development Roadmap & Execution Phases

## 1. Overview & Strategy
This roadmap defines the structured, phase-by-phase implementation plan for the **Swastik Jewel Kitty App** frontend.

The plan is designed so that the frontend developer can build, test, and verify 100% of the UI screens using mock repositories and design tokens before backend APIs are deployed.

---

## 2. Phase Breakdown

```
Phase 0 ──► Phase 1 ──► Phase 2 ──► Phase 3 ──► Phase 4 ──► Phase 5 ──► Phase 6 ──► Phase 7 ──► Phase 8 ──► Phase 9
 Docs &      Project     Design     Auth &       Main       Kitty       Passbook &   Offers &    Backend     Polish &
Arch Plan   Foundation   System      KYC        Shell      Dashboard     Payments    Settings   Integrate    Release
```

---

### Phase 0 — Documentation & Architecture (CURRENT MILESTONE)
* **Objective:** Comprehensive requirement discovery, source code audit, UI inventory, and API contract definition.
* **Deliverables:**
  - Audit of existing 5 markdown plans, 8 HTML screens, 7 JS controllers, and 107 assets.
  - Complete documentation suite in `kitty_docs/` (`PRD`, `SYSTEM_FLOW`, `ARCHITECTURE`, `API_PLAN`, etc.).
  - User review and architectural sign-off.

---

### Phase 1 — Project Foundation & Core Infrastructure
* **Objective:** Initialize scalable Flutter project codebase and core systems.
* **Tasks:**
  - Initialize Flutter project with package name `com.swastikjewel.kittyapp`.
  - Configure Riverpod dependency injection and state management root.
  - Set up `core/network/` (Dio HTTP client, logging interceptors, timeout handling).
  - Configure `core/storage/` (`FlutterSecureStorage` wrapper for JWT tokens).
  - Set up `core/routing/` (`GoRouter` with route tables, auth guards, and deep links).
  - Configure assets directory (logos, jewelry photography, damask patterns).

---

### Phase 2 — Design System & Shared UI Component Library
* **Objective:** Implement the dual-surface visual foundation and atomic widgets.
* **Tasks:**
  - Implement color tokens: Emerald (`#05241C`, `#064E3B`), Gold (`#C59B27`, `#DFC178`), Off-white (`#F8F9FA`).
  - Configure typography: Google Fonts `Cinzel` and `Plus Jakarta Sans`.
  - Build `GoldPrimaryButton` with gradient, states, and loading spinner.
  - Build `HeaderNavBar` (sticky logo + 3-lines menu toggle) and `LuxuryNavDrawer`.
  - Build input components: `PhoneInputField`, `OtpInputGrid`, `KycTextInput`.
  - Build feedback components: `SwastikToast`, `EmptyStateCard`, shimmer skeletons.

---

### Phase 3 — Authentication & KYC Feature Modules
* **Objective:** Complete onboarding, phone OTP flow, and legal document verification.
* **Tasks:**
  - Build 3D Faceted Diamond animation splash screen (`SplashScreen`).
  - Build `LoginScreen` with 4-view state transition engine:
    - View 0: Google SSO & Mobile Choice.
    - View 1: Mobile Phone input with international country selector.
    - View 2: 6-Digit OTP grid with 30s countdown timer.
    - View 3: Success Card with Patron Tier chip.
  - Build `KycScreen`:
    - Aadhaar / PAN document selector tabs.
    - Native camera capture & gallery image picker.
    - Live thumbnail preview with file metadata and delete action.
    - Statutory RBI & PMLA consent checkbox.
    - Reference badge success state (`#KYC-849201`).
  - Connect with `MockAuthRepository` and `MockKycRepository`.

---

### Phase 4 — Main Application Shell & Home Screen
* **Objective:** Assemble the primary customer landing experience.
* **Tasks:**
  - Build `HomeScreen` layout within 440px container.
  - Implement Active Scheme Privileges status card.
  - Implement touch/swipe enabled Exclusive Kitty Offers carousel with autoplay.
  - Build horizontal "Shop by Category" scroll track (Rings, Earrings, Necklaces, Bangles).
  - Build "Curated For You" 2-column product grid with interactive wishlist hearts.
  - Implement Gold Rate & Trust strip with live IBJA ticker.

---

### Phase 5 — Core Kitty Vault & Dashboard Feature
* **Objective:** Deliver the primary financial tracking interface.
* **Tasks:**
  - Build `DashboardScreen` (My Scheme):
    - Active Scheme Hero Card with Chit number badge (`#SW-042`).
    - Custom SVG / Painter Circular Progress Gauge ($r=66$, fraction `8 / 12`, 67%).
    - 2x2 Financial Statistics Grid (Target ₹60,000, Paid ₹40,000, Gold 5.482g, Gain +2.59%).
    - Month 9 Due Card with countdown badge ("5 Days Left").
    - Large Prominent Gold CTA: "PAY NEXT EMI (₹5,000) ->".
    - Trust guarantees strip (Zero fee, instant credit, verified).

---

### Phase 6 — Passbook, Ledger & Digital Receipts
* **Objective:** Deliver the 12-month savings statement and receipt viewer.
* **Tasks:**
  - Build `PassbookScreen` with view toggle (Table View vs Card Timeline View).
  - Implement 12-month installment nodes with status styling (`PAID`, `CURRENT`, `UPCOMING`, `BONUS`).
  - Render transaction ID, payment method (Online vs Cash), and gold weight credited.
  - Build `DigitalReceiptModal`:
    - Official tax & gold passbook invoice paper template.
    - System print spooler trigger (`Printing` package) and Cloudinary PDF download.

---

### Phase 7 — Kitty Offers Discovery & Scheme Enrollment
* **Objective:** Enable discovery and self-enrollment into curated gold schemes.
* **Tasks:**
  - Build `OffersScreen` with category filter tabs (Classic, Express, Bridal, High-Yield).
  - Implement Offer Plan cards highlighting jeweler incentives (1-month free bonus, 25% discount).
  - Build Scheme Enrollment modal with fast-track confirmation.
  - Implement dynamic EMI preview for late joiners.

---

### Phase 8 — Payment Gateway Orchestration & Settings
* **Objective:** Complete checkout integration and account management.
* **Tasks:**
  - Build `PaymentCheckoutSheet` (Amount due summary, Instant UPI, NetBanking, Cards).
  - Integrate GoKwik SDK / Webview orchestration.
  - Implement payment status reconciliation poller (`/api/payments/status/:orderId`).
  - Build `SettingsScreen`:
    - UPI AutoPay / e-Mandate toggle.
    - Nominee registration status.
    - Biometric App Lock switch (via `local_auth`).
    - Change 4-digit MPIN dialog.
    - KYC verification status badge.
    - Destructive "Log Out" flow with full session cleanup.

---

### Phase 9 — Live Backend Integration & End-to-End Verification
* **Objective:** Connect frontend to the Node.js / Express backend deployed by the backend engineer.
* **Tasks:**
  - Switch `USE_MOCK_API=false` in environment configuration.
  - Point `API_BASE_URL` to staging/production server.
  - Validate live OTP delivery via Twilio/MSG91.
  - Validate Cloudinary upload for KYC documents and PDF receipts.
  - Verify GoKwik live payment webhook and ACID database ledger updates.
  - Perform cross-device testing on physical Android and iOS devices.

---

### Phase 10 — Quality Assurance, Security Audit & Store Release
* **Objective:** Final polish, performance optimization, and release preparation.
* **Tasks:**
  - Execute automated test suite (Unit, Widget, Integration).
  - Audit accessibility, touch targets, and contrast ratios.
  - Strip debug logs and verify release mode security configurations.
  - Build production release APK/AAB and iOS IPA bundles.
