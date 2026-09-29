# Definition of Done — Backend Integration

## 1. Overview
This document defines the formal **Acceptance Criteria & Verification Gate** that both the Frontend Developer and Backend Developer must jointly satisfy before the frontend and backend are certified as **Fully Integrated**.

---

## 2. Integration Verification Checklist

### 2.1 API & Networking Sign-Off
- [ ] **Base URLs Validated:**
  - [ ] Development Base URL (`http://10.0.2.2:5000/api/v1` or local IP) verified reachable.
  - [ ] Staging Base URL (`https://staging-api.swastikjewels.com/api/v1`) verified reachable with valid SSL.
  - [ ] Production Base URL confirmed.
- [ ] **Endpoint Routes Confirmed:**
  - [ ] `POST /api/v1/auth/send-otp`
  - [ ] `POST /api/v1/auth/verify-otp`
  - [ ] `POST /api/v1/users/kyc`
  - [ ] `GET /api/v1/schemes/active`
  - [ ] `POST /api/v1/memberships/join`
  - [ ] `GET /api/v1/memberships/my-dashboard`
  - [ ] `POST /api/v1/payments/initiate`
  - [ ] `GET /api/v1/payments/status/:orderId`
  - [ ] `GET /api/v1/rates/gold`
- [ ] **Envelopes Confirmed:** Both developers adhere strictly to the `{ success, message, data, meta }` and `{ success, message, error }` JSON envelopes.

---

### 2.2 Authentication & Authorization Sign-Off
- [ ] **Bearer Token Format:** Frontend transmits `Authorization: Bearer <token>`; backend validates JWT signature and user claims.
- [ ] **OTP Delivery:** Twilio/MSG91 SMS gateway delivers 6-digit OTP to real mobile numbers within 10 seconds.
- [ ] **Token Expiration & 401 Interception:** When token expires, backend returns HTTP 401; frontend automatically wipes Keychain and redirects to `/auth/login`.
- [ ] **Logout Invalidation:** Frontend wipes stored tokens; backend logs token session termination.

---

### 2.3 Data Models & Precision Sign-Off
- [ ] **Field Name Agreement:** 100% camelCase naming verified across all entities (`totalPaidAmount`, `customMonthlyEmi`, `chitToken`).
- [ ] **Strict Typing:**
  - [ ] All monetary sums are integers in whole Rupees (e.g. `5000`).
  - [ ] Gold fine weight is double with 3 decimals (e.g. `5.482`).
  - [ ] No raw floating-point rounding artifacts (`4999.9999`) in responses.
- [ ] **Date/Time Standard:** All timestamps formatted in **ISO 8601 UTC** with `Z` suffix (`2026-09-15T13:14:41.000Z`).
- [ ] **Null Safety:** All optional fields tested with `null` values; client does not throw null pointer exceptions.
- [ ] **Enums Tested:** All 7 enums (`InstallmentStatus`, `MembershipStatus`, `KycStatus`, etc.) match allowable strings. Unrecognized strings fall back safely to `unknown`.

---

### 2.4 KYC & File Storage Sign-Off
- [ ] **File Size & Type Cap:** Frontend compresses images to $<2\text{ MB}$; backend accepts multipart files up to 10MB.
- [ ] **Cloudinary Integration:** Uploaded images and generated PDF receipts successfully store in Cloudinary and return valid HTTPS URLs accessible by the mobile app.

---

### 2.5 Payment Gateway & Webhook Sign-Off
- [ ] **GoKwik Sandbox Order:** `POST /api/v1/payments/initiate` returns valid `orderId`.
- [ ] **SDK / Webview Invocation:** Gateway loads in test mode with UPI/Card options.
- [ ] **ACID Webhook Verification:** Simulated payment success triggers HMAC-verified webhook; MongoDB commits transaction, updates `Payment` to `SUCCESS`, increments `totalPaidAmount`, and triggers PDF receipt.
- [ ] **Polling Reconciliation:** Frontend checks `GET /api/v1/payments/status/:orderId` and verifies completion without race conditions.

---

### 2.6 Error Handling & Edge Cases Sign-Off
- [ ] **Validation Errors (400 / 422):** Return user-friendly field-level error messages.
- [ ] **Server Crash (500):** Frontend renders error card with functional "Retry" button.
- [ ] **Network Timeout (15s):** Dispatches friendly timeout dialog.
- [ ] **Offline Handling:** Network disconnect shows offline banner and displays cached passbook.

---

### 2.7 Sign-Off Signatures

| Role | Engineer Name | Date | Integration Status |
| :--- | :--- | :---: | :---: |
| **Frontend Lead** | | | [ ] APPROVED |
| **Backend Lead** | | | [ ] APPROVED |
