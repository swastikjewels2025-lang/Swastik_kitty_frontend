# Google Play Store Data Safety Declaration Draft

**Application Name**: Swastik Kitty (Swastik Jewel Kitty App / Kitty Vault)  
**Package Name / Application ID**: `com.swastikjewel.kittyapp`  
**Version**: `1.0.0` (Build `1`)  
**Assessment Date**: 2026-09-18  

---

## 1. Overview & Data Collection Architecture

This Data Safety inventory is derived strictly from the technical source code implementation of the Flutter Kitty App and its frozen backend contract v1.0.

- **Data in Transit**: All communications between the mobile application and the Swastik Jewellers backend are encrypted in transit via bank-grade Transport Layer Security (TLS/HTTPS). Cleartext HTTP is explicitly restricted to local developer loopback hosts (`10.0.2.2`, `localhost`, `127.0.0.1`).
- **Data Deletion Mechanism**: Users may request deletion of their account and personal records by contacting Swastik Jewellers customer support or through authorized account closure.
- **Sensitive Client Storage**: Sensitive credentials (JWT auth tokens and 10,000-iteration PBKDF2 MPIN hashes) are stored exclusively in hardware-backed secure storage via `FlutterSecureStorage` (Android KeyStore with AES-256 / RSA hardware encryption).

---

## 2. Comprehensive Data Category Breakdown

### A. Personal Information

| Data Type | Collected? | Shared? | Purpose of Collection | Ephemeral / Stored |
| :--- | :---: | :---: | :--- | :--- |
| **Phone Number** | **Yes** | **No** | **Account Management & Authentication** (Primary identifier for 6-digit SMS OTP login and customer profile association). | Stored securely in backend database; cached in local hardware secure storage. |
| **Name** | **Yes** | **No** | **App Functionality & Personalization** (Displayed on header greeting, passbook, and digital payment receipts). | Stored in backend database; retrieved on profile fetch. |
| **Email Address** | **Optional** | **No** | **Account Management & Communications** (Optional receipt delivery and notification contact). | Stored in backend database if provided. |
| **User Identifiers** | **Yes** | **No** | **Account Management** (Internal UUID / MongoDB ObjectID and Membership ID `MEM-...`). | Stored in backend; referenced in state. |

---

### B. Financial Information

| Data Type | Collected? | Shared? | Purpose of Collection | Ephemeral / Stored |
| :--- | :---: | :---: | :--- | :--- |
| **User Payment Info (Cards, UPI, NetBanking)** | **No (Client-Side)** | **Yes (Gateway)** | **Purchase & Installment Fulfillment**. Payment details are entered directly inside the PCI-DSS certified hosted gateway (GoKwik). | The Flutter app **never** collects, processes, or stores card numbers, CVVs, or bank account credentials. |
| **Purchase & Installment History** | **Yes** | **No** | **Financial Accounting & Passbook Records** (Tracking 11 monthly installments, 12th month bonus, gold weight allocation, and payment status). | Stored authoritatively on backend server; rendered in Passbook ledger. |
| **Credit Info / Credit Score** | **No** | **No** | Not collected. | N/A |

---

### C. Government & Regulatory ID (KYC)

| Data Type | Collected? | Shared? | Purpose of Collection | Ephemeral / Stored |
| :--- | :---: | :---: | :--- | :--- |
| **Aadhaar Number / PAN Number** | **Yes** | **No** | **Fraud Prevention, Legal Compliance & KYC**. Gold savings schemes in India are subject to anti-money laundering (PMLA) and Jeweller KYC compliance. | Stored in secure backend database; masked in application logs and redacted from telemetry. |
| **Identity Document Photos / Scans** | **Yes** | **Yes (Cloud Storage)** | **KYC Verification**. Document images (Aadhaar card / PAN card, max 10MB) uploaded via multipart form. | Uploaded to secure asset repository (Cloudinary) for admin CRM verification. Not cached on device. |

---

### D. Photos and Videos

| Data Type | Collected? | Shared? | Purpose of Collection | Ephemeral / Stored |
| :--- | :---: | :---: | :--- | :--- |
| **Photos / Files (Document Picker)** | **Yes** | **Yes (Cloud Storage)** | **KYC Document Upload**. Triggered only when the user explicitly selects an identity document or takes a camera photo. | Transmitted directly to backend KYC endpoint; temporary cache cleared after transmission. |

---

### E. App Info and Performance

| Data Type | Collected? | Shared? | Purpose of Collection | Ephemeral / Stored |
| :--- | :---: | :---: | :--- | :--- |
| **Crash Logs & Diagnostics** | **No** | **No** | No external third-party telemetry (Firebase Crashlytics / Sentry) currently enabled in codebase. | Ephemeral in-memory logging in debug builds only (`kDebugMode`). |
| **Device or other IDs** | **No** | **No** | No advertising IDs (AD_ID) or hardware IMEI collected. | N/A |

---

## 3. Third-Party Service Integrations

1. **GoKwik Payment Gateway**:
   - **Data Shared**: Order ID, installment amount (rupees), patron phone number, patron name.
   - **Reason**: Payment processing and hosted checkout invocation.
   - **Classification**: Service Provider / Payment Processor.
2. **Cloudinary Asset Storage**:
   - **Data Shared**: KYC document image binaries.
   - **Reason**: Cloud document storage for backend administrative verification.
3. **SMS Gateway (MSG91)**:
   - **Data Shared**: Mobile phone number, 6-digit one-time password (OTP).
   - **Reason**: Transactional OTP authentication dispatch.

---

## 4. Google Play Console Form Answers Summary

| Play Console Question | Technical Answer |
| :--- | :--- |
| Does your app collect or share any user data? | **Yes** |
| Is all user data collected by your app encrypted in transit? | **Yes** (HTTPS/TLS enforced; cleartext traffic disabled by default) |
| Do you provide a way for users to request that their data be deleted? | **Yes** (Via customer support account closure protocol) |
| Is this data collection required or can users choose if it is collected? | **Required for Account & KYC; Optional for Profile Email** |
| Do you collect location data? | **No** |
| Do you collect contacts? | **No** |
| Do you collect Web Browsing history? | **No** |
| Is the data shared with third parties? | **Yes, only with technical service providers (payment processor, SMS gateway, document storage)** |

---

## 5. Items Requiring Legal / Business Sign-Off

> [!CAUTION]
> **USER ACTION REQUIRED**:
> - Formal confirmation from Swastik Jewellers legal counsel on PMLA compliance data retention periods (e.g. 5-year retention for KYC records as mandated by Indian financial regulations).
> - Confirmation of dedicated data deletion contact URL / email (e.g., `privacy@swastikjewellers.com`).
