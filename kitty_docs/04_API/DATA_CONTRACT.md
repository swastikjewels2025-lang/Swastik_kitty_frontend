# Master Data Contract & Type Specification

> [!IMPORTANT]
> **DEFINITIVE DATA CONTRACT SPECIFICATION:**  
> The comprehensive and binding data contract is formalized in:
> * [BACKEND_CONTRACT_FREEZE.md](file:///d:/ui%20design/kitty_docs/api/BACKEND_CONTRACT_FREEZE.md) — Master Frontend ↔ Backend Contract Freeze (Sections 11–14)
> * [BACKEND_DEVELOPER_IMPLEMENTATION_GUIDE.md](file:///d:/ui%20design/kitty_docs/api/BACKEND_DEVELOPER_IMPLEMENTATION_GUIDE.md) — Backend Implementation Guide & Mongoose Schemas

## 1. Overview & Data Philosophy
This document establishes the binding data contract between the frontend and backend. It resolves potential serialization disputes regarding nullability, date/time formatting, monetary precision, and file uploads.

### Core Data Principles:
1. **Backend is Financial Source of Truth:** The frontend renders financial sums and valuation gains, but the backend is the authoritative ledger. The frontend never computes final balance liabilities independently.
2. **Strict Null-Safety:** Optional fields must be explicitly marked nullable (`?`). Required fields must always be present in responses.
3. **No Floating-Point Math for Money:** Currencies are represented strictly as whole integers in standard Rupee denomination (e.g. `5000` = ₹5,000) or explicit integer paise where fractional precision is necessary.

---

## 2. Date & Time Contract

| Dimension | Specification | Notes & Guidelines |
| :--- | :--- | :--- |
| **API Wire Format** | **ISO 8601 UTC** (`YYYY-MM-DDTHH:mm:ss.sssZ`) | All timestamps emitted by the backend must be in UTC timezone ending in `Z`. |
| **Example Wire String**| `2026-09-15T13:14:41.000Z` | Never send UNIX millisecond timestamps or localized strings. |
| **Client Parsing** | `DateTime.parse(isoString).toLocal()` | Frontend deserializes to UTC `DateTime` and transforms to user device local timezone for display. |
| **Date-Only Fields** | `YYYY-MM-DD` (e.g. `2026-09-15`) | Used for due dates and scheme start dates where time-of-day is irrelevant. |
| **Display Formatting** | E.g. `"15 Sep 2026"` / `"15th Sep 2026"` | Formatted exclusively on client using `intl` / `DateTimeFormatter`. |

---

## 3. Money & Currency Contract

| Dimension | Specification | Notes & Rules |
| :--- | :--- | :--- |
| **Currency Code** | **INR (`₹`)** | Official currency for all savings plans and valuations. |
| **API Wire Type** | **`Integer` (Whole Rupees)** | Installment payments are discrete Rupee amounts (`5000`, `30000`, `60000`). No floats! |
| **Paise vs. Rupee** | Standard whole Rupee integer (`5000` = ₹5,000) | `BACKEND DEVELOPER TO CONFIRM`: If backend uses integer paise (`500000`), frontend must be notified. |
| **Rounding Rule** | Standard Half-Up (`Round(val, 2)`) | Backend executes any rounding for dynamic EMI late-joiner divisions. |
| **Display Format** | Indian Numbering System (`en-IN`) | Formats with Indian comma grouping: `₹3,60,000`, `₹40,000`. |
| **Gold Weight Type** | **`Double` with 3 Decimals (`0.001g`)** | Fine bullion is measured in grams up to 3 decimal places (e.g. `5.482 g`). |

---

## 4. Entity Field-by-Field Contracts

### 4.1 Entity: `User`
* **Collection / Table:** `User`
* **DTO:** `UserDto` $\rightarrow$ **Domain Entity:** `UserEntity`

| Field | Frontend Type | Backend Type | Nullable? | Req? | Format / Constraint | Example | Notes |
| :--- | :--- | :--- | :---: | :---: | :--- | :--- | :--- |
| `id` | `String` | `ObjectId / String` | No | Yes | 24-char hex string | `"usr_654321abcdef"` | Unique user key |
| `name` | `String` | `String` | No | Yes | Max 100 chars | `"Rihan"` | Patron full name |
| `phone` | `String` | `String` | No | Yes | E.164 (`^\+[1-9]\d{1,14}$`)| `"+919876543210"` | Indexed unique phone |
| `role` | `UserRoleEnum` | `String (Enum)` | No | Yes | `CUSTOMER`, `ADMIN` | `"CUSTOMER"` | Authorization role |
| `tier` | `String` | `String` | Yes | No | Descriptive string | `"Tier 1 Verified Member"`| Loyalty tier badge |
| `kyc` | `KycInfoEntity` | `Object / Subdoc` | No | Yes | Nested object | `{ ... }` | KYC compliance state |
| `createdAt` | `DateTime` | `Date / ISO8601` | No | Yes | ISO 8601 UTC | `"2026-01-01T00:00:00Z"` | Signup timestamp |

---

### 4.2 Entity: `KycInfo`
* **Embedded inside:** `User`
* **DTO:** `KycInfoDto` $\rightarrow$ **Domain Entity:** `KycInfoEntity`

| Field | Frontend Type | Backend Type | Nullable? | Req? | Format / Constraint | Example | Notes |
| :--- | :--- | :--- | :---: | :---: | :--- | :--- | :--- |
| `isVerified` | `bool` | `Boolean` | No | Yes | Boolean flag | `false` | Statutory verification flag |
| `status` | `KycStatusEnum` | `String (Enum)` | No | Yes | `PENDING`, `VERIFIED`, `REJECTED`, `NOT_SUBMITTED` | `"PENDING"` | Form status indicator |
| `documentType` | `DocTypeEnum?` | `String (Enum)` | Yes | No | `AADHAAR`, `PAN` | `"AADHAAR"` | Chosen ID type |
| `documentNumberMasked`| `String?` | `String` | Yes | No | Masked UIDAI format | `"XXXX XXXX 9012"` | PII protection |
| `documentUrl` | `String?` | `String (URL)` | Yes | No | Cloudinary HTTPS link | `"https://res.cloudinary..."`| Uploaded image link |
| `rejectionReason`| `String?` | `String` | Yes | No | Explanatory error | `"Blurry photo"` | Feedback if rejected |

---

### 4.3 Entity: `Scheme`
* **Collection / Table:** `Scheme`
* **DTO:** `SchemeDto` $\rightarrow$ **Domain Entity:** `SchemeEntity`

| Field | Frontend Type | Backend Type | Nullable? | Req? | Format / Constraint | Example | Notes |
| :--- | :--- | :--- | :---: | :---: | :--- | :--- | :--- |
| `id` | `String` | `ObjectId / String` | No | Yes | Unique scheme key | `"sch_12month_suvarna"` | Scheme ID |
| `name` | `String` | `String` | No | Yes | Max 100 chars | `"Swastik Suvarna Varsha"` | Display scheme name |
| `targetAmount` | `int` | `Number (Int)` | No | Yes | Positive integer | `60000` | Target savings goal |
| `durationMonths`| `int` | `Number (Int)` | No | Yes | `6`, `12`, `18`, `24` | `12` | Tenure in months |
| `monthlyInstallment`| `int`| `Number (Int)` | No | Yes | Positive integer | `5000` | Base monthly EMI |
| `maxCapacity` | `int` | `Number (Int)` | No | Yes | Max members | `100` | Chit slot limit |
| `currentMembers`| `int` | `Number (Int)` | No | Yes | $\le$ `maxCapacity` | `42` | Enrolled count |
| `status` | `SchemeStatusEnum`| `String (Enum)` | No | Yes | `OPEN`, `ONGOING`, `COMPLETED` | `"OPEN"` | Enrollment status |
| `benefits` | `List<String>` | `Array of Strings`| No | Yes | Non-empty array | `["1 Month Free", ...]` | Perk highlights |
| `bannerImageUrl`| `String?` | `String (URL)` | Yes | No | Valid image URL | `"assets/banner.jpg"` | Banner artwork |
| `isPopular` | `bool` | `Boolean` | No | No | Boolean flag | `true` | Badge highlight |

---

### 4.4 Entity: `Membership`
* **Collection / Table:** `Membership`
* **DTO:** `MembershipDto` $\rightarrow$ **Domain Entity:** `MembershipEntity`

| Field | Frontend Type | Backend Type | Nullable? | Req? | Format / Constraint | Example | Notes |
| :--- | :--- | :--- | :---: | :---: | :--- | :--- | :--- |
| `id` | `String` | `ObjectId / String` | No | Yes | Unique membership key| `"mem_994411"` | Membership ID |
| `userId` | `String` | `ObjectId` | No | Yes | Ref to User | `"usr_654321abcdef"` | Owner ID |
| `schemeId` | `String` | `ObjectId` | No | Yes | Ref to Scheme | `"sch_12month_suvarna"` | Enrolled Scheme |
| `tokenNumber` | `int` | `Number (Int)` | No | Yes | Integer `1` to `100` | `42` | Chit number |
| `tokenString` | `String` | `String` | No | Yes | Prefix + 3-digit | `"#SW-042"` | UI Display chit token |
| `customMonthlyEmi`| `int` | `Number (Int)` | No | Yes | Calculated late-join EMI| `5000` | Dynamic EMI formula |
| `totalPaidAmount`| `int` | `Number (Int)` | No | Yes | Incremented on webhook | `40000` | Total verified sum |
| `status` | `MembershipStatusEnum`| `String (Enum)` | No | Yes | `ACTIVE`, `WINNER`, `COMPLETED`, `DEFAULTED` | `"ACTIVE"` | Member state |
| `joinedAtMonth` | `int` | `Number (Int)` | No | Yes | Integer `1` to `duration`| `1` | Enrolled month index |
| `winMonth` | `int?` | `Number (Int)` | Yes | No | Month won (or null) | `null` | Physical draw winner |

---

### 4.5 Entity: `PassbookEntry`
* **Collection / Table:** Read from `Payment`
* **DTO:** `PassbookEntryDto` $\rightarrow$ **Domain Entity:** `PassbookEntryEntity`

| Field | Frontend Type | Backend Type | Nullable? | Req? | Format / Constraint | Example | Notes |
| :--- | :--- | :--- | :---: | :---: | :--- | :--- | :--- |
| `month` | `int` | `Number (Int)` | No | Yes | `1` to `duration` | `9` | Installment number |
| `label` | `String` | `String` | No | Yes | E.g. `"Month 9"` | `"Month 9"` | Display title |
| `amount` | `int` | `Number (Int)` | No | Yes | Whole Rupees | `5000` | Installment value |
| `status` | `InstallmentStatusEnum`| `String (Enum)` | No | Yes | `PAID`, `CURRENT`, `UPCOMING`, `BONUS` | `"CURRENT"` | Ledger node status |
| `paidAt` | `DateTime?` | `Date / ISO8601` | Yes | No | ISO 8601 UTC | `"2026-01-15T10:30:00Z"` | Verified pay date |
| `dueDate` | `DateTime?` | `Date / ISO8601` | Yes | No | ISO 8601 UTC | `"2026-09-15T00:00:00Z"` | Deadline date |
| `paymentMethod`| `PaymentMethodEnum?`| `String (Enum)` | Yes | No | `ONLINE`, `CASH` | `"ONLINE"` | Payment channel |
| `transactionId`| `String?` | `String` | Yes | No | Alphanumeric | `"TXN-SW-10821"` | Bank/GoKwik txn ID |
| `goldGrams` | `double?` | `Number (Float)` | Yes | No | 3 Decimals | `0.702` | Grams allocated |
| `receiptUrl` | `String?` | `String (URL)` | Yes | No | Cloudinary PDF URL | `"https://res.cloudinary..."`| Official receipt |
| `bonusNote` | `String?` | `String` | Yes | No | Descriptive text | `"100% Free Bonus"` | For month 12 |

---

## 5. File & Image Upload Contract

| Dimension | Specification | Notes & Limits |
| :--- | :--- | :--- |
| **Mechanism** | Standard Multipart/form-data | Field name: `file` |
| **Max File Size** | **10 Megabytes (10 MB)** | Frontend validates size client-side before sending. |
| **Permitted MIME Types** | `image/jpeg`, `image/png`, `image/webp`, `application/pdf` | Whitelisted extensions: `.jpg`, `.jpeg`, `.png`, `.webp`, `.pdf`. |
| **Cloud Storage** | **Cloudinary CDN** | Uploaded via backend `multer-storage-cloudinary`. |
| **URL Format** | Fully qualified HTTPS Cloudinary URL | Example: `https://res.cloudinary.com/swastik/image/upload/v1/kyc/doc_123.jpg`. |
| **PDF Receipts** | Generated server-side using `pdfkit` | Stored in Cloudinary `receipts/` folder; URL attached to `Payment.receiptUrl`. |
