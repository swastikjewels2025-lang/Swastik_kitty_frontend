# Backend Database Schema Changes Specification V2

**Target Database**: MongoDB (`Swastik_kitty_backend`)  
**Document Status**: Official Database Architecture & Migration Specification (V2)  
**Effective Date**: 2026-09-29  
**Replaces**: Database references in `07_FRONTEND_DATA_AND_API_CONTRACT.md`  

---

## 1. Database Architecture Overview

To support Kitty V2 capabilities without breaking existing records or queries, changes are partitioned into:
1. **Additive Field Extensions** to existing collections (`memberships`, `payment_orders`, `passbook_entries`).
2. **Two New Collections**:
   - `scheme_slots`: Manages real-time numbers (01–50) and temporary locking.
   - `scheme_reservations`: Manages advance lucky number reservations (₹100 token deposit).

---

## 2. Modifications to Existing Collections

### 2.1 Collection: `memberships`

| Field Name | Type | Status | Description | Default / Migration Rule |
| :--- | :---: | :---: | :--- | :--- |
| `_id` | `ObjectId` | Existing | Unique membership ID (e.g. `mem_994411`). | Unchanged. |
| `userId` | `ObjectId` | Existing | References `users._id`. | Unchanged. |
| `schemeId` | `String` | Existing | References `schemes.id`. | Unchanged. |
| `kittyNumber` | `Integer` | **NEW** | Numerical Kitty token number (e.g. `6`, `42`). | Backfill existing records from `tokenNumber` integer field. |
| `chitToken` | `String` | Existing | Formatted token string (e.g. `#SW-042`). | Unchanged. |
| `customMonthlyEmi` | `Integer` | Existing | Monthly payment in whole rupees (e.g. `5000`). | Unchanged. |
| `monthsPaid` | `Integer` | Existing | Count of deposited installments (0 to 11). | Unchanged. |
| `isEarlySettled` | `Boolean` | **NEW** | True if patron paid full remaining balance early. | Default: `false`. |
| `earlySettledAt` | `ISODate` | **NEW** | Timestamp when full balance was cleared. | Default: `null`. |
| `status` | `String` | Existing | `ACTIVE` \| `SETTLED` \| `COMPLETED` \| `CANCELLED`. | Added `SETTLED`. |

#### Recommended Index Updates:
```javascript
// Ensure Kitty Number is strictly unique per scheme group
db.memberships.createIndex({ schemeId: 1, kittyNumber: 1 }, { unique: true, sparse: true });

// Multi-scheme fast lookup for patron dashboard
db.memberships.createIndex({ userId: 1, status: 1 });
```

---

### 2.2 Collection: `payment_orders`

| Field Name | Type | Status | Description | Default / Migration Rule |
| :--- | :---: | :---: | :--- | :--- |
| `orderId` | `String` | Existing | Unique GoKwik / gateway order ID. | Unique index. |
| `membershipId` | `ObjectId` | Existing | References `memberships._id`. | Required for Kitty orders. |
| `monthsCovered` | `Array<Int>` | **NEW** | Array of installment months paid (e.g. `[9, 10]`). | For single payments, populate `[month]`. |
| `paymentType` | `String` | **NEW** | `SINGLE_EMI` \| `MULTI_EMI` \| `FULL_SETTLEMENT` \| `RESERVATION`. | Default: `SINGLE_EMI`. |
| `amount` | `Integer` | Existing | Total order amount in whole INR. | Unchanged. |
| `status` | `String` | Existing | `PENDING` \| `PAID` \| `FAILED`. | Unchanged. |

---

### 2.3 Collection: `passbook_entries`

| Field Name | Type | Status | Description | Default / Migration Rule |
| :--- | :---: | :---: | :--- | :--- |
| `receiptId` | `String` | Existing | Tax receipt identifier (e.g. `REC-2026-09-8812`). | Unchanged. |
| `month` | `Integer` | Existing | Installment month (1 to 12). | Unchanged. |
| `goldRateAtPayment`| `Double` | Existing | Live 24K rate used to allocate gold. | Unchanged. |
| `goldGramsAllocated`| `Double` | Existing | Calculated grams (3 decimal precision). | Unchanged. |
| `parentOrderId` | `String` | **NEW** | References `payment_orders.orderId`. | Allows grouping multi-month payments. |

---

## 3. New Collections

### 3.1 Collection: `scheme_slots`
Manages the real-time grid of numbers for a scheme group:

```javascript
{
  "_id": ObjectId("..."),
  "schemeId": "sch_12month_suvarna",
  "number": 6,
  "tokenString": "#SW-006",
  "status": "AVAILABLE", // AVAILABLE | HELD | BOOKED | RESERVED
  "heldByUserId": ObjectId("usr_654321"),
  "heldUntil": ISODate("2026-09-29T14:15:00.000Z"),
  "membershipId": ObjectId("mem_994411"),
  "createdAt": ISODate("2026-09-01T00:00:00Z"),
  "updatedAt": ISODate("2026-09-29T14:00:00Z")
}
```

```javascript
// Constraints
db.scheme_slots.createIndex({ schemeId: 1, number: 1 }, { unique: true });
db.scheme_slots.createIndex({ schemeId: 1, status: 1 });
```

---

### 3.2 Collection: `scheme_reservations`
Tracks future number reservation requests with token deposits:

```javascript
{
  "_id": ObjectId("res_884920"),
  "userId": ObjectId("usr_654321"),
  "futureSchemeId": "sch_diwali_2026",
  "kittyNumber": 7,
  "tokenString": "#SW-007",
  "depositAmount": 100,
  "paymentOrderId": "ord_gokwik_token_100",
  "paymentStatus": "PAID",
  "reservationStatus": "CONFIRMED", // CONFIRMED | CONVERTED | EXPIRED | CANCELLED
  "isAdjustedInMonth1": false,
  "convertedMembershipId": null,
  "expiresAt": ISODate("2026-10-25T23:59:59Z"),
  "createdAt": ISODate("2026-09-29T14:00:00Z")
}
```

```javascript
// Constraints
db.scheme_reservations.createIndex(
  { futureSchemeId: 1, kittyNumber: 1 },
  { unique: true, partialFilterExpression: { reservationStatus: "CONFIRMED" } }
);
```

---

## 4. Safe Non-Destructive Migration Script Specification

```javascript
// migration_v2_additive.js
// Run against MongoDB instance:
print("--- Starting Kitty V2 Non-Destructive Migration ---");

// 1. Backfill kittyNumber in memberships from existing tokenNumber
db.memberships.find({ kittyNumber: { $exists: false } }).forEach(function(doc) {
  var num = doc.tokenNumber || parseInt(doc.tokenString.replace('#SW-', ''), 10) || 1;
  db.memberships.updateOne(
    { _id: doc._id },
    { $set: { kittyNumber: num, isEarlySettled: false, earlySettledAt: null } }
  );
});

// 2. Initialize scheme_slots for active schemes
db.schemes.find({ status: "OPEN" }).forEach(function(scheme) {
  var cap = scheme.maxCapacity || 50;
  for (var i = 1; i <= cap; i++) {
    var formattedToken = "#SW-" + (i < 10 ? "00" + i : (i < 100 ? "0" + i : i));
    var existingMember = db.memberships.findOne({ schemeId: scheme.id, kittyNumber: i });
    
    db.scheme_slots.updateOne(
      { schemeId: scheme.id, number: i },
      {
        $setOnInsert: {
          tokenString: formattedToken,
          status: existingMember ? "BOOKED" : "AVAILABLE",
          heldByUserId: existingMember ? existingMember.userId : null,
          membershipId: existingMember ? existingMember._id : null,
          createdAt: new Date()
        }
      },
      { upsert: true }
    );
  }
});

print("--- Kitty V2 Database Migration Complete ---");
```
