# Backend Developer Handoff Manual V2 — Kitty App

**Target Audience**: Lead Backend Engineer & DevOps (`Swastik_kitty_backend`)  
**Document Status**: Official Backend Implementation Manual (V2)  
**Effective Date**: 2026-09-29  
**Replaces**: `19_BACKEND_HANDOFF.md`  

---

## 1. Executive Briefing: The V2 Product Transition

Welcome to the **Kitty App V2 Backend Architecture**.

The Swastik Jewellers application is pivoting to become an authoritative **Kitty-First Savings & Installment Platform**. While the Flutter frontend is being simplified to serve non-technical and elderly patrons, the backend must evolve to support **5 primary capabilities**:

1. **Kitty Number Selection**: Real-time availability matrix (01–50) with atomic race-condition locking.
2. **Multi-Month Installment Orders**: Generating single GoKwik orders covering multiple consecutive months (e.g. Months 9 & 10 = ₹10,000).
3. **Full Remaining Balance Settlement**: Calculating lump-sum balance for early scheme closure.
4. **Multiple Active Kitties**: Returning an array of active schemes per user rather than a single summary.
5. **Future Lucky Number Reservation**: Temporary holds on upcoming festive schemes with a ₹100 token deposit (contingent on business sign-off).

> [!NOTE]
> **Preservation Directive**: All existing endpoints for authentication (`/auth/*`), bullion market rates (`/market/rates`), single-month payment verification (`/payments/*`), and KYC compliance (`/kyc/*`) **must remain 100% operational and backward-compatible**.

---

## 2. Master Specification Reading Order for Backend Engineer

Before writing any backend code, read these specialized specifications in order:
1. [`BACKEND_CHANGE_REQUIREMENTS_V2.md`](file:///D:/kitty_frontend/kitty_docs/BACKEND_CHANGE_REQUIREMENTS_V2.md) — High-level requirements summary.
2. [`KITTY_API_CONTRACT_V2.md`](file:///D:/kitty_frontend/kitty_docs/KITTY_API_CONTRACT_V2.md) — Complete endpoint schemas, parameters, and HTTP codes.
3. [`BACKEND_DATABASE_CHANGES_V2.md`](file:///D:/kitty_frontend/kitty_docs/BACKEND_DATABASE_CHANGES_V2.md) — MongoDB schema updates, compound indexes, and migration scripts.
4. [`BACKEND_KITTY_NUMBER_BOOKING_SPEC_V1.md`](file:///D:/kitty_frontend/kitty_docs/BACKEND_KITTY_NUMBER_BOOKING_SPEC_V1.md) — Real-time slot locking state machine.
5. [`BACKEND_MULTI_MONTH_PAYMENT_SPEC_V1.md`](file:///D:/kitty_frontend/kitty_docs/BACKEND_MULTI_MONTH_PAYMENT_SPEC_V1.md) — Multi-month order engine and passbook allocation.
6. [`BACKEND_FULL_KITTY_PAYMENT_SPEC_V1.md`](file:///D:/kitty_frontend/kitty_docs/BACKEND_FULL_KITTY_PAYMENT_SPEC_V1.md) — Early settlement math and maturity rules.
7. [`KITTY_BUSINESS_RULES_PENDING_V1.md`](file:///D:/kitty_frontend/kitty_docs/KITTY_BUSINESS_RULES_PENDING_V1.md) — Policy questions requiring management decision.

---

## 3. Core Technical Requirements for Backend Developer

### 3.1 Security & Access Control
1. **Strict User Scoping**: Patrons must **only** access their own Kitty memberships, passbook entries, and payment orders. Every database query on sensitive entities must include `{ userId: req.user.id }`.
2. **Server-Side Financial Authority**: The Flutter client **never sends payment amounts**. The client requests which months it wishes to pay (`months: [9, 10]`); the server computes `amount = months.length * customMonthlyEmi` based on the authoritative database record.
3. **Idempotent Webhook Processing**: All GoKwik webhook events must be verified using HMAC-SHA256 signature checking. Duplicate webhook deliveries must return `200 OK` immediately without double-allocating gold or duplicate passbook rows.

### 3.2 Concurrency & Race Condition Safeguards
When two mobile users tap the same number (e.g. No. 06) simultaneously:
* Use atomic MongoDB operations (`findOneAndUpdate` with `status: 'AVAILABLE'`).
* If the slot was already claimed, immediately return `409 Conflict` with error code `NUMBER_ALREADY_BOOKED`.
* Implement a 15-minute lock expiration (`heldUntil`) using a MongoDB TTL index or periodic background worker.

---

## 4. Feature-by-Feature Acceptance Criteria for Backend Developer

### Milestone 1: Kitty Number Availability & Booking
* [ ] `GET /api/v1/schemes/:id/numbers` returns all 50 slots with accurate real-time statuses (`AVAILABLE`, `BOOKED`, `HELD`).
* [ ] `POST /api/v1/schemes/enroll` atomically transitions slot to `HELD` for 15 minutes.
* [ ] Two simultaneous requests for the same number result in exactly one `201 Created` and one `409 Conflict`.
* [ ] If Month 1 payment is not verified within 15 minutes, slot automatically reverts to `AVAILABLE`.
* [ ] Successful payment webhook permanently marks slot as `BOOKED` tied to `membershipId`.

### Milestone 2: Multi-Month Installment Orders
* [ ] `POST /api/v1/payments/create-order` accepts `months: [9, 10]`.
* [ ] Rejects non-consecutive months (e.g. `[9, 11]`) with `400 Bad Request`.
* [ ] Rejects requests if Month 9 is already marked as `PAID`.
* [ ] Creates GoKwik order with exact amount (`2 * 5000 = 10000`).
* [ ] Upon `payment.success` webhook, creates exactly two distinct passbook records (Month 9 and Month 10) in a single atomic transaction.
* [ ] Increments `monthsPaid` by `2` on the membership record.

### Milestone 3: Multiple Active Kitties
* [ ] `GET /api/v1/schemes/my-schemes` returns array of all active schemes for the user.
* [ ] `GET /api/v1/schemes/memberships/:id/passbook` scopes records strictly to the requested membership.
* [ ] Rejects requests for another patron's membership with `403 Forbidden`.

### Milestone 4: Early Full Balance Settlement
* [ ] `GET /api/v1/schemes/memberships/:id/settlement-summary` accurately calculates remaining months count and total payable balance.
* [ ] `POST /api/v1/payments/create-settlement-order` generates lump-sum GoKwik order for remaining balance.
* [ ] Upon payment success, marks all remaining months as `PAID` and sets `isEarlySettled: true`.

---

## 5. Deployment & Environment Configuration

* **Staging Base URL**: `https://staging-api.swastikjewel.in/api/v1`
* **Production Base URL**: `https://api.swastikjewel.in/api/v1`
* **Required Server Environment Variables**:
  ```env
  PORT=5000
  NODE_ENV=production
  MONGODB_URI=mongodb+srv://...
  JWT_SECRET=...
  GOKWIK_APP_ID=...
  GOKWIK_APP_SECRET=...
  GOKWIK_WEBHOOK_SECRET=...
  ```
