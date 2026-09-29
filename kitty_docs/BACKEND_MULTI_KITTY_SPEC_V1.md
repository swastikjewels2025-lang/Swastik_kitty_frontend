# Backend Specification: Multiple Active Kitties Architecture V1

**Feature**: Multi-Scheme Dashboard & Concurrent Kitty Management  
**Document Status**: Official Backend Engineering Specification (V1)  
**Target Backend**: Node.js / Express / MongoDB (`Swastik_kitty_backend`)  
**Effective Date**: 2026-09-29  

---

## 1. Problem Statement & Existing Backend Limitation

In the existing Backend Contract v1.0, the mobile application client primarily interacts with:
* `GET /api/v1/schemes/my-schemes`
* `GET /api/v1/dashboard`

Both endpoints are mapped to a singular domain entity (`DashboardSummaryEntity`) which assumes **one single active scheme per patron**.

In reality, affluent patrons frequently maintain multiple Kitty schemes concurrently (e.g., one ₹5,000/mo plan for their daughter's wedding, and a second ₹2,000/mo plan for annual Diwali gifting).

The backend must update its endpoints to return an array of active memberships and support switching context by `membershipId`.

---

## 2. API Endpoint Specifications

### 2.1 Get All Active Memberships for Logged-In User
* **Endpoint**: `GET /api/v1/schemes/my-schemes`
* **Auth**: `Bearer <JWT>`

#### Response `200 OK`:
```json
{
  "success": true,
  "data": {
    "totalActiveCount": 2,
    "totalMonthlyCommitment": 7000,
    "totalAccumulatedGoldGrams": 6.842,
    "memberships": [
      {
        "membershipId": "mem_994411",
        "schemeId": "sch_12month_suvarna",
        "schemeName": "Swastik Suvarna Varsha",
        "kittyNumber": 42,
        "chitToken": "#SW-042",
        "customMonthlyEmi": 5000,
        "totalMonths": 12,
        "monthsPaid": 8,
        "totalPaidAmount": 40000,
        "accumulatedGoldGrams": 4.921,
        "nextInstallment": {
          "month": 9,
          "amount": 5000,
          "dueDate": "2026-10-05T00:00:00.000Z",
          "daysRemaining": 6
        },
        "status": "ACTIVE",
        "isPrimary": true
      },
      {
        "membershipId": "mem_882200",
        "schemeId": "sch_6month_express",
        "schemeName": "Express Suvarna Savings",
        "kittyNumber": 12,
        "chitToken": "#SW-012",
        "customMonthlyEmi": 2000,
        "totalMonths": 6,
        "monthsPaid": 3,
        "totalPaidAmount": 6000,
        "accumulatedGoldGrams": 1.921,
        "nextInstallment": {
          "month": 4,
          "amount": 2000,
          "dueDate": "2026-10-10T00:00:00.000Z",
          "daysRemaining": 11
        },
        "status": "ACTIVE",
        "isPrimary": false
      }
    ]
  },
  "timestamp": 1727600000000
}
```

---

### 2.2 Get Detailed Passbook by Specific Membership ID
* **Endpoint**: `GET /api/v1/schemes/memberships/:membershipId/passbook`
* **Auth**: `Bearer <JWT>`
* **Description**: Scopes passbook entries strictly to the requested `membershipId`. Ensures patron cannot view another user's passbook.

---

## 3. Database Architecture (1:N User-to-Membership Relationship)

The MongoDB schema already natively supports 1:N relations via `userId` foreign keys:

```javascript
// Database Query in schemes.controller.js:
const activeMemberships = await db.memberships
  .find({ userId: req.user.id, status: { $in: ['ACTIVE', 'SETTLED_PENDING_MATURITY'] } })
  .sort({ createdAt: -1 });
```

### 3.1 Business Caps & Safeguards
* `BUSINESS RULE`: Maximum **5 active Kitty schemes** per verified Aadhaar/PAN identity. If user attempts to join a 6th scheme, return `400 Bad Request` with message: *"Maximum active savings schemes reached for this account."*
* Every payment order and receipt must permanently store `membershipId` and `chitToken` to prevent cross-account ledger pollution.
