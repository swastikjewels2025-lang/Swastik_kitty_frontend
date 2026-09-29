# Master API Contract Reference V2 — Kitty App

**Project**: Swastik Jewellers Kitty App  
**Document Status**: Official Frontend/Backend API Contract (V2)  
**Base URL**: `https://api.swastikjewel.in/api/v1`  
**Effective Date**: 2026-09-29  
**Replaces**: `07_FRONTEND_DATA_AND_API_CONTRACT.md`  

---

## 1. Governance & Contract Classification

To ensure absolute transparency between the frontend Flutter team and the backend Node.js team, every endpoint is classified as either:
* **`[EXISTING API]`**: Currently implemented and operational in Backend v1.0. Must NOT be altered or broken.
* **`[PROPOSED API]`**: New or extended endpoint required for Kitty V2 UX. Must be implemented by the backend engineer.

---

## 2. Authentication & Patron Onboarding `[EXISTING API]`

### 2.1 Send Mobile OTP
* **Endpoint**: `POST /auth/send-otp`
* **Auth**: Public
* **Request**: `{ "phone": "+919876543210" }`
* **Response `200 OK`**:
  ```json
  {
    "success": true,
    "message": "OTP sent successfully.",
    "data": { "sessionId": "sess_otp_88992211", "expiresInSeconds": 300 }
  }
  ```

### 2.2 Verify Mobile OTP
* **Endpoint**: `POST /auth/verify-otp`
* **Auth**: Public
* **Request**: `{ "phone": "+919876543210", "otp": "123456", "sessionId": "sess_otp_88992211" }`
* **Response `200 OK`**:
  ```json
  {
    "success": true,
    "data": {
      "token": "eyJhbGciOiJIUzI1NiIsIn...",
      "user": {
        "id": "usr_654321abcdef",
        "name": "Rihan Saifi",
        "phone": "+919876543210",
        "kyc": { "isVerified": true, "status": "VERIFIED" }
      }
    }
  }
  ```

---

## 3. Market Bullion Rates `[EXISTING API]`

### 3.1 Get Live Gold & Silver Rates
* **Endpoint**: `GET /market/rates`
* **Auth**: Public / Optional JWT
* **Response `200 OK`**:
  ```json
  {
    "success": true,
    "data": {
      "gold24k": 15268.00,
      "gold22k": 13995.00,
      "gold18k": 11451.00,
      "gold14k": 8932.00,
      "silver999": 89.50,
      "currency": "INR",
      "timestamp": "2026-09-29T10:30:00.000Z"
    }
  }
  ```

---

## 4. Kitty Schemes & Number Booking `[EXISTING + PROPOSED]`

### 4.1 Scheme Catalog `[EXISTING API]`
* **Endpoint**: `GET /schemes/catalog`
* **Auth**: Public / Optional JWT
* **Response `200 OK`**: Returns array of all active savings plans (`targetAmount`, `monthlyInstallment`, `durationMonths`, `benefits`).

### 4.2 Available Numbers Matrix `[PROPOSED API]`
* **Endpoint**: `GET /schemes/:id/numbers`
* **Auth**: `Bearer <JWT>`
* **Response `200 OK`**:
  ```json
  {
    "success": true,
    "data": {
      "schemeId": "sch_12month_suvarna",
      "totalCapacity": 50,
      "availableCount": 34,
      "bookedCount": 16,
      "numbers": [
        { "number": 1, "status": "AVAILABLE", "tokenString": "#SW-001" },
        { "number": 2, "status": "BOOKED", "tokenString": "#SW-002" },
        { "number": 6, "status": "AVAILABLE", "tokenString": "#SW-006" }
      ]
    }
  }
  ```

### 4.3 Enroll in Scheme with Selected Number `[PROPOSED EXTENSION]`
* **Endpoint**: `POST /schemes/enroll`
* **Auth**: `Bearer <JWT>`
* **Request**:
  ```json
  {
    "schemeId": "sch_12month_suvarna",
    "selectedNumber": 6,
    "monthlyInstallment": 5000
  }
  ```
* **Response `201 Created`**:
  ```json
  {
    "success": true,
    "data": {
      "membershipId": "mem_994411",
      "kittyNumber": 6,
      "chitToken": "#SW-006",
      "holdExpiresAt": "2026-09-29T14:15:00.000Z"
    }
  }
  ```
* **Error Response `409 Conflict`**: If number was taken within the last second:
  ```json
  {
    "success": false,
    "error": { "code": "NUMBER_ALREADY_BOOKED", "message": "This Kitty number was just booked by another patron." }
  }
  ```

### 4.4 Get Patron's Active Kitty Schemes `[PROPOSED EXTENSION]`
* **Endpoint**: `GET /schemes/my-schemes`
* **Auth**: `Bearer <JWT>`
* **Response `200 OK`**: Returns array of all active Kitty memberships (`memberships: [ ... ]`). See `BACKEND_MULTI_KITTY_SPEC_V1.md`.

---

## 5. Payments, Passbook & Tax Invoices `[EXISTING + PROPOSED]`

### 5.1 Create Payment Order `[PROPOSED EXTENSION]`
* **Endpoint**: `POST /payments/create-order`
* **Auth**: `Bearer <JWT>`
* **Request (Multi-Month Support)**:
  ```json
  {
    "membershipId": "mem_994411",
    "months": [9, 10],
    "paymentMethod": "ONLINE"
  }
  ```
* **Response `201 Created`**:
  ```json
  {
    "success": true,
    "data": {
      "orderId": "ord_gokwik_multi_77491",
      "totalAmount": 10000,
      "monthsCovered": [9, 10],
      "paymentUrl": "https://sandbox.gokwik.co/checkout?orderId=ord_gokwik_multi_77491"
    }
  }
  ```

### 5.2 Verify Payment Status `[EXISTING API]`
* **Endpoint**: `POST /payments/verify-payment`
* **Auth**: `Bearer <JWT>`
* **Request**: `{ "orderId": "ord_gokwik_multi_77491" }`
* **Response `200 OK`**: `{ "status": "SUCCESS", "receiptId": "REC-8812", "amount": 10000 }`

### 5.3 Full Balance Settlement Order `[PROPOSED API]`
* **Endpoint**: `POST /payments/create-settlement-order`
* **Auth**: `Bearer <JWT>`
* **Request**: `{ "membershipId": "mem_994411", "settlementType": "FULL_BALANCE" }`
* **Response `201 Created`**: `{ "orderId": "ord_settle_991", "amount": 15000, "monthsSettled": [9, 10, 11] }`

### 5.4 Get Passbook & Tax Receipts `[EXISTING API]`
* **Endpoint**: `GET /payments/history` or `GET /schemes/memberships/:id/passbook`
* **Response `200 OK`**: 12-month installment timeline records.

---

## 6. Statutory KYC & Compliance `[EXISTING API]`

### 6.1 Get KYC Status
* **Endpoint**: `GET /kyc/status`
* **Response**: `{ "status": "VERIFIED", "documentType": "AADHAAR", "maskedNumber": "XXXX XXXX 9012" }`

### 6.2 Upload KYC Document
* **Endpoint**: `POST /kyc/upload` (Multipart)
* **Fields**: `documentType`, `documentNumber`, `frontImage`, `backImage`, `statutoryConsentChecked`
