# Pre-Launch Statutory Sign-Off Checklist — Kitty App

**Project**: Swastik Jewellers Kitty App (Sub-Brand: Kitty Vault)  
**Primary Codebase**: `D:\kitty_app\`  
**Document Status**: Synchronized with Current Implementation  
**Last Audit Date**: 2026-09-23  

---

## 1. Sign-Off Stakeholder Matrix

Before publishing the Kitty App on the Google Play Store and Apple App Store, the following formal corporate sign-offs must be completed:

```text
┌────────────────────────────────────────────────────────┐
│ PRE-LAUNCH STATUTORY SIGN-OFF STAKEHOLDERS             │
├────────────────────────────────────────────────────────┤
│ 1. Corporate Legal Counsel: Terms, BUDS Act, Chit Laws │
│ 2. Statutory Auditor / CA:  GST, Advance Deposit Rules │
│ 3. Managing Director:       Bonus Month Scheme Policy  │
│ 4. Lead Security Engineer:  KeyStore, TLS & Play Store │
└────────────────────────────────────────────────────────┘
```

---

## 2. 30-Point Statutory Pre-Launch Checklist

### 2.1 Corporate Legal & Scheme Structuring (10 Items)
* [ ] **1. Scheme Agreement Characterization**: Confirmed schemes are structured as *Jewellery Advance Purchase Agreements* under Companies Act Section 73 exemptions.
* [ ] **2. 365-Day Delivery Term**: Formal guarantee that physical gold jewelry is delivered within 365 days of enrollment.
* [ ] **3. Chit Terminology Elimination**: Reviewed client UI copy to replace "Chit Token" with "Membership ID" / "Plan Token".
* [ ] **4. Lucky Draw Verification**: Confirmed no unauthorized prize chits or installment waiver lotteries are active in backend.
* [ ] **5. Jeweler Bonus Legal Classification**: Month 12 bonus formally documented as a making-charge discount voucher.
* [ ] **6. Forfeiture Prohibition Clause**: Terms explicitly forbid forfeiture of principal installments upon default.
* [ ] **7. Exit & Cancellation Policy**: Formal jewelry redemption voucher policy established for early exits.
* [ ] **8. Terms & Conditions URL**: Published and hosted at `https://swastikjewel.in/legal/terms`.
* [ ] **9. Privacy Policy URL**: Published and hosted at `https://swastikjewel.in/legal/privacy`.
* [ ] **10. Grievance Officer Disclosed**: Designated Data Protection Officer name and contact details published.

### 2.2 Taxation, GST & PMLA Compliance (7 Items)
* [ ] **11. PMLA ₹2,00,000 Threshold**: KYC center enforces PAN verification on schemes exceeding ₹2 Lakhs.
* [ ] **12. Cash Deposit Limit**: Cash payments at Lucknow showroom counter strictly capped under PMLA ₹50,000 reporting limits.
* [ ] **13. GST Invoicing Alignment**: Accounts team confirmed whether GST is collected on monthly receipts or final maturity bill.
* [ ] **14. HSN & GSTIN Disclosure**: Official Swastik Jewellers GSTIN and HSN gold bullion codes displayed on digital tax receipts.
* [ ] **15. BIS Hallmarking License**: 6-digit HUID compliance statement and registered BIS license number published in app terms.
* [ ] **16. IBJA Rate Benchmark Disclosure**: Citations of daily bullion rates displayed on header ticker and coin rates.
* [ ] **17. Aadhaar Masking Verification**: Backend database verified to store only masked Aadhaar numbers (last 4 digits).

### 2.3 Payment & Banking Regulations (6 Items)
* [ ] **18. RBI e-Mandate Pre-Debit Alerts**: Automated SMS/WhatsApp notifications sent 24 hours prior to recurring debit.
* [ ] **19. GoKwik Production Merchant KYC**: GoKwik production merchant account approved and live keys provisioned.
* [ ] **20. Failed Transaction Auto-Reversal**: Automated T+3 bank reversal workflow tested for dropped transactions.
* [ ] **21. Zero Surcharge Disclosure**: Confirmed zero hidden checkout fees charged to customer without itemized notice.
* [ ] **22. Reconciliation Polling Safety**: Back-button protection dialog verified to prevent dropped payments.
* [ ] **23. Bank Account Binding**: Patrons can securely link and verify bank accounts for maturity settlement.

### 2.4 Technical Security & App Store Readiness (7 Items)
* [ ] **24. Production Release Keystore**: Release APK/AAB compiled with official Swastik Jewellers upload keystore.
* [ ] **25. TLS 1.3 Enforcement**: Android cleartext traffic disabled; strict HTTPS enforced across all endpoints.
* [ ] **26. Secure KeyStore Storage**: Tokens and MPIN hashes verified to reside exclusively in hardware-backed storage.
* [ ] **27. Production Log Scrubbing**: Dio HTTP logging interceptors disabled in release builds.
* [ ] **28. Google Play Data Safety Section**: Data Safety form completed accurately disclosing collected phone, name, and KYC data.
* [ ] **29. App Content Rating**: Questionnaire completed confirming e-commerce and savings utility rating (PEGI 3 / Everyone).
* [ ] **30. Static Analysis & Test Cleanliness**: Zero lint errors; 346 of 346 automated tests passing in release pipeline.
