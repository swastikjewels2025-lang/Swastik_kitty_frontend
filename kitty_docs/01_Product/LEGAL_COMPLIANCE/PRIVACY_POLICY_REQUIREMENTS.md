# Privacy Policy Requirements for Swastik Jewel Kitty App

**Application Name**: Swastik Kitty (Swastik Jewel Kitty App / Kitty Vault)  
**Package Name / Application ID**: `com.swastikjewel.kittyapp`  
**Target Platform**: Google Play Store (Android) & Apple App Store (iOS)  
**Document Status**: `USER ACTION REQUIRED` (For Legal / Compliance Review)  

---

## 1. Executive Notice

Google Play Store policy strictly requires a publicly accessible, active Privacy Policy URL before an application handling sensitive user data (including phone numbers, financial installment history, and government KYC identifiers) can be submitted for review.

> [!WARNING]
> **PRIVACY POLICY = USER ACTION REQUIRED**  
> An engineering agent cannot draft or certify binding legal terms. The business owners of Swastik Jewellers and their legal counsel must host an official Privacy Policy on their domain (e.g., `https://www.swastikjewellers.com/privacy-policy`) incorporating the technical disclosures detailed below.

---

## 2. Technical Disclosures Required in the Privacy Policy

### A. Entity Information
- **Legal Entity Name**: Swastik Jewellers Pvt. Ltd. (or appropriate legal business name).
- **Physical Address**: Retail showroom / corporate headquarters.
- **Support & Privacy Officer Contact**: Dedicated email address (e.g. `privacy@swastikjewellers.com` / `support@swastikjewellers.com`) and telephone contact.

### B. Categories of Data Collected
1. **Phone Number**: Collected during OTP authentication to establish and verify user account ownership.
2. **Patron Identity**: Full name, email address (optional), nominee name (optional).
3. **Government Identifiers & KYC Documents**: Aadhaar number and Permanent Account Number (PAN) details, along with uploaded identity document images (scans or camera captures, maximum 10MB) as mandated by Indian bullion trade and anti-money laundering (PMLA) regulations.
4. **Transaction & Ledger Data**: 11 monthly installments, 12th month bonus contributions, accumulated 24K gold weight (grams), maturity dates, and payment order reference codes.
5. **Local Device Storage**: Salted PBKDF2 MPIN hashes (10,000 iterations) and 30-day JWT authentication tokens stored in hardware-backed secure storage (`Android KeyStore`).

### C. Third-Party Data Processors
The policy must explicitly name and explain the role of third-party service providers:
1. **GoKwik Payment Gateway**: Processes credit cards, debit cards, UPI, and NetBanking transactions via hosted checkout. The Swastik Kitty application never directly accesses or stores raw card or banking credentials.
2. **Cloudinary Asset Storage**: Hosts encrypted KYC document images uploaded by users for administrative verification.
3. **SMS Gateway Provider (e.g. MSG91)**: Transmits 6-digit one-time password (OTP) verification codes to the user's mobile number.

### D. Security & Encryption Commitments
- All data transmission between the mobile application and backend servers is encrypted using standard Transport Layer Security (TLS 1.2+ / HTTPS).
- Cleartext HTTP traffic is disabled across production builds via Android Network Security Configuration (`network_security_config.xml`).
- Application backups to external storage and ADB extraction are disabled (`android:allowBackup="false"`).
- Local MPIN verification uses cryptographic salted hashes preventing plaintext recovery.

### E. Data Retention & Deletion Rights
- **Retention Period**: Statutory retention of financial transaction logs and KYC documents in accordance with applicable Indian financial and tax laws.
- **User Deletion Procedure**: Explicit instructions explaining how patrons can request account closure and data deletion by emailing the support desk with their registered mobile phone number.

---

## 3. Play Console Submission Checklist for Business Owner

- [ ] Privacy policy web page published and publicly accessible without login or password.
- [ ] URL entered into Google Play Console -> App Content -> Privacy Policy.
- [ ] URL matches company branding (`swastikjewellers.com`).
- [ ] Privacy policy includes link to account deletion request mechanism.
