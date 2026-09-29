# Payment Contract Specification V2 (Unified Gateway & Multi-Channel)

**Project**: Swastik Jewellers Kitty App  
**Document Status**: Official Payment Gateway Contract & Integration Guide (V2)  
**Effective Date**: 2026-09-29  
**Replaces**: `11_PAYMENT_FRONTEND_FLOW.md` (V1.0)  
**Primary Gateway**: GoKwik Unified Checkout + Showroom Counter Cash Reconciliation  

---

## 1. Executive Payment Principles & Preserved Architecture

> [!IMPORTANT]
> **Preservation Directive**: The underlying GoKwik checkout WebView architecture, live banking status reconciliation polling loop ([payment_controller.dart](file:///d:/kitty_app/lib/features/checkout/presentation/providers/payment_controller.dart)), and local token storage are **100% preserved**. 
>
> Contract V2 **extends** this foundation to support:
> 1. Multi-month bulk orders
> 2. Full balance settlement orders
> 3. Future lucky number reservation token orders (₹100)
> 4. Doorstep cash collection verification ("Pick Cash")

---

## 2. The 5 Supported Payment Scenarios

```
PAYMENT CHANNELS & SCENARIOS
│
├── 1. Single Installment Payment (Legacy v1.0 Preserved)
│   └── 1 Month Due (e.g. Month 9 = ₹5,000)
│
├── 2. Multi-Month Installment Payment (New v2.0)
│   └── Consecutive Months (e.g. Months 9 & 10 = ₹10,000)
│
├── 3. Full Remaining Balance Settlement (New v2.0)
│   └── All Remaining Months (e.g. Months 9, 10, 11 = ₹15,000)
│
├── 4. Future Number Reservation Token (New v2.0)
│   └── Token Lock Deposit = ₹100
│
└── 5. Doorstep Cash Pickup ("Pick Cash")
    └── Verified Swastik Executive collects physical cash + OTP confirmation
```

---

## 3. Order Creation Endpoint: `POST /api/v1/payments/create-order`

### 3.1 Request Payload Variants

#### Scenario A: Single Month (Backward-Compatible)
```json
{
  "membershipId": "mem_994411",
  "month": 9,
  "paymentMethod": "ONLINE"
}
```

#### Scenario B: Multi-Month Advance
```json
{
  "membershipId": "mem_994411",
  "months": [9, 10],
  "paymentMethod": "ONLINE"
}
```

#### Scenario C: Full Balance Early Settlement
```json
{
  "membershipId": "mem_994411",
  "settlementType": "FULL_BALANCE",
  "paymentMethod": "ONLINE"
}
```

#### Scenario D: Future Number Reservation (₹100)
```json
{
  "reservationId": "res_884920",
  "paymentType": "RESERVATION_DEPOSIT",
  "paymentMethod": "ONLINE"
}
```

### 3.2 Standard Order Response `201 Created`
```json
{
  "success": true,
  "data": {
    "orderId": "ord_gokwik_998822",
    "membershipId": "mem_994411",
    "amount": 10000,
    "currency": "INR",
    "paymentUrl": "https://sandbox.gokwik.co/checkout?orderId=ord_gokwik_998822",
    "merchantCallbackUrl": "https://api.swastikjewel.in/api/v1/payments/gokwik-webhook",
    "expiresAt": "2026-09-29T14:30:00.000Z"
  }
}
```

---

## 4. Verification Polling Endpoint: `POST /api/v1/payments/verify-payment`

When the customer finishes their payment inside the GoKwik WebView or UPI application, the Flutter client calls `verify-payment` up to 5 times (every 3 seconds):

```json
// Request:
{
  "orderId": "ord_gokwik_998822"
}

// Success Response 200 OK:
{
  "success": true,
  "data": {
    "orderId": "ord_gokwik_998822",
    "status": "SUCCESS", // PENDING | SUCCESS | FAILED
    "transactionId": "TXN_UPI_9988112233",
    "paymentMethod": "UPI",
    "amountPaid": 10000,
    "receiptId": "REC-2026-09-8812",
    "monthsAllocated": [9, 10],
    "goldRateAtPayment": 15268.00,
    "totalGramsAllocated": 0.655,
    "updatedMonthsPaid": 10,
    "paidAt": "2026-09-29T14:15:32.000Z"
  }
}
```

---

## 5. Webhook Security & Idempotency Rules

1. **HMAC-SHA256 Signature Verification**: All webhook requests from GoKwik must carry an `X-GoKwik-Signature` header matching `HMAC_SHA256(rawBody, GOKWIK_WEBHOOK_SECRET)`.
2. **Idempotency Guarantee**: If the webhook arrives multiple times for the same `orderId`, the backend must process it strictly once:
   ```javascript
   const order = await db.payment_orders.findOne({ orderId });
   if (order.status === 'PAID') {
     return res.status(200).json({ success: true, message: 'Already reconciled.' });
   }
   ```
3. **Passbook Synchronicity**: Passbook records for all allocated months must be committed within the same database transaction.
