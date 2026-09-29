# Backend Specification: Future Kitty Number Reservation V1

**Feature**: Upcoming Scheme Lucky Number Advance Reservation (Token Deposit Model)  
**Document Status**: Official Backend Engineering & Policy Specification (V1)  
**Target Backend**: Node.js / Express / MongoDB (`Swastik_kitty_backend`)  
**Effective Date**: 2026-09-29  

---

## 1. Feature Context & Concept

Patrons frequently express interest in locking a specific lucky or auspicious number (e.g. `07`, `21`, `51`) for an upcoming seasonal Kitty group (e.g. *Akshaya Tritiya Gold Group* or *Diwali Suvarna Group*) before the group officially opens for installment collections.

To accommodate this without encouraging frivolous reservations, a **₹100 Token Deposit** model is proposed.

```
Patron Selects Upcoming Scheme + Lucky Number
                     │
                     ▼
Pay ₹100 Token Deposit via GoKwik Gateway
                     │
                     ▼
Status: RESERVED (Held until Group Launch Date)
                     │
         ┌───────────┴───────────┐
         ▼                       ▼
Group Opens: Patron     Group Opens: Patron
Pays Month 1 Installment Fails to Pay Month 1
(₹100 Adjusted / Refunded)   (Reservation Expired)
         │                       │
         ▼                       ▼
Number Permanently      Number Released to
BOOKED                  AVAILABLE Pool
```

---

## 2. API Endpoint Specifications

### 2.1 Create Future Number Reservation
* **Endpoint**: `POST /api/v1/schemes/future-reservations`
* **Auth**: `Bearer <JWT>`
* **Description**: Initiates a reservation request and generates a ₹100 GoKwik payment order.

#### Request Body:
```json
{
  "futureSchemeId": "sch_diwali_2026",
  "requestedNumber": 7,
  "depositAmount": 100
}
```

#### Response `201 Created`:
```json
{
  "success": true,
  "message": "Reservation order created. Please pay ₹100 to lock Number 07.",
  "data": {
    "reservationId": "res_884920",
    "futureSchemeId": "sch_diwali_2026",
    "requestedNumber": 7,
    "depositAmount": 100,
    "paymentOrderId": "ord_gokwik_token_100",
    "expiresAt": "2026-10-15T23:59:59.000Z"
  },
  "timestamp": 1727600000000
}
```

---

### 2.2 Get Patron's Active Reservations
* **Endpoint**: `GET /api/v1/schemes/my-reservations`
* **Auth**: `Bearer <JWT>`

#### Response `200 OK`:
```json
{
  "success": true,
  "data": {
    "reservations": [
      {
        "reservationId": "res_884920",
        "futureSchemeName": "Diwali Suvarna Dhanvarsha 2026",
        "kittyNumber": 7,
        "tokenString": "#SW-007",
        "depositPaid": 100,
        "status": "CONFIRMED",
        "groupLaunchDate": "2026-10-20T00:00:00.000Z",
        "paymentDueDate": "2026-10-25T23:59:59.000Z"
      }
    ]
  },
  "timestamp": 1727600000000
}
```

---

## 3. Database Schema Requirements (MongoDB)

### 3.1 New Collection: `scheme_reservations`
```javascript
{
  "_id": ObjectId("res_884920"),
  "userId": ObjectId("usr_654321"),
  "futureSchemeId": "sch_diwali_2026",
  "kittyNumber": 7,
  "depositAmount": 100,
  "paymentOrderId": "ord_gokwik_token_100",
  "paymentStatus": "PAID", // PENDING | PAID | FAILED
  "reservationStatus": "CONFIRMED", // CONFIRMED | CONVERTED | EXPIRED | CANCELLED
  "isAdjustedInMonth1": false,
  "convertedMembershipId": null,
  "expiresAt": ISODate("2026-10-25T23:59:59Z"),
  "createdAt": ISODate("2026-09-29T14:00:00Z"),
  "updatedAt": ISODate("2026-09-29T14:05:00Z")
}
```

### 3.2 Constraints & Indexes
```javascript
// Prevent two users from reserving the same number in the same future scheme
db.scheme_reservations.createIndex(
  { futureSchemeId: 1, kittyNumber: 1, reservationStatus: 1 },
  { unique: true, partialFilterExpression: { reservationStatus: "CONFIRMED" } }
);

// Patron fast lookup
db.scheme_reservations.createIndex({ userId: 1, reservationStatus: 1 });
```

---

## 4. Mandatory Business Decisions Required Before Implementation

The backend engineer **MUST NOT** proceed with code implementation until Swastik Jewellers management resolves the following legal and business questions:

> [!CAUTION]
> ### 1. Refundability Policy
> * `DECISION REQUIRED`: Is the ₹100 token deposit refundable if the customer cancels their reservation before the group begins?
>   * *Option A*: Non-refundable administrative fee (discourages false bookings).
>   * *Option B*: 100% refundable as store credit if cancelled 7 days prior to group launch.
>
> ### 2. Adjustment Against Month 1 Payment
> * `DECISION REQUIRED`: Does the ₹100 deposit get subtracted from the first month's payment?
>   * *Example*: If the monthly plan is ₹5,000, does the user pay `₹4,900` for Month 1?
>   * *Or*: Is Month 1 full `₹5,000` and the ₹100 is refunded to their bank / credited to jewellery making charges?
>
> ### 3. Reservation Expiry & Grace Period
> * `DECISION REQUIRED`: Once the group officially opens on Day 1, how many days does the reserving patron have to pay Month 1 before their reservation expires and the number is released to the public?
>   * *Recommended*: **5 calendar days** grace period.
>
> ### 4. Maximum Reservations per Patron
> * `DECISION REQUIRED`: Can a single user reserve 5 or 10 numbers at ₹100 each, or is there a hard cap of **maximum 2 reservations per verified phone number**?
>
> ### 5. Statutory Compliance (BUDS Act & RBI Escrow)
> * `DECISION REQUIRED`: Can an Indian jeweller accept advance deposits of ₹100 without immediate gold allocation under the Banning of Unregulated Deposit Schemes (BUDS) Act 2019? Legal counsel must confirm.
