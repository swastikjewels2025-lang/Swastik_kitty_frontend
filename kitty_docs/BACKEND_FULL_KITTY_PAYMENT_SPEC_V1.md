# Backend Specification: Full Remaining Kitty Payment & Early Settlement V1

**Feature**: Full Remaining Kitty Balance Settlement & Maturity  
**Document Status**: Official Backend Engineering & Policy Specification (V1)  
**Target Backend**: Node.js / Express / MongoDB (`Swastik_kitty_backend`)  
**Effective Date**: 2026-09-29  

---

## 1. Feature Context & User Intent

In traditional jewellery savings, patrons frequently choose to pay their entire remaining balance at once (e.g. before Diwali or a family wedding) so they can finalize their jewellery selection.

* **Example Scenario**:
  - Plan: Swastik Suvarna Varsha (12 Months, ₹5,000 / month).
  - Target Value: ₹60,000 (11 months paid by customer = ₹55,000; 12th month paid by Swastik = ₹5,000).
  - Current Status: Patron has paid Months 1 through 8 (₹40,000).
  - Remaining Customer Obligation: Months 9, 10, and 11 = **₹15,000**.
  - Patron taps **[ Pay Full Remaining Balance: ₹15,000 ]**.

---

## 2. API Endpoint Specification

### 2.1 Get Full Settlement Breakdown
* **Endpoint**: `GET /api/v1/schemes/memberships/:id/settlement-summary`
* **Auth**: `Bearer <JWT>`
* **Description**: Returns exact mathematical breakdown of remaining installments, total amount, bonus qualification, and redemption terms.

#### Response `200 OK`:
```json
{
  "success": true,
  "data": {
    "membershipId": "mem_994411",
    "schemeName": "Swastik Suvarna Varsha",
    "kittyNumber": 42,
    "chitToken": "#SW-042",
    "totalMonths": 12,
    "monthsPaid": 8,
    "totalPaidAmount": 40000,
    "remainingMonths": [9, 10, 11],
    "remainingMonthsCount": 3,
    "payableRemainingAmount": 15000,
    "swastikBonusMonth": 12,
    "swastikBonusAmount": 5000,
    "totalMaturityGoldValue": 60000,
    "isEarlySettlement": true,
    "maturityDate": "2027-01-05T00:00:00.000Z"
  },
  "timestamp": 1727600000000
}
```

---

### 2.2 Create Full Balance Settlement Order
* **Endpoint**: `POST /api/v1/payments/create-settlement-order`
* **Auth**: `Bearer <JWT>`

#### Request Body:
```json
{
  "membershipId": "mem_994411",
  "settlementType": "FULL_BALANCE"
}
```

#### Response `201 Created`:
```json
{
  "success": true,
  "message": "Full settlement payment order created for ₹15,000.",
  "data": {
    "orderId": "ord_gokwik_settle_9944",
    "membershipId": "mem_994411",
    "amount": 15000,
    "currency": "INR",
    "monthsSettled": [9, 10, 11],
    "paymentUrl": "https://sandbox.gokwik.co/checkout?orderId=ord_gokwik_settle_9944"
  },
  "timestamp": 1727600000000
}
```

---

## 3. Mandatory Business Decisions Required

> [!CAUTION]
> The backend engineering team **CANNOT** finalize the early settlement business logic without formal executive decisions on these 4 legal and financial questions:
>
> ### Decision 1: Jeweller Bonus Eligibility on Early Settlement
> * `BUSINESS DECISION REQUIRED`: If a patron deposits all remaining months in Month 8, do they still qualify for the full 12th-month ₹5,000 bonus?
>   * *Option A (Recommended)*: **YES**, as long as all 11 customer installments (₹55,000) are paid in full.
>   * *Option B*: Pro-rated bonus based on time elapsed.
>
> ### Decision 2: Gold Price Lock-in Timing
> * `BUSINESS DECISION REQUIRED`: When the remaining ₹15,000 is paid on a single day:
>   * *Option A*: The entire ₹15,000 is converted to gold grams at **today's live 24K rate**.
>   * *Option B*: The money sits in INR cash escrow and converts to gold on the 5th of each remaining month.
>
> ### Decision 3: Immediate vs Deferred Jewellery Redemption
> * `BUSINESS DECISION REQUIRED`: Can the patron walk into the Lucknow showroom and claim their ₹60,000 jewellery **the next day**, or must they wait until the original 12th month maturity date?
>   * *Legal Context*: Under Indian Companies Act (Acceptance of Deposits) & State Chit Fund Regulations, advance jewellery purchase agreements often stipulate a minimum holding period.
>
> ### Decision 4: Scheme Status Transition
> * When payment succeeds, does the membership transition to:
>   * `SETTLED_PENDING_MATURITY` (Paid in full, waiting for maturity date) OR
>   * `COMPLETED_READY_FOR_REDEMPTION` (Eligible for immediate showroom billing)?
