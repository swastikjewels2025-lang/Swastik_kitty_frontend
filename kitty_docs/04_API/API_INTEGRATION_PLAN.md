# API Integration Plan

## 1. Overview & Architectural Notice
This document defines the exact contract of all RESTful APIs expected by the **Kitty App Frontend**. 
* **Crucial Rule:** The frontend developer will **not** build the backend or alter backend logic.
* Details that must be finalized or configured by the backend engineer are explicitly marked as **`BACKEND DEVELOPER TO DEFINE`**.
* Placeholder endpoints for undeclared services are marked as **`TBD`**.

---

## 2. API Dependency Catalog

### 2.1 Authentication Module (`/api/auth`)

#### API 1.1: Send Mobile OTP
* **Feature:** Authentication / Phone Login
* **Screen:** Login Screen (`login.html` - View 1)
* **API Purpose:** Dispatches a 6-digit one-time password via SMS to the provided phone number.
* **HTTP Method:** `POST`
* **Endpoint:** `/api/auth/send-otp`
* **Authentication Required:** No (Public)
* **Request Headers:** `Content-Type: application/json`
* **Request Body:**
  ```json
  {
    "phone": "+919876543210"
  }
  ```
* **Response Expected by UI (200 OK):**
  ```json
  {
    "success": true,
    "message": "OTP sent successfully to your mobile number.",
    "expiresInSeconds": 300
  }
  ```
* **Error Cases:**
  - `400 Bad Request`: Invalid phone format (`"Phone number must be a valid 10-digit Indian mobile number"`).
  - `429 Too Many Requests`: Rate limit exceeded (`"Too many OTP requests. Please wait 2 minutes."`).
  - `500 Internal Server Error`: SMS Gateway failure (`"Unable to deliver SMS. Please try again later."`).
* **Loading Behavior:** Submit button enters loading state with spinner; input field disabled during dispatch.
* **Retry Behavior:** User can tap "Resend OTP" after 30-second countdown expires.
* **Cache Requirement:** None.

---

#### API 1.2: Verify Mobile OTP
* **Feature:** Authentication / Verification
* **Screen:** Login Screen (`login.html` - View 2)
* **API Purpose:** Validates the 6-digit OTP, creates a user record if first-time sign-in, and returns a signed JWT.
* **HTTP Method:** `POST`
* **Endpoint:** `/api/auth/verify-otp`
* **Authentication Required:** No (Public)
* **Request Headers:** `Content-Type: application/json`
* **Request Body:**
  ```json
  {
    "phone": "+919876543210",
    "otp": "123456"
  }
  ```
* **Response Expected by UI (200 OK):**
  ```json
  {
    "success": true,
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
        "documentUrl": "https://res.cloudinary.com/swastik/image/upload/kyc_docs/doc_123.jpg"
      }
    }
  }
  ```
* **Error Cases:**
  - `400 Bad Request`: Invalid or expired OTP (`"Incorrect OTP entered. Please try again."`).
  - `404 Not Found`: Session expired or phone mismatch.
* **Loading Behavior:** Screen displays inline validating loader; digit boxes disabled.
* **Retry Behavior:** User re-types incorrect digits; error message displayed in red below grid.
* **Cache Requirement:** Token and user profile stored in platform `SecureStorage`.

---

### 2.2 User & KYC Module (`/api/users`)

#### API 2.1: Submit KYC Document
* **Feature:** KYC Verification & Compliance
* **Screen:** KYC Screen (`kyc.html`)
* **API Purpose:** Uploads document image to Cloudinary and updates user's KYC record in MongoDB.
* **HTTP Method:** `POST`
* **Endpoint:** `/api/users/kyc`
* **Authentication Required:** Yes (`Bearer <token>`)
* **Request Headers:** `Content-Type: multipart/form-data`
* **Request Data (Form-Data):**
  - `documentType`: String (`"AADHAAR"` | `"PAN"`)
  - `documentNumber`: String (e.g. `"123456789012"` or `"ABCDE1234F"`)
  - `consentAgreed`: Boolean (`true`)
  - `file`: Binary File (JPG / PNG / PDF, max 10MB)
* **Response Expected by UI (200 OK / 201 Created):**
  ```json
  {
    "success": true,
    "message": "KYC documents uploaded successfully and under verification.",
    "referenceId": "KYC-849201",
    "kyc": {
      "documentType": "AADHAAR",
      "documentNumberMasked": "XXXX XXXX 9012",
      "documentUrl": "https://res.cloudinary.com/swastik/image/upload/kyc_docs/aadhar_sample.jpg",
      "isVerified": false,
      "status": "PENDING"
    }
  }
  ```
* **Error Cases:**
  - `400 Bad Request`: File size exceeds 10MB or invalid document number format.
  - `401 Unauthorized`: Token missing or expired.
  - `500 Internal Server Error`: Cloudinary upload timeout.
* **Loading Behavior:** Full-card glassmorphic progress bar showing upload %; submit button disabled.
* **Retry Behavior:** User can tap "Retry Upload" if network connection fails.
* **Cache Requirement:** None.

---

### 2.3 Schemes Module (`/api/schemes`)

#### API 3.1: Get Active Kitty Schemes
* **Feature:** Scheme Discovery & Offers
* **Screen:** Offers Screen (`offers.html`), Home Promo Carousel (`home.html`)
* **API Purpose:** Fetches all currently open schemes available for enrollment.
* **HTTP Method:** `GET`
* **Endpoint:** `/api/schemes/active`
* **Authentication Required:** Optional / Yes (`Bearer <token>`)
* **Query Parameters:**
  - `category`: String (optional: `12_MONTH`, `6_MONTH`, `18_MONTH`) - **BACKEND DEVELOPER TO DEFINE**
* **Response Expected by UI (200 OK):**
  ```json
  {
    "success": true,
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
      },
      {
        "id": "sch_6month_dhanteras",
        "name": "Dhanteras Labh",
        "targetAmount": 60000,
        "durationMonths": 6,
        "monthlyInstallment": 10000,
        "maxCapacity": 50,
        "currentMembers": 28,
        "status": "OPEN",
        "benefits": [
          "50% Sponsored Bonus on Month 6",
          "Fast-track festival accumulation for Dhanteras"
        ],
        "bannerImageUrl": "assets/banner_clean_coin.jpg",
        "isPopular": false
      }
    ]
  }
  ```
* **Error Cases:** `500 Server Error` (UI presents fallback cached schemes or retry banner).
* **Loading Behavior:** Shimmer / Skeleton cards for 3 scheme tiles.
* **Retry Behavior:** Pull-to-refresh on offers page.
* **Cache Requirement:** Cache in local memory for 15 minutes.

---

### 2.4 Memberships Module (`/api/memberships`)

#### API 4.1: Join Scheme (Dynamic EMI Late-Joiner Calculation)
* **Feature:** Scheme Enrollment
* **Screen:** Offers Screen Modal (`offers.html`)
* **API Purpose:** Enrolls customer in a scheme; backend dynamically computes `customMonthlyEmi` based on current scheme month.
* **HTTP Method:** `POST`
* **Endpoint:** `/api/memberships/join`
* **Authentication Required:** Yes (`Bearer <token>`)
* **Request Body:**
  ```json
  {
    "schemeId": "sch_12month_suvarna"
  }
  ```
* **Response Expected by UI (201 Created):**
  ```json
  {
    "success": true,
    "message": "Enrolled in Swastik Suvarna Varsha successfully.",
    "membership": {
      "id": "mem_994411",
      "schemeId": "sch_12month_suvarna",
      "schemeName": "Swastik Suvarna Varsha",
      "tokenNumber": 42,
      "targetAmount": 60000,
      "durationMonths": 12,
      "joinedAtMonth": 1,
      "customMonthlyEmi": 5000,
      "totalPaidAmount": 0,
      "status": "ACTIVE",
      "nextDueMonth": 1,
      "nextDueDate": "2026-10-15T00:00:00.000Z"
    }
  }
  ```
* **Error Cases:**
  - `400 Bad Request`: Scheme is full or closed (`"This scheme has reached its maximum capacity."`).
  - `403 Forbidden`: KYC not verified (`"Statutory KYC verification required before joining scheme."`).
* **Loading Behavior:** "Enrol Plan" button changes to spinner; modal blocks dismissal.
* **Retry Behavior:** Error message displayed inside modal sheet.

---

#### API 4.2: Get My Active Dashboard Data
* **Feature:** Core Dashboard & Passbook
* **Screen:** Dashboard (`dashboard.html`), Home (`home.html`), Passbook (`passbook.html`)
* **API Purpose:** Returns consolidated summary of the active membership, progress metrics, and 12-month ledger entries.
* **HTTP Method:** `GET`
* **Endpoint:** `/api/memberships/my-dashboard`
* **Authentication Required:** Yes (`Bearer <token>`)
* **Response Expected by UI (200 OK):**
  ```json
  {
    "success": true,
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
      "membershipStatus": "ACTIVE",
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
  ```
* **Empty Case (No Active Scheme):**
  ```json
  {
    "success": true,
    "hasActiveScheme": false,
    "dashboard": null
  }
  ```
  *(Frontend displays "No Active Kitty Joined" empty state with CTA to `/offers`)*.
* **Loading Behavior:** Full dashboard shimmer skeleton (gauge, cards, buttons).
* **Retry Behavior:** Pull-to-refresh on dashboard screen.
* **Cache Requirement:** Cached locally in `SharedPreferences` for offline passbook viewing.

---

### 2.5 Payments Module (`/api/payments`)

#### API 5.1: Initiate GoKwik Payment
* **Feature:** Installment Checkout
* **Screen:** Payment Checkout Modal (`#payment-modal`)
* **API Purpose:** Creates an order with GoKwik, creates a `PENDING` payment record, and returns order parameters.
* **HTTP Method:** `POST`
* **Endpoint:** `/api/payments/initiate`
* **Authentication Required:** Yes (`Bearer <token>`)
* **Request Body:**
  ```json
  {
    "membershipId": "mem_994411",
    "monthFor": 9,
    "paymentMethod": "ONLINE"
  }
  ```
* **Response Expected by UI (200 OK):**
  ```json
  {
    "success": true,
    "orderId": "gokwik_ord_771829",
    "paymentId": "pay_662819",
    "amount": 5000,
    "currency": "INR",
    "merchantKey": "BACKEND DEVELOPER TO DEFINE",
    "sdkPayload": {
      "app_id": "swastik_jewel_kitty",
      "env": "sandbox"
    }
  }
  ```
* **Error Cases:** `400 Bad Request` (Payment for this month is already paid or pending verification).
* **Loading Behavior:** "Confirm & Pay" button displays animated circular indicator.

---

#### API 5.2: Check Payment Status / Verification Poll
* **Feature:** Payment Reconciliation
* **Screen:** Payment Return / Modal
* **API Purpose:** Polls backend status after GoKwik webview closes to confirm webhook execution.
* **HTTP Method:** `GET`
* **Endpoint:** `/api/payments/status/:orderId`
* **Status:** `BACKEND DEVELOPER TO DEFINE`
* **Authentication Required:** Yes (`Bearer <token>`)
* **Response Expected by UI (200 OK):**
  ```json
  {
    "success": true,
    "status": "SUCCESS",
    "transactionId": "TXN-SW-50291",
    "receiptUrl": "https://res.cloudinary.com/swastik/image/upload/receipts/rec_50291.pdf",
    "updatedTotalPaidAmount": 45000,
    "monthsPaid": 9
  }
  ```
* **Loading Behavior:** Shimmer confirmation overlay: *"Reconciling gold allocation with Swastik Vault..."*
* **Retry Behavior:** Poll every 2 seconds up to 5 times (max 10 seconds).

---

### 2.6 Live Gold Rate Module (`/api/rates`)

#### API 6.1: Get Real-Time Gold Benchmark Rate
* **Feature:** Gold Ticker & Real-time Valuation
* **Screen:** Sticky Header Bar, Home Screen, Dashboard
* **API Purpose:** Delivers latest 24K and 22K per-gram bullion rates based on IBJA benchmark.
* **HTTP Method:** `GET`
* **Endpoint:** `/api/rates/gold`
* **Status:** `BACKEND DEVELOPER TO DEFINE`
* **Authentication Required:** Optional / Public
* **Response Expected by UI (200 OK):**
  ```json
  {
    "success": true,
    "rate24k": 7485.50,
    "rate22k": 6860.00,
    "rateChangePct": 0.62,
    "benchmark": "IBJA Official",
    "updatedAt": "2026-09-15T13:14:41.000Z"
  }
  ```
* **Polling Interval:** Poll once every 5 minutes while app is foregrounded.
