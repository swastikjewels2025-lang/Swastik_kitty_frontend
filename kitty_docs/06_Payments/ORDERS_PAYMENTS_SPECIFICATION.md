# Orders & Payments Specification

**Project**: Swastik Jewellers Kitty Savings App  
**Location**: `kitty_frontend/kitty_docs/06_Payments/ORDERS_PAYMENTS_SPECIFICATION.md`  
**Status**: Complete Specification  

---

## 1. Payment Infrastructure Overview

The Swastik Kitty App supports two distinct payment channels:
1. **Digital Online Checkout**: Integrated with **GoKwik Checkout SDK & Gateway** (supporting UPI intent/collect, NetBanking, Debit/Credit Cards).
2. **Doorstep Cash Pickup ("Pick Cash")**: A luxury concierge service where a verified Swastik executive visits the patron's address with a secure verification OTP to collect cash installments.

---

## 2. Digital Online Payment Workflow

```
[Mobile App: CheckoutScreen]
        │
        │ 1. POST /api/v1/payments/initiate
        ▼
[Backend: payment.controller.js]
  - Validates active membership
  - Computes authoritative installment amount
  - Generates GoKwik Order
        │
        │ 2. Returns orderId, amount, callbackUrl
        ▼
[Mobile App: Launches GoKwik SDK / UPI]
        │
        │ 3. Patron completes payment on phone
        ├─────────────────────────────────────────┐
        │                                         │
        ▼ (Client redirect)                       ▼ (Asynchronous Webhook)
[Mobile App: Polls status]             [GoKwik Server: POST /payments/webhook]
[GET /api/v1/payments/status/:orderId]        - HMAC-SHA256 signature verified
                                              - Payment marked SUCCESS
                                              - Gold grams credited to ledger
                                              - PDFKit generates receipt PDF
```

---

## 3. Endpoints Specification

### 3.1 Initiate Payment Order
* **Endpoint**: `POST /api/v1/payments/initiate`
* **Implementation Status**: `[IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Controller**: `src/controllers/payment.controller.js` (`initiatePaymentController`)
* **Service**: `src/services/payment.service.js` (`initiatePaymentOrder`)
* **Auth Required**: Yes (`Authorization: Bearer <TOKEN>`)
* **Request Body**:
  ```json
  {
    "membershipId": "67039a48b71d4a0012349001",
    "monthFor": 9,
    "paymentMethod": "ONLINE"
  }
  ```
* **Multi-Month Extension Requirement**:
  To support the approved multi-month checkout feature (e.g. paying Months 9 & 10 together), the backend must accept an array of months:
  ```json
  {
    "membershipId": "67039a48b71d4a0012349001",
    "months": [9, 10],
    "paymentMethod": "ONLINE"
  }
  ```
  The server calculates `amount = months.length * customMonthlyEmi` (e.g. ₹20,000) rather than trusting client-side totals.
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Payment order initiated.",
    "data": {
      "orderId": "ORD-SW-9001-M9",
      "amount": 10000,
      "currency": "INR",
      "customer": {
        "phone": "+919876543210",
        "email": "patron@swastik.in"
      },
      "callbackUrl": "https://api.swastikjewel.com/api/v1/payments/webhook"
    }
  }
  ```

### 3.2 Poll Payment Status
* **Endpoint**: `GET /api/v1/payments/status/:orderId`
* **Implementation Status**: `[IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Auth Required**: Yes (`Authorization: Bearer <TOKEN>`)
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Payment status checked.",
    "data": {
      "orderId": "ORD-SW-9001-M9",
      "status": "SUCCESS",
      "amount": 10000,
      "monthFor": 9,
      "transactionId": "TXN-GK-8192038",
      "paidAt": "2026-10-07T12:35:00.000Z"
    }
  }
  ```

### 3.3 Gateway Webhook Handler
* **Endpoint**: `POST /api/v1/payments/webhook`
* **Implementation Status**: `[IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Controller**: `src/controllers/payment.controller.js` (`paymentWebhookController`)
* **Security**: Enforces cryptographic HMAC-SHA256 signature verification in header `x-gokwik-signature` against `process.env.GOKWIK_WEBHOOK_SECRET`.
* **Idempotency**: Duplicate webhook payloads for the same `orderId` return `200 OK` immediately without duplicate ledger writes.

### 3.4 Doorstep Cash Pickup Request ("Pick Cash")
* **Endpoint**: `POST /api/v1/payments/cash-pickup-request`
* **Implementation Status**: `[REQUIRED / NOT CURRENTLY IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Auth Required**: Yes (`Authorization: Bearer <TOKEN>`)
* **Request Body**:
  ```json
  {
    "membershipId": "67039a48b71d4a0012349001",
    "amount": 10000,
    "monthFor": 9,
    "pickupAddress": "Flat 402, Royal Palms, Civil Lines, Bareilly",
    "pickupPincode": "243001",
    "preferredTimeSlot": "14:00 - 18:00",
    "contactPhone": "+919876543210"
  }
  ```
* **Success Response (`201 Created`)**:
  ```json
  {
    "success": true,
    "message": "Doorstep cash pickup requested. An executive will arrive with verification OTP.",
    "data": {
      "requestId": "PCK-SW-10829",
      "status": "SCHEDULED",
      "verificationOtp": "7482"
    }
  }
  ```
* **Admin Cash Counter Reconciliation**: Once collected, staff records the cash receipt via `POST /api/v1/admin/payments/record-cash`.

---

## 4. Digital Receipt Generation (PDFKit)

* Upon payment completion, backend `receipt.service.js` generates a branded PDF receipt using **PDFKit**.
* The PDF includes: Swastik Jewellers emblem, chit token number, month paid, transaction reference ID, gold gram weight credited, and timestamp.
* Uploaded to Cloudinary (`https://res.cloudinary.com/swastik/image/upload/receipts/rec_<id>.pdf`) and served directly into the mobile app's `DigitalReceiptModal`.
