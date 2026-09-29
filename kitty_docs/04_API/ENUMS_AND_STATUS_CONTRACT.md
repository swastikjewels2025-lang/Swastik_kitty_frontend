# Master Enums & Status Contract

## 1. Overview & Defensive Deserialization Rule
This document catalogs every enumeration and status flag across the Kitty App system.

> [!IMPORTANT]
> **Defensive Deserialization Non-Negotiable Rule:**
> To ensure frontend stability when the backend introduces new statuses, the frontend Dart enums must implement an `unknown` fallback:
> ```dart
> enum InstallmentStatus {
>   paid, current, upcoming, bonus, defaulted, preJoin, unknown;
> 
>   static InstallmentStatus fromString(String? value) {
>     return InstallmentStatus.values.firstWhere(
>       (e) => e.name.toUpperCase() == (value ?? '').toUpperCase(),
>       orElse: () => InstallmentStatus.unknown,
>     );
>   }
> }
> ```
> The frontend **must never throw an uncaught `ArgumentError`** when receiving an unrecognized string.

---

## 2. Enumeration Catalog

### 2.1 `InstallmentStatusEnum`
Identifies the payment lifecycle of an individual monthly passbook node.
* **Backend Source:** Computed in `/api/v1/memberships/my-dashboard` from `Payment` collection.

| Allowed String Value | Semantic Meaning | UI Display & Styling | Unknown Value Handling |
| :--- | :--- | :--- | :--- |
| **`"PAID"`** | Installment successfully paid and confirmed. | Green badge (`#ECFDF5` bg, `#047857` text), checkmark icon, "View Receipt" button enabled. | Falls back to `unknown`. |
| **`"CURRENT"`** | Active installment due for the ongoing cycle. | Amber highlight row (`#FFFBEB`), "Pay Now" gold CTA button enabled. | Falls back to `unknown`. |
| **`"UPCOMING"`** | Future scheduled installment not yet due. | Muted gray text (`#64748B`), scheduled date subtitle, no action buttons. | Falls back to `unknown`. |
| **`"BONUS"`** | Final 12th/18th month 100% jeweler-sponsored deposit. | Yellow highlight row (`#FEFCE8`), gift star icon, "100% Jeweler Bonus Deposit" label. | Falls back to `unknown`. |
| **`"PRE_JOIN"`** | Past month prior to late-join enrollment. | Muted gray row (`#F1F5F9` bg, `#64748B` text) with lock icon: "Joined Month N". Excluded from remaining balance. | Falls back to `unknown`. |
| **`"DEFAULTED"`** | Missed deadline beyond the permissible grace period. | Red status pill (`#FEF2F2` bg, `#DC2626` text), "Contact Showroom" action. | Falls back to `unknown`. |
| **`unknown`** | Unrecognized future backend status. | Neutral gray badge with text value; does not crash screen. | Default fallback. |

---

### 2.2 `MembershipStatusEnum`
Represents the overall standing of a user's scheme enrollment.
* **Backend Source:** `Membership.status`

| Allowed String Value | Semantic Meaning | UI Display & Styling | Unknown Value Handling |
| :--- | :--- | :--- | :--- |
| **`"ACTIVE"`** | Normal standing; regular monthly savings ongoing. | Green dot with "ACTIVE SCHEME" pill on hero pass card. | Falls back to `unknown`. |
| **`"WINNER"`** | Chit token drawn as winner in physical monthly draw. | Golden celebratory banner: "Winner of Month X Draw! Visit showroom." Payment CTA disabled. | Falls back to `unknown`. |
| **`"COMPLETED"`** | All 12 installments paid; scheme matured. | Green star badge: "Matured • Ready for Gold Delivery / Showroom Redemption". | Falls back to `unknown`. |
| **`"DEFAULTED"`** | Multiple payments missed; membership suspended. | Red warning card with store concierge phone link. | Falls back to `unknown`. |
| **`unknown`** | Unrecognized status. | Muted badge; logs warning to telemetry. | Default fallback. |

---

### 2.3 `KycStatusEnum`
Tracks statutory identity document compliance.
* **Backend Source:** `User.kyc.isVerified`, `User.kyc.status`

| Allowed String Value | Semantic Meaning | UI Display & Styling | Unknown Value Handling |
| :--- | :--- | :--- | :--- |
| **`"NOT_SUBMITTED"`** | User has never uploaded KYC documents. | Yellow warning banner on dashboard: "Complete KYC to enroll". | Falls back to `unknown`. |
| **`"PENDING"`** | Documents submitted and under admin review. | Amber pill: "KYC Under Verification (Ref #KYC-XXXX)". Blocks payment CTA. | Falls back to `unknown`. |
| **`"VERIFIED"`** | Document approved by compliance team. | Green check badge: "Verified Member • Tier 1". Unlocks all actions. | Falls back to `unknown`. |
| **`"REJECTED"`** | Document rejected (blurry, expired, mismatch). | Red alert banner with rejection reason and "Re-upload KYC" CTA. | Falls back to `unknown`. |
| **`unknown`** | Unrecognized status. | Treats as `PENDING` for safety. | Default fallback. |

---

### 2.4 `DocTypeEnum`
The statutory document presented for identity verification.
* **Backend Source:** `User.kyc.documentType`

| Allowed String Value | Semantic Meaning | UI Format & Validation Rules | Unknown Value Handling |
| :--- | :--- | :--- | :--- |
| **`"AADHAAR"`** | 12-Digit Indian National UIDAI Identity. | 12 numeric digits with real-time 4-4-4 spacing (`XXXX XXXX XXXX`). | Falls back to `unknown`. |
| **`"PAN"`** | Permanent Account Number (Income Tax Dept). | 10 alphanumeric uppercase characters (`^[A-Z]{5}[0-9]{4}[A-Z]{1}$`). | Falls back to `unknown`. |
| **`unknown`** | Unrecognized document type. | Generic text field without format mask. | Default fallback. |

---

### 2.5 `PaymentMethodEnum`
Channel utilized to record a transaction.
* **Backend Source:** `Payment.paymentMethod`

| Allowed String Value | Semantic Meaning | UI Display | Unknown Value Handling |
| :--- | :--- | :--- | :--- |
| **`"ONLINE"`** | Digital payment via GoKwik (UPI, NetBanking, Card). | Displays "UPI / Online Payment" + bank txn ID. | Falls back to `unknown`. |
| **`"CASH"`** | Walk-in store payment logged by showroom admin. | Displays "Cash (Showroom Receipt)" + cashier stamp icon. | Falls back to `unknown`. |
| **`unknown`** | Unrecognized method. | Displays "Other Payment". | Default fallback. |

---

### 2.6 `PaymentStatusEnum`
Transactional state of a payment record.
* **Backend Source:** `Payment.status`

| Allowed String Value | Semantic Meaning | UI Action & Display | Unknown Value Handling |
| :--- | :--- | :--- | :--- |
| **`"PENDING"`** | Order created; awaiting gateway webhook confirmation. | Shimmer reconciliation spinner: "Verifying payment with bank...". | Falls back to `unknown`. |
| **`"SUCCESS"`** | Verified by GoKwik webhook with signature check. | Green checkmark animation; updates total paid amount. | Falls back to `unknown`. |
| **`"FAILED"`** | Declined by bank, user cancelled, or gateway error. | Red rejection dialog with "Retry Payment" option. | Falls back to `unknown`. |
| **`unknown`** | Unrecognized status. | Prompts user to check bank statement; provides support link. | Default fallback. |

---

### 2.7 `SchemeStatusEnum`
State of scheme availability.
* **Backend Source:** `Scheme.status`

| Allowed String Value | Semantic Meaning | UI Action & Display | Unknown Value Handling |
| :--- | :--- | :--- | :--- |
| **`"OPEN"`** | Accepting new members. | "Enrol Plan" button enabled. | Falls back to `unknown`. |
| **`"ONGOING"`** | Chit cycle running; capacity full or registration closed. | "Scheme Full" badge; enrollment disabled. | Falls back to `unknown`. |
| **`"COMPLETED"`** | Scheme cycle has concluded. | "Archived Scheme". | Falls back to `unknown`. |
| **`unknown`** | Unrecognized status. | Disables enrollment action for safety. | Default fallback. |
