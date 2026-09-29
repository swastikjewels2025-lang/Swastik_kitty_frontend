# Frontend/Backend Integration Conflicts & Risk Analysis

## 1. Overview
This document conducts a deep-dive risk assessment of all potential technical conflicts between the separately developed Flutter frontend and the Node.js / Express backend.

Every conflict is analyzed with its severity risk, occurrence point, required architectural solution, owner, and resolution status.

---

## 2. Exhaustive Conflict Analysis

### Conflict 1: Case Sensitivity & Naming Convention Clash (`camelCase` vs `snake_case`)
* **Conflict:** MongoDB schemas and Node.js code often default to camelCase (`userId`, `schemeId`, `totalPaidAmount`), but third-party gateways or certain database conventions use snake_case (`user_id`, `scheme_id`, `total_paid_amount`).
* **Risk:** **CRITICAL.** If field names mismatch, client JSON deserializers encounter `null` values, resulting in runtime rendering bugs or application crashes.
* **Where It Can Happen:** `/api/v1/auth/verify-otp`, `/api/v1/memberships/my-dashboard`, `/api/v1/payments/initiate`.
* **Required Solution:** Enforce **strict camelCase** across all JSON API requests and responses as specified in `API_CONTRACT.md` and `DATA_CONTRACT.md`. The frontend uses `@JsonKey(name: 'fieldName')` to defend against variations.
* **Owner:** Both Frontend & Backend Developers
* **Status:** STANDARDIZED IN DATA CONTRACT

---

### Conflict 2: Webhook Asynchrony vs. Mobile Return Race Condition
* **Conflict:** The customer completes payment in the external GoKwik gateway/UPI app and returns to the mobile app immediately, before GoKwik's server-to-server webhook has reached the Node.js backend and finished committing the ACID transaction in MongoDB.
* **Risk:** **HIGH.** If the frontend immediately refreshes the dashboard upon return, the backend reports the payment as still `PENDING`, causing the user to believe their payment failed or was lost.
* **Where It Can Happen:** GoKwik payment completion callback in `dashboard.html` / `PaymentCheckoutSheet`.
* **Required Solution:** 
  1. Backend implements `GET /api/v1/payments/status/:orderId`.
  2. Frontend runs a dedicated status reconciliation poller (polling every 2s up to 5 times) before showing the success checkmark.
  3. If timeout occurs, show a reassuring pending notification: *"Your bank payment is being confirmed. Your passbook will update within 2 minutes."*
* **Owner:** Backend Developer (Endpoint) & Frontend Developer (Poller)
* **Status:** CONTRACT SPECIFIED IN `API_CONTRACT.md`

---

### Conflict 3: Monetary Representation Mismatch (Float vs. Integer vs. String)
* **Conflict:** Backend calculates values in JavaScript `Number` (IEEE 754 floating-point) which introduces binary rounding anomalies (e.g. `4999.999999999999` instead of `5000`).
* **Risk:** **HIGH.** Inaccurate balance display, validation failures on exact amount matching.
* **Where It Can Happen:** Dynamic EMI calculations (`customMonthlyEmi`), `totalPaidAmount`, `targetAmount`.
* **Required Solution:** 
  - All currency values transmitted across the API wire must be **discrete whole integer numbers** in Rupees (e.g. `5000`) or explicit integer paise.
  - Backend must execute `Math.round()` prior to sending any financial figure.
* **Owner:** Backend Developer
* **Status:** LOCKED IN `DATA_CONTRACT.md`

---

### Conflict 4: Date/Time Format & Timezone Deserialization
* **Conflict:** Backend sends localized date strings (e.g. `"15/09/2026 05:30 PM"`) or raw Unix epoch timestamps, while frontend parser expects ISO 8601 UTC.
* **Risk:** **MEDIUM.** `FormatException` during JSON parsing, wrong due dates shown across timezones.
* **Where It Can Happen:** `paidAt`, `dueDate`, `createdAt`, `nextDueDate`.
* **Required Solution:** Standardize exclusively on **ISO 8601 UTC with 'Z' suffix** (`2026-09-15T13:14:41.000Z`). Frontend handles localized date formatting via `intl`.
* **Owner:** Backend Developer
* **Status:** LOCKED IN `DATA_CONTRACT.md`

---

### Conflict 5: Late-Joiner Past Months Representation in Passbook
* **Conflict:** A late joiner in Month 3 has a 12-month tenure with 10 payable months. If the backend sends 12 items where Month 1 and 2 are missing or marked `DEFAULTED`, the user receives false warnings.
* **Risk:** **MEDIUM.** Customer panic regarding false defaults; incorrect progress gauge rendering.
* **Where It Can Happen:** `GET /api/v1/memberships/my-dashboard` $\rightarrow$ `passbook` array.
* **Required Solution:** Backend sets Month 1 and 2 status as `NOT_APPLICABLE` or calculates `monthsPaid` strictly relative to the user's active tenure (`totalMonths: 10`, `monthsPaid: 8`).
* **Owner:** Product Manager & Backend Developer
* **Status:** PROPOSED IN `OPEN_QUESTIONS.md`

---

### Conflict 6: Missing Required UI Fields in Backend Aggregator Response
* **Conflict:** The initial minimal backend plan (`design_backend_plan.md`) omitted fields strictly required by the designed UI (e.g. `chitToken: "#SW-042"`, `accumulatedGoldGrams: 5.482`, `currentValuation: 41036`, `valuationGainPct: 2.59`, `daysRemaining: 5`).
* **Risk:** **CRITICAL.** Frontend dashboard screens render blank spaces or crash due to null assertions.
* **Where It Can Happen:** `/api/v1/memberships/my-dashboard`.
* **Required Solution:** Backend developer must implement the comprehensive aggregator payload explicitly specified in `BACKEND_HANDOFF.md` and `API_CONTRACT.md` Section 5.6.
* **Owner:** Backend Developer
* **Status:** EXPLICIT CONTRACT PROVIDED

---

### Conflict 7: HTTP 401 Session Expiry Handling vs. Silent Failure
* **Conflict:** If the backend returns HTTP 200 with an error flag (`{ success: false, message: "Token expired" }`) instead of standard HTTP 401, the HTTP interceptor cannot catch unauthorized states.
* **Risk:** **HIGH.** User gets trapped in broken UI states without automatic redirection to login.
* **Where It Can Happen:** Global Dio `AuthInterceptor`.
* **Required Solution:** Backend MUST respond with **HTTP status code 401 Unauthorized** whenever an access token is expired or missing.
* **Owner:** Backend Developer
* **Status:** SPECIFIED IN `API_CONTRACT.md`

---

### Conflict 8: Unhandled Future Enum Values
* **Conflict:** Backend adds a new scheme or payment status (e.g. `REFUNDED`, `UNDER_REVIEW`, `PARTIALLY_PAID`) without notifying frontend.
* **Risk:** **MEDIUM.** Standard Dart `Enum.values.byName()` throws unhandled `ArgumentError` on unseen strings.
* **Where It Can Happen:** Client DTO mappers.
* **Required Solution:** Frontend enums implement defensive deserialization with an `unknown` fallback value as documented in `ENUMS_AND_STATUS_CONTRACT.md`.
* **Owner:** Frontend Developer
* **Status:** MITIGATED IN FRONTEND ENUM SPECIFICATION

---

### Conflict 9: Local Development Host Reachability (`localhost` on Android)
* **Conflict:** Frontend developer sets `API_BASE_URL=http://localhost:5000` and attempts to run on an Android emulator or physical device.
* **Risk:** **LOW (Dev Environment).** App fails to connect because `localhost` points to the mobile device loopback, not the developer PC.
* **Where It Can Happen:** Development environment setup.
* **Required Solution:** Documented in `FRONTEND_BACKEND_INTEGRATION.md`: use `http://10.0.2.2:5000` for Android emulator and host LAN IP (`http://192.168.X.X:5000`) for physical devices.
* **Owner:** Frontend Developer
* **Status:** DOCUMENTED IN INTEGRATION GUIDE

---

### Conflict 10: KYC File Size Exceeding Server Limits
* **Conflict:** User takes an uncompressed 15MB photo with a high-end smartphone camera; NGINX/Node server rejects request with `413 Payload Too Large`.
* **Risk:** **MEDIUM.** User unable to upload KYC, abrupt upload failure.
* **Where It Can Happen:** `/api/v1/users/kyc`.
* **Required Solution:** 
  1. Frontend compresses image client-side to $<2\text{ MB}$ before dispatch.
  2. Backend configures NGINX `client_max_body_size 15M;` and `multer` file limits.
* **Owner:** Both Frontend & Backend Developers
* **Status:** MITIGATED IN SPECIFICATION
