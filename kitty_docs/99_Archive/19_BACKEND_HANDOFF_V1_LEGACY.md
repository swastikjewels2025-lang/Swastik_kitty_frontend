# Backend Handoff Manual & Integration Guide — Kitty App

**Project**: Swastik Jewellers Kitty App (Sub-Brand: Kitty Vault)  
**Primary Codebase**: `D:\kitty_app\`  
**Backend Workspace**: `D:\Kitty_backend\Swastik_kitty_backend\`  
**Document Status**: SUPERSEDED  
**SUPERSEDED BY**: `BACKEND_DEVELOPER_HANDOFF_V2.md` & `BACKEND_CHANGE_REQUIREMENTS_V2.md`  
**Last Audit Date**: 2026-09-29  

> [!NOTE]
> **STATUS: SUPERSEDED (PRESERVED FOR HISTORICAL CONTEXT)**  
> This V1 backend handoff manual has been superseded by [`BACKEND_DEVELOPER_HANDOFF_V2.md`](file:///D:/kitty_frontend/kitty_docs/BACKEND_DEVELOPER_HANDOFF_V2.md) and [`BACKEND_CHANGE_REQUIREMENTS_V2.md`](file:///D:/kitty_frontend/kitty_docs/BACKEND_CHANGE_REQUIREMENTS_V2.md). Do not delete.

---

## 1. Executive Handoff Statement

> [!IMPORTANT]
> **THE FRONTEND APPLICATION IS FEATURE-COMPLETE AND CODE-FROZEN.**
> The backend developer must implement the server API to satisfy the contract specifications detailed in [`07_FRONTEND_DATA_AND_API_CONTRACT.md`](file:///d:/ui%20design/docs/07_FRONTEND_DATA_AND_API_CONTRACT.md) and [`BACKEND_CONTRACT_FREEZE.md`](file:///d:/ui%20design/kitty_docs/api/BACKEND_CONTRACT_FREEZE.md).
> 
> **Zero frontend code modifications are permitted or required** for backend integration. Switching from the offline mock sandbox to the live backend is achieved entirely via `--dart-define=USE_MOCK_API=false` and `--dart-define=BASE_URL=https://api.swastikjewel.com`.

---

## 2. Master Verification Checklist for Backend Engineer

| Milestone | Category | Endpoints / Requirements | Verification Criteria | Status |
| :---: | :--- | :--- | :--- | :---: |
| **M1** | **Authentication** | `send-otp`, `verify-otp`, `register`, `refresh-token` | Must issue 30-day JWT and return `{ success: true, data: { token, user } }`. | Active |
| **M2** | **Patron Profile** | `GET /api/v1/user/profile`, `PUT /api/v1/user/profile` | Must persist nominee and profile preferences. | Active |
| **M3** | **Market Rates** | `GET /api/v1/market/rates` | Must return 24K and 22K gold rates per gram in INR. | Active |
| **M4** | **Kitty Schemes** | `schemes/catalog`, `schemes/my-schemes`, `schemes/:id` | Must calculate months paid, next due date, and 11+1 bonus status. | Active |
| **M5** | **Payments** | `create-order`, `verify-payment`, `payments/history` | Must handle GoKwik callbacks and return official receipt record. | Active |
| **M6** | **Statutory KYC** | `kyc/status`, `kyc/upload` | Must accept multipart image upload and store masked document IDs. | Active |

---

## 3. Server Configuration & Boundary Rules

1. **CORS Headers**:
   - The backend must respond to all HTTP `OPTIONS` pre-flight requests with:
     ```http
     Access-Control-Allow-Origin: *
     Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
     Access-Control-Allow-Headers: Authorization, Content-Type, Accept
     ```
2. **Standard HTTP Status Codes**:
   - `200 OK`: Successful retrieval / processing.
   - `201 Created`: Successful resource creation (Order created, Scheme enrolled).
   - `400 Bad Request`: Form validation failure.
   - `401 Unauthorized`: Token expired or missing. Client interceptor will invoke `/refresh-token`.
   - `403 Forbidden`: KYC compliance restriction.
   - `500 Internal Server Error`: Server exception.
3. **Showroom Cash Payment Webhooks**:
   - Physical cash payments recorded at the Lucknow showroom counter must update the scheme's installment schedule in MongoDB so the patron's passbook reflects the deposit.

---

## 4. Frontend Requirements for Future Backend (2026-09-24 Product Update)

> [!IMPORTANT]
> **CLASSIFICATION: FRONTEND REQUIREMENT FOR FUTURE BACKEND**
> The frontend client (`kitty_app`) has implemented UI models, state managers, and offline mock fallbacks for the new features. The future backend developer must implement the following 4 API contracts to replace the mock abstractions with real production services. **DO NOT modify the frontend API contract schemas.**

### 4.1 Bullion & Coin Rates Contract
* **Endpoints**:
  * `GET /api/v1/bullion/rates`
  * `GET /api/v1/bullion/coins?metal={gold|silver}`
* **Headers**: `Authorization: Bearer <JWT>`
* **Response Schema**:
```json
{
  "success": true,
  "timestamp": "2026-09-24T12:00:00Z",
  "data": {
    "metals": {
      "gold": {
        "rate24kPerGram": 7550.00,
        "rate22kPerGram": 6920.00,
        "supportedKarats": ["24K", "22K"],
        "unit": "INR/gram"
      },
      "silver": {
        "rate999PerGram": 96.50,
        "rate925PerGram": 89.20,
        "hasKarat": false,
        "unit": "INR/gram"
      }
    },
    "coins": [
      { "id": "C-AU-1G", "metal": "gold", "weightGrams": 1, "purity": "24K", "rate": 7550, "inStock": true },
      { "id": "C-AU-2G", "metal": "gold", "weightGrams": 2, "purity": "24K", "rate": 15100, "inStock": true },
      { "id": "C-AU-3G", "metal": "gold", "weightGrams": 3, "purity": "24K", "rate": 22650, "inStock": true },
      { "id": "C-AU-4G", "metal": "gold", "weightGrams": 4, "purity": "24K", "rate": 30200, "inStock": true },
      { "id": "C-AU-5G", "metal": "gold", "weightGrams": 5, "purity": "24K", "rate": 37750, "inStock": true },
      { "id": "C-AG-1G", "metal": "silver", "weightGrams": 1, "purity": "999", "rate": 96.5, "inStock": true },
      { "id": "C-AG-2G", "metal": "silver", "weightGrams": 2, "purity": "999", "rate": 193, "inStock": true },
      { "id": "C-AG-3G", "metal": "silver", "weightGrams": 3, "purity": "999", "rate": 289.5, "inStock": true },
      { "id": "C-AG-4G", "metal": "silver", "weightGrams": 4, "purity": "999", "rate": 386, "inStock": true },
      { "id": "C-AG-5G", "metal": "silver", "weightGrams": 5, "purity": "999", "rate": 482.5, "inStock": true }
    ]
  }
}
```

### 4.2 Gold Valuation Calculator Benchmark API
* **Endpoint**: `GET /api/v1/calculator/benchmark-rates`
* **Response Schema**:
```json
{
  "success": true,
  "data": {
    "benchmark24k": 7550.00,
    "purityMultipliers": {
      "24K": 1.0,
      "22K": 0.9167,
      "18K": 0.7500
    },
    "effectiveRates": {
      "24K": 7550.00,
      "22K": 6921.00,
      "18K": 5662.50
    },
    "currency": "INR",
    "lastUpdated": "2026-09-24T12:00:00Z"
  }
}
```

### 4.3 Doorstep Cash Pickup Ingestion ("Pick Cash")
* **Endpoint**: `POST /api/v1/payments/cash-pickup`
* **Method**: `POST`
* **Headers**: `Authorization: Bearer <JWT>`, `Content-Type: application/json`
* **Request Payload**:
```json
{
  "patronName": "Rihan Saifi",
  "patronPhone": "+919876543210",
  "patronEmail": "rihan.saifi@swastikjewellers.com",
  "pickupAddress": "Flat 402, Royal Palms, Gomti Nagar",
  "city": "Lucknow",
  "pincode": "226010",
  "schemeId": "sch_gold_elite_01",
  "schemeName": "Swarna Nidhi 11+1 Plan",
  "installmentMonth": 4,
  "amount": 5000,
  "preferredSlot": "morning",
  "additionalNotes": "Please ring doorbell twice"
}
```
* **Success Response (`201 Created`)**:
```json
{
  "success": true,
  "data": {
    "pickupId": "PCK-482910",
    "status": "scheduled",
    "assignedAgent": "Swastik Secured Courier Service",
    "scheduledDate": "2026-09-25",
    "timeSlot": "10:00 AM - 01:00 PM",
    "amount": 5000,
    "handoverOtp": "839201",
    "instructions": "Present the 6-digit OTP to the bonded Swastik security executive upon verification of photo ID."
  }
}
```
* **Statutory Compliance Rules**:
  * PMLA ceiling: Maximum ₹1,99,999 cash collection per patron order.
  * Section 269ST Income Tax Act: Backend must reject single transactions exceeding ₹2,00,000 in cash.
  * Form 60 / PAN mandatory for transactions exceeding ₹50,000.

### 4.4 Instagram SSO Authentication Exchange
* **Endpoint**: `POST /api/v1/auth/instagram/callback`
* **Headers**: `Content-Type: application/json`
* **Request Payload**:
```json
{
  "code": "IG_AUTH_CODE_FROM_SDK",
  "redirectUri": "https://swastikjewellers.com/auth/instagram/callback"
}
```
* **Response Schema (`200 OK`)**:
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsIn...",
    "refreshToken": "d8f93a10...",
    "user": {
      "id": "usr_ig_89410",
      "name": "Rihan Saifi",
      "instagramHandle": "rihan_jewels",
      "phone": "+919876543210",
      "email": "rihan.saifi@swastikjewellers.com",
      "tier": "Tier 1 Member",
      "kyc": {
        "status": "VERIFIED",
        "isVerified": true
      }
    }
  }
}
```
* **Configuration Requirements**:
  * Meta Developer App Registration (`App ID`, `App Secret`).
  * Instagram Basic Display API or Instagram Graph API permissions (`user_profile`, `user_media`).

