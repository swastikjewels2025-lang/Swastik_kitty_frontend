# GOOGLE PLAY STORE READINESS AUDIT — KITTY APP

**Application Name**: Swastik Kitty  
**Target Marketplace**: Google Play Store (Production Track)  
**Package Name / Application ID**: `com.swastikjewel.kittyapp`  
**Audit Date**: 2026-09-18  
**Release Readiness Rating**: **TECHNICAL READY — USER / BUSINESS ACTIONS REQUIRED**  

---

## 1. Technical Release Configuration Audit

| Configuration Item | Required Standard | Current Project Value | Status | Evidence / Notes |
| :--- | :--- | :--- | :---: | :--- |
| **Application ID** | Unique company domain format | `com.swastikjewel.kittyapp` | ✅ **PASS** | `android/app/build.gradle.kts:27` |
| **Application Label** | Consistent branded title | `Swastik Kitty` | ✅ **PASS** | `android/app/src/main/AndroidManifest.xml:4` |
| **Version Code** | Incremental integer $\ge 1$ | `1` | ✅ **PASS** | `pubspec.yaml:19` (`versionCode: 1`) |
| **Version Name** | Semantic version string | `1.0.0` | ✅ **PASS** | `pubspec.yaml:19` (`versionName: 1.0.0`) |
| **Target SDK** | Android 14 (API level 34+) | `34` (`flutter.targetSdkVersion`) | ✅ **PASS** | Google Play 2024–2026 policy compliant |
| **Compile SDK** | API level 34+ | `34` (`flutter.compileSdkVersion`) | ✅ **PASS** | `android/app/build.gradle.kts:18` |
| **Minimum SDK** | API level 21+ | `21` (`flutter.minSdkVersion`) | ✅ **PASS** | Supports 99.2% of active Android devices |
| **Release Signing Architecture** | External keystore via properties | `key.properties.example` template | ⚠️ **USER ACTION REQUIRED** | Falls back to debug signing if `key.properties` missing. Production keystore must be generated. |
| **Production AAB Artifact** | `.aab` compiled and verified | `build\app\outputs\bundle\release\app-release.aab` (65.8 MB) | ✅ **PASS** | Verified build artifact exists |
| **Production APK Artifact** | Release APK for local smoke tests | `build\app\outputs\flutter-apk\app-release.apk` (67.8 MB) | ✅ **PASS** | Verified build artifact exists |
| **Network Security Config** | Cleartext traffic disabled | `cleartextTrafficPermitted="false"` | 🟡 **PARTIAL PASS** | Enforces HTTPS; whitelist contains `192.168.29.46` which must be removed before production submission. |
| **Android Backup Flag** | Secure data isolation | `android:allowBackup="false"` | ✅ **PASS** | `android/app/src/main/AndroidManifest.xml:7` |
| **Runtime Permissions** | Minimal necessary permissions | `INTERNET` only in Manifest | ✅ **PASS** | Camera/storage handled dynamically via system photo picker. |

---

## 2. Google Play Policy Classification & Financial Features

### Business Model Analysis
The application implements an advance recurring gold savings / installment scheme ("Kitty Scheme"):
- **Structure**: 11 customer monthly installments + 1 jeweller bonus installment (11+1 structure).
- **Commitment**: Fixed target amount (e.g. ₹60,000) redeemable strictly in 22K/24K gold jewellery, gold coins, or bullion.
- **Collateral / Credit**: No money is lent to users. The app does not charge interest, issue loans, or offer revolving credit lines.

### Critical Google Play Policy Distinctions:

#### 1. Personal Loans Policy — NOT APPLICABLE
> [!NOTE]
> The app **DOES NOT** provide personal loans, payday loans, peer-to-peer lending, or credit products.  
> It must **NOT** be declared under the Personal Loans category in Google Play Console. Declaring it as a loan app would trigger inappropriate requirements (such as NBFC loan license, APR disclosures, maximum repayment duration disclosures).

#### 2. Financial Features Declaration — CATEGORY INSPECTION
Google Play's Developer Console mandates that apps offering financial capabilities complete the **Financial Features Declaration**.
Within this declaration, Google Play explicitly includes:
- *"Crowdfunding and chit funds"*
- *"Banking"*
- *"Investment / Wealth management"*
- *"Accounting / Budgeting"*

**Crucial Recommendation for Business & Legal Counsel**:
1. If Swastik Jewellers operates this app as a **formally registered Chit Fund** under the *Chit Funds Act, 1982*, it **MUST** select the *"Crowdfunding and chit funds"* financial feature category and provide the State Chit Registrar registration details requested by Google Play.
2. If Swastik Jewellers operates this app as a **Retail Jewellery Advance Purchase / Booking Scheme** (exempt from deposit/chit rules under the Companies Act 2013 and BUDS Act 2019, where money paid is an advance for physical goods delivered within 365 days):
   - Selecting "Chit Funds" in Google Play may cause Google Play reviewers to demand a Chit Fund or NBFC financial institution license that a retail jeweler does not possess.
   - Legal counsel must review whether to declare it under retail purchase savings or financial features, and ensure the app's metadata explicitly specifies that it is a *jewellery purchase advance plan*.

---

## 3. Data Safety Declaration Matrix (Play Console Form)

Based on the actual code, data models, and storage mechanisms in the app, here is the factual Data Safety declaration required for Google Play Console:

| Data Type | Collected? | Shared with Third Parties? | Purpose | Ephemeral or Stored? | Security Standard |
| :--- | :---: | :---: | :--- | :---: | :--- |
| **Phone Number** | Yes | Yes (SMS Gateway MSG91 for OTP) | Account management, authentication, transaction SMS | Stored in MongoDB | Encrypted in transit (HTTPS) |
| **User Name** | Yes | No | Account management, personalizing passbook | Stored in MongoDB | Encrypted in transit (HTTPS) |
| **Aadhaar Number** | Yes | No (Strictly internal / regulatory) | Statutory KYC compliance for bullion purchase | Stored in MongoDB (hashed/encrypted) | Encrypted in transit (HTTPS) |
| **PAN Card Number** | Yes | No (Strictly internal / regulatory) | Income Tax & PMLA compliance for high-value gold | Stored in MongoDB (encrypted) | Encrypted in transit (HTTPS) |
| **KYC Document Images** | Yes | Yes (Cloudinary for secure hosting) | Identity verification as required by bullion trade rules | Stored in Cloudinary (private/authenticated) | Encrypted in transit (HTTPS) |
| **Payment History / Ledger**| Yes | Yes (GoKwik Gateway for processing) | Processing monthly installments, scheme fulfillment | Stored in MongoDB | Encrypted in transit (HTTPS) |
| **Device / Local Secrets** | Yes | No | 4-digit MPIN for local lock | Stored locally in Android KeyStore (PBKDF2) | Never transmitted |
| **App Diagnostics / Crashes**| No | No | No third-party crash reporting SDK included (e.g. Firebase Crashlytics not present) | N/A | N/A |

### User Rights & Deletion
- **Data Deletion Mechanism**: Google Play requires a data deletion request link. Swastik Jewellers must provide a web link (e.g. `https://www.swastikjewellers.com/account-deletion`) where users can submit account and data deletion requests.

---

## 4. Google Play Console Publishing Deliverables Checklist

### Business / Legal Actions Required:
- [ ] **Organization Developer Account**: Google Play Console account registered under Swastik Jewellers' legal corporate entity (requires D-U-N-S number verification).
- [ ] **Production Keystore (`.jks`)**: Generate genuine RSA-4096 production keystore, create `android/key.properties`, and execute clean release build.
- [ ] **Official Privacy Policy URL**: Publish privacy policy on `swastikjewellers.com` domain detailing phone, KYC, and payment handling.
- [ ] **Account Deletion URL**: Host active account deletion request form on official domain.
- [ ] **512x512 High-Res App Icon**: 32-bit PNG icon (up to 1024KB) without alpha transparency.
- [ ] **1024x500 Feature Graphic**: JPG or 24-bit PNG banner showcasing Swastik Jewellers Kitty Vault branding.
- [ ] **Store Screenshots**: Minimum 4 phone screenshots (16:9 or 9:16 aspect ratio, min 1080px) and tablet screenshots.
- [ ] **Short Description** (up to 80 chars): e.g., *"Exclusive digital gold savings scheme & installment vault by Swastik Jewellers."*
- [ ] **Full Description** (up to 4000 chars): Comprehensive overview of scheme terms, 11+1 bonus, hallmarked 24K gold accumulation, and store redemption details.
- [ ] **Content Rating Questionnaire**: Expected rating: Everyone / 3+ (Financial / Retail).
- [ ] **App Access Credentials**: Provide a test phone number (e.g. `+919876543210`) with fixed test OTP (`123456`) in Play Console App Access section so Google review team can inspect the app without an Indian SIM card.
