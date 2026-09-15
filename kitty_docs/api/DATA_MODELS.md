# Frontend Data Models

## 1. Overview
This document defines all strongly typed data models required by the Kitty App frontend presentation and state management layers. Fields whose backend structures remain flexible are explicitly marked as `BACKEND CONTRACT TBD`.

---

## 2. Model Definitions

### 2.1 `UserModel`
Represents the authenticated customer profile.
* **Source:** `POST /api/auth/verify-otp`, `GET /api/users/profile`
* **Used by Screens:** Splash, Home, Settings, Navigation Drawer

| Field | Type | Req/Opt | Description |
| :--- | :--- | :---: | :--- |
| `id` | String | Required | Unique MongoDB ObjectId / user identifier. |
| `name` | String | Required | Customer full name (e.g. "Rihan"). |
| `phone` | String | Required | Formatted telephone number (e.g. "+919876543210"). |
| `role` | String | Required | User role: `CUSTOMER`, `ADMIN`, `SUPER_ADMIN`. |
| `tier` | String | Optional | Loyalty tier badge (e.g. "Tier 1 Verified Member"). |
| `kyc` | `KycInfoModel` | Required | Embedded KYC verification metadata. |
| `activeChitToken`| String | Optional | Primary scheme token (e.g. "#SW-042"). |
| `createdAt` | DateTime | Optional | Timestamp of account registration. |

---

### 2.2 `KycInfoModel`
Details user KYC compliance status and stored documents.
* **Source:** Embedded in `UserModel`, `POST /api/users/kyc`
* **Used by Screens:** KYC Screen, Settings, Dashboard KYC guard

| Field | Type | Req/Opt | Description |
| :--- | :--- | :---: | :--- |
| `documentType` | String | Optional | `AADHAAR` or `PAN`. |
| `documentNumberMasked` | String | Optional | Masked document number (e.g. `XXXX XXXX 9012`). |
| `documentUrl` | String | Optional | Cloudinary HTTPS link to stored file. |
| `isVerified` | Boolean | Required | Flag indicating statutory verification status. |
| `status` | String | Required | `PENDING`, `VERIFIED`, `REJECTED`, `NOT_SUBMITTED`. |
| `rejectionReason` | String | Optional | Error feedback if rejected (`BACKEND CONTRACT TBD`). |
| `submittedAt` | DateTime | Optional | Timestamp of document submission. |

---

### 2.3 `SchemeModel`
The blueprint of an available or enrolled kitty scheme.
* **Source:** `GET /api/schemes/active`
* **Used by Screens:** Kitty Offers, Home Carousel, Scheme Details Modal

| Field | Type | Req/Opt | Description |
| :--- | :--- | :---: | :--- |
| `id` | String | Required | Scheme unique identifier. |
| `name` | String | Required | Title (e.g. "Swastik Suvarna Varsha", "Royal Bridal Kitty"). |
| `targetAmount` | Double / Int | Required | Total scheme target (e.g. `60000`, `360000`). |
| `durationMonths` | Int | Required | Term duration (e.g. `6`, `12`, `18`). |
| `monthlyInstallment`| Double / Int | Required | Standard base monthly payment (e.g. `5000`). |
| `maxCapacity` | Int | Optional | Max participants limit (e.g. `100`). |
| `currentMembers`| Int | Optional | Active enrolled members count. |
| `status` | String | Required | `OPEN`, `ONGOING`, `COMPLETED`. |
| `benefits` | List<String> | Required | Bulleted scheme incentives and bonus notes. |
| `bannerImageUrl`| String | Optional | Cloudinary or local asset path for promotion card. |
| `isPopular` | Boolean | Optional | Highlight badge ("Most Popular"). |

---

### 2.4 `MembershipModel`
The binding relationship connecting a User to a specific Scheme.
* **Source:** `POST /api/memberships/join`, `GET /api/memberships/my-dashboard`
* **Used by Screens:** Dashboard, Home, Passbook

| Field | Type | Req/Opt | Description |
| :--- | :--- | :---: | :--- |
| `id` | String | Required | Unique membership ID (e.g. `mem_994411`). |
| `userId` | String | Required | Reference to User ID. |
| `schemeId` | String | Required | Reference to Scheme ID. |
| `tokenNumber` | Int | Required | Chit token number (1 to 100). |
| `tokenString` | String | Required | Formatted chit tag (e.g. `#SW-042`). |
| `customMonthlyEmi`| Double / Int| Required | Dynamic EMI computed for late joiners (`target / remaining`). |
| `totalPaidAmount`| Double / Int| Required | Sum total of all verified payments. |
| `status` | String | Required | `ACTIVE`, `WINNER`, `COMPLETED`, `DEFAULTED`. |
| `winMonth` | Int | Optional | Month won if declared winner in physical draw (else `null`). |
| `joinedAtMonth` | Int | Required | Month when user enrolled (e.g. `1`, `3`). |
| `createdAt` | DateTime | Required | Membership start timestamp. |

---

### 2.5 `DashboardSummaryModel`
Consolidated aggregator model consumed by the primary dashboard view.
* **Source:** `GET /api/memberships/my-dashboard`
* **Used by Screens:** Dashboard, Home

| Field | Type | Req/Opt | Description |
| :--- | :--- | :---: | :--- |
| `hasActiveScheme` | Boolean | Required | True if user has an enrolled scheme. |
| `schemeName` | String | Required | Display name of active plan. |
| `chitToken` | String | Required | Display token `#SW-042`. |
| `targetAmount` | Double / Int | Required | Total scheme target (₹60,000). |
| `totalPaidAmount` | Double / Int | Required | Total verified paid amount (₹40,000). |
| `remainingAmount` | Double / Int | Required | Remaining to pay excluding bonus (₹15,000). |
| `totalMonths` | Int | Required | Scheme tenure (12). |
| `monthsPaid` | Int | Required | Count of paid installments (8). |
| `accumulatedGoldGrams`| Double | Required | Total 24K gold allocated in grams (5.482 g). |
| `currentValuation`| Double / Int | Required | Gold grams multiplied by current rate. |
| `valuationGainPct`| Double | Required | Percentage profit based on gold market fluctuation. |
| `nextDueMonth` | Int | Optional | Upcoming installment month number (9). |
| `nextDueAmount` | Double / Int | Optional | Amount due for next installment (₹5,000). |
| `nextDueDate` | DateTime | Optional | Installment deadline date. |
| `daysRemaining` | Int | Optional | Days left until due date (5). |

---

### 2.6 `PassbookEntryModel`
Individual installment record in the 12-month savings passbook.
* **Source:** `GET /api/memberships/my-dashboard` (embedded list)
* **Used by Screens:** Passbook Screen, Digital Receipt Modal

| Field | Type | Req/Opt | Description |
| :--- | :--- | :---: | :--- |
| `month` | Int | Required | Installment index (1 to 12). |
| `label` | String | Required | Display title (e.g. "Month 1", "Month 12"). |
| `amount` | Double / Int | Required | Installment currency value (e.g. `5000`). |
| `status` | String | Required | `PAID`, `CURRENT`, `UPCOMING`, `BONUS`. |
| `paidAt` | DateTime | Optional | Actual payment timestamp. |
| `dueDate` | DateTime | Optional | Scheduled payment deadline. |
| `paymentMethod` | String | Optional | `ONLINE` (UPI, NetBanking, Card) or `CASH`. |
| `transactionId` | String | Optional | Bank reference / GoKwik ID / Cash receipt ID. |
| `goldGrams` | Double | Optional | Grams of 24K gold allocated for this payment. |
| `receiptUrl` | String | Optional | Cloudinary HTTPS link to official PDF receipt. |
| `bonusNote` | String | Optional | Explanatory text for jeweler sponsored installments. |

---

### 2.7 `PaymentOrderModel`
Transient state model for initiating GoKwik checkout orders.
* **Source:** `POST /api/payments/initiate`
* **Used by Screens:** Payment Checkout Modal, GoKwik Webview

| Field | Type | Req/Opt | Description |
| :--- | :--- | :---: | :--- |
| `orderId` | String | Required | GoKwik unique order reference. |
| `paymentId` | String | Required | Internal backend payment record ID. |
| `amount` | Double / Int | Required | Transaction amount in INR (₹5,000). |
| `currency` | String | Required | Default `"INR"`. |
| `merchantKey` | String | Required | `BACKEND CONTRACT TBD` (Merchant public key). |
| `sdkPayload` | Map<String, dynamic> | Optional | `BACKEND CONTRACT TBD` (GoKwik SDK params). |

---

### 2.8 `LiveGoldRateModel`
Benchmark daily bullion rate used across the interface.
* **Source:** `GET /api/rates/gold`
* **Used by Screens:** App Bar, Home Ticker, Dashboard Valuation

| Field | Type | Req/Opt | Description |
| :--- | :--- | :---: | :--- |
| `rate24k` | Double | Required | Today's 24K gold rate per gram (₹7,485.50). |
| `rate22k` | Double | Required | Today's 22K hallmark rate per gram (₹6,860.00). |
| `rateChangePct`| Double | Required | Percentage delta compared to yesterday (`+0.62%`). |
| `benchmark` | String | Optional | "IBJA Official Benchmark". |
| `updatedAt` | DateTime | Required | Timestamp of last price refresh. |
