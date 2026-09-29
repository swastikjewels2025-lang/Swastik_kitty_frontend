# Backend Specification: Kitty Number Selection & Allocation V1

**Feature**: Kitty Number / Slot Selection & Real-Time Availability  
**Document Status**: Official Backend Engineering Specification (V1)  
**Target Backend**: Node.js / Express / MongoDB (`Swastik_kitty_backend`)  
**Effective Date**: 2026-09-29  

---

## 1. Domain Concepts & State Machine

In traditional Indian jewellery chit/kitty groups, each participant holds a dedicated number (e.g. No. 01, No. 07, No. 42). To replicate this high-trust ritual, the backend must manage numbers through a strict lifecycle state machine:

```
                  ┌──────────────┐
                  │  AVAILABLE   │
                  └──────┬───────┘
                         │ User selects number & initiates enrollment
                         ▼
                  ┌──────────────┐
       ┌──────────┤ HELD / TEMP  ├──────────┐
       │ (Timeout)│  (15 mins)   │ (Payment │
       │          └──────────────┘   Fails) │
       ▼                                    ▼
┌──────────────┐                     ┌──────────────┐
│  AVAILABLE   │                     │  AVAILABLE   │
└──────────────┘                     └──────────────┘
       │                                    ▲
       │ Payment Confirmed (GoKwik Webhook) │
       ▼                                    │
┌──────────────┐                            │
│    BOOKED    ├────────────────────────────┘
│ (Permanent)  │ Scheme Cancelled / Terminated
└──────────────┘
```

### 1.1 State Definitions
* **`AVAILABLE`**: Number is open for any authenticated patron to view and select.
* **`HELD`**: A patron has selected the number and proceeded to the payment checkout. A 15-minute countdown locks other users from selecting it.
* **`BOOKED`**: Month 1 payment has been verified via GoKwik webhook. Number is permanently tied to the patron's `membershipId`.
* **`RESERVED`**: Held for an upcoming future group via token deposit (see `BACKEND_FUTURE_KITTY_RESERVATION_SPEC_V1.md`).

---

## 2. API Endpoint Specifications

### 2.1 Get Scheme Number Availability Matrix
* **Endpoint**: `GET /api/v1/schemes/:id/numbers`
* **Auth**: `Bearer <JWT>`
* **Description**: Returns all numbers for the scheme with their current real-time status.

#### Response `200 OK`:
```json
{
  "success": true,
  "data": {
    "schemeId": "sch_12month_suvarna",
    "schemeName": "Swastik Suvarna Varsha",
    "totalCapacity": 50,
    "availableCount": 34,
    "bookedCount": 16,
    "numbers": [
      { "number": 1, "status": "AVAILABLE", "tokenString": "#SW-001" },
      { "number": 2, "status": "BOOKED", "tokenString": "#SW-002" },
      { "number": 3, "status": "AVAILABLE", "tokenString": "#SW-003" },
      { "number": 6, "status": "HELD", "expiresAt": "2026-09-29T14:15:00.000Z" }
    ]
  },
  "timestamp": 1727600000000
}
```

---

### 2.2 Enroll and Lock Selected Kitty Number
* **Endpoint**: `POST /api/v1/schemes/enroll`
* **Auth**: `Bearer <JWT>`
* **Description**: Atomically holds the number and creates a pending membership record.

#### Request Body:
```json
{
  "schemeId": "sch_12month_suvarna",
  "selectedNumber": 6,
  "monthlyInstallment": 5000
}
```

#### Success Response `201 Created`:
```json
{
  "success": true,
  "message": "Kitty number 06 locked. Please complete Month 1 payment within 15 minutes.",
  "data": {
    "membershipId": "mem_994411",
    "schemeId": "sch_12month_suvarna",
    "kittyNumber": 6,
    "chitToken": "#SW-006",
    "amountDue": 5000,
    "lockExpiresAt": "2026-09-29T14:15:00.000Z",
    "paymentOrderId": "ord_gokwik_998822"
  },
  "timestamp": 1727600000000
}
```

#### Error Response `409 Conflict` (Race Condition Handled):
```json
{
  "success": false,
  "error": {
    "code": "NUMBER_UNAVAILABLE",
    "message": "Kitty Number 06 was just selected by another patron. Please pick another lucky number.",
    "details": { "suggestedAvailableNumbers": [7, 8, 11, 14] }
  },
  "timestamp": 1727600000000
}
```

---

## 3. Database Schema Requirements (MongoDB)

### 3.1 New Collection: `scheme_slots`
```javascript
{
  "_id": ObjectId("..."),
  "schemeId": "sch_12month_suvarna",
  "number": 6,
  "tokenString": "#SW-006",
  "status": "AVAILABLE", // AVAILABLE | HELD | BOOKED | RESERVED
  "heldByUserId": ObjectId("usr_12345"),
  "heldUntil": ISODate("2026-09-29T14:15:00Z"),
  "membershipId": ObjectId("mem_994411"),
  "createdAt": ISODate("2026-09-01T00:00:00Z"),
  "updatedAt": ISODate("2026-09-29T14:00:00Z")
}
```

### 3.2 Indexing & Constraints
```javascript
// 1. Strict Uniqueness: Prevent duplicate numbers within the same scheme
db.scheme_slots.createIndex({ schemeId: 1, number: 1 }, { unique: true });

// 2. High-speed lookup for available numbers
db.scheme_slots.createIndex({ schemeId: 1, status: 1 });

// 3. TTL Auto-Expiry Index for temporary locks
db.scheme_slots.createIndex({ heldUntil: 1 }, { expireAfterSeconds: 0 });
```

---

## 4. The 14 Unresolved Business & Architectural Questions

The backend engineer and Swastik Jewellers management must review and sign off on these 14 questions:

1. **Capacity Limit**: What is the maximum number of members per Kitty group? Is it strictly 50, 100, or dynamic per scheme?
2. **Number Range**: Are numbers strictly sequential integers (`01` to `50`), or can alphanumeric tokens exist (e.g. `A-01`, `B-12`)?
3. **Cross-Group Collisions**: Can the same number (e.g. `07`) exist in Scheme A (12-Month) and Scheme B (6-Month)? *(Recommendation: Yes, uniqueness is scoped to `{ schemeId, number }`).*
4. **Permanent vs Temporary Locking**: Exactly when does a number transition from `HELD` to `BOOKED`? *(Recommendation: Only upon GoKwik payment webhook `SUCCESS`).*
5. **Lock Timeout**: Is 15 minutes the optimal timeout for the payment hold? What if UPI app takes longer?
6. **Payment Failure Protocol**: If the payment fails or user cancels in GoKwik, is the number released immediately or kept until timeout?
7. **Disconnection Handling**: If user pays successfully via bank but their phone battery dies, how does the webhook reconcile? *(Recommendation: Webhook updates slot to `BOOKED` asynchronously; passbook ready upon next login).*
8. **Race Conditions**: When two users tap the same number simultaneously, how should the UI inform the second user? *(Recommendation: HTTP 409 Conflict with real-time alternative suggestions).*
9. **Admin Manual Assignment**: Can showroom counter staff manually override or reserve a number in the CRM for a VIP customer?
10. **Pre-Payment Number Change**: Can a patron back out of the checkout screen and choose a different number before paying? *(Recommendation: Yes, releases original hold).*
11. **Post-Payment Number Change**: Can a patron swap their number after Month 1 payment has been completed? *(Recommendation: Strictly No, unless showroom manager approves via CRM).*
12. **Lucky Number Search**: Does backend need a specific filter for numerology/lucky numbers (e.g. single digit, ending in 7, adds to 9)?
13. **Multiple Numbers in Same Group**: Can one patron book Number 04 AND Number 05 in the exact same Kitty group? *(Recommendation: Yes, if business allows multiple memberships).*
14. **Unsold Numbers at Group Launch**: If 42 of 50 numbers are booked when the group starts, does Swastik absorb the remaining 8 or resize the group?
