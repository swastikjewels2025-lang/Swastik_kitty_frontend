# Frontend Business Rules & UI Logic Specification — Kitty App

**Project**: Swastik Jewellers Kitty App (Sub-Brand: Kitty Vault)  
**Primary Codebase**: `D:\kitty_app\`  
**Document Status**: SUPERSEDED  
**SUPERSEDED BY**: `KITTY_BUSINESS_RULES_PENDING_V1.md`  
**Last Audit Date**: 2026-09-29  

> [!NOTE]
> **STATUS: SUPERSEDED (PRESERVED FOR HISTORICAL CONTEXT)**  
> This V1 business rules document has been superseded by [`KITTY_BUSINESS_RULES_PENDING_V1.md`](file:///D:/kitty_frontend/kitty_docs/KITTY_BUSINESS_RULES_PENDING_V1.md) and [`BACKEND_FULL_KITTY_PAYMENT_SPEC_V1.md`](file:///D:/kitty_frontend/kitty_docs/BACKEND_FULL_KITTY_PAYMENT_SPEC_V1.md). Do not delete.

---

## 1. Scheme Installment & Bonus Mathematics

### 1.1 The 11+1 Suvarna Varsha Scheme Model
* **Scheme Duration**: Exactly 12 months.
* **Patron Obligation**: The patron pays **11 equal monthly installments** (e.g., ₹5,000/month = ₹55,000 total).
* **Jeweler Contribution**: Month 12 installment (₹5,000) is sponsored 100% by Swastik Jewellers.
* **Total Value at Maturity**: ₹60,000 + accumulated 24K gold weight accrued at each month's prevailing rate.

### 1.2 Circular Progress Gauge Sweep Angle
```dart
double calculateGaugeSweepAngle(int completedMonths, int totalMonths) {
  final double ratio = completedMonths / totalMonths;
  return ratio.clamp(0.0, 1.0) * 360.0; // In degrees
}
```

### 1.3 Late-Joiner Proration Policy
> [!IMPORTANT]
> **Status**: `REQUIRES BUSINESS CONFIRMATION`
> In legacy documents, two competing models were proposed:
> 1. *Dynamic Prorated Installment*: `customMonthlyEmi = targetAmount / (12 - joinedMonth + 1)`
> 2. *Fixed Monthly Tier with Catch-up Deposit*: Patron deposits past months as an upfront lump sum.
> The current UI implementation in `DashboardScreen` displays the fixed monthly EMI (₹5,000) while supporting a `customMonthlyEmi` field if supplied by backend contracts. Final policy must be confirmed by Swastik Jewellers management.

---

## 2. Button Disabling & Interactive UI Gates

| UI Element | Screen | Enabling Conditions | Disabled / Inactive State |
| :--- | :--- | :--- | :--- |
| **"Continue" Button** | `/auth/phone` | Phone field contains exactly 10 numeric digits starting with `[6-9]`. | Button opacity 0.45; tap ignored. |
| **"Verify OTP" Button** | `/auth/otp` | All 6 OTP cells filled with numeric digits. | Button disabled with grey border. |
| **"Complete Registration"**| `/auth/profile` | Name $\ge 2$ chars, valid email syntax, city filled. | Button disabled; field validation errors visible. |
| **"PAY INSTALLMENT"** | `/home`, `/dashboard` | Scheme status is `ACTIVE` and current month installment is unpaid. | If all months paid, button reads "ALL PAID" (disabled). |
| **"Submit KYC"** | `/kyc` | Document number valid, front & back images uploaded, consent checkbox checked. | Button opacity 0.50; statutory warning displayed. |
| **"Book Coin"** | `/coin-rates` | For bulk orders: grams $\ge 11$ and $\le 1000$. | Custom input validation message displayed. |

---

## 3. Regulatory Route Guarding & Enforcement

1. **Statutory KYC Route Guard**:
   - Implemented in `AppRouter`:
   ```dart
   if (auth.isAuthenticated && !auth.isKycVerified) {
     if (location == RoutePaths.kyc || location == RoutePaths.authSuccess || location == RoutePaths.profile) {
       return null; // Permit onboarding
     }
     return RoutePaths.kyc; // Mandatory redirect
   }
   ```
2. **Transaction Double-Submission Protection**:
   - `PaymentController` enforces `canPop = !isBusy`. During active polling (5 attempts $\times$ 3s), user cannot dismiss the sheet without confirming an explicit abandon dialog.

---

## 4. Bullion & Coin Pricing Logic

1. **Daily Benchmark Bullion Rates**:
   - 24K 999 Gold benchmark: ₹7,550.00/g
   - 22K 916 Gold benchmark: ₹6,920.00/g
   - 999 Fine Silver benchmark: ₹96.50/g
2. **Karat Purity Metallurgy Rules**:
   - **Gold**: Supports 24K (investment grade) and 22K (hallmarked jewelry). The Karat selector is shown dynamically.
   - **Silver**: Metallurgy does not use Karat ratings. The Karat selector is strictly hidden in the UI when Silver Coins is selected.
3. **Denomination Cards**: 1g, 2g, 3g, 4g, 5g rectangular cards calculate total rate directly from prevailing metal rate without arbitrary surcharge fabrication.

---

## 5. Gold Valuation Calculator Calculation Engine

The calculator enforces a strict mathematical model with zero invented charges:

### 5.1 Karat Multipliers
* **24K (Pure Gold 999)**: Rate Multiplier = $1.0000$ (e.g. ₹7,550/g)
* **22K (Hallmarked 916)**: Rate Multiplier = $\frac{22}{24} \approx 0.9167$ (e.g. ₹6,921/g)
* **18K (Diamond Jewellery 750)**: Rate Multiplier = $\frac{18}{24} = 0.7500$ (e.g. ₹5,662.50/g)

### 5.2 Bi-Directional Modes
* **Shop by Gram**:
  $$\text{Total Amount (INR)} = \text{Entered Weight (g)} \times \text{Applicable Karat Rate (INR/g)}$$
* **Shop by Money**:
  $$\text{Calculated Weight (g)} = \frac{\text{Entered Amount (INR)}}{\text{Applicable Karat Rate (INR/g)}}$$
* **No Speculative Add-ons**: Taxes (GST), making charges, and discounts are NOT invented or added to the valuation display unless supplied by backend contracts.

---

## 6. Doorstep Cash Pickup ("Pick Cash") Statutory Rules

1. **PMLA & Tax Compliance Ceiling**:
   - Maximum allowed cash collection is **₹1,99,999** per transaction.
   - Single cash transactions $\ge ₹2,00,000$ are strictly prohibited under **Section 269ST** of the Indian Income Tax Act.
2. **Identity & Location Validation**:
   - Address, City, and valid 6-digit Indian PIN code are mandatory.
   - Pre-fills verified patron name and contact from active profile session to avoid redundant data entry.
3. **Chain of Custody Handover**:
   - Generates a 6-digit verification OTP on booking.
   - Physical cash handover requires the patron to verify the courier's badge and communicate the OTP to complete custody transfer.

   - 3g to 5g: ₹450
   - 6g to 10g: ₹600
3. **Bulk Coin Orders (>10g)**:
   - Base Gold = $\text{Grams} \times \text{Benchmark Rate}$
   - Assay Fee = ₹$600 + (\text{Grams} - 10) \times 20$
   - Total Price = $\text{Base Gold} + \text{Assay Fee}$

---

## 5. Hardware Back-Button & Drawer Dismissal Hierarchy

1. **Level 1**: If `LuxuryNavDrawer` is currently open $\rightarrow$ Close the drawer; stay on current screen.
2. **Level 2**: If the user is on Tab 1, 2, 3, or 4 $\rightarrow$ Return to Tab 0 (`/home`).
3. **Level 3**: If on Tab 0 (`/home`) $\rightarrow$ Allow system exit.
