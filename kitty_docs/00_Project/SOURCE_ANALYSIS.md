# Source Analysis & Audit Trail

## 1. Overview
This document provides a comprehensive audit trail of all source files analyzed in the Kitty App workspace (`d:\ui design`), detailing what was found, how the architectural and functional requirements were extracted, ambiguities identified, and production-critical requirements added.

---

## 2. Workspace & UI Design Folder Information
* **Primary Workspace Location:** `d:\ui design`
* **Total Planning Markdown Documents:** 5 files
* **Total Interactive HTML/Prototype Screens:** 8 screen prototypes + 4 modal overlays + 1 navigation drawer
* **Total JavaScript Controllers & Service Modules:** 7 files
* **Total CSS Design & Theme Files:** 5 files
* **Total Image & Media Assets Analyzed:** 107 files in `d:\ui design\assets`
* **Active Documentation Target:** `d:\ui design\kitty_docs`

---

## 3. Detailed Inventory of Analyzed Source Files

### 3.1 Planning Markdown Documents

| File Name | Size | Core Content & Role | Key Discoveries |
| :--- | :--- | :--- | :--- |
| `design_ui_plan.md` | 2,463 B | UI/UX Design Plan for Customer Mobile App (Flutter) and Admin Panel (React) | Specifies MVVM with Riverpod, Dark Green (`#064e3b`) & Gold (`#facc15`), 6 core customer screens (Splash, Login, KYC, Dashboard, GoKwik Payment, Passbook/Receipts). |
| `design_backend_plan.md` | 2,579 B | RESTful API design plan built on Node.js / Express | 6 Modules: `/api/auth` (send-otp, verify-otp), `/api/users` (kyc), `/api/schemes` (active, create), `/api/memberships` (join, my-dashboard), `/api/payments` (initiate, webhook), `/api/admin` (record-cash, record-winner). |
| `design_db_schema.md` | 3,067 B | MongoDB schema specifications using Mongoose | 4 Core Collections: `User` (phone, role, kyc), `Scheme` (targetAmount, durationMonths, capacity), `Membership` (customMonthlyEmi, totalPaidAmount, status, tokenNumber, joinedAtMonth), `Payment` (immutable ledger, transactionId, receiptUrl, status). |
| `design_system_architecture.md` | 2,090 B | High-level system architecture & critical data flows | Flutter Client + React Admin + Node/Express on VPS with NGINX + MongoDB Replica Sets + GoKwik + Cloudinary + Twilio/MSG91. Details late-joiner dynamic EMI formula and payment webhook with ACID rollback. |
| `master_integration_plan.md` | 5,217 B | Build order, dependency chain, and 4-phase testing plan | Establishes dependency chain (DB -> Backend APIs -> System Architecture -> UI). Phase 1: Core Services; Phase 2: Business Logic & Math; Phase 3: Customer Interface; Phase 4: Admin Panel. |

---

### 3.2 High-Fidelity UI Screens & Prototypes Analyzed

| Prototype File | Rendered Screen Title | UI Components & Functionality Discovered | Data & Actions Identified |
| :--- | :--- | :--- | :--- |
| `index.html` | Swastik Jewel \| Kitty Vault | 3D Crystal Diamond WebGL canvas loader (Phase 1: 0-2.3s rotation, Phase 2: Damask wallpaper & logo, Phase 3: Stops cleanly), intro replay button, fallback dashboard preview. | Loading sequence, brand asset initialization. |
| `login.html` | Sign In \| Kitty Vault | 4-View state machine: View 0 (Google SSO + Mobile Choice), View 1 (Mobile Input with Country Code Selector: India, UAE, UK, USA, SG, AU), View 2 (6-digit OTP grid with auto-focus, paste, 30s resend timer), View 3 (Auth Success with Patron Tier badge). | Input: Phone, Country Code, OTP. Output: Session token, User object, Tier. |
| `kyc.html` | KYC Document Verification | Document selector tabs (Aadhaar 12-digit / PAN 10-char), Real-time input masking, Camera capture (`capture="environment"`) & Gallery file upload, Live thumbnail card with file size and delete, Statutory RBI & PMLA consent checkbox, Success confirmation with reference code. | Input: Document Type, Document Number, File upload (Max 10MB JPG/PNG/PDF), Consent boolean. Output: KYC Status, Reference ID. |
| `home.html` | Home \| Swastik Jewel Kitty | Mobile container (440px), Sticky header with brand logo & 3-line hamburger menu, Active Kitty Scheme Status Card (dynamic progress bar, monthly rate, days remaining), Exclusive Kitty Offers Carousel (touch/swipe/autoplay), Shop by Category horizontal scroll (Rings, Earrings, Necklaces, Bangles, Bracelets, Pendants), Curated for You 2-column product grid with wishlist toggles, Editorial banner, Gold Rate & Trust strip (22K/24K live rates, BIS Hallmark badge), Slide-out navigation drawer, Payment modal, Receipt modal, Offers modal. | Input: Navigation, Product click, Payment initiate, Plan enroll. Output: Live rates, active scheme snapshot, curated catalog. |
| `dashboard.html` | My Scheme \| Swastik Jewellers | Active Scheme Hero Card, Chit number badge (#SW-042), Circular SVG progress gauge (8/12 EMIs paid, 67%), 2x2 Statistics Grid (Scheme Target ₹60,000, Paid So Far ₹40,000, Accumulated 24K Gold 5.482g / ₹41,036, Current Valuation +2.59%), Next EMI Installment Due Card with countdown badge ("Due by 15th Sep 2026, 5 Days Left"), Large "PAY NEXT EMI (₹5,000) ->" CTA, Trust benefits strip, Modals & Drawer. | Input: Pay Next EMI trigger. Output: Aggregated dashboard metrics, active membership data. |
| `passbook.html` | 12-Month Installment Passbook | Passbook controls row, Chit token badge, View Mode Toggle (Table View vs Card/Timeline View), Status filters, 12-row table (Month, Paid Date, Payment Mode & Txn ID, Gold Weight Credit, Amount ₹, Status Badge [PAID, CURRENT, UPCOMING, BONUS], Action [View PDF Receipt / Pay]), Digital Receipt modal with print trigger. | Input: View mode toggle, receipt view click. Output: Immutable payment ledger records, Cloudinary receipt links. |
| `offers.html` / `kitty-offers.html` | Curated Gold Kitty Plans | Filter tabs (All Plans, 12-Month Classic, 6-Month Express, 18-Month Bridal, High-Yield Gold), Plan Cards (11+1 Bonus Kitty, Suvarna Varsha, Dhanteras Labh, Navratna Bridal Royal, Akshaya Tritiya Bullion), Highlight benefits (1 Month Free, 25% flat discount on making charges, zero enrollment fee), Enrollment trigger. | Input: Filter selection, Plan enrollment. Output: List of open schemes, scheme details and perks. |
| `settings.html` | Settings & Preferences | Top sticky header with circular back button and hamburger menu, Gold Kitty & Scheme Settings (UPI AutoPay / e-Mandate switch, Nominee registration status), Security & PIN (Biometric App Lock switch, Change 4-Digit MPIN), KYC Verification status badge, App Language selector, Scheme Rules & BIS compliance modal, Destructive "Log Out of Account" button, App version/encryption footer. | Input: Toggle AutoPay, toggle Biometric lock, change MPIN, change language, logout. Output: User profile settings, security state. |

---

### 3.3 JavaScript Client Architecture & Controller Modules

| Script File | Architecture & Responsibility | Key Logic Identified |
| :--- | :--- | :--- |
| `auth.js` | `SwastikAuth` Client SDK Singleton | Handles `/api/auth/send-otp` and `/api/auth/verify-otp`. Features automatic fallback to sandbox dev mode (`123456` test OTP) when backend is unavailable. Manages JWT and user profile persistence in `localStorage`. Dispatches `swastik:authenticated` custom DOM event. |
| `login.js` | View-State Transition Engine | Manages multi-step view transitions (Initial -> Phone -> OTP -> Success). Auto-advances 6-digit OTP input boxes on keystroke, handles backspace/paste, formats phone inputs, triggers resend timer countdown. |
| `kyc.js` | KYC Validation & File Pipeline | Document type tab switching, real-time input formatting (Aadhaar 4-4-4 spacing, PAN uppercase regex), camera/file input binding, object URL preview generation, consent validation, `/api/users/kyc` submission handler. |
| `home.js` | Home View Controller | Renders active kitty metrics, updates circular progress ring, runs simulated live gold rate ticker, manages touch/drag interactions for carousels and category tracks, controls modal lifecycles. |
| `dashboard.js` | My Scheme View Controller | Calculates mathematical formulas for circular gauge stroke-dashoffset, calculates valuation gains, renders 12-month passbook grid dynamically, controls payment checkout and receipt generation. |
| `passbook.js` | Transaction History Controller | Toggles between HTML table view and responsive card timeline view, formats currency and gold weight, opens receipt modal with receipt paper template. |
| `loader.js` & `diamond-bg.js` | 3D WebGL / Canvas Geometric Engine | High-performance 3D faceted crystal diamond rotating mesh with ambient glow orbs and particle effects. |

---

## 4. Synthesis of Product Flow & Business Rules Discovered

### 4.1 Digital Kitty Savings Concept
1. **Core Value Proposition:** Customers accumulate physical 24K gold bullion or jewelry via monthly installments over 6, 12, or 18 months.
2. **Jeweler Bonus Incentive:** 
   - 12-Month Schemes: Customer pays 11 installments, and Swastik Jewellers sponsors the 12th installment (100% free bonus).
   - 18-Month Schemes: Customer pays 16 installments, Jeweler sponsors 2 installments + gift voucher.
   - 6-Month Express: Customer pays 5 installments, Jeweler sponsors 50% of the 6th installment.
3. **Gold Purity & Locking:** Every payment locks gold at the prevailing IBJA / 24K 999 benchmark daily rate, credited in grams to the user's digital passbook.
4. **Maturity Benefits:** 100% BIS hallmarked jewelry redemption at Swastik showrooms with a guaranteed discount on making charges (typically 25%).
5. **Monthly Physical Draw:** Once a month, the admin declares a winning token number for a scheme. If a customer's token is selected, their membership status becomes `WINNER`, entitling them to the prize pool according to scheme rules.

### 4.2 The "Late-Joiner" Dynamic EMI Business Rule
* If a customer joins an ongoing scheme in Month $M$ of a $D$-month scheme with target amount $T$:
  $$\text{customMonthlyEmi} = \frac{T}{D - M + 1}$$
* *Example:* For a ₹60,000 scheme over 12 months, joining in Month 3 yields:
  $$\frac{60000}{12 - 3 + 1} = \frac{60000}{10} = ₹6,000/\text{month}$$
* The backend calculates and stores `customMonthlyEmi` on the `Membership` record, which the frontend displays on the dashboard.

---

## 5. Ambiguities & Contradictions Identified

### 5.1 Technology Platform Ambiguity: Flutter vs. Web/HTML
* **Observation:** `design_ui_plan.md` and `master_integration_plan.md` state that the Customer Mobile App is to be built in **Flutter** (iOS/Android) using **MVVM** and **Riverpod**. Simultaneously, the repository contains a fully working, highly refined responsive **HTML/CSS/Vanilla JS** prototype designed for mobile viewports (max-width 440–480px).
* **Impact:** Development roadmap and folder structure must support the primary Flutter application while honoring the high-fidelity UI prototype as the exact visual and interaction specification.
* **Resolution:** Document both architectures clearly:
  - Provide a production-ready **Flutter (MVVM + Riverpod)** architecture and folder structure as specified in the UI plan.
  - Provide the exact UI component mapping from the HTML/CSS prototype to Flutter widgets so that UI fidelity is preserved 100%.

### 5.2 Brand Name Variation
* **Observation:** The source documents alternate between "Swastik Kitty App", "Swastik Jewel | Kitty Vault", "Royal Kitty Investment Vault", and "Swastik Jewellers".
* **Resolution:** Standardized to **Swastik Jewel Kitty App** (Sub-heading / Feature: **Kitty Vault**), operating within the Swastik Jewellers CRM ecosystem.

### 5.3 Color Palette Divergence Across Pages
* **Observation:**
  - `design_ui_plan.md`: Primary Dark Green (`#064e3b`), Secondary Gold (`#facc15`).
  - `login.html` & `login.css`: Primary Background `#05241C` (Deep Emerald Forest), Gold `#C59B27` / `#CCA043`.
  - `passbook.html` & `settings.html`: Explicitly defined "Refined Modern Color Specification" with `#F8F9FA` clean off-white page background, `#0F172A` deep slate text, `#064E3B` emerald action buttons, and `#C59B27` metallic gold.
* **Resolution:** Establish a dual-surface Design System:
  - **Surface Dark (Luxury/Branding):** Used for Splash, Login, KYC, Hero Banners, and Modals (`#05241C`, `#092B22`, `#C59B27`).
  - **Surface Light (Clarity/Transactional):** Used for Passbook, Settings, and Detail Screens (`#F8F9FA`, `#FFFFFF`, `#0F172A`, `#064E3B`, `#C59B27`).

---

## 6. Critical Missing Production Requirements Added (`ADDED REQUIREMENT`)

During source analysis, several gaps essential for a production-ready frontend were identified and added:

1. **[ADDED REQUIREMENT] Network Connectivity & Offline Awareness:**
   - Network listener to detect disconnects.
   - Global offline banner with cached passbook display.
   - Retry trigger on reconnection.
2. **[ADDED REQUIREMENT] Session Expiry & Auto-Logout:**
   - HTTP 401 response interceptor clearing `SecureStorage` / `localStorage` and redirecting to Login with a session expired toast.
3. **[ADDED REQUIREMENT] KYC Guarding on Transactional Actions:**
   - Prevent "Pay Next EMI" or "Enroll Scheme" if KYC status is `PENDING` or `REJECTED`, routing user to `kyc.html` / KYC screen with a context banner.
4. **[ADDED REQUIREMENT] Payment Status Polling & Fallback:**
   - Mobile GoKwik webview closes -> Frontend must poll `GET /api/payments/status/:orderId` with exponential backoff (1s, 2s, 4s up to 10s) to verify ACID webhook completion before displaying success screen.
5. **[ADDED REQUIREMENT] Comprehensive Empty States:**
   - Zero active schemes (new user view on Home and Dashboard).
   - Zero transactions in Passbook.
   - Failed offers loading state with retry button.
6. **[ADDED REQUIREMENT] Biometric Authentication & Secure Storage:**
   - Native biometric unlock for accessing Passbook and Settings when enabled.
   - Storage of JWT and refresh tokens in `FlutterSecureStorage` (iOS Keychain / Android EncryptedSharedPreferences).
7. **[ADDED REQUIREMENT] Input Formatting & Masking:**
   - Phone auto-prefix with country code.
   - Aadhaar 4-4-4 auto-spacing (`XXXX XXXX XXXX`).
   - PAN uppercase formatting (`ABCDE1234F`).

---

## 7. Audit Sign-Off
All 5 Markdown planning files, 8 HTML screens, 7 JS scripts, 5 CSS files, and 107 assets have been cataloged and cross-referenced. The requirements extracted form the single source of truth for the documentation suite in `d:\ui design\kitty_docs`.
