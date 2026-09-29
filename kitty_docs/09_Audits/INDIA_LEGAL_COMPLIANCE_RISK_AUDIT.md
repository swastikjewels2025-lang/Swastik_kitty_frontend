# INDIA LEGAL & COMPLIANCE RISK AUDIT — KITTY APP

**Application / Brand**: Swastik Kitty / Kitty Vault (Swastik Jewellers)  
**Codebases Inspected**: `D:\kitty_app\` (Flutter) & `D:\Kitty_backend\Swastik_kitty_backend\` (Node.js/Express)  
**Audit Scope**: Risk Identification across Applicable Indian Laws & Regulations  
**Audit Nature**: **TECHNICAL & REGULATORY RISK IDENTIFICATION (NOT LEGAL ADVICE)**  
**Audit Date**: 2026-09-18  

---

## 1. Statutory & Regulatory Framework Overview

The application facilitates periodic recurring customer monetary payments (e.g. ₹5,000/month for 11 months) with a 1-month jeweller bonus (11+1) to accumulate 24K gold valuation for redemption in physical jewellery at Swastik Jewellers.

In the Indian legal landscape, such schemes intersect multiple complex statutes:
1. **Chit Funds Act, 1982**
2. **Prize Chits and Money Circulation Schemes (Banning) Act, 1978**
3. **Companies Act, 2013 & Companies (Acceptance of Deposits) Rules, 2014**
4. **Banning of Unregulated Deposit Schemes Act, 2019 (BUDS Act)**
5. **Reserve Bank of India (RBI) NBFC & Public Deposit Regulations**
6. **Prevention of Money Laundering Act, 2002 (PMLA) & Bullion Trade Rules**
7. **Digital Personal Data Protection Act, 2023 (DPDP Act)**
8. **Goods and Services Tax (GST) on Advance Receipts for Goods**
9. **Consumer Protection Act, 2019 & E-Commerce Rules**
10. **Bureau of Indian Standards (BIS) Hallmarking Regulations**

---

## 2. Risk Identification & Classification Matrix

| Regulatory Area | App Implementation Fact | Statutory Reference | Risk Classification | Legal / Operational Consideration |
| :--- | :--- | :--- | :---: | :--- |
| **"Kitty" & "Chit Token" Terminology** | App uses terms: "Kitty App", "Kitty Vault", "Chit Token #SW-042", "Token Number". | Section 4 & 11, *Chit Funds Act, 1982* | **POTENTIAL REGULATORY ISSUE** | In India, the term "Chit" or "Chit Fund" is legally protected. Using "Chit Token" implies a registered Chit Fund under the 1982 Act. If Swastik Jewellers is a retail jeweller operating an advance purchase scheme, using "Chit" creates severe regulatory confusion. Legal review must consider replacing "Chit Token" with "Membership ID" or "Enrollment Number". |
| **Lucky Draw / Winner Feature** | Backend contains `recordDrawWinnerController` (`POST /api/v1/admin/draw/record-winner`), marking `status = 'WINNER'`. In tests: *"Winner declared! Patron won Month 4 draw!"* | *Prize Chits and Money Circulation Schemes (Banning) Act, 1978* | **POTENTIAL REGULATORY ISSUE — REQUIRES LEGAL REVIEW** | **CRITICAL FINDING**: Under the 1978 Act, conventional prize chits or schemes where lots/draws are held to give prizes or waive future installments are strictly banned in India. If the Kitty scheme includes a lottery or lucky draw where winning patrons get jewellery without completing all payments, this presents substantial legal exposure. Counsel must verify whether this feature is active or must be completely decommissioned. |
| **365-Day Advance Limit** | Scheme duration is 12 months (11 payments + 1 bonus month = 365 days). | Rule 2(1)(c)(xii), *Companies (Acceptance of Deposits) Rules, 2014* | **CLEARLY REQUIRES DOCUMENTATION** | Under the Companies Act, advances received for the supply of goods (jewellery) are exempt from being treated as illegal "public deposits" **ONLY IF** the goods are delivered within **365 days** of receipt. Scheme terms must explicitly guarantee delivery of jewellery within 365 days. |
| **Banning of Unregulated Deposit Schemes** | Monthly installments collected from retail public with promises of a "1-month bonus". | *Banning of Unregulated Deposit Schemes Act, 2019 (BUDS Act)* | **REQUIRES LEGAL REVIEW** | Under the BUDS Act, schemes receiving deposits without specific statutory registration (e.g. RBI, SEBI, State Govt) are prohibited, UNLESS they qualify as legitimate commercial advances for goods. Scheme terms must clearly state that payments are advance payments for gold jewellery, not monetary deposits with interest. |
| **PMLA & KYC Compliance** | App collects Aadhaar and PAN documents $\le 10\text{ MB}$ with consent before high-value scheme enrollment. | *Prevention of Money Laundering Act, 2002* & Rule 9(1) of PMLA Rules | **LOWER RISK — COMPLIANT PATTERN** | Collecting PAN and government ID for high-value gold transactions ($\ge \text{₹2,00,000}$ or bullion purchase) is mandatory under Indian tax and PMLA guidelines. The app's KYC verification module aligns well with statutory requirements. |
| **Aadhaar Storage & Masking** | App collects 12-digit Aadhaar number and uploaded card image. | *Aadhaar Act, 2016* & UIDAI Regulations | **CLEARLY REQUIRES DOCUMENTATION** | Storing raw Aadhaar numbers or unmasked Aadhaar card images without UIDAI license or offline e-KYC integration has statutory restrictions. Legal counsel must ensure uploaded Aadhaar images have the first 8 digits masked (Virtual ID or Redaction), or provide Voter ID/Driving License as primary alternatives. |
| **Digital Data Protection** | App collects patron phone, name, KYC documents, and session data. | *Digital Personal Data Protection Act, 2023 (DPDP Act)* | **REQUIRES LEGAL REVIEW** | App includes explicit consent checkboxes during KYC and login. However, Swastik Jewellers must appoint a Data Protection / Grievance Officer, provide a data deletion workflow, and state explicit data retention periods in the published Privacy Policy. |
| **GST on Advances for Goods** | Payments collected monthly prior to physical supply of gold jewellery. | *Central Goods and Services Tax Act, 2017 (CGST Act)* | **CLEARLY REQUIRES DOCUMENTATION** | While GST on advances for goods (under Notification No. 66/2017-Central Tax) is exempted for standard registered suppliers, special rules apply to precious metals. Accounts counsel must clarify whether GST is charged upon monthly receipt or fully upon final invoice at maturity. |
| **Hallmarking & BIS Disclosures** | App promises "Hallmarked 999 24K Gold" and "22K Hallmark Ornaments". | *Bureau of Indian Standards (Hallmarking) Regulations, 2018* | **LOWER RISK** | Mandatory hallmarking applies to gold jewellery sold in India. Scheme terms should display Swastik Jewellers' BIS Hallmarking License number and 6-digit HUID (Hallmark Unique Identification) compliance statement. |
| **Refunds & Scheme Cancellation** | If a customer defaults or wishes to exit before Month 11, how is refund processed? | *Consumer Protection Act, 2019* & E-Commerce Rules | **CLEARLY REQUIRES DOCUMENTATION** | The app currently does not contain an automated in-app refund initiation flow. Scheme terms must explicitly define: (1) what happens to accumulated gold if a user defaults, (2) whether cash refunds are permitted or only gold vouchers, and (3) refund timelines. |

---

## 3. App Name & Branding Terminology Review

| Current App Terminology | Where Used | Potential Legal Misunderstanding | Recommended Safe Terminology |
| :--- | :--- | :--- | :--- |
| **"Kitty App" / "Kitty Vault"** | App title, splash screen, launcher | Colloquial term in North India; could be misconstrued as an unregulated kitty party / prize chit. | *"Swastik Suvarna"* or *"Swastik Gold Savings Vault"* |
| **"Chit Token" (`#SW-042`)** | Dashboard, Passbook, Receipts, Badges | Implies a registered chit fund under the *Chit Funds Act, 1982*. | *"Patron ID"*, *"Plan Token"*, or *"Enrollment Number"* |
| **"Draw Winner" / "Lucky Winner"** | Backend admin controller, test scripts | Directly triggers the *Prize Chits and Money Circulation Schemes (Banning) Act, 1978*. | **Decommission this feature entirely** unless operating under a licensed State lottery/chit approval. |
| **"Precious Gold Savings Vault"** | Login tagline, onboarding | Word "Savings" might imply a banking deposit account regulated by RBI. | *"Gold Purchase Advance Plan"* or *"Jewellery Booking Vault"* |
| **"100% Jeweler Bonus Deposit"** | Passbook Month 12 node | Word "Deposit" triggers BUDS Act / Companies Deposit Rules scrutiny. | *"100% Swastik Loyalty Contribution"* or *"Maturity Jewellery Discount"* |

---

## 4. Mandatory Legal Documents Checklist (Before Production)

The following legal agreements must be drafted by qualified Indian legal counsel and hosted on Swastik Jewellers' website:

1. [ ] **Comprehensive Terms & Conditions**:
   - Defining the legal business entity (e.g. Swastik Jewellers Pvt. Ltd., CIN/GSTIN).
   - Eligibility (Indian residents, 18+ years).
   - Non-transferability of membership.
2. [ ] **Gold Scheme Rules & Maturity Policy**:
   - Exact 11+1 installment schedule and due dates.
   - 365-day physical redemption guarantee.
   - Clarification that redemption is strictly in jewellery/coins, not cash withdrawal.
   - Making charge discount and loyalty bonus rules.
3. [ ] **Cancellation, Default & Exit Policy**:
   - Grace period for overdue installments (e.g. 15 days).
   - Pro-rata gold redemption if closed early (exclusion of 12th-month bonus if defaulted).
4. [ ] **Statutory Privacy Policy**:
   - Disclosures under DPDP Act 2023, PMLA, and IT Act 2000.
   - Data collection purpose, third-party processors (GoKwik, Cloudinary, MSG91), retention, and user deletion rights.
5. [ ] **Grievance Redressal Mechanism**:
   - Name, physical address, email, and phone number of the designated Grievance Officer (mandatory under Consumer Protection E-Commerce Rules, 2020).

---

## 5. Summary & Recommendation

> [!IMPORTANT]
> **LEGAL REVIEW REQUIRED**  
> 1. **Do not launch with "Lucky Draw" or "Winner" active in the backend**: Counsel must immediately review the backend `recordDrawWinnerController` against the *Prize Chits and Money Circulation Schemes (Banning) Act, 1978*. If this is an informal lucky draw, it should be removed from the production codebase.  
> 2. **Refine Terminology**: Transition from "Chit Token" to "Plan Token" or "Membership Number" to avoid unnecessary Chit Funds Act regulatory scrutiny.  
> 3. **Draft Authoritative Scheme Terms**: Ensure the 365-day jewellery delivery commitment is explicitly documented to maintain clear exemption under the Companies (Acceptance of Deposits) Rules, 2014.
