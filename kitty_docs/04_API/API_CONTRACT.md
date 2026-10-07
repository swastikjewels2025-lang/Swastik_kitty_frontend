# Master API Contract & HTTP Specification

**Project**: Swastik Jewellers Kitty Savings App  
**API Base URL**: `/api/v1`  
**Protocol**: HTTPS REST JSON / Multipart Form-Data  
**Target Backend**: `D:\Kitty_backend\Swastik_kitty_backend\`  
**Target Mobile Client**: `D:\kitty_app\`  
**Status**: Authoritative Master API Contract  

---

## 1. Global Standards & Protocols

### 1.1 Response Envelopes
All responses returned by the backend MUST adhere strictly to one of the following two standard JSON envelopes:

#### Success Envelope
```json
{
  "success": true,
  "message": "Human readable success explanation.",
  "data": {}
}
```

#### Error Envelope
```json
{
  "success": false,
  "message": "Human readable user-friendly error explanation.",
  "error": {
    "code": "ERROR_CODE_STRING",
    "details": {}
  }
}
```

### 1.2 HTTP Headers
* **Client Request Headers**:
  * `Content-Type: application/json` (or `multipart/form-data` for KYC file upload)
  * `Accept: application/json`
  * `Authorization: Bearer <TOKEN>` (on all protected endpoints)
* **Webhook Headers**:
  * `x-gokwik-signature: <HMAC_SHA256_HEX>`

### 1.3 Data Formatting Standards
* **Timestamps**: Strict ISO-8601 UTC strings (`2026-10-07T12:00:00.000Z`).
* **Currencies**: INR amounts formatted as numbers or integer paise/rupees as documented per endpoint.
* **Weights**: Gold grams formatted to 3 decimal places (e.g. `12.500`).

---

## 2. Complete Endpoint Catalog

---

### [AUTH-01] Send Mobile OTP
* **Status**: `[IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Method**: `POST`
* **Endpoint**: `/api/v1/auth/send-otp`
* **Auth Required**: No (Public)
* **Request Headers**: `Content-Type: application/json`
* **Request Body**:
  ```json
  {
    "phone": "+919876543210"
  }
  ```
* **Validation**:
  * `phone`: Required, valid Indian E.164 phone string starting with `+91` followed by 10 digits (`^\+91[6-9]\d{9}$`).
* **Rate Limiting**: Maximum 3 OTP requests per 15 minutes, minimum 60-second cooldown between requests.
* **Success Response (`200 OK`)**:
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
* **Error Responses**:
  * `400 Bad Request`: `{"success": false, "message": "Invalid phone number format...", "error": {"code": "VALIDATION_ERROR", "details": {"field": "phone"}}}`
  * `429 Too Many Requests`: `{"success": false, "message": "Please wait 45 seconds before requesting a new OTP.", "error": {"code": "RATE_LIMIT_EXCEEDED"}}`
* **Frontend Usage**: `lib/features/auth/presentation/screens/login_screen.dart` (Phone number input step).

---

### [AUTH-02] Verify Mobile OTP & Issue Session
* **Status**: `[IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Method**: `POST`
* **Endpoint**: `/api/v1/auth/verify-otp`
* **Auth Required**: No (Public)
* **Request Headers**: `Content-Type: application/json`
* **Request Body**:
  ```json
  {
    "phone": "+919876543210",
    "otp": "123456"
  }
  ```
* **Validation**:
  * `phone`: Required Indian E.164 string.
  * `otp`: Required 6-digit numeric string.
* **Behavior**:
  * Verifies against cached OTP (valid for 300s, max 3 attempts).
  * Automatically creates user if new (`role: 'CUSTOMER'`).
  * Issues signed JWT Bearer token (30-day validity).
  * Test bypass: Phone `+919876543210` with OTP `123456` always passes.
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Authentication successful.",
    "data": {
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "isNewUser": false,
      "user": {
        "id": "67039a48b71d4a001234abcd",
        "name": "Rihan Saifi",
        "phone": "+919876543210",
        "role": "CUSTOMER",
        "tier": "Standard Member",
        "kyc": {
          "isVerified": true,
          "documentType": "AADHAAR",
          "documentNumberMasked": "XXXX XXXX 3210",
          "documentUrl": "https://res.cloudinary.com/swastik/image/upload/kyc/kyc-123456.jpg",
          "status": "VERIFIED"
        }
      }
    }
  }
  ```
* **Error Responses**:
  * `400 Bad Request`: `INVALID_OTP` (with `attemptsRemaining`) or `OTP_EXPIRED`.
* **Frontend Usage**: `lib/features/auth/presentation/screens/login_screen.dart` (OTP verification step).

---

### [AUTH-03] Google Sign-In Exchange
* **Status**: `[REQUIRED / NOT CURRENTLY IMPLEMENTED]`
* **Method**: `POST`
* **Endpoint**: `/api/v1/auth/google`
* **Auth Required**: No (Public)
* **Request Headers**: `Content-Type: application/json`
* **Request Body**:
  ```json
  {
    "idToken": "eyJhbGciOiJSUzI1NiIsImtpZCI6Ij...",
    "email": "patron@gmail.com",
    "name": "Rihan Saifi"
  }
  ```
* **Validation**: Valid Google OAuth2 ID Token verified via `google-auth-library` server-side.
* **Expected Response (`200 OK`)**: Same session envelope as `verify-otp`.
* **Frontend Usage**: `lib/features/auth/presentation/screens/login_screen.dart` (Google button).

---

### [AUTH-04] Patron Sign Out
* **Status**: `[IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Method**: `POST`
* **Endpoint**: `/api/v1/auth/logout`
* **Auth Required**: Yes (`Authorization: Bearer <TOKEN>`)
* **Request Body**: None (`{}`)
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Logged out successfully.",
    "data": {}
  }
  ```
* **Frontend Usage**: `lib/features/menu/presentation/widgets/kitty_menu_sheet.dart`, `lib/features/settings/presentation/screens/settings_screen.dart`.

---

### [USER-01] Get Patron Profile
* **Status**: `[IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Method**: `GET`
* **Endpoint**: `/api/v1/users/profile`
* **Auth Required**: Yes (`Authorization: Bearer <TOKEN>`)
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "User profile retrieved.",
    "data": {
      "user": {
        "id": "67039a48b71d4a001234abcd",
        "name": "Rihan Saifi",
        "phone": "+919876543210",
        "role": "CUSTOMER",
        "tier": "Privilege Member",
        "kyc": {
          "isVerified": true,
          "documentType": "AADHAAR",
          "documentNumberMasked": "XXXX XXXX 3210",
          "documentUrl": "https://res.cloudinary.com/swastik/image/upload/kyc/kyc-123456.jpg",
          "status": "VERIFIED",
          "referenceId": "KYC-481920"
        },
        "createdAt": "2026-09-15T12:00:00.000Z"
      }
    }
  }
  ```
* **Frontend Usage**: `lib/features/settings/data/repositories/profile_repository_impl.dart`, `HeaderNavBar`, `KittyMenuSheet`.

---

### [USER-02] Update Patron Profile
* **Status**: `[REQUIRED / NOT CURRENTLY IMPLEMENTED]`
* **Method**: `PUT`
* **Endpoint**: `/api/v1/users/profile`
* **Auth Required**: Yes (`Authorization: Bearer <TOKEN>`)
* **Request Body**:
  ```json
  {
    "name": "Rihan",
    "surname": "Saifi",
    "email": "rihan@swastik.in",
    "dateOfBirth": "1995-08-15T00:00:00.000Z"
  }
  ```
* **Validation**: Name min 2 chars; valid email format; phone cannot be modified through profile update.
* **Expected Response (`200 OK`)**: Updated profile data object.
* **Frontend Usage**: `lib/features/settings/data/repositories/profile_repository_impl.dart`, `RegisterProfileScreen`.

---

### [KYC-01] Submit KYC Statutory Verification
* **Status**: `[IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Method**: `POST`
* **Endpoint**: `/api/v1/users/kyc`
* **Auth Required**: Yes (`Authorization: Bearer <TOKEN>`)
* **Content-Type**: `multipart/form-data`
* **Form Fields**:
  * `documentType`: Required string, `'AADHAAR'` or `'PAN'`.
  * `documentNumber`: Required string. 12 numeric digits for Aadhaar; 10 alphanumeric (`^[A-Z]{5}[0-9]{4}[A-Z]{1}$`) for PAN.
  * `consentAgreed`: Required boolean / string `'true'`.
  * `file`: Required file (JPEG, PNG, or PDF; max 10MB).
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "KYC document submitted successfully.",
    "data": {
      "referenceId": "KYC-582194",
      "status": "PENDING",
      "documentType": "AADHAAR",
      "documentNumberMasked": "XXXX XXXX 3210",
      "documentUrl": "https://res.cloudinary.com/swastik/image/upload/kyc/kyc-582194.jpg"
    }
  }
  ```
* **Frontend Usage**: `lib/features/kyc/presentation/screens/kyc_screen.dart`.

---

### [SCHEME-01] List Active Gold Savings Schemes
* **Status**: `[IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Method**: `GET`
* **Endpoint**: `/api/v1/schemes/active`
* **Auth Required**: No (Public)
* **Query Parameters**:
  * `duration`: Optional integer (e.g. `12`).
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Active schemes retrieved.",
    "data": {
      "schemes": [
        {
          "id": "67039a48b71d4a0012341001",
          "name": "Swastik Royal Gold Kitty (11+1)",
          "targetAmount": 120000,
          "durationMonths": 12,
          "monthlyInstallment": 10000,
          "maxCapacity": 50,
          "currentMembers": 28,
          "status": "OPEN",
          "benefits": [
            "1 Month Free: 11 Paid + 12th Month 100% Jeweler Bonus",
            "25% Flat Discount on Jewellery Making Charges",
            "Accumulate 24K 999 Hallmark Purity Gold"
          ],
          "bannerImageUrl": "assets/images/kitty_banner_royal_gold.jpg",
          "isPopular": true
        }
      ]
    }
  }
  ```
* **Frontend Usage**: `lib/features/offers/presentation/screens/offers_screen.dart`, `HomeGoldSchemesList`.

---

### [SCHEME-02] Get Kitty Numbers Availability Matrix (01–50)
* **Status**: `[REQUIRED / NOT CURRENTLY IMPLEMENTED]`
* **Method**: `GET`
* **Endpoint**: `/api/v1/schemes/:id/numbers`
* **Auth Required**: Yes (`Authorization: Bearer <TOKEN>`)
* **Path Parameter**: `id` (Scheme Mongo ID).
* **Expected Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Scheme number slots retrieved.",
    "data": {
      "schemeId": "67039a48b71d4a0012341001",
      "totalSlots": 50,
      "numbers": [
        { "number": 1, "label": "01", "status": "BOOKED", "chitToken": "SW-ROYAL-001" },
        { "number": 7, "label": "07", "status": "AVAILABLE", "chitToken": "SW-ROYAL-007" },
        { "number": 12, "label": "12", "status": "HELD", "heldUntil": "2026-10-07T12:45:00.000Z" }
      ]
    }
  }
  ```
* **Frontend Usage**: `lib/features/offers/presentation/widgets/kitty_number_picker_sheet.dart`.

---

### [SCHEME-03] Enroll in Scheme / Join Kitty
* **Status**: `[IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Method**: `POST`
* **Endpoint**: `/api/v1/memberships/join`
* **Auth Required**: Yes (`Authorization: Bearer <TOKEN>`)
* **Request Body**:
  ```json
  {
    "schemeId": "67039a48b71d4a0012341001",
    "joinedAtMonth": 1,
    "selectedNumber": 7
  }
  ```
* **Validation**:
  * `schemeId`: Required valid Mongo ID.
  * User must have verified KYC (or pending in test).
  * Scheme must be OPEN and `currentMembers < maxCapacity`.
* **Success Response (`201 Created`)**:
  ```json
  {
    "success": true,
    "message": "Enrolled in scheme successfully.",
    "data": {
      "membership": {
        "id": "67039a48b71d4a0012349001",
        "schemeId": "67039a48b71d4a0012341001",
        "schemeName": "Swastik Royal Gold Kitty (11+1)",
        "tokenNumber": 7,
        "chitToken": "SW-ROYAL-007",
        "customMonthlyEmi": 10000,
        "targetAmount": 120000,
        "totalPaidAmount": 0,
        "status": "ACTIVE",
        "joinedAtMonth": 1
      }
    }
  }
  ```
* **Frontend Usage**: `lib/features/offers/presentation/screens/review_plan_screen.dart`, `OffersEnrollmentDialog`.

---

### [DASHBOARD-01] Get My Plan Dashboard & Passbook
* **Status**: `[IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Method**: `GET`
* **Endpoint**: `/api/v1/memberships/my-dashboard`
* **Auth Required**: Yes (`Authorization: Bearer <TOKEN>`)
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Dashboard data retrieved.",
    "data": {
      "hasActiveScheme": true,
      "dashboard": {
        "membershipId": "67039a48b71d4a0012349001",
        "chitToken": "SW-ROYAL-007",
        "schemeName": "Swastik Royal Gold Kitty (11+1)",
        "targetAmount": 120000,
        "customMonthlyEmi": 10000,
        "totalMonths": 12,
        "monthsPaid": 8,
        "totalPaidAmount": 80000,
        "remainingAmount": 30000,
        "accumulatedGoldGrams": 10.688,
        "currentValuation": 80000,
        "valuationGainPct": 0.0,
        "nextInstallment": {
          "month": 9,
          "amount": 10000,
          "dueDate": "2026-10-15T00:00:00.000Z",
          "daysRemaining": 8
        },
        "passbook": [
          {
            "month": 1,
            "label": "Month 1",
            "amount": 10000,
            "status": "PAID",
            "paidAt": "2026-02-14T10:30:00.000Z",
            "paymentMethod": "ONLINE",
            "transactionId": "TXN-SW-90011",
            "goldGrams": 1.336,
            "receiptUrl": "https://res.cloudinary.com/swastik/image/upload/receipts/rec_1.pdf"
          },
          {
            "month": 9,
            "label": "Month 9",
            "amount": 10000,
            "status": "CURRENT",
            "dueDate": "2026-10-15T00:00:00.000Z"
          },
          {
            "month": 10,
            "label": "Month 10",
            "amount": 10000,
            "status": "UPCOMING",
            "dueDate": "2026-11-15T00:00:00.000Z"
          },
          {
            "month": 12,
            "label": "Month 12",
            "amount": 10000,
            "status": "BONUS",
            "bonusNote": "100% Jeweler Bonus Deposit on completion"
          }
        ]
      }
    }
  }
  ```
* **Frontend Usage**: `lib/features/dashboard/presentation/screens/dashboard_screen.dart`, `PassbookScreen`, `HomeActiveKittyCard`.

---

### [RATE-01] Get Live Benchmark Gold Rate
* **Status**: `[IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Method**: `GET`
* **Endpoint**: `/api/v1/rates/gold`
* **Auth Required**: No (Public)
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Live gold rates retrieved.",
    "data": {
      "rate24k": 7485.50,
      "rate22k": 6860.00,
      "rateChangePct": 0.62,
      "unit": "1 gram",
      "currency": "INR",
      "benchmark": "IBJA Official",
      "updatedAt": "2026-10-07T06:30:00.000Z"
    }
  }
  ```
* **Frontend Usage**: `HomeGoldRateStrip`, `LiveRatesScreen`, `CalculatorScreen`, `CoinRatesScreen`.

---

### [RATE-02] Admin Update Daily Gold Rate
* **Status**: `[IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Method**: `POST`
* **Endpoint**: `/api/v1/admin/rates/gold`
* **Auth Required**: Yes (`ADMIN` / `SUPER_ADMIN` role)
* **Request Body**:
  ```json
  {
    "rate24k": 7520.00,
    "rate22k": 6890.00,
    "benchmark": "IBJA Official"
  }
  ```
* **Success Response (`200 OK`)**: Updated rate object.

---

### [PAY-01] Initiate Payment Order (GoKwik)
* **Status**: `[IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Method**: `POST`
* **Endpoint**: `/api/v1/payments/initiate`
* **Auth Required**: Yes (`Authorization: Bearer <TOKEN>`)
* **Request Body**:
  ```json
  {
    "membershipId": "67039a48b71d4a0012349001",
    "monthFor": 9,
    "paymentMethod": "ONLINE"
  }
  ```
* **Multi-Month Extension Required**: Backend should accept `months: [9, 10]` to generate single order covering multiple consecutive months.
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
* **Frontend Usage**: `lib/features/checkout/presentation/screens/checkout_screen.dart`.

---

### [PAY-02] Poll Payment Status
* **Status**: `[IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Method**: `GET`
* **Endpoint**: `/api/v1/payments/status/:orderId`
* **Auth Required**: Yes (`Authorization: Bearer <TOKEN>`)
* **Path Parameter**: `orderId` (e.g. `ORD-SW-9001-M9`).
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
* **Frontend Usage**: `CheckoutScreen` (status polling dialog).

---

### [PAY-03] Payment Webhook (GoKwik Gateway)
* **Status**: `[IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Method**: `POST`
* **Endpoint**: `/api/v1/payments/webhook`
* **Auth Required**: No (Cryptographic HMAC-SHA256 signature in `x-gokwik-signature` header)
* **Request Body**: GoKwik payment notification payload.
* **Behavior**:
  * Verifies HMAC signature.
  * Idempotently marks payment `SUCCESS`.
  * Computes accumulated gold grams based on live rate at moment of payment.
  * Updates membership ledger.
* **Success Response (`200 OK`)**: `{"success": true, "message": "Webhook processed successfully."}`

---

### [PAY-04] Request Doorstep Cash Pickup ("Pick Cash")
* **Status**: `[REQUIRED / NOT CURRENTLY IMPLEMENTED]`
* **Method**: `POST`
* **Endpoint**: `/api/v1/payments/cash-pickup-request`
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
* **Expected Response (`201 Created`)**:
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
* **Frontend Usage**: `lib/features/checkout/presentation/screens/cash_pickup_screen.dart`.

---

### [BOOK-01] Create Booking (Coins / Jewellery / Scheme Reserve)
* **Status**: `[REQUIRED / NOT CURRENTLY IMPLEMENTED]`
* **Method**: `POST`
* **Endpoint**: `/api/v1/bookings`
* **Auth Required**: Yes (`Authorization: Bearer <TOKEN>`)
* **Request Body**:
  ```json
  {
    "category": "COINS",
    "itemName": "4g Gold Coin 24K (999)",
    "karat": "24K",
    "weightGrams": 4.0,
    "unitPrice": 29942,
    "quantity": 1,
    "totalAmount": 29942,
    "notes": "Booked from App"
  }
  ```
* **Expected Response (`201 Created`)**:
  ```json
  {
    "success": true,
    "message": "Booking confirmed.",
    "data": {
      "bookingId": "BKG-SW-50291",
      "category": "COINS",
      "itemName": "4g Gold Coin 24K (999)",
      "totalAmount": 29942,
      "status": "CONFIRMED",
      "createdAt": "2026-10-07T12:00:00.000Z"
    }
  }
  ```
* **Frontend Usage**: `lib/features/coin_rates/presentation/screens/coin_rates_screen.dart` (Book Now CTA).

---

### [BOOK-02] Get Patron Orders & Bookings History
* **Status**: `[REQUIRED / NOT CURRENTLY IMPLEMENTED]`
* **Method**: `GET`
* **Endpoint**: `/api/v1/bookings`
* **Auth Required**: Yes (`Authorization: Bearer <TOKEN>`)
* **Query Parameters**:
  * `category`: Optional filter (`SCHEMES` | `COINS` | `JEWELLERY`).
* **Expected Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Bookings retrieved.",
    "data": {
      "bookings": [
        {
          "id": "BKG-SW-50291",
          "category": "COINS",
          "itemName": "4g Gold Coin 24K (999)",
          "weightGrams": 4.0,
          "totalAmount": 29942,
          "status": "CONFIRMED",
          "createdAt": "2026-10-07T12:00:00.000Z"
        }
      ]
    }
  }
  ```
* **Frontend Usage**: `lib/features/orders/presentation/screens/orders_screen.dart`.

---

### [NOTIF-01] Get In-App Notifications Feed
* **Status**: `[REQUIRED / NOT CURRENTLY IMPLEMENTED]`
* **Method**: `GET`
* **Endpoint**: `/api/v1/notifications`
* **Auth Required**: Yes (`Authorization: Bearer <TOKEN>`)
* **Expected Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Notifications retrieved.",
    "data": {
      "unreadCount": 2,
      "notifications": [
        {
          "id": "NTF-101",
          "title": "EMI Installment Due",
          "body": "Month 9 installment of ₹10,000 for Swastik Royal Gold is due on Oct 15.",
          "type": "EMI_DUE",
          "isRead": false,
          "actionRoute": "/checkout",
          "createdAt": "2026-10-06T09:00:00.000Z"
        }
      ]
    }
  }
  ```
* **Frontend Usage**: `lib/features/notifications/presentation/screens/notifications_screen.dart`.

---

### [NOTIF-02] Mark Notifications As Read
* **Status**: `[REQUIRED / NOT CURRENTLY IMPLEMENTED]`
* **Method**: `PATCH`
* **Endpoint**: `/api/v1/notifications/read-all` (or `/:id/read`)
* **Auth Required**: Yes (`Authorization: Bearer <TOKEN>`)
* **Expected Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Notifications marked as read.",
    "data": { "unreadCount": 0 }
  }
  ```
* **Frontend Usage**: `NotificationsScreen`.
