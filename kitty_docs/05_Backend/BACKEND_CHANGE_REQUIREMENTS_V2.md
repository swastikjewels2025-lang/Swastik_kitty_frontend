# Backend Change Requirements V2 — Kitty App

**Audience**: Backend Engineers & System Architects  
**Project**: Swastik Jewellers Kitty Backend (`Swastik_kitty_backend`)  
**Document Status**: Official Backend Requirements Specification (V2)  
**Effective Date**: 2026-09-29  
**Replaces**: Backend sections of `07_FRONTEND_DATA_AND_API_CONTRACT.md` & `19_BACKEND_HANDOFF.md`  

---

## 1. Executive Summary: What Changed & Why Backend Must Adapt

The Swastik Jewellers mobile app has completed a comprehensive UX simplification audit. The product is transitioning from a general jewellery catalog app to a **Kitty-First Financial & Savings Platform**.

To support this simplified, high-trust experience, the frontend client requires **5 fundamental backend capabilities** that do not currently exist in the Backend v1.0 API:
1. **Kitty Number Selection & Concurrency Locking**: Patrons must be able to view available numbers (e.g. 01 to 50) and select their preferred number upon enrollment.
2. **Multi-Month Installment Orders**: Patrons must be able to pay 2, 3, or multiple upcoming months in a single transaction. Currently, the payment API is hardcoded to a single `int monthFor`.
3. **Full Remaining Kitty Balance Settlement**: Patrons must be able to clear their remaining balance in full.
4. **Multiple Active Kitty Management**: The dashboard response must support multiple concurrent active schemes per patron rather than a single scheme object.
5. **Future Number Reservation (Optional Business Feature)**: Temporary reservation of upcoming scheme numbers with a token deposit (e.g. ₹100).

> [!IMPORTANT]
> **Directive for Backend Developer**: Do NOT break existing authentication, single-installment GoKwik payment flows, or KYC verification. All new capabilities must be implemented as additive extensions under the versioned `/api/v1/` or `/api/v2/` routes as specified below.

---

## 2. Master Backend Change Requirements Matrix

| Requirement | Current Backend v1.0 Behavior | Required Backend v2.0 Behavior | API Change Required? | DB Schema Change? | Payment Gateway Impact? | Business Decision Required? |
| :--- | :--- | :--- | :---: | :---: | :---: | :---: |
| **1. Kitty Number Availability** | Backend assigns arbitrary sequential token string (`#SW-042`) upon enrollment. | Returns list of all numbers (e.g. 1–50) with status: `AVAILABLE`, `BOOKED`, `TEMP_RESERVED`. | 🔴 **NEW API**<br>`GET /schemes/:id/numbers` | 🟡 **YES**<br>Add `kittyNumber`, `slotStatus` to Scheme/Membership | ❌ None | 🔴 **YES**<br>Max numbers per group (50 vs 100)? |
| **2. Kitty Number Selection on Join** | `POST /schemes/enroll` accepts only `{ schemeId }`. | `POST /schemes/enroll` accepts `{ schemeId, selectedNumber }`. Locks number atomically. | 🟡 **UPDATE API**<br>`POST /schemes/enroll` | 🟡 **YES**<br>Unique index on `{ schemeId, kittyNumber }` | ❌ None | 🔴 **YES**<br>Hold timeout if unpaid? |
| **3. Multi-Month Installment Payment** | `POST /payments/create-order` only accepts single `month: int` and `amount: int`. | Accepts `months: [9, 10]` or `monthsCount: 2`. Calculates authoritative server total. | 🟡 **UPDATE API**<br>`POST /payments/create-order` | 🟡 **YES**<br>Support multi-month allocation array in Payment | 🟡 **YES**<br>Order amount = `N * monthlyInstallment` | 🔴 **YES**<br>Can user pay non-consecutive months? |
| **4. Full Remaining Kitty Settlement** | No remaining calculation or bulk settlement endpoint exists. | Calculates remaining balance, creates final lump-sum order, flags scheme as `FULLY_PAID`. | 🟡 **UPDATE API**<br>`POST /payments/create-order` | 🟡 **YES**<br>`isSettledEarly`, `settledAt` fields in Membership | 🟡 **YES**<br>Order amount = Remaining balance | 🔴 **YES**<br>Does bonus unlock immediately or on maturity date? |
| **5. Multiple Active Schemes Dashboard** | `GET /schemes/my-schemes` and `GET /dashboard` return single active scheme object. | Returns array of all active memberships: `memberships: [ { id, name, emi, monthsPaid } ]`. | 🟡 **UPDATE API**<br>`GET /schemes/my-schemes` | ❌ No schema change (already 1:N in MongoDB) | ❌ None | 🟡 **YES**<br>Max concurrent active schemes per user? |
| **6. Future Number Reservation** | Non-existent. | Creates a 30-day reservation record for an upcoming scheme with ₹100 deposit order. | 🔴 **NEW API**<br>`POST /schemes/reserve-number` | 🔴 **NEW COLLECTION**<br>`SchemeReservations` | 🟡 **YES**<br>₹100 token payment order via GoKwik | 🔴 **YES**<br>Is ₹100 refundable? Is it adjusted in Month 1? |
| **7. Doorstep Cash Collection ("Pick Cash")** | Handled in client state; counter counter-entry required. | Webhook / Counter CRM endpoint to confirm counter cash deposit and update passbook. | 🟡 **UPDATE API**<br>`POST /payments/cash-pickup` | 🟡 **YES**<br>Track pickup status: `REQUESTED`, `COLLECTED` | ❌ Cash transaction | 🟡 **YES**<br>Pickup radius & service fees (if any)? |

---

## 3. High-Priority Backend Technical Deep Dives

### 3.1 Concurrency & Race Condition Rules (Kitty Number Booking)
* **The Problem**: Two users on their mobile apps tap Number `12` at the exact same second.
* **Backend Requirement**:
  1. The database must enforce a **unique compound constraint**:
     ```javascript
     db.memberships.createIndex({ schemeId: 1, kittyNumber: 1 }, { unique: true });
     ```
  2. Implement atomic locking using MongoDB `findOneAndUpdate` with a temporary status:
     ```javascript
     const lock = await db.schemeSlots.findOneAndUpdate(
       { schemeId, number: selectedNumber, status: 'AVAILABLE' },
       { $set: { status: 'HELD', heldByUserId: userId, heldUntil: new Date(Date.now() + 15 * 60 * 1000) } },
       { new: true }
     );
     if (!lock) {
       return res.status(409).json({ success: false, error: { code: 'NUMBER_ALREADY_TAKEN', message: 'This kitty number was just taken by another member. Please choose another number.' } });
     }
     ```
  3. If payment is completed within 15 minutes, update status to `BOOKED`.
  4. If payment fails or 15 minutes expire, a background worker or TTL index resets status to `AVAILABLE`.

### 3.2 Authoritative Server-Side Calculation (Multi-Month Payments)
* **Security Rule**: The frontend client **must NEVER** dictate the total payable amount to the backend.
* **Backend Requirement**:
  - Frontend sends: `{ membershipId: "mem_994411", months: [9, 10] }`.
  - Backend queries `membership.monthlyInstallment` (e.g. ₹5,000).
  - Backend verifies Month 9 is indeed the next unpaid month and Month 10 is the subsequent month.
  - Backend computes authoritative total: `2 * 5000 = 10000`.
  - Backend creates GoKwik order with `amount: 10000`.
  - Passbook updates both Month 9 and Month 10 records upon payment confirmation webhook.

---

## 4. Unresolved Business Decisions (Requires Management Sign-Off)

The backend developer should **NOT** make independent assumptions regarding the following business policies:

1. **Reservation Deposit (₹100)**:
   - `BUSINESS DECISION REQUIRED`: Is the ₹100 deposit refundable if the customer cancels before group start?
   - `BUSINESS DECISION REQUIRED`: Is the ₹100 adjusted in the Month 1 payment (e.g. Customer pays ₹4,900 instead of ₹5,000)?
2. **Early Full Balance Settlement**:
   - `BUSINESS DECISION REQUIRED`: Under Indian Legal Compliance (BUDS Act & Chit Funds Act), if an 11-month plan is paid off in Month 3, can the 12th-month free bonus be awarded immediately, or is it legally restricted until 12 chronological calendar months elapse?
3. **Skipped Installments**:
   - `BUSINESS DECISION REQUIRED`: Can a patron pay Month 10 if Month 9 is unpaid? (Recommendation: Disallow non-consecutive payments; installments must be cleared in strict chronological order).
