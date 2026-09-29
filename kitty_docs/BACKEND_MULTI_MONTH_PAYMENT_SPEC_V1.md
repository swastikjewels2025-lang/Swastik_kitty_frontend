# Backend Specification: Multi-Month Installment Payment V1

**Feature**: Multi-Month Advance Kitty Installment Payments  
**Document Status**: Official Backend Engineering Specification (V1)  
**Target Backend**: Node.js / Express / MongoDB (`Swastik_kitty_backend`)  
**Effective Date**: 2026-09-29  

---

## 1. Problem Statement & Existing Backend Limitation

In the existing Backend Contract v1.0 ([`07_FRONTEND_DATA_AND_API_CONTRACT.md`](file:///D:/kitty_frontend/kitty_docs/07_FRONTEND_DATA_AND_API_CONTRACT.md#L99-L101)), `POST /api/v1/payments/create-order` only accepts:
```json
{
  "membershipId": "mem_994411",
  "chitToken": "#SW-042",
  "month": 9,
  "amount": 5000
}
```

This enforces a strict 1-to-1 constraint where a patron can **only pay one single month at a time**. If a patron wants to pay Months 9, 10, and 11 together (total ₹15,000), they are forced to go through the payment gateway checkout 3 separate times, paying 3 separate transaction fees and generating 3 separate OTP verifications.

---

## 2. Recommended API Contract Design: `months` Array (Option B)

### 2.1 Why Option B (`months: [9, 10]`) is the Superior Engineering Choice
* **Option A (`monthsCount: 2`)**: Ambiguous if the customer has missed an earlier month.
* **Option B (`months: [9, 10]`)** *(Recommended)*: Explicit, deterministic, and self-documenting. The client states exactly which installment cycles it is paying for, and the server validates that they are strictly consecutive and currently unpaid.

### 2.2 API Endpoint: `POST /api/v1/payments/create-order`

#### Request Body (Multi-Month):
```json
{
  "membershipId": "mem_994411",
  "months": [9, 10],
  "paymentMethod": "ONLINE" // ONLINE | CASH
}
```

> [!IMPORTANT]
> **Zero Client-Side Amount Trust**: Notice that the client **does not send the `amount` field**. The backend must look up the membership's monthly installment (e.g. ₹5,000) and calculate `totalAmount = months.length * monthlyInstallment` (`2 * 5000 = 10000`).

#### Backend Validation Logic:
```javascript
// 1. Fetch active membership
const membership = await db.memberships.findOne({ _id: membershipId, userId: req.user.id });
if (!membership || membership.status !== 'ACTIVE') {
  return res.status(404).json({ success: false, error: { code: 'MEMBERSHIP_NOT_FOUND', message: 'Active Kitty membership not found.' } });
}

// 2. Validate consecutive unpaid months
const nextDueMonth = membership.monthsPaid + 1;
for (let i = 0; i < months.length; i++) {
  const expectedMonth = nextDueMonth + i;
  if (months[i] !== expectedMonth) {
    return res.status(400).json({
      success: false,
      error: {
        code: 'NON_CONSECUTIVE_MONTHS',
        message: `Installments must be paid consecutively. Expected Month ${expectedMonth}, received Month ${months[i]}.`
      }
    });
  }
}

// 3. Ensure not exceeding total plan duration
if (membership.monthsPaid + months.length > membership.totalMonths - 1) { // 12th month is jeweler bonus
  return res.status(400).json({
    success: false,
    error: { code: 'EXCEEDS_SCHEME_DURATION', message: 'Payment exceeds remaining payable installments.' }
  });
}

// 4. Calculate authoritative amount
const calculatedAmount = months.length * membership.customMonthlyEmi;
```

#### Success Response `201 Created`:
```json
{
  "success": true,
  "message": "Payment order generated for 2 installments.",
  "data": {
    "orderId": "ord_gokwik_multi_77491",
    "membershipId": "mem_994411",
    "monthsCovered": [9, 10],
    "totalAmount": 10000,
    "currency": "INR",
    "paymentUrl": "https://sandbox.gokwik.co/checkout?orderId=ord_gokwik_multi_77491",
    "expiresAt": "2026-09-29T14:30:00.000Z"
  },
  "timestamp": 1727600000000
}
```

---

## 3. Webhook & Passbook Allocation Engine

When GoKwik issues the `payment.success` webhook callback:

```javascript
// Webhook Handler: POST /api/v1/payments/gokwik-webhook
async function handlePaymentSuccess(event) {
  const { orderId, transactionId, paymentMethod, paidAt } = event.payload;
  
  const paymentOrder = await db.payment_orders.findOne({ orderId, status: 'PENDING' });
  if (!paymentOrder) return; // Idempotency check: already processed

  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    // 1. Mark Payment Order as PAID
    paymentOrder.status = 'PAID';
    paymentOrder.transactionId = transactionId;
    paymentOrder.paidAt = paidAt;
    await paymentOrder.save({ session });

    // 2. Fetch current 24K gold rate for assay allocation
    const currentRate = await getLatestGoldRate();
    const gramsPerMonth = (membership.customMonthlyEmi / currentRate).toFixed(3);

    // 3. Batch insert Passbook entries for each month covered
    for (const monthNumber of paymentOrder.monthsCovered) {
      await db.passbook_entries.create([{
        membershipId: paymentOrder.membershipId,
        userId: paymentOrder.userId,
        month: monthNumber,
        amount: paymentOrder.amount / paymentOrder.monthsCovered.length,
        status: 'PAID',
        paymentMethod: paymentMethod,
        transactionId: `${transactionId}-M${monthNumber}`,
        goldRateAtPayment: currentRate,
        goldGramsAllocated: parseFloat(gramsPerMonth),
        paidAt: paidAt,
        receiptId: `REC-${monthNumber}-${paymentOrder.orderId.slice(-6)}`
      }], { session });
    }

    // 4. Increment monthsPaid on the Membership
    await db.memberships.updateOne(
      { _id: paymentOrder.membershipId },
      { 
        $inc: { 
          monthsPaid: paymentOrder.monthsCovered.length,
          totalPaidAmount: paymentOrder.totalAmount
        } 
      },
      { session }
    );

    await session.commitTransaction();
  } catch (error) {
    await session.abortTransaction();
    throw error;
  } finally {
    session.endSession();
  }
}
```

---

## 5. Passbook & Single Consolidated Digital Receipt

* When multiple months are paid together, the backend generates **one single consolidated digital tax invoice** covering the total amount (`₹10,000`), with an itemized breakdown:
  - Month 9 Deposit: ₹5,000 (Gold Allocated: 0.327g)
  - Month 10 Deposit: ₹5,000 (Gold Allocated: 0.327g)
  - Total GST / Transaction: Zero (Advance Purchase Agreement)
* Tapping either Month 9 or Month 10 in the mobile passbook opens this same consolidated receipt.
