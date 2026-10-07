# Frontend ↔ Backend Integration Matrix

**Project**: Swastik Jewellers Kitty Savings App  
**Location**: `kitty_frontend/kitty_docs/05_Backend/FRONTEND_BACKEND_INTEGRATION_MATRIX.md`  
**Status**: Authoritative Master Integration Table  

---

## 1. Complete Feature Integration Matrix

The following table maps every Flutter client feature to its corresponding REST API endpoint, required HTTP method, authorization level, backend implementation status in `Swastik_kitty_backend`, and engineering notes.

| # | Flutter Feature | API Endpoint | Method | Auth | Backend Status | Implementation Notes |
| :-: | :--- | :--- | :---: | :---: | :---: | :--- |
| **1** | **Send OTP** | `/api/v1/auth/send-otp` | `POST` | Public | 🟢 **EXISTING** | Validates Indian phone; rate-limits 3/15min; bypass phone `+919876543210` with OTP `123456`. |
| **2** | **Verify OTP & Login** | `/api/v1/auth/verify-otp` | `POST` | Public | 🟢 **EXISTING** | Verifies OTP; auto-creates User document; returns Bearer JWT (30d expiry). |
| **3** | **Google Sign-In** | `/api/v1/auth/google` | `POST` | Public | 🔴 **MISSING** | Required for Google button on login screen; backend needs Google ID token validation. |
| **4** | **Logout** | `/api/v1/auth/logout` | `POST` | Bearer | 🟢 **EXISTING** | Purges session; client wipes local `FlutterSecureStorage`. |
| **5** | **Get Patron Profile** | `/api/v1/users/profile` | `GET` | Bearer | 🟢 **EXISTING** | Returns name, phone, tier, KYC verification status. |
| **6** | **Update Patron Profile** | `/api/v1/users/profile` | `PUT` | Bearer | 🔴 **MISSING** | Updates name, surname, email, DOB. Phone is immutable. (Currently mocked in Flutter repo). |
| **7** | **Submit KYC Documents** | `/api/v1/users/kyc` | `POST` | Bearer | 🟢 **EXISTING** | Multipart upload; validates Aadhaar (12-digit) or PAN (10-char); streams to Cloudinary; status `PENDING`. |
| **8** | **Admin Review KYC** | `/api/v1/admin/kyc/:userId` | `PATCH` | Admin | 🟢 **EXISTING** | Approves or rejects patron KYC (`VERIFIED` / `REJECTED`). |
| **9** | **List Active Schemes** | `/api/v1/schemes/active` | `GET` | Public | 🟢 **EXISTING** | Returns schemes catalog (11+1 benefits, installment, capacity, image). |
| **10** | **Admin Create Scheme** | `/api/v1/schemes` | `POST` | Admin | 🟢 **EXISTING** | Creates new gold kitty savings scheme. |
| **11** | **Kitty Number Grid (01–50)** | `/api/v1/schemes/:id/numbers` | `GET` | Bearer | 🔴 **MISSING** | Real-time availability for lucky numbers 01 to 50 (`AVAILABLE`, `BOOKED`, `HELD`). |
| **12** | **Join Scheme / Enroll** | `/api/v1/memberships/join` | `POST` | Bearer | 🟢 **EXISTING** | Checks KYC (`403` if unverified); prevents duplicate (`409`); computes dynamic EMI for late joiners. |
| **13** | **My Plan Dashboard & Passbook** | `/api/v1/memberships/my-dashboard` | `GET` | Bearer | 🟢 **EXISTING** | Returns active scheme summary, months paid, gold grams, valuation, next installment, passbook. |
| **14** | **Multi-Scheme Array** | `/api/v1/memberships/my-schemes` | `GET` | Bearer | 🟡 **NEEDS MOD** | Needed when patron holds multiple active schemes; returns array of scheme dashboards. |
| **15** | **Live Gold Rates** | `/api/v1/rates/gold` | `GET` | Public | 🟢 **EXISTING** | Returns 24K and 22K per gram rate, change percentage, timestamp. Subordinate karats derived on client. |
| **16** | **Admin Update Rates** | `/api/v1/admin/rates/gold` | `POST` | Admin | 🟢 **EXISTING** | Publishes daily IBJA gold rate. |
| **17** | **Gold Coins Catalog** | `/api/v1/coins` | `GET` | Public | 🔴 **MISSING** | Returns direct 4g, 5g coins and mint options. (Currently computed dynamically from live rates). |
| **18** | **Coin / Order Booking** | `/api/v1/bookings` | `POST` | Bearer | 🔴 **MISSING** | Records bullion/jewellery reservation in database for physical store pickup. |
| **19** | **Get Orders History** | `/api/v1/bookings` | `GET` | Bearer | 🔴 **MISSING** | Returns list of past bookings filtered by Schemes, Coins, Jewellery. |
| **20** | **Gold Calculator** | *N/A (Client Math)* | *N/A* | None | 🟢 **CLIENT ONLY** | Valuation computed 100% client-side using live rates from `GET /rates/gold`. Zero backend API required. |
| **21** | **Initiate Payment (Single)** | `/api/v1/payments/initiate` | `POST` | Bearer | 🟢 **EXISTING** | Creates GoKwik checkout order for single installment month (`monthFor: 9`). |
| **22** | **Initiate Payment (Multi-Month)** | `/api/v1/payments/initiate` | `POST` | Bearer | 🟡 **NEEDS MOD** | Backend needs to accept `months: [9, 10]` array to generate single order covering multiple months. |
| **23** | **Poll Payment Status** | `/api/v1/payments/status/:orderId` | `GET` | Bearer | 🟢 **EXISTING** | Checks status (`PENDING`, `SUCCESS`, `FAILED`); returns transaction details. |
| **24** | **Payment Webhook** | `/api/v1/payments/webhook` | `POST` | HMAC | 🟢 **EXISTING** | Verifies GoKwik HMAC-SHA256 signature; updates membership ledger; generates PDFKit receipt. |
| **25** | **Doorstep Cash Pickup** | `/api/v1/payments/cash-pickup-request` | `POST` | Bearer | 🔴 **MISSING** | Requests executive visit for cash EMI collection with verification OTP. |
| **26** | **Admin Record Cash Payment** | `/api/v1/admin/payments/record-cash` | `POST` | Admin | 🟢 **EXISTING** | Counter staff records cash installment receipt. |
| **27** | **Notifications Feed** | `/api/v1/notifications` | `GET` | Bearer | 🔴 **MISSING** | Returns unread count and list of transaction/EMI alerts. |
| **28** | **Mark Notifications Read** | `/api/v1/notifications/read-all` | `PATCH` | Bearer | 🔴 **MISSING** | Marks notifications as read. |
| **29** | **Jewellery Showroom** | *N/A (In-App WebView)* | *N/A* | None | 🟢 **CLIENT ONLY** | Direct embedded web bridge to official Swastik website via `webview_flutter`. |
