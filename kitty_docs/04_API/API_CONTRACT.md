# Master API Contract & HTTP Specification

> [!IMPORTANT]
> **DEFINITIVE CONTRACT SPECIFICATION:**  
> The definitive version of this contract is formalized in:
> * [BACKEND_CONTRACT_FREEZE.md](file:///d:/ui%20design/kitty_docs/api/BACKEND_CONTRACT_FREEZE.md) — Master Frontend ↔ Backend Contract Freeze
> * [BACKEND_DEVELOPER_IMPLEMENTATION_GUIDE.md](file:///d:/ui%20design/kitty_docs/api/BACKEND_DEVELOPER_IMPLEMENTATION_GUIDE.md) — Backend Implementation Guide & To-Do Checklist

## 1. Status & Engineering Notice
* **Document Status:** **`PROPOSED CONTRACT — BACKEND DEVELOPER MUST CONFIRM`**
* **Target Backend Architecture:** Node.js + Express REST API with MongoDB
* **API Base URL Path:** `/api/v1`

---

## 2. Standard Response & Error Envelopes

Every API response dispatched by the backend must conform to one of two envelopes:

### 2.1 Standard Success Envelope
```json
{
  "success": true,
  "message": "Operation completed successfully.",
  "data": {},
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "hasNext": true
  }
}
```
* Note: `meta` is optional and only included for paginated endpoints.

### 2.2 Standard Error Envelope
```json
{
  "success": false,
  "message": "Human-readable user-friendly error message.",
  "error": {
    "code": "INVALID_OTP",
    "details": {
      "field": "otp",
      "attemptRemaining": 2
    }
  }
}
```

---

## 3. HTTP Status Code Contract

| HTTP Status | Meaning | Backend Responsibility | Frontend Action |
| :--- | :--- | :--- | :--- |
| **`200 OK`** | Request succeeded. | Returns requested data inside `data` envelope. | Deserializes DTO, maps to Domain Entity, renders UI. |
| **`201 Created`** | Resource created. | Returns new entity (e.g. membership record). | Displays success feedback / routes to next step. |
| **`204 No Content`** | Success with no body. | Dispatched on deletions or acknowledgement. | Triggers success toast, no deserialization. |
| **`400 Bad Request`** | Syntactic / Form error. | Returns validation reason in `message` and `error`.| Highlights input field with red border and error text. |
| **`401 Unauthorized`** | Token invalid / expired. | Returns 401 when Bearer token fails verification. | Clears SecureStorage, displays toast, redirects to `/auth/login`. |
| **`403 Forbidden`** | Action not allowed. | Dispatched if user lacks required permission/KYC. | Displays compliance bottom sheet / routes to `/kyc`. |
| **`404 Not Found`** | Resource does not exist. | Returns 404 for missing IDs or routes. | Displays reusable `EmptyStateCard` or 404 message. |
| **`409 Conflict`** | Resource state clash. | Duplicate phone number registration, double pay. | Displays conflict banner with resolution advice. |
| **`422 Unprocessable`** | Semantic validation error. | Input valid JSON but violates domain rules. | Displays specific field validation errors. |
| **`429 Rate Limited`** | Too many requests. | Dispatched when SMS OTP rate limit reached. | Disables action button, displays countdown warning. |
| **`500 Server Error`** | Unhandled crash. | Logs server error stack internally. | Displays error card with "Retry" button. |
| **`502 Bad Gateway`** | Reverse proxy failure. | NGINX unable to reach Node process. | Displays server maintenance notice. |
| **`503 Unavailable`** | System maintenance. | Server temporarily down or deploying. | Displays maintenance screen with auto-retry. |

---

## 4. Authentication Contract

### 4.1 Frontend Responsibility
* Render mobile phone number and 6-digit OTP UI inputs.
* Submit phone and OTP to backend.
* Store received JWT token securely using `FlutterSecureStorage` (KeyStore / Keychain).
* Inject `Authorization: Bearer <token>` into every protected HTTP request header.
* Intercept HTTP 401 to wipe local session storage and route to Login.
* Provide clean logout UI and delete cached credentials on exit.

### 4.2 Backend Responsibility
* Generate 6-digit cryptographic OTP and manage 5-minute expiry in Redis/memory.
* Dispatch SMS via Twilio or MSG91.
* Verify OTP and issue signed JWT token with appropriate expiry.
* Validate JWT signature and claims on all protected routes (`/api/v1/users/*`, `/api/v1/memberships/*`, `/api/v1/payments/*`).
* Revoke/blacklist tokens upon logout if stateful sessions are enabled.

---

## 5. Detailed Endpoint Contracts

### 5.1 Auth: Dispatch Mobile OTP
* **Feature:** Authentication
* **API Name:** `sendOtp`
* **Purpose:** Sends 6-digit OTP to user's phone via SMS.
* **HTTP Method:** `POST`
* **Endpoint:** `/api/v1/auth/send-otp`
* **Authentication:** None (Public)
* **Required Headers:** `Content-Type: application/json`
* **Request:**
  ```json
  {
    "phone": "+919876543210"
  }
  ```
* **Success Status:** `200 OK`
* **Response:**
  ```json
  {
    "success": true,
    "message": "OTP sent successfully.",
    "data": {
      "phone": "+919876543210",
      "expiresInSeconds": 300
    }
  }
  ```
* **Error Statuses:** `400 Bad Request`, `429 Too Many Requests`, `500 Server Error`
* **Error Response:**
  ```json
  {
    "success": false,
    "message": "Too many requests. Please wait 2 minutes.",
    "error": { "code": "RATE_LIMIT_EXCEEDED" }
  }
  ```
* **Pagination / Sorting / Filtering:** N/A

---

### 5.2 Auth: Verify Mobile OTP
* **Feature:** Authentication
* **API Name:** `verifyOtp`
* **Purpose:** Validates 6-digit OTP and returns signed JWT with user profile.
* **HTTP Method:** `POST`
* **Endpoint:** `/api/v1/auth/verify-otp`
* **Authentication:** None (Public)
* **Required Headers:** `Content-Type: application/json`
* **Request:**
  ```json
  {
    "phone": "+919876543210",
    "otp": "123456"
  }
  ```
* **Success Status:** `200 OK`
* **Response:**
  ```json
  {
    "success": true,
    "message": "Authentication successful.",
    "data": {
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "isNewUser": false,
      "user": {
        "id": "usr_654321abcdef",
        "name": "Rihan",
        "phone": "+919876543210",
        "role": "CUSTOMER",
        "tier": "Tier 1 Verified Member",
        "kyc": {
          "isVerified": true,
          "documentType": "AADHAAR",
          "documentNumberMasked": "XXXX XXXX 9012",
          "documentUrl": "https://res.cloudinary.com/swastik/image/upload/kyc/sample.jpg",
          "status": "VERIFIED"
        }
      }
    }
  }
  ```
* **Error Statuses:** `400 Bad Request` (Invalid/Expired OTP)
* **Error Response:**
  ```json
  {
    "success": false,
    "message": "Incorrect OTP entered. Please try again.",
    "error": { "code": "INVALID_OTP" }
  }
  ```
* **Pagination / Sorting / Filtering:** N/A

---

### 5.3 KYC: Submit Identity Document
* **Feature:** Statutory Compliance
* **API Name:** `submitKyc`
* **Purpose:** Uploads identity document to Cloudinary and saves KYC record.
* **HTTP Method:** `POST`
* **Endpoint:** `/api/v1/users/kyc`
* **Authentication:** Required (`Bearer <token>`)
* **Required Headers:** `Content-Type: multipart/form-data`
* **Request (Form-Data):**
  - `documentType`: String (`AADHAAR` | `PAN`)
  - `documentNumber`: String (`123456789012` | `ABCDE1234F`)
  - `consentAgreed`: Boolean (`true`)
  - `file`: Binary File (JPG/PNG/PDF, Max 10MB)
* **Success Status:** `200 OK` / `201 Created`
* **Response:**
  ```json
  {
    "success": true,
    "message": "KYC submitted successfully.",
    "data": {
      "referenceId": "KYC-849201",
      "status": "PENDING",
      "documentType": "AADHAAR",
      "documentNumberMasked": "XXXX XXXX 9012",
      "documentUrl": "https://res.cloudinary.com/swastik/image/upload/kyc/sample.jpg"
    }
  }
  ```
* **Error Statuses:** `400 Bad Request` (Invalid format/size), `401 Unauthorized`
* **Pagination / Sorting / Filtering:** N/A

---

### 5.4 Schemes: List Active Schemes
* **Feature:** Scheme Discovery & Offers
* **API Name:** `getActiveSchemes`
* **Purpose:** Retrieves all active gold kitty savings schemes.
* **HTTP Method:** `GET`
* **Endpoint:** `/api/v1/schemes/active`
* **Authentication:** Optional / Public
* **Required Headers:** `Accept: application/json`
* **Filtering (Query Params):**
  - `duration`: Int (optional: `6`, `12`, `18`) — `TBD — BACKEND DEVELOPER`
* **Success Status:** `200 OK`
* **Response:**
  ```json
  {
    "success": true,
    "message": "Active schemes retrieved.",
    "data": {
      "schemes": [
        {
          "id": "sch_12month_suvarna",
          "name": "Swastik Suvarna Varsha",
          "targetAmount": 60000,
          "durationMonths": 12,
          "monthlyInstallment": 5000,
          "maxCapacity": 100,
          "currentMembers": 42,
          "status": "OPEN",
          "benefits": [
            "1 Month Free: 11 Paid + 12th Month 100% Jeweler Bonus",
            "25% Flat Discount on Jewellery Making Charges",
            "Accumulate 24K 999 Hallmark Purity Gold"
          ],
          "bannerImageUrl": "assets/banner_clean_bonus.jpg",
          "isPopular": true
        }
      ]
    }
  }
  ```
* **Error Statuses:** `500 Server Error`
* **Pagination / Sorting:** `TBD — BACKEND DEVELOPER`

---

### 5.5 Membership: Join Scheme (Dynamic EMI Late-Joiner)
* **Feature:** Scheme Enrollment
* **API Name:** `joinScheme`
* **Purpose:** Enrolls user in scheme, calculates dynamic EMI if joining late.
* **HTTP Method:** `POST`
* **Endpoint:** `/api/v1/memberships/join`
* **Authentication:** Required (`Bearer <token>`)
* **Required Headers:** `Content-Type: application/json`
* **Request:**
  ```json
  {
    "schemeId": "sch_12month_suvarna"
  }
  ```
* **Success Status:** `201 Created`
* **Response:**
  ```json
  {
    "success": true,
    "message": "Enrolled in scheme successfully.",
    "data": {
      "membership": {
        "id": "mem_994411",
        "schemeId": "sch_12month_suvarna",
        "schemeName": "Swastik Suvarna Varsha",
        "tokenNumber": 42,
        "customMonthlyEmi": 5000,
        "targetAmount": 60000,
        "totalPaidAmount": 0,
        "status": "ACTIVE",
        "joinedAtMonth": 1
      }
    }
  }
  ```
* **Error Statuses:** `400 Bad Request` (Capacity Full), `403 Forbidden` (KYC Required)
* **Pagination / Sorting / Filtering:** N/A

---

### 5.6 Dashboard: Get Active Summary & Passbook
* **Feature:** Core Dashboard & Passbook
* **API Name:** `getMyDashboard`
* **Purpose:** Aggregates active scheme, progress metrics, and 12-month installment records.
* **HTTP Method:** `GET`
* **Endpoint:** `/api/v1/memberships/my-dashboard`
* **Authentication:** Required (`Bearer <token>`)
* **Required Headers:** `Accept: application/json`
* **Success Status:** `200 OK`
* **Response:**
  ```json
  {
    "success": true,
    "message": "Dashboard data retrieved.",
    "data": {
      "hasActiveScheme": true,
      "dashboard": {
        "membershipId": "mem_994411",
        "chitToken": "#SW-042",
        "schemeName": "Swastik Suvarna Varsha (12-Month Gold Kitty)",
        "targetAmount": 60000,
        "customMonthlyEmi": 5000,
        "totalMonths": 12,
        "monthsPaid": 8,
        "totalPaidAmount": 40000,
        "remainingAmount": 15000,
        "accumulatedGoldGrams": 5.482,
        "currentValuation": 41036,
        "valuationGainPct": 2.59,
        "nextInstallment": {
          "month": 9,
          "amount": 5000,
          "dueDate": "2026-09-15T00:00:00.000Z",
          "daysRemaining": 5
        },
        "passbook": [
          {
            "month": 1,
            "label": "Month 1",
            "amount": 5000,
            "status": "PAID",
            "paidAt": "2026-01-15T10:30:00.000Z",
            "paymentMethod": "ONLINE",
            "transactionId": "TXN-SW-10821",
            "goldGrams": 0.702,
            "receiptUrl": "https://res.cloudinary.com/swastik/image/upload/receipts/rec_10821.pdf"
          },
          {
            "month": 9,
            "label": "Month 9",
            "amount": 5000,
            "status": "CURRENT",
            "dueDate": "2026-09-15T00:00:00.000Z"
          },
          {
            "month": 12,
            "label": "Month 12",
            "amount": 5000,
            "status": "BONUS",
            "bonusNote": "100% Jeweler Bonus Deposit on completion"
          }
        ]
      }
    }
  }
  ```
* **Error Statuses:** `401 Unauthorized`, `500 Server Error`
* **Pagination / Sorting / Filtering:** N/A

---

### 5.7 Payments: Initiate Order
* **Feature:** Installment Checkout
* **API Name:** `initiatePayment`
* **Purpose:** Creates GoKwik gateway order and pending payment entry.
* **HTTP Method:** `POST`
* **Endpoint:** `/api/v1/payments/initiate`
* **Authentication:** Required (`Bearer <token>`)
* **Request:**
  ```json
  {
    "membershipId": "mem_994411",
    "monthFor": 9,
    "paymentMethod": "ONLINE"
  }
  ```
* **Success Status:** `200 OK`
* **Response:**
  ```json
  {
    "success": true,
    "message": "Payment order initiated.",
    "data": {
      "orderId": "gokwik_ord_771829",
      "paymentId": "pay_662819",
      "amount": 5000,
      "currency": "INR",
      "merchantKey": "TBD — BACKEND DEVELOPER"
    }
  }
  ```
* **Error Statuses:** `400 Bad Request`, `401 Unauthorized`

---

### 5.8 Payments: Verify / Poll Payment Status
* **Feature:** Payment Reconciliation
* **API Name:** `getPaymentStatus`
* **Purpose:** Polls payment verification status after GoKwik webview closes.
* **HTTP Method:** `GET`
* **Endpoint:** `/api/v1/payments/status/:orderId`
* **Authentication:** Required (`Bearer <token>`)
* **Success Status:** `200 OK`
* **Response:**
  ```json
  {
    "success": true,
    "message": "Payment status checked.",
    "data": {
      "orderId": "gokwik_ord_771829",
      "status": "SUCCESS",
      "transactionId": "TXN-SW-50291",
      "receiptUrl": "https://res.cloudinary.com/swastik/image/upload/receipts/rec_50291.pdf",
      "totalPaidAmount": 45000,
      "monthsPaid": 9
    }
  }
  ```
* **Error Statuses:** `404 Not Found`
