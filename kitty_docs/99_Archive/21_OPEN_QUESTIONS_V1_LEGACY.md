# Open Questions & Business Confirmations — Kitty App

**Project**: Swastik Jewellers Kitty App (Sub-Brand: Kitty Vault)  
**Primary Codebase**: `D:\kitty_app\`  
**Document Status**: Synchronized with Current Implementation  
**Last Audit Date**: 2026-09-23  

---

## 1. Governance & Resolution Process

This catalog records all open product, business, architectural, and statutory questions discovered during the documentation synchronization audit. Per the absolute protection rules, **no assumptions were hardcoded into application source code**. Each open item is documented below with its current UI behavior, business impact, and recommended resolution:

---

## 2. Master Catalog of Open Questions

### Q1: Late-Joiner Installment Proration Policy
* **Status**: `REQUIRES BUSINESS CONFIRMATION`
* **Current UI Behavior**: Displays the standard fixed monthly installment (₹5,000) while supporting an optional `customMonthlyEmi` field from backend contracts.
* **The Conflict**:
  - *Option A (Dynamic Proration)*: A patron joining in Month 4 pays higher installments: $\text{customMonthlyEmi} = 60,000 / (12 - 4 + 1) = ₹6,667/\text{month}$.
  - *Option B (Catch-up Deposit)*: The patron pays ₹15,000 upfront for Months 1–3, and continues paying ₹5,000/month for Months 4–11.
* **Recommended Resolution**: Adopt Option B (Catch-up Deposit) to maintain uniform monthly accounting and simplify GST tax invoice generation.

### Q2: Jeweler Bonus Month (Month 12) Legal Structuring
* **Status**: `REQUIRES BUSINESS CONFIRMATION`
* **Current UI Behavior**: Month 12 installment is rendered with a gold "BONUS" badge and ₹0.00 patron contribution.
* **The Conflict**:
  - Under the **Banning of Unregulated Deposit Schemes (BUDS) Act 2019**, jewelers cannot promise financial interest returns on customer advances.
  - *Option A (Promotional Making Charge Discount)*: The ₹5,000 bonus is granted strictly as a voucher against making charges at the time of final jewelry redemption.
  - *Option B (Precious Metal Advance Credit)*: The jeweler deposits ₹5,000 worth of 24K gold bullion into the patron's account at Month 12.
* **Recommended Resolution**: Option A (Discount Voucher) provides the lowest statutory risk under BUDS Act Section 2(4).

### Q3: Default & Missed Installment Policy
* **Status**: `REQUIRES BUSINESS CONFIRMATION`
* **Current UI Behavior**: Overdue installments display an `OVERDUE` badge, and the "PAY INSTALLMENT" button prioritizes settling the overdue month.
* **Open Decisions**:
  - What grace period is permitted? (e.g. 7 days or 15 days).
  - Does missing an installment forfeit the Month 12 jeweler bonus?
  - Does an overdue installment extend the 12-month maturity date?
* **Recommended Resolution**: Allow a 7-day grace period without penalty; if unpaid beyond 30 days, the Month 12 bonus is forfeited, but the patron retains all deposited principal in pure gold weight.

### Q4: Early Scheme Cancellation & Exit Terms
* **Status**: `REQUIRES BUSINESS CONFIRMATION`
* **Current UI Behavior**: UI does not provide an automated cancellation button; prompts user to visit the showroom.
* **Open Decisions**:
  - Under Indian Consumer Protection regulations, can deposits be refunded in cash, or must they be redeemed exclusively in gold jewelry?
* **Recommended Resolution**: Provide a physical showroom jewelry redemption voucher for accumulated gold weight; strictly prohibit cash refunds to avoid deposit scheme classification.

### Q5: GoKwik Live Production Merchant Credentials
* **Status**: `EXTERNAL DEPENDENCY`
* **Current UI Behavior**: Operates seamlessly in GoKwik sandbox/mock mode.
* **Action Required**: Swastik Jewellers management must complete GoKwik merchant KYC and supply live App ID and Secret Keys for production deployment.

### Q6: Google Play Store Upload Keystore
* **Status**: `EXTERNAL DEPENDENCY`
* **Current UI Behavior**: Build scripts utilize mock debug keystore.
* **Action Required**: System administrator must generate and securely back up a production release upload keystore (`upload-keystore.jks`) before publishing the release AAB to the Play Store Console.

### Q7: Doorstep Cash Pickup Operational Policy & Transit Insurance ("Pick Cash")
* **Status**: `REQUIRES BUSINESS CONFIRMATION`
* **Current UI Behavior**: Captures patron address, 6-digit postal code, and time slot; enforces ₹1,99,999 statutory ceiling; generates 6-digit handover OTP.
* **Open Decisions**:
  - What geographical pincode boundary in Lucknow is eligible for doorstep cash pickup?
  - Does Swastik Jewellers levy a courier convenience fee, or is the service complimentary for verified patrons?
  - What commercial transit cash insurance policy is held for the bonded courier executives during transit?
* **Recommended Resolution**: Restrict initial rollout to major Lucknow PIN codes (e.g., 226001–226028) with complimentary pickup for active kitty patrons, backed by a comprehensive Cash-in-Transit (CIT) insurance policy.

### Q8: Instagram SSO Meta App Review & Privacy Disclosures
* **Status**: `BACKEND DEPENDENCY & LEGAL REVIEW`
* **Current UI Behavior**: Implemented via frontend authentication abstraction (`authController.loginWithInstagram()`).
* **Open Decisions**:
  - Meta App Review for Instagram Graph API permissions (`user_profile`).
  - Privacy policy disclosures regarding Instagram user ID mapping under the Digital Personal Data Protection Act (DPDPA) 2023.

### Q9: Fine Jewellery Studio Photography for Chain Bracelets
* **Status**: `ASSET DEPENDENCY`
* **Current UI Behavior**: Authentic showroom photography is active across rings, pendants, necklaces, earrings, and bangles. Chain bracelets currently display approved studio twisted bangle assets as a temporary fallback.
* **Action Required**: Swastik Jewellers creative media team must provide authentic high-resolution studio photographs specifically for gold chain bracelets.

