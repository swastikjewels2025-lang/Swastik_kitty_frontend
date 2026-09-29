# Indian Legal & Regulatory Compliance Framework — Kitty App

**Project**: Swastik Jewellers Kitty App (Sub-Brand: Kitty Vault)  
**Primary Codebase**: `D:\kitty_app\`  
**Document Status**: Synchronized with Current Implementation  
**Last Audit Date**: 2026-09-23  
**Legal Disclaimer**: *Technical and regulatory risk analysis for engineering alignment. Not formal legal advice; requires review by Swastik Jewellers legal counsel.*

---

## 1. Statutory Landscape for Gold Advance Schemes in India

Periodic installment schemes with jeweler bonuses (e.g. 11+1 Suvarna Varsha) operate at the intersection of several strict Indian statutory acts:

```text
┌────────────────────────────────────────────────────────┐
│ INDIAN STATUTORY REGULATORY FRAMEWORK                  │
├────────────────────────────────────────────────────────┤
│ 1. BUDS Act 2019:        Banning Unregulated Deposits   │
│ 2. Companies Act 2013:   Section 73 (365-day rule)     │
│ 3. Chit Funds Act 1982:  Protected terminology          │
│ 4. Prize Chits Act 1978: Lucky draw / lottery ban       │
│ 5. PMLA 2002:            Rule 9 KYC thresholds         │
│ 6. UIDAI Regulations:    Aadhaar masking rules          │
│ 7. DPDPA 2023:           Digital personal data privacy  │
│ 8. BIS Hallmarking:      Mandatory 6-digit HUID tags    │
└────────────────────────────────────────────────────────┘
```

---

## 2. Core Statutory Compliance Analyses

### 2.1 Banning of Unregulated Deposit Schemes (BUDS) Act, 2019
* **Statutory Rule**: Prohibits businesses from accepting deposits from the retail public without statutory registration (RBI, SEBI, or State Government).
* **Safe Commercial Exemption**: Legitimate commercial advance payments received in connection with the future supply of specific goods (jewelry) are exempt under Section 2(4).
* **Application to Kitty App**: All schemes must be characterized strictly as **"Jewellery Advance Purchase Agreements"**, and all customer promotional credits (e.g. Month 12 bonus) must be treated as jewelry discounts rather than interest returns on money.

### 2.2 Companies Act, 2013 (Section 73 & Deposit Rules 2014)
* **The 365-Day Rule**: Rule 2(1)(c)(xii) of the Companies (Acceptance of Deposits) Rules states that advance payments for goods remain exempt from illegal public deposit classifications **ONLY IF** the goods are delivered within **365 days** of receiving the advance.
* **Application to Kitty App**: The scheme duration is strictly fixed at 12 months (11 installments + 1 bonus month = 365 days), and terms must mandate delivery of physical gold jewelry within 365 days.

### 2.3 Chit Funds Act, 1982 & Terminology Risks
* **Statutory Rule**: The word "Chit" or "Chit Fund" is legally protected under Section 4 and 11.
* **Risk Finding**: Using the term "Chit Token" (e.g. `#SW-042`) creates regulatory confusion implying a registered chit fund.
* **Recommendation**: Replace customer-facing copy from "Chit Token" to **"Membership ID"** or **"Plan Token"**.

### 2.4 Prize Chits and Money Circulation Schemes (Banning) Act, 1978
* **Statutory Rule**: Conventional prize chits where lots or lucky draws are held to waive future installments or give prizes are strictly banned.
* **Recommendation**: If any lucky draw or lottery feature was planned in legacy backend modules, it must be decommissioned unless operating under a licensed State lottery approval.

### 2.5 Prevention of Money Laundering Act (PMLA), 2002 & Rule 9
* **PAN Threshold**: Mandatory PAN collection for transactions or scheme targets exceeding **₹2,00,000** (and cash transactions >₹50,000).
* **Application to Kitty App**: KYC center (`/kyc`) enforces PAN collection when schemes exceed statutory thresholds.

---

## 3. Statutory Implications of 2026-09-24 Product Updates

> [!CAUTION]
> **LEGAL DISCLAIMER: REQUIRES PROFESSIONAL COUNSEL REVIEW**
> The following items represent engineering regulatory safeguards implemented on the frontend. Formal legal review by Swastik Jewellers retained advocate/compliance officer is mandatory prior to live commercial operations.

### 3.1 Doorstep Cash Pickup ("Pick Cash") & Section 269ST Income Tax Act
1. **Statutory Cash Ceiling**:
   - Under **Section 269ST of the Income Tax Act, 1961**, no person shall receive an amount of **₹2,00,000 or more** in cash in a single day, or in respect of a single transaction, or in respect of transactions relating to one event from a person.
   - *Technical Enforcement*: The frontend strictly hard-codes a **₹1,99,999 ceiling** for doorstep cash collection requests. Any attempt to input or accumulate cash exceeding this limit is immediately blocked with a compliance warning.
2. **PAN Reporting Mandate (Rule 114B)**:
   - For cash payments exceeding **₹50,000**, Form 60 or a verified PAN number must be submitted by the patron. The frontend reminds patrons of this requirement during the pickup confirmation step.
3. **Chain of Custody Handover**:
   - To prevent fraudulent impersonation and ensure audit trail integrity, a **6-digit verification OTP** is generated upon booking. Physical cash handover requires the patron to verify the courier's official badge and communicate the OTP to complete custody transfer.
4. **Patron Address Collection (DPDPA 2023)**:
   - Street address and postal codes collected for cash pickup must be processed strictly for physical dispatch and never shared with third-party advertising brokers.

### 3.2 Bullion Rate Transparency & Valuation Calculator Outputs
1. **Estimate Disclaimer**:
   - The valuation calculator (`CalculatorScreen`) outputs calculated amounts based on prevailing benchmark rates. A clear statutory disclosure is required:
     > *"Valuation results are illustrative estimates based on prevailing market rates and do not constitute an irrevocable purchase contract or price guarantee until locked and booked at checkout."*
2. **Karat Metallurgy Transparency**:
   - Purity benchmarks must strictly distinguish 24K (999 pure gold), 22K (916 standard jewelry), and 18K (750 diamond jewelry). Silver bullion must not be represented using karat terminology.

### 3.3 Product Imagery, BIS Hallmarking & Consumer Protection
1. **Mandatory BIS Hallmarking**:
   - In compliance with the Bureau of Indian Standards (Hallmarking) Regulations, 2018, all gold jewelry depicted in the catalog must be accompanied by the 6-digit alphanumeric **HUID** statement.
2. **Authentic Photography & Asset Dependencies**:
   - In accordance with the Consumer Protection (E-Commerce) Rules, 2020, product images must represent authentic merchandise crafted by Swastik Jewellers. Missing studio assets (such as chain bracelets) must be provisioned without using deceptive representations.

### 3.4 Instagram SSO & Social Login Privacy
1. **Digital Personal Data Protection Act (DPDPA) 2023**:
   - Patron data ingested via Instagram authentication (User ID, Name, Media Handle) must be bound to a clear consent notice specifying that social credentials are used exclusively for account authentication and membership verification.

