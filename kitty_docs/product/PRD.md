# Product Requirements Document (PRD)

## 1. Product Overview

### 1.1 Product Name
**Swastik Jewel Kitty App** (Sub-Brand: **Kitty Vault**)

### 1.2 Product Purpose
The Swastik Jewel Kitty App is a luxury mobile-first digital gold savings and kitty chit platform developed for patrons of **Swastik Jewellers**. It digitizes the traditional Indian jewelry chit/kitty scheme, allowing customers to systematically save in physical 24K gold bullion or jewelry, track monthly installments, receive jeweler-sponsored bonus installments, view real-time gold rates, and redeem accumulated savings at maturity.

### 1.3 Target Users
* **Retail Jewelry Buyers & Investors:** Customers wanting disciplined monthly savings backed by certified 999 24K hallmark gold.
* **Wedding Planners & Brides:** Customers preparing for major family weddings through high-value kitty schemes (e.g., Royal Bridal Kitty).
* **Existing Showroom Walk-in Patrons:** Patrons linked to Swastik Jewellers' physical showrooms who make both online UPI payments and in-store cash installments.

### 1.4 Core Problem Solved
Traditional jewelry kitty schemes rely on manual paper passbooks, physical showroom visits for cash deposits, lack of transparent gold rate tracking, and delayed receipt dispatch. The Kitty App solves this by:
* Providing a transparent 12-month digital passbook with live gold allocation in grams.
* Enabling instant online installment payments via UPI, Net Banking, and Cards through GoKwik.
* Delivering official digital tax and gold passbook PDF receipts directly to the customer.
* Rewarding disciplined savings with guaranteed 100% jeweler-sponsored bonus installments and making-charge discounts.

### 1.5 Product Goals
* **Frictionless Onboarding:** Mobile phone OTP authentication within 30 seconds.
* **Statutory Compliance:** RBI & PMLA compliant KYC document upload (Aadhaar/PAN) before scheme enrollment.
* **Complete Financial Transparency:** Instant visualization of total paid amount, remaining EMIs, target amount, accumulated gold weight (grams), and portfolio valuation gain.
* **Zero Disruption for Walk-in Customers:** Seamless synchronization of cash payments recorded by showroom staff alongside digital payments.

---

## 2. Scope of Work

### 2.1 In Scope (Frontend Responsibilities)
* Implementation of all customer-facing mobile interfaces (Splash, Onboarding, Authentication, KYC, Home, Dashboard/My Scheme, Passbook, Kitty Offers, and Settings).
* Mobile-responsive layout (optimized for 360px–480px mobile viewports with tablet/desktop preview support).
* Client-side form validation, input masking, and error handling.
* State management for authentication session, active schemes, passbook entries, live gold rates, and modals.
* Abstracted Service and Repository layer interfacing with backend RESTful APIs.
* Third-party payment gateway integration (GoKwik SDK / Webview orchestration).
* In-app rendering and triggering of digital PDF receipts.
* Camera capture and file upload preview for KYC documents.
* Offline awareness, loading skeletons, empty states, and toast notifications.

### 2.2 Out of Scope (Backend & External Responsibilities)
* **Backend API Implementation:** Express / Node.js server routes, business logic execution, and database controllers.
* **Database & Infrastructure:** MongoDB schema provisioning, replica sets, indexing, and backups.
* **Server-side Security & Auth:** JWT signing/verification, OTP generation, Twilio/MSG91 SMS gateway dispatch.
* **Payment Gateway Server Logic:** GoKwik order creation, signature verification, and webhook handling.
* **PDF Receipt Generation:** Server-side `pdfkit` drawing and Cloudinary asset management.
* **WhatsApp Notification Engine:** Twilio / MSG91 WhatsApp Business API dispatch.
* **Admin CRM Web Panel:** React-based admin panel for scheme creation, member ledger, cash collection, and monthly draw declarations (managed by Swastik CRM team).

---

## 3. User Roles

The existing system documents define two primary roles, with a third administrative tier:

| User Role | Location | Description & Permissions |
| :--- | :--- | :--- |
| **`CUSTOMER`** | Mobile App | Standard retail user. Can authenticate via OTP, upload KYC, view active scheme, make online EMI payments, view passbook records, explore offers, and manage app preferences. |
| **`ADMIN`** | Admin Panel (Web) | Showroom staff / store owner. Creates schemes, views member ledgers, manually records cash payments, and declares monthly draw winners. |
| **`SUPER_ADMIN`** | Admin Panel (Web) | System administrator. Full control over system configurations, staff roles, and audit logs. |

*Note: The frontend mobile application caters exclusively to the **`CUSTOMER`** role.*

---

## 4. Feature Matrix

| Feature ID | Feature Name | User Goal | Associated Screens | Frontend Behavior | Backend Dependency |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **FEAT-01** | Splash & 3D Brand Loader | Experience brand luxury and initialize app state | `index.html` / Splash Screen | Displays 3D rotating faceted diamond canvas, transitions to Damask logo stage, checks active session, routes user. | Session validation endpoint |
| **FEAT-02** | OTP & Google Authentication | Quick, passwordless login | `login.html` | Step-by-step wizard (Option select -> Phone input with country code -> 6-digit OTP grid -> Success card). Resend timer countdown. | `POST /api/auth/send-otp`, `POST /api/auth/verify-otp` |
| **FEAT-03** | KYC Verification | Complete legal verification to enroll/pay | `kyc.html` | Aadhaar/PAN selector, input validation, camera capture / gallery upload with preview, statutory consent checkbox. | `POST /api/users/kyc` (multipart form-data) |
| **FEAT-04** | Home Screen & Catalog | Overview of privileges, offers, and jewelry | `home.html` | Active scheme banner, auto-scrolling promo carousel, category pills, curated product cards with wishlist toggle, gold rate strip. | `GET /api/memberships/my-dashboard`, `GET /api/schemes/active`, Live Gold Rate API |
| **FEAT-05** | My Scheme (Core Dashboard) | Track active kitty scheme progress | `dashboard.html` | Active scheme card with chit number, circular SVG progress gauge (e.g. 8/12 EMIs, 67%), 2x2 statistics grid, Month 9 due countdown banner. | `GET /api/memberships/my-dashboard` |
| **FEAT-06** | Next EMI Payment | Pay monthly installment online | `dashboard.html`, `home.html`, Payment Modal | Prominent Gold CTA ("PAY NEXT EMI (₹5,000)"), opens payment modal, triggers GoKwik gateway, monitors payment status. | `POST /api/payments/initiate`, GoKwik Webview / SDK |
| **FEAT-07** | 12-Month Installment Passbook | Review payment history and receipts | `passbook.html` | Toggle between Table View and Timeline/Card View. Displays status badges (`PAID`, `CURRENT`, `UPCOMING`, `BONUS`), gold grams credited. | `GET /api/memberships/my-dashboard`, Payment ledger records |
| **FEAT-08** | Digital PDF Receipts | Download/view official payment proof | Receipt Modal, `passbook.html` | Opens modal with official invoice styling, supports in-app viewing and system print/download. | Cloudinary URL returned from payment ledger |
| **FEAT-09** | Curated Kitty Offers | Discover and enroll in new savings schemes | `offers.html`, `kitty-offers-modal` | Category tabs (Classic, Express, Bridal), scheme cards highlighting 1-month free bonus, enrollment action trigger. | `GET /api/schemes/active`, `POST /api/memberships/join` |
| **FEAT-10** | Settings & Preferences | Manage account, security, and preferences | `settings.html` | UPI AutoPay toggle, Nominee registration status, Biometric lock toggle, MPIN change, KYC status badge, Language selector, Logout. | User profile preferences API, Local Secure Storage |
| **FEAT-11** | Dynamic EMI Late-Joiner | Join ongoing scheme with adjusted EMI | Dashboard, Offers | Accurately reflects dynamic EMI calculated by backend based on `joinedAtMonth`. | `POST /api/memberships/join`, `customMonthlyEmi` |

---

## 5. End-to-End User Journeys

### Journey 1: New User Onboarding, KYC & First Enrollment
```
App Launch
  ↓
3D Diamond Loader / Splash Screen
  ↓
Session Check: No Active Session
  ↓
Login Screen (Select "Continue with mobile number")
  ↓
Enter Mobile Number (+91 98765 43210) → Tap "Continue"
  ↓
Backend: POST /api/auth/send-otp → SMS Dispatched
  ↓
OTP Verification Screen (Enter 6-digit OTP, auto-advances)
  ↓
Backend: POST /api/auth/verify-otp → Returns JWT + isNewUser: true
  ↓
Success Card ("Welcome Back, Patron • Tier 1")
  ↓
Route to KYC Verification Screen
  ↓
Select Document (Aadhaar) → Enter 12-digit Number → Camera Photo Upload
  ↓
Check Statutory Consent Checkbox → Tap "Submit KYC Documents"
  ↓
Backend: POST /api/users/kyc → Cloudinary Upload → Status: PENDING / VERIFIED
  ↓
Route to Kitty Offers Screen → Select "Suvarna Varsha (12-Month)"
  ↓
Backend: POST /api/memberships/join → Membership Created
  ↓
Route to My Scheme Dashboard (Installment 1 Due)
```

---

### Journey 2: Existing Patron Paying Monthly Installment via UPI
```
App Launch → Splash → Active Session Validated
  ↓
My Scheme Dashboard Loaded
  ↓
Dashboard Displays:
- Scheme: "Swastik Suvarna Varsha"
- Progress: 8/12 Paid (67%)
- Next Due: "Month 9 Installment Due • 5 Days Left"
- CTA: "PAY NEXT EMI (₹5,000)"
  ↓
User Taps "PAY NEXT EMI (₹5,000)"
  ↓
Payment Checkout Modal Opens (Summary: ₹5,000 • Select UPI / NetBanking / Card)
  ↓
User Selects "Instant UPI" → Taps "Confirm & Pay ₹5,000"
  ↓
Backend: POST /api/payments/initiate → Returns GoKwik orderId
  ↓
Frontend Launches GoKwik Webview / SDK
  ↓
User Authorizes Payment in UPI App (GPay / PhonePe)
  ↓
GoKwik Server triggers Webhook: POST /api/payments/webhook
(ACID Transaction: Payment SUCCESS, Membership totalPaidAmount += ₹5,000, PDF generated)
  ↓
Frontend Polls / Receives Completion Callback
  ↓
Payment Modal Closes → Success Toast & Checkmark Animation
  ↓
Dashboard Refreshes Dynamically:
- Progress Updates to 9/12 Paid (75%)
- Paid So Far: ₹45,000
- Next Due Updates to Month 10
  ↓
User Taps "View Receipt" → Opens Digital Receipt Modal with Cloudinary PDF Link
```

---

### Journey 3: Walk-in Showroom Cash Payment Flow (Synchronization)
```
Customer visits Swastik Jewellers showroom
  ↓
Store Staff opens Admin Panel → Selects Customer Membership → Enters ₹5,000 Cash
  ↓
Admin Backend: POST /api/admin/payments/record-cash
(Payment logged as CASH, totalPaidAmount incremented, PDF created, WhatsApp sent)
  ↓
Customer receives WhatsApp message with official Cloudinary PDF receipt link
  ↓
Customer opens Swastik Kitty Mobile App
  ↓
Dashboard automatically pulls updated ledger via GET /api/memberships/my-dashboard
  ↓
Passbook displays Month 9 marked "PAID" with Method: "Cash (Store Receipt)"
```

---

## 6. Functional Requirements

### 6.1 Authentication Module
* **FR-AUTH-01:** The app must support phone number input with international country codes (default: `+91` India, selectable: UAE, UK, USA, Singapore, Australia).
* **FR-AUTH-02:** Phone input must validate Indian numbers (10 digits starting with 6, 7, 8, or 9).
* **FR-AUTH-03:** The OTP input component must feature 6 distinct character boxes with auto-focus to next box, backspace navigation, and full paste support.
* **FR-AUTH-04:** A 30-second countdown timer must disable the "Resend OTP" button until expiration.
* **FR-AUTH-05:** JWT token and user profile must be persisted in secure local storage upon successful verification.

### 6.2 KYC Verification Module
* **FR-KYC-01:** User must be able to switch between "Aadhaar Card" and "PAN Card" document types.
* **FR-KYC-02:** Aadhaar number input must enforce 12 numeric digits with automatic 4-4-4 spacing formatting (`XXXX XXXX XXXX`).
* **FR-KYC-03:** PAN number input must enforce 10 alphanumeric characters formatted in uppercase (`ABCDE1234F`).
* **FR-KYC-04:** Document photo capture must support direct camera invocation (`capture="environment"`) and gallery photo selection (JPG, PNG, WEBP, PDF up to 10 MB).
* **FR-KYC-05:** Real-time thumbnail preview must display the selected image with filename, file size, and a deletion button.
* **FR-KYC-06:** The submission button must remain disabled until a valid document number is entered, an image is uploaded, and the statutory consent checkbox is ticked.

### 6.3 Dashboard & Active Scheme Module
* **FR-DASH-01:** Active scheme card must display Scheme Name, Chit Number, and Monthly Installment Amount.
* **FR-DASH-02:** The circular progress gauge must dynamically calculate SVG `stroke-dashoffset` representing `monthsPaid / totalMonths`.
* **FR-DASH-03:** The statistics grid must calculate:
  - **Scheme Target:** Total scheme commitment amount.
  - **Paid So Far:** Total verified payments recorded.
  - **Accumulated 24K Gold:** Total gold credited in grams ($\text{Gold Weight} = \sum \text{Installment Gold Grams}$).
  - **Current Valuation:** $\text{Accumulated Gold Grams} \times \text{Live 24K Gold Price}$.
  - **Valuation Gain %:** $\frac{\text{Current Valuation} - \text{Total Paid}}{\text{Total Paid}} \times 100$.
* **FR-DASH-04:** Next EMI card must display due month, due date, and days remaining badge.

### 6.4 Passbook & Transaction Ledger Module
* **FR-PASS-01:** Passbook must support toggling between Table View and Timeline/Card View without reloading data.
* **FR-PASS-02:** Each installment row must indicate status (`PAID`, `CURRENT`, `UPCOMING`, `BONUS`).
* **FR-PASS-03:** For `PAID` installments, display payment date, payment method, transaction ID, gold weight added, and a "View Receipt" button.
* **FR-PASS-04:** For `BONUS` installment (Month 12), highlight 100% jeweler-sponsored deposit note.
* **FR-PASS-05:** Clicking "View Receipt" must open the Digital Receipt Modal with printable format and Cloudinary PDF download link.

### 6.5 Offers & Scheme Discovery Module
* **FR-OFF-01:** Schemes must be filterable by duration categories (All Plans, 12-Month Classic, 6-Month Express, 18-Month Bridal).
* **FR-OFF-02:** Each offer card must highlight specific jeweler incentives (e.g. 1 Month Free, Flat 25% discount on making charges, free gold coin).
* **FR-OFF-03:** Tapping "Enrol Plan" triggers scheme membership creation via `/api/memberships/join`.

---

## 7. Non-Functional Frontend Requirements

### 7.1 Performance & Responsiveness
* **NFR-PERF-01:** First Contentful Paint (FCP) must be under 1.5 seconds on a standard 4G mobile network.
* **NFR-PERF-02:** Animations (circular SVG gauge, 3D diamond WebGL, modal sheet slides) must maintain a steady 60 FPS without jank.
* **NFR-PERF-03:** Layout must gracefully adapt to standard mobile viewport widths: 320px, 360px, 390px, 412px, 430px, and 480px, maintaining max-width containment on tablets/desktops.

### 7.2 Accessibility (a11y)
* **NFR-A11Y-01:** Minimum touch target size of $44 \times 44$ px for all interactive buttons, links, and switches.
* **NFR-A11Y-02:** Contrast ratio of at least 4.5:1 for body text against backgrounds (`#0F172A` on `#FFFFFF` / `#F8F9FA`; `#FAF8F2` on `#0B3026`).
* **NFR-A11Y-03:** Form inputs must include associated labels, semantic `aria-label`, and `role="alert"` for validation errors.

### 7.3 Security on Frontend
* **NFR-SEC-01:** No sensitive API secret keys, merchant private keys, or credentials stored in client code.
* **NFR-SEC-02:** JWT tokens stored in platform-level secure storage (`FlutterSecureStorage` using Keychain / EncryptedSharedPreferences).
* **NFR-SEC-03:** Masking of sensitive identity inputs (Aadhaar display shows only last 4 digits `XXXX XXXX 1234` after entry).
* **NFR-SEC-04:** Automatic session invalidation and cleanup upon receiving HTTP 401 responses.

### 7.4 Offline & Network Resilience
* **NFR-NET-01:** Active scheme and passbook data must be cached locally to allow offline passbook viewing.
* **NFR-NET-02:** App must display an unobtrusive offline warning bar when device connectivity is lost.
* **NFR-NET-03:** Network requests must incorporate a 15-second timeout with friendly retry dialogs on failure.

---

## 8. Assumptions & Dependencies

### 8.1 Confirmed Requirements
* The backend exposes RESTful endpoints using JSON payloads as detailed in `design_backend_plan.md`.
* GoKwik is the selected payment gateway provider for processing UPI, cards, and net banking.
* Cloudinary is the cloud asset repository for storing KYC identity documents and generated PDF receipts.
* Monthly Chit drawings and Cash payments are logged by store staff via the separate React Admin CRM.

### 8.2 Architectural Assumptions
* While the interactive UI prototype is written in responsive HTML5/CSS3/Vanilla JS, the target native mobile build is designed for Flutter as outlined in `design_ui_plan.md`.
* The backend will deliver live gold rates via an endpoint or the frontend can poll a public benchmark rate (IBJA).
* Real-time payment verification will rely on status polling or WebSocket/Server-Sent Events if available.
