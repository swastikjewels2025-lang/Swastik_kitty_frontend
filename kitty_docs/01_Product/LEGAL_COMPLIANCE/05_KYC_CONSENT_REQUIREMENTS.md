# KYC & Consent Requirements (PMLA & UIDAI) — Kitty App

**Project**: Swastik Jewellers Kitty App (Sub-Brand: Kitty Vault)  
**Primary Codebase**: `D:\kitty_app\`  
**Document Status**: Synchronized with Current Implementation  
**Last Audit Date**: 2026-09-23  

---

## 1. Statutory Thresholds under PMLA Rule 9

Under the **Prevention of Money Laundering Act (PMLA), 2002** and Government of India precious metal notifications:
* Dealers in precious metals and stones are reporting entities for cash transactions exceeding **₹50,000**.
* Retail jewellers must collect and verify PAN cards for any gold bullion or jewelry transaction where the aggregate value exceeds **₹2,00,000**.
* The Kitty App implements statutory KYC gating at `/kyc` prior to scheme maturity or high-value enrollment.

---

## 2. UIDAI Aadhaar Masking Regulations

The Aadhaar Act, 2016 and UIDAI circulars strictly regulate the collection and storage of Aadhaar credentials by non-banking private entities:

1. **Mandatory Masking**:
   - The application client and backend database must ensure that only the **last 4 digits** of the Aadhaar number are visible (`XXXX XXXX 1234`).
   - The first 8 digits must never be displayed in plain text on client screens or in digital receipts.
2. **Aadhaar Redaction Guidance**:
   - The upload interface on `KycScreen` advises patrons to upload a masked Aadhaar copy where the first 8 digits are obscured.
3. **Alternative ID Support**:
   - The client supports **PAN Card** as an equal primary verification alternative to prevent exclusive reliance on Aadhaar.

---

## 3. Mandatory Statutory Consent Checkbox

Before submitting documents on `/kyc`, patrons must check the statutory consent box containing the following legally vetted text:

> *"I hereby give voluntary consent to Swastik Jewellers to verify my identity document for statutory compliance under PMLA Rule 9 and Indian precious metal regulations. I understand my data is securely encrypted and will not be shared with unauthorized third parties."*
