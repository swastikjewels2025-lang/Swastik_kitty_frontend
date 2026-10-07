# Backend Gap Analysis & Implementation Roadmap

**Project**: Swastik Jewellers Kitty Savings App  
**Target Backend**: `D:\Kitty_backend\Swastik_kitty_backend\`  
**Target Mobile Client**: `D:\kitty_app\`  
**Location**: `kitty_frontend/kitty_docs/05_Backend/BACKEND_GAP_ANALYSIS.md`  
**Status**: Authoritative Gap Analysis for Backend Handover  

---

## 1. Executive Summary: Current Backend vs. Required Backend

An exhaustive audit of `Swastik_kitty_backend` compared against the approved production Flutter client (`kitty_app`) reveals:
* **16 Endpoints Are Already Available & Working** (Health, Send OTP, Verify OTP, Logout, Profile GET, KYC POST, Active Schemes GET, Create Scheme POST, Join Scheme POST, My Dashboard GET, Live Gold Rates GET, Admin Rates POST, Initiate Single Payment POST, Payment Status GET, Payment Webhook POST, Admin Cash Payment POST, Admin KYC PATCH, Admin Winner POST).
* **2 Endpoints Need Modification** (Payment Initiation for Multi-Month orders, Dashboard for Multi-Scheme array).
* **7 Endpoints Are Missing** (Google Auth exchange, Profile Update, Scheme Numbers availability grid, Coins catalog, Bookings/Orders CRUD, Doorstep Cash Pickup request, Notifications feed).
* **2 Explicit Mismatches Documented** (Profile update route, Single-month vs multi-month payment payload).

---

## 2. Categorized Inventory

### 2.1 Category 1: Already Available & 100% Matched
These endpoints are fully implemented in `Swastik_kitty_backend` and ready for immediate end-to-end testing:

1. `GET /api/v1/health` — Service health & database connectivity check.
2. `POST /api/v1/auth/send-otp` — Indian phone OTP dispatch with rate limiting.
3. `POST /api/v1/auth/verify-otp` — OTP validation, auto user registration, JWT generation.
4. `POST /api/v1/auth/logout` — Session revocation.
5. `GET /api/v1/users/profile` — Patron profile and KYC verification status.
6. `POST /api/v1/users/kyc` — Multipart Aadhaar/PAN upload with format validation.
7. `GET /api/v1/schemes/active` — Public active gold savings schemes listing.
8. `POST /api/v1/schemes` — Admin scheme creation.
9. `POST /api/v1/memberships/join` — Scheme enrollment with dynamic late-joiner EMI math.
10. `GET /api/v1/memberships/my-dashboard` — Full active scheme summary and 12-month passbook timeline.
11. `GET /api/v1/rates/gold` — Live 24K and 22K IBJA gold rates.
12. `POST /api/v1/admin/rates/gold` — Admin daily rate publishing.
13. `POST /api/v1/payments/initiate` — GoKwik single-month payment order creation.
14. `GET /api/v1/payments/status/:orderId` — Payment status polling.
15. `POST /api/v1/payments/webhook` — GoKwik HMAC-SHA256 signed payment webhook.
16. `POST /api/v1/admin/payments/record-cash` — Counter staff cash receipt logging.
17. `PATCH /api/v1/admin/kyc/:userId` — Admin KYC approval/rejection.
18. `POST /api/v1/admin/draw/record-winner` — Admin lucky draw winner selection.

---

### 2.2 Category 2: Needs Modification

#### [MOD-01] Payment Initiation Multi-Month Support
* **Current Backend**: Accepts only single integer `monthFor: 9`.
* **Frontend Requirement**: Users can select multiple consecutive installments in checkout (e.g. Month 9 and Month 10).
* **Modification Needed**: In `src/controllers/payment.controller.js` and `src/services/payment.service.js`, accept `months: [9, 10]` array in addition to `monthFor`. Calculate `totalAmount = months.length * customMonthlyEmi`.
* **Priority**: **HIGH** (Required for multi-month checkout feature).

#### [MOD-02] Dashboard Support for Multiple Active Schemes
* **Current Backend**: Returns single `membership` in `my-dashboard`.
* **Frontend Requirement**: Patrons holding more than one active scheme can view swipeable cards.
* **Modification Needed**: Extend `my-dashboard` or provide `GET /api/v1/memberships/my-schemes` returning `{ hasActiveSchemes: true, memberships: [...] }`.
* **Priority**: **MEDIUM** (Required when user enrolls in a 2nd scheme).

---

### 2.3 Category 3: Frontend / Backend Mismatches

#### [MIS-01] Patron Profile Update Route
* **Frontend Expectation**: `PUT /api/v1/users/profile` to update name, surname, email, DOB.
* **Backend Status**: No update endpoint exposed in `src/routes/user.routes.js`.
* **Current Client State**: Handled safely in `ProfileRepositoryImpl` with local copy fallback so app does not crash.
* **Resolution**: Add `PUT /api/v1/users/profile` in `user.routes.js`.

#### [MIS-02] Single-Month vs Multi-Month Payment Payload
* **Frontend Expectation**: Sends `months: [9, 10]` to pay multiple installments.
* **Backend Status**: Schema strictly expects `monthFor: Number`.
* **Resolution**: Support both `months: Array` and `monthFor: Number` gracefully in backend.

---

## 3. Detailed Specification for Missing Endpoints

---

### GAP 1: Patron Profile Update
* **Why Frontend Needs It**: Users updating their personal details in onboarding (`RegisterProfileScreen`) or settings (`KittyMenuSheet`).
* **Expected Endpoint**: `PUT /api/v1/users/profile`
* **HTTP Method**: `PUT` (or `PATCH`)
* **Auth**: Bearer JWT (`req.user._id`)
* **Expected Request**:
  ```json
  {
    "name": "Rihan",
    "surname": "Saifi",
    "email": "rihan@swastik.in",
    "dateOfBirth": "1995-08-15T00:00:00.000Z"
  }
  ```
* **Expected Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Profile updated successfully.",
    "data": {
      "user": {
        "id": "67039a48b71d4a001234abcd",
        "name": "Rihan Saifi",
        "phone": "+919876543210",
        "email": "rihan@swastik.in",
        "role": "CUSTOMER",
        "tier": "Standard Member"
      }
    }
  }
  ```
* **Validation**: Name min 2 chars; valid email pattern; phone cannot be altered.
* **Priority**: **HIGH**

---

### GAP 2: Google Sign-In Exchange
* **Why Frontend Needs It**: Login screen features a prominent "Sign in with Google" button.
* **Expected Endpoint**: `POST /api/v1/auth/google`
* **HTTP Method**: `POST`
* **Auth**: Public
* **Expected Request**:
  ```json
  {
    "idToken": "eyJhbGciOiJSUzI1NiIsImtpZCI6Ij...",
    "email": "patron@gmail.com",
    "name": "Rihan Saifi"
  }
  ```
* **Expected Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Authentication successful.",
    "data": {
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "isNewUser": false,
      "user": { ... }
    }
  }
  ```
* **Validation**: Verify signature using `google-auth-library`.
* **Priority**: **MEDIUM**

---

### GAP 3: Scheme Numbers Availability Grid (01–50)
* **Why Frontend Needs It**: The enrollment flow includes `KittyNumberPickerSheet` where patrons select their lucky chit token number from a 50-slot grid.
* **Expected Endpoint**: `GET /api/v1/schemes/:id/numbers`
* **HTTP Method**: `GET`
* **Auth**: Bearer JWT
* **Path Parameter**: `id` (Scheme Mongo ID)
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
        { "number": 2, "label": "02", "status": "AVAILABLE" },
        { "number": 7, "label": "07", "status": "HELD", "heldUntil": "2026-10-07T13:15:00.000Z" }
      ]
    }
  }
  ```
* **Validation**: Ensure numbers 1 to 50 are represented; lock slots to `HELD` for 15 minutes during enrollment.
* **Priority**: **HIGH**

---

### GAP 4: Gold Coins Catalog & Dynamic Inventory
* **Why Frontend Needs It**: The Gold Coins screen (`coin_rates_screen.dart`) displays 4g, 5g, and custom minted coin options.
* **Expected Endpoint**: `GET /api/v1/coins`
* **HTTP Method**: `GET`
* **Auth**: Public
* **Expected Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Coins catalog retrieved.",
    "data": {
      "coins": [
        {
          "id": "COIN-4G-999",
          "name": "4g 24K Gold Coin",
          "purity": "24K (999)",
          "purityFraction": 1.0,
          "weightGrams": 4.0,
          "inStock": true,
          "makingCharges": 0,
          "imageUrl": "assets/images/gold-coins.jpg"
        }
      ]
    }
  }
  ```
* **Priority**: **LOW** (Frontend already computes live prices accurately using `GET /rates/gold`).

---

### GAP 5: Bookings & Orders (Create & History)
* **Why Frontend Needs It**: Booking bullion coins from the app or viewing past orders in `OrdersScreen`.
* **Expected Endpoints**:
  * `POST /api/v1/bookings` (Create booking)
  * `GET /api/v1/bookings` (List patron bookings)
* **HTTP Method**: `POST` / `GET`
* **Auth**: Bearer JWT
* **Expected Request (`POST`)**:
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
      "status": "CONFIRMED",
      "totalAmount": 29942,
      "createdAt": "2026-10-07T12:00:00.000Z"
    }
  }
  ```
* **Priority**: **MEDIUM**

---

### GAP 6: Doorstep Cash Pickup Request ("Pick Cash")
* **Why Frontend Needs It**: Patrons who prefer paying installments in cash can request doorstep collection from `CashPickupScreen`.
* **Expected Endpoint**: `POST /api/v1/payments/cash-pickup-request`
* **HTTP Method**: `POST`
* **Auth**: Bearer JWT
* **Expected Request**:
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
* **Priority**: **MEDIUM**

---

### GAP 7: In-App Notifications Feed
* **Why Frontend Needs It**: In-app notifications feed (`NotificationsScreen`) and header bell badge with unread count.
* **Expected Endpoints**:
  * `GET /api/v1/notifications` (List notifications)
  * `PATCH /api/v1/notifications/:id/read` (Mark one read)
  * `PATCH /api/v1/notifications/read-all` (Mark all read)
* **Auth**: Bearer JWT
* **Expected Response (`GET`)**:
  ```json
  {
    "success": true,
    "message": "Notifications retrieved.",
    "data": {
      "unreadCount": 1,
      "notifications": [
        {
          "id": "NTF-101",
          "title": "Monthly Installment Due",
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
* **Priority**: **LOW** (Currently backed by clean mock repository).

---

## 4. Priority Implementation Order for Backend Engineer

```
MILESTONE 1 (High Priority - Immediate Integration):
1. [GAP 1] Implement PUT /api/v1/users/profile (Profile update)
2. [GAP 3] Implement GET /api/v1/schemes/:id/numbers (Kitty numbers 01–50 grid)
3. [MOD-01] Extend POST /api/v1/payments/initiate to accept `months: [9, 10]`

MILESTONE 2 (Medium Priority - Enhanced Flows):
4. [GAP 2] Implement POST /api/v1/auth/google (Google OAuth exchange)
5. [GAP 5] Implement POST & GET /api/v1/bookings (Bullion/coin bookings)
6. [GAP 6] Implement POST /api/v1/payments/cash-pickup-request (Doorstep cash pickup)
7. [MOD-02] Support multi-scheme array in my-dashboard

MILESTONE 3 (Low Priority - Engagement & Polish):
8. [GAP 7] Implement /api/v1/notifications endpoints
9. [GAP 4] Implement /api/v1/coins inventory endpoints
```
