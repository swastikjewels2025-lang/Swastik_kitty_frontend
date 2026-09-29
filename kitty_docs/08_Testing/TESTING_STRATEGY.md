# Frontend Testing Strategy & Quality Assurance Plan

## 1. Overview
This document defines the testing strategy for the Kitty App frontend, ensuring that the application is production-ready, resilient to network volatility, and completely verifiable using mocked contracts prior to backend deployment.

```
                  ┌──────────────────────┐
                  │  INTEGRATION TESTS   │  (10%) End-to-End User Journeys
                  ├──────────────────────┤
                  │   WIDGET / UI TESTS  │  (30%) Visual States & Interactions
                  ├──────────────────────┤
                  │      UNIT TESTS      │  (60%) Logic, Math, Mappers, Models
                  └──────────────────────┘
```

---

## 2. Unit Testing Suite

Unit tests validate pure logic, formatters, domain calculations, and data serialization in isolation with zero UI or network dependencies.

### 2.1 Validators & Input Masks (`test/unit/utils/`)
* **Phone Number Validation:**
  - Verify valid 10-digit Indian numbers (`9876543210`, `7012345678`) pass.
  - Verify invalid lengths (`12345`, `987654321012`) and non-numeric characters fail.
* **Aadhaar Number Validation:**
  - Verify 12-digit number correctly formats with 4-4-4 spacing (`XXXX XXXX XXXX`).
* **PAN Number Validation:**
  - Verify uppercase formatting and strict statutory regex (`^[A-Z]{5}[0-9]{4}[A-Z]{1}$`).
* **OTP Input Validation:**
  - Verify 6-digit numeric constraint.

### 2.2 Domain & Mathematical Formulas (`test/unit/domain/`)
* **Dynamic EMI Late-Joiner Calculation:**
  - Test formula: `targetAmount / (durationMonths - joinedAtMonth + 1)`.
  - Case 1: Standard Join Month 1: ₹60,000 / (12 - 1 + 1) = ₹5,000.
  - Case 2: Late Join Month 3: ₹60,000 / (12 - 3 + 1) = ₹6,000.
  - Case 3: Late Join Month 6: ₹60,000 / (12 - 6 + 1) = ₹8,571.42 (Verify rounding).
* **Circular Progress Gauge Angle / Offset:**
  - Circumference = $2 \times \pi \times 66 \approx 414.69$.
  - Verify 0/12 paid = offset 414.69.
  - Verify 8/12 paid (66.67%) = offset 138.23.
  - Verify 12/12 paid = offset 0.0.
* **Portfolio Valuation Gain:**
  - Formula: $\frac{(\text{Accumulated Gold} \times \text{Price}) - \text{Total Paid}}{\text{Total Paid}} \times 100$.
  - Test positive gain (+2.59%) and negative market fluctuation.

### 2.3 Data Mappers & DTO Serialization (`test/unit/data/`)
* Verify `UserModel.fromJson()` correctly parses nested `kyc` objects.
* Verify missing or null backend fields gracefully fallback to sensible defaults without triggering null pointer exceptions.

---

## 3. Widget & UI Testing Suite

Widget tests verify component rendering, user interactions, and visual state transitions.

### 3.1 Component States Testing (`test/widget/components/`)
* **`GoldPrimaryButton`:**
  - Verify label renders correctly.
  - Verify tapping triggers `onPressed`.
  - Verify when `isLoading: true`, label is hidden and circular spinner is shown.
  - Verify when `isEnabled: false`, button does not trigger taps.
* **`PassbookTableRow`:**
  - Verify `PAID` row renders green status badge and "View Receipt" button.
  - Verify `CURRENT` row renders amber highlight and "Pay Now" CTA.
  - Verify `BONUS` row renders 100% sponsored note.

### 3.2 Screen Flow & State Matrix Testing (`test/widget/screens/`)
For every screen, verify the 4 standard production states:

| Screen | Loading State Test | Empty State Test | Error State Test | Success State Test |
| :--- | :--- | :--- | :--- | :--- |
| **Login Screen** | Spinner on "Continue" button | N/A | Red validation text below phone/OTP | Transition to Success Card |
| **KYC Screen** | Upload progress bar | Clean empty dropzone | File size / format rejection alert | Success badge `#KYC-849201` |
| **Dashboard** | Full shimmer skeleton | Empty card ("No Active Kitty") | Retry banner with refresh button | Render Hero Pass, Gauge, Stats |
| **Passbook** | 6-row table shimmer | "Zero Transactions" placeholder| Network failure notice | 12 installment rows rendered |
| **Offers Screen** | 3-card skeleton tiles | "No schemes matching filter" | Error banner with reload CTA | Filterable scheme cards list |

---

## 4. Integration & Flow Testing Suite

Integration tests verify end-to-end user journeys using mock HTTP clients (`MockAuthRepository`, `MockSchemeRepository`).

### 4.1 Flow 1: Complete Authentication & Token Persistence
1. Launch app at `/splash`.
2. Verify redirection to `/auth/login`.
3. Tap "Continue with mobile number".
4. Enter `9876543210` -> Tap "Continue".
5. Enter `123456` in OTP boxes.
6. Verify token is written to `SecureStorage`.
7. Verify route navigates to `/dashboard`.

### 4.2 Flow 2: Payment Initiation & Modal Flow
1. Load dashboard with Month 9 due.
2. Tap "PAY NEXT EMI (₹5,000)".
3. Verify Payment Checkout Modal appears with amount ₹5,000.
4. Select "Instant UPI" -> Tap "Confirm & Pay".
5. Verify order parameters passed to payment service.
6. Simulate payment success callback.
7. Verify modal closes and progress gauge animates from 8/12 to 9/12.

---

## 5. Mock Test Data & Fixtures (`test/mocks/`)

To ensure complete independence from backend availability, static JSON fixtures are maintained in `test/mocks/fixtures/`:

* `auth_success_existing_user.json`: Returns valid JWT + Tier 1 user profile.
* `auth_success_new_user.json`: Returns valid JWT + `isNewUser: true`.
* `dashboard_active_suvarna.json`: Full active scheme payload matching `#SW-042` with 8/12 paid.
* `dashboard_empty.json`: `{ "hasActiveScheme": false, "dashboard": null }`.
* `passbook_12_months.json`: 12-month array with 8 PAID, 1 CURRENT, 2 UPCOMING, 1 BONUS.
* `offers_active_list.json`: 5 curated scheme objects.
* `rates_gold_live.json`: 24K and 22K rates with timestamp.
