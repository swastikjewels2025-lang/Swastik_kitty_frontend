# Frontend Data & API Contract Specification — Kitty App

**Project**: Swastik Jewellers Kitty App (Sub-Brand: Kitty Vault)  
**Primary Codebase**: `D:\kitty_app\`  
**Backend Workspace**: `D:\Kitty_backend\Swastik_kitty_backend\`  
**Document Status**: SUPERSEDED  
**SUPERSEDED BY**: `KITTY_API_CONTRACT_V2.md` & `BACKEND_CHANGE_REQUIREMENTS_V2.md`  
**Last Audit Date**: 2026-09-29  

> [!NOTE]
> **STATUS: SUPERSEDED (PRESERVED FOR HISTORICAL CONTEXT)**  
> This V1 API contract has been superseded by [`KITTY_API_CONTRACT_V2.md`](file:///D:/kitty_frontend/kitty_docs/KITTY_API_CONTRACT_V2.md) and [`BACKEND_CHANGE_REQUIREMENTS_V2.md`](file:///D:/kitty_frontend/kitty_docs/BACKEND_CHANGE_REQUIREMENTS_V2.md). Do not delete.

---

## 1. API Contract Governance & Implementation Status

The contract between the Flutter frontend and the backend service is frozen as **v1.0**:

| Contract Category | Status | Implementation Details |
| :--- | :---: | :--- |
| **Authentication & Profile** | `CURRENTLY IMPLEMENTED` | Implemented in Flutter and Node/Express backend with JWT (30-day expiry) and OTP session management. |
| **User Profile & Settings** | `CURRENTLY IMPLEMENTED` | Profile retrieval, update, and nominee data endpoints active. |
| **Market Rates & Bullion** | `CURRENTLY IMPLEMENTED` | Live gold rates (24K, 22K) and bullion benchmarks consumed by Home and Coin Rates screens. |
| **Schemes & Passbook** | `CURRENTLY IMPLEMENTED` | 12-month installment schedule, pre-join math, and passbook entries active with MongoDB persistence. |
| **Payments & Polling** | `CURRENTLY IMPLEMENTED` | Order creation and verification polling implemented with GoKwik gateway simulation. |
| **KYC Identity Verification** | `CURRENTLY IMPLEMENTED` | Document metadata, masked ID, and Cloudinary upload active. |
| **Jewellery & Products** | `MOCK DATA` | High-definition product catalog is served via offline local mock fixtures (`lib/core/mock/mock_fixtures.dart`). |
| **In-App Notifications** | `MOCK DATA` | Notifications feed and unread status managed via client-side storage and fixtures. |
| **Production Payment Credentials** | `FUTURE BACKEND DEPENDENCY` | Awaiting live GoKwik merchant account provisioning from Swastik Jewellers management. |
| **Video Asset Stream** | `FUTURE BACKEND DEPENDENCY` | Showroom store video upload currently persists in widget state; backend persistent streaming endpoint is future work. |

---

## 2. Standard JSON Response Envelopes

### 2.1 Success Envelope
```json
{
  "success": true,
  "message": "Operation completed successfully.",
  "data": { ... },
  "timestamp": 1727092800000
}
```

### 2.2 Error Envelope
```json
{
  "success": false,
  "error": {
    "code": "INVALID_OTP",
    "message": "The 6-digit OTP code entered is incorrect or expired.",
    "details": null
  },
  "timestamp": 1727092800000
}
```

---

## 3. The 18 Backend API Endpoints

### 3.1 Authentication & Patron Onboarding
1. `POST /api/v1/auth/send-otp`
   - **Payload**: `{ "phone": "+919876543210" }`
   - **Response**: `{ "sessionId": "sess_otp_88992211", "expiresInSeconds": 300 }`
2. `POST /api/v1/auth/verify-otp`
   - **Payload**: `{ "phone": "+919876543210", "otp": "123456", "sessionId": "sess_otp_88992211" }`
   - **Response**: `{ "token": "jwt_token_here", "user": { "id", "name", "phone", "role", "tier", "kyc": { "isVerified": true } } }`
3. `POST /api/v1/auth/register`
   - **Payload**: `{ "name": "Rihan Saifi", "email": "rihan@example.com", "city": "Lucknow" }`
   - **Response**: Updated user entity.
4. `POST /api/v1/auth/refresh-token`
   - **Headers**: `Authorization: Bearer <refresh_token>`
   - **Response**: `{ "token": "new_jwt_token", "expiresIn": 2592000 }`

### 3.2 User Profile & Security
5. `GET /api/v1/user/profile`
   - **Response**: Full patron details including tier, nominee information, and KYC summary.
6. `PUT /api/v1/user/profile`
   - **Payload**: Editable patron preferences, nominee name, and relationship.

### 3.3 Market Bullion Rates
7. `GET /api/v1/market/rates`
   - **Response**:
     ```json
     {
       "gold24k": 7485.50,
       "gold22k": 6861.70,
       "silver999": 89.50,
       "currency": "INR",
       "timestamp": "2026-09-23T10:00:00.000Z"
     }
     ```

### 3.4 Schemes & Installments
8. `GET /api/v1/schemes/catalog` — List of available investment plans.
9. `GET /api/v1/schemes/my-schemes` — Active schemes for logged-in patron.
10. `GET /api/v1/schemes/:id` — Detailed scheme progress, circular gauge metrics, and monthly schedule.
11. `POST /api/v1/schemes/enroll` — Enroll patron in selected scheme.

### 3.5 Payments & Tax Invoices
12. `POST /api/v1/payments/create-order`
    - **Payload**: `{ "membershipId": "mem_994411", "chitToken": "#SW-042", "month": 9, "amount": 5000 }`
    - **Response**: `{ "orderId": "ord_gokwik_12345", "paymentUrl": "https://sandbox.gokwik.co/..." }`
13. `POST /api/v1/payments/verify-payment`
    - **Payload**: `{ "orderId": "ord_gokwik_12345" }`
    - **Response**: `{ "status": "SUCCESS", "receiptId": "REC-2026-09-8812" }`
14. `GET /api/v1/payments/history` — 12-month passbook transaction list.
15. `GET /api/v1/payments/receipt/:receiptId` — Official tax receipt details.

### 3.6 Statutory KYC
16. `GET /api/v1/kyc/status` — Current verification status (`NOT_SUBMITTED`, `PENDING`, `VERIFIED`, `REJECTED`).
17. `POST /api/v1/kyc/upload`
    - **Multipart**: `documentType`, `documentNumber`, `frontImage`, `backImage`, `statutoryConsentChecked`.

### 3.7 Marketing & Offers
18. `GET /api/v1/offers/active` — Active festival promotions and bonus schemes.

---

## 4. Coin Rates & Jewellery Data Contract

### 4.1 Coin Rates Specification
* **Benchmark Rate**: 24K 999 Purity Gold rate per gram (`benchmarkGoldRate = 7485.50`).
* **Assay & Blister Packaging Cost**:
  - 1g to 2g: ₹300
  - 3g to 5g: ₹450
  - 6g to 10g: ₹600
* **Bulk Formula (>10g)**: `rawGold = grams * benchmarkGoldRate; fee = 600 + (grams - 10) * 20; total = rawGold + fee;`

### 4.2 Jewellery Catalog Item Schema
```json
{
  "id": "G-RNG-01",
  "name": "Royal Mayura Filigree Ring",
  "metal": "GOLD",
  "category": "RINGS",
  "purity": "22K (916) Gold",
  "weight": "4.85 g",
  "price": 36800,
  "imageAsset": "assets/images/hero_diamond_ring.jpg",
  "badge": "Best Seller"
}
```

---

## 5. New API Contracts (2026-09-24 Product Update)

> [!NOTE]
> **CLASSIFICATION: FRONTEND REQUIREMENT FOR FUTURE BACKEND**
> The frontend client (`kitty_app`) has implemented UI models, state managers, and offline mock fallbacks for these contracts. The backend engineer must implement these endpoints without altering schemas.

### 5.1 Bullion & Coin Rates API
* **Endpoint**: `GET /api/v1/bullion/rates` and `GET /api/v1/bullion/coins`
* **Response**:
```json
{
  "success": true,
  "data": {
    "metals": {
      "gold": { "rate24kPerGram": 7550.00, "rate22kPerGram": 6920.00, "supportedKarats": ["24K", "22K"] },
      "silver": { "rate999PerGram": 96.50, "rate925PerGram": 89.20, "hasKarat": false }
    },
    "coins": [
      { "id": "C-AU-1G", "metal": "gold", "weightGrams": 1, "purity": "24K", "rate": 7550, "inStock": true },
      { "id": "C-AU-2G", "metal": "gold", "weightGrams": 2, "purity": "24K", "rate": 15100, "inStock": true },
      { "id": "C-AU-3G", "metal": "gold", "weightGrams": 3, "purity": "24K", "rate": 22650, "inStock": true },
      { "id": "C-AU-4G", "metal": "gold", "weightGrams": 4, "purity": "24K", "rate": 30200, "inStock": true },
      { "id": "C-AU-5G", "metal": "gold", "weightGrams": 5, "purity": "24K", "rate": 37750, "inStock": true },
      { "id": "C-AG-1G", "metal": "silver", "weightGrams": 1, "purity": "999", "rate": 96.5, "inStock": true },
      { "id": "C-AG-2G", "metal": "silver", "weightGrams": 2, "purity": "999", "rate": 193.0, "inStock": true },
      { "id": "C-AG-3G", "metal": "silver", "weightGrams": 3, "purity": "999", "rate": 289.5, "inStock": true },
      { "id": "C-AG-4G", "metal": "silver", "weightGrams": 4, "purity": "999", "rate": 386.0, "inStock": true },
      { "id": "C-AG-5G", "metal": "silver", "weightGrams": 5, "purity": "999", "rate": 482.5, "inStock": true }
    ]
  }
}
```

### 5.2 Gold Valuation Calculator Benchmark API
* **Endpoint**: `GET /api/v1/calculator/benchmark-rates`
* **Response**:
```json
{
  "success": true,
  "data": {
    "benchmark24k": 7550.00,
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

### 5.3 Doorstep Cash Pickup Ingestion ("Pick Cash")
* **Endpoint**: `POST /api/v1/payments/cash-pickup`
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
  "additionalNotes": "Optional instructions"
}
```
* **Success Response (`201 Created`)**:
```json
{
  "success": true,
  "data": {
    "pickupId": "PCK-482910",
    "status": "scheduled",
    "scheduledDate": "2026-09-25",
    "timeSlot": "10:00 AM - 01:00 PM",
    "amount": 5000,
    "handoverOtp": "839201"
  }
}
```

### 5.4 Instagram SSO Authentication Callback
* **Endpoint**: `POST /api/v1/auth/instagram/callback`
* **Request Payload**: `{ "code": "AUTH_CODE", "redirectUri": "https://..." }`
* **Response**: Session token and user profile.

