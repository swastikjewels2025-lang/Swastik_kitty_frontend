# PHASE 20 — RELEASE ENGINEERING & PLAY STORE PREPARATION REPORT

**Project**: Flutter Kitty App (Swastik Jewellers Digital Gold Kitty / Kitty Vault)  
**Working Directory**: `D:\kitty_app`  
**Backend API**: `D:\Kitty_backend\Swastik_kitty_backend` (running on `http://localhost:5000/api/v1`)  
**UI / Design Source of Truth**: `D:\ui design\`  
**Documentation**: `D:\ui design\kitty_docs\`  
**Execution Timestamp**: 2026-09-18T13:58:00+05:30  
**Flutter SDK**: 3.47.4 (Channel stable) • Tools: Dart 3.13.3 • DevTools 2.60.0  

---

## 1. Executive Summary

Phase 20 concluded the final planned milestone of the Flutter Kitty App development lifecycle: **Release Engineering and Google Play Store Submission Preparation**. 

All technical release requirements have been implemented and verified:
- **Application ID Migration**: Successfully migrated Android package identity from development placeholder `com.example.kitty_app` to the approved production identifier `com.swastikjewel.kittyapp` (per `FRONTEND_DEVELOPMENT_ROADMAP.md:32`) with complete Kotlin package reorganization.
- **Application Branding**: Standardized Android launcher label to `"Swastik Kitty"` in `AndroidManifest.xml` (per `SOURCE_ANALYSIS.md`).
- **Release Signing Architecture**: Established a secure signing configuration pattern using `android/key.properties.example` and Git exclusions, with conditional fallback in `build.gradle.kts` to allow local release dry-runs without committing secrets.
- **Environment & Mock Isolation**: Hardened `AppConfig` so release builds (`kReleaseMode`) automatically enforce `AppEnvironment.prod` and `useMockApi = false`.
- **Packaging Verification**:
  - `flutter build apk --release`: Successfully generated `build\app\outputs\flutter-apk\app-release.apk` (**67.8 MB**).
  - `flutter build appbundle --release`: Successfully generated `build\app\outputs\bundle\release\app-release.aab` (**65.8 MB**).
- **Code Quality**: `flutter analyze` completed with **0 errors, 0 warnings, 0 lints**; all **346 automated tests pass** (100% pass rate).
- **Store Documentation Deliverables**: Created `DATA_SAFETY_DRAFT.md`, `PRIVACY_POLICY_REQUIREMENTS.md`, `RELEASE_CHECKLIST.md`, and `RELEASE_BUILD_INSTRUCTIONS.md`.

---

## 2. Current Project Identity

| Property | Value |
| :--- | :--- |
| **Flutter Project Name** | `kitty_app` |
| **Android Application ID** | `com.swastikjewel.kittyapp` |
| **Android Namespace** | `com.swastikjewel.kittyapp` |
| **Android App Label** | `Swastik Kitty` |
| **MainActivity Path** | `android/app/src/main/kotlin/com/swastikjewel/kittyapp/MainActivity.kt` |
| **Minimum SDK** | `21` (`flutter.minSdkVersion`) |
| **Target SDK** | `34` (`flutter.targetSdkVersion`) |
| **Compile SDK** | `34` (`flutter.compileSdkVersion`) |

---

## 3. Production Application ID

- **Previous ID**: `com.example.kitty_app` (development default).
- **Approved Production ID**: `com.swastikjewel.kittyapp` (identified in `D:\ui design\kitty_docs\planning\FRONTEND_DEVELOPMENT_ROADMAP.md:32`).
- **Action Taken**:
  - Updated `namespace = "com.swastikjewel.kittyapp"` in `android/app/build.gradle.kts`.
  - Updated `applicationId = "com.swastikjewel.kittyapp"` in `android/app/build.gradle.kts`.
  - Created new Kotlin file `android/app/src/main/kotlin/com/swastikjewel/kittyapp/MainActivity.kt` with `package com.swastikjewel.kittyapp`.
  - Removed outdated directory `android/app/src/main/kotlin/com/example/`.
- **Status**: **FIXED & VERIFIED**

---

## 4. Production App Name

- **Previous Label**: `kitty_app`.
- **Approved Product Branding**: `Swastik Kitty` / `Swastik Jewel Kitty App` (Feature: `Kitty Vault`) based on `SOURCE_ANALYSIS.md:94`.
- **Action Taken**:
  - Set `android:label="Swastik Kitty"` in `android/app/src/main/AndroidManifest.xml`.
  - Preserved internal Dart package name `kitty_app` in `pubspec.yaml` to avoid risky cross-module refactoring.
- **Status**: **FIXED & VERIFIED**

---

## 5. Version / Build Number

- **Version Declaration**: `version: 1.0.0+1` in `pubspec.yaml`.
- **Android Version Name**: `1.0.0` (derived from `flutter.versionName`).
- **Android Version Code**: `1` (derived from `flutter.versionCode`).
- **Policy Compliance**: Meets Google Play Store initial versioning standard (`1.0.0` / Code `1`).
- **Status**: **READY**

---

## 6. Environment Configuration

- **Configuration File**: `lib/core/config/app_config.dart`.
- **Production URL**: `https://api.swastikjewel.com` (base path `/api/v1`).
- **Release Guard**: Hardened `factory AppConfig` with `kReleaseMode`:
  - Release builds automatically default to `AppEnvironment.prod` and `useMockApi: false`.
  - Debug builds default to `AppEnvironment.mock` and `useMockApi: true`.
  - Dynamic overrides remain supported via `--dart-define=BASE_URL=...` and `--dart-define=ENVIRONMENT=...`.
- **Status**: **FIXED & VERIFIED**

---

## 7. Mock/Real Repository Audit

| Repository | Current Architecture | Reason for Current State | Production Acceptability | Future Action |
| :--- | :---: | :--- | :---: | :--- |
| **AuthRepository** | **Real Backend** | Live `/api/v1/auth/*` OTP dispatch and JWT verification. | **Production Ready** | None required. |
| **ProfileRepository** | **Real Backend** | Live `/api/v1/users/profile` patron information. | **Production Ready** | None required. |
| **KycRepository** | **Real Backend** | Live `/api/v1/users/kyc` multipart document upload. | **Production Ready** | None required. |
| **SchemeRepository** | **Real Backend** | Live `/api/v1/schemes/active` and `/api/v1/schemes/join`. | **Production Ready** | None required. |
| **DashboardRepository** | **Real Backend** | Live `/api/v1/memberships/my-dashboard` membership stats. | **Production Ready** | None required. |
| **GoldRateRepository** | **Real Backend** | Live `/api/v1/rates/gold` 24K & 22K rates. | **Production Ready** | None required. |
| **PaymentRepository** | **Real Backend** | Live `/api/v1/payments/initiate` and status polling. | **Production Ready** | Blocked by GoKwik credentials. |
| **ProductRepository** | *Client Local* | Catalog products are curated retail items; no backend API in Frozen Contract v1.0. | **Acceptable for v1.0** | Backend catalog API in v2. |
| **NotificationRepository** | *Client Local* | Notifications generated from local system events; no backend route in v1.0. | **Acceptable for v1.0** | Push notification service in v2. |
| **ReceiptRepository** | *Client Local* | PDF URL provided authoritatively by backend; fallback details render dynamically. | **Acceptable for v1.0** | Direct PDF download API in v2. |

- **Status**: **VERIFIED SAFE** (No mock data is masquerading as backend data).

---

## 8. Android Signing Status

- **Architecture**: Separated production keystore properties from version control.
- **Template Created**: `android/key.properties.example` with standard placeholders (`storePassword`, `keyPassword`, `keyAlias`, `storeFile`).
- **Gradle Integration**: `build.gradle.kts` loads `key.properties` conditionally:
  - When `key.properties` is present, `signingConfigs.release` signs the build with genuine keys.
  - When absent, `signingConfigs.debug` is used for developer dry-runs without breaking CI/local compilation.
- **Git Safety**: Excluded `**/key.properties`, `*.jks`, `*.keystore` in `.gitignore`.
- **Status**: **READY (PRODUCTION KEYSTORE = USER ACTION REQUIRED)**

---

## 9. Launcher Icon Status

- **Current Asset**: Official vector emblem located at `assets/icons/swastiklogo.svg`.
- **Android Mipmap State**: Default Flutter icon currently in `res/mipmap-*/ic_launcher.png`.
- **Status**: **USER ACTION REQUIRED**  
  *(The Swastik Jewellers design team must provide the official 512x512 PNG app icon for generation across mipmap densities. Per Phase 20 instructions, no placeholder or fabricated company logo was committed).*

---

## 10. Splash Status

- **Implementation**: `SplashScreen` (`lib/features/splash/presentation/screens/splash_screen.dart`).
- **Visuals**: Royal noir/emerald background (`#0B0B0E`), 3D crystal diamond animation, and fade-in of `assets/icons/swastiklogo.svg` + `KITTY VAULT` typography.
- **Launch Performance**: Native window background configured in `NormalTheme` and `LaunchTheme`.
- **Status**: **PASS (FROZEN & VERIFIED)**

---

## 11. Network Security

- **Configuration File**: `android/app/src/main/res/xml/network_security_config.xml`.
- **Base Policy**: `cleartextTrafficPermitted="false"`. Bank-grade HTTPS/TLS enforced by default.
- **Trust Anchors**: System CA certificates only (user-installed certificates rejected).
- **Development Whitelist**: Cleartext loopback strictly scoped to `10.0.2.2`, `localhost`, `127.0.0.1`, and `192.168.29.46`.
- **Status**: **PASS & VERIFIED**

---

## 12. Release Logging

- **Logging Interceptor**: Enforced in development only (`kDebugMode`); completely disabled in release builds.
- **Redaction Policy**: Deep recursive redaction of `password`, `otp`, `token`, `jwt`, `mpin`, `aadhaarNumber`, `panNumber`, and payment secrets.
- **Phone Masking**: Phone numbers formatted as `+91******XXXX`.
- **Raw Prints**: Zero unredacted `debugPrint` or `print` calls in release code paths.
- **Status**: **PASS & VERIFIED**

---

## 13. Asset Audit

- Total image and icon assets: 32 files.
- Unused or temporary debug assets: None.
- Asset tree-shaking:
  - `CupertinoIcons.ttf` reduced from 257 KB to 848 bytes (99.7% reduction).
  - `MaterialIcons-Regular.otf` reduced from 1.64 MB to 16 KB (99.0% reduction).
- Status: **PASS & OPTIMIZED**

---

## 14. APK Size

- **Path**: `build\app\outputs\flutter-apk\app-release.apk`
- **Size**: **67.8 MB** (Includes all 4 target ABIs: `arm64-v8a`, `armeabi-v7a`, `x86_64`, `x86`).

---

## 15. AAB Size

- **Path**: `build\app\outputs\bundle\release\app-release.aab`
- **Size**: **65.8 MB** (Google Play dynamically generates per-device splits under ~22 MB for end users).

---

## 16. R8 / Minification

- **Configuration**: Standard Flutter Gradle plugin release pipeline with Java 17 toolchain.
- **Aggressive Obfuscation**: Not forced to prevent runtime reflection issues with `flutter_secure_storage` and `local_auth`.
- **Stability**: Full compile-time stability preserved without risking plugin crashes.
- **Status**: **VERIFIED SAFE**

---

## 17. Release APK Result

```text
Command: flutter build apk --release
Duration: 302.3s
Exit Code: 0
Artifact: build\app\outputs\flutter-apk\app-release.apk (67.8MB)
Result: SUCCESS
```

---

## 18. Release AAB Result

```text
Command: flutter build appbundle --release
Duration: 61.7s
Exit Code: 0
Artifact: build\app\outputs\bundle\release\app-release.aab (65.8MB)
Result: SUCCESS
```

---

## 19. Smoke Test Result

| Component / Journey | Verification Method | Status |
| :--- | :--- | :---: |
| **App Launch & Splash** | Widget smoke test & compile verification | **PASS** |
| **Auth Flow (OTP / JWT)** | Live backend integration test suite | **PASS** |
| **Profile Resolution** | Live backend integration test suite | **PASS** |
| **KYC Document Upload** | Multipart upload live test (10MB boundary) | **PASS** |
| **Active Schemes & Join** | Live backend integration test suite | **PASS** |
| **Dashboard & Passbook** | Live backend integration test suite | **PASS** |
| **Payment Order Initiation** | Live backend integration test suite | **PASS** |
| **Payment Gateway Checkout** | Boundary tested (Blocked by credentials) | **BLOCKED (EXTERNAL)** |
| **Receipt Generation** | Widget and PDF launch test suite | **PASS** |
| **Notification Center** | Widget and controller test suite | **PASS** |
| **Settings & PBKDF2 MPIN** | Security test suite | **PASS** |
| **Session Invalidation & Logout** | 401 interceptor & logout test suite | **PASS** |

---

## 20. Git & Secret Safety

- `git status` audit confirms:
  - Zero private keys, JKS keystores, or `.env` files tracked.
  - Exclusions verified in `.gitignore`.
- Status: **VERIFIED SAFE**

---

## 21. Play Store Metadata Preparation

| Metadata Field | Draft Specification | Status |
| :--- | :--- | :---: |
| **App Name** | Swastik Kitty — Gold Savings | **DRAFT READY** |
| **Short Description** | Invest in digital gold kitty schemes with Swastik Jewellers. 11+1 bonus month! | **DRAFT READY** |
| **Full Description** | Securely enroll in Swastik Jewellers monthly gold kitty schemes. Track installments in real-time, view accumulated 24K gold weight, receive a 100% jeweler-sponsored 12th month bonus, and redeem for BIS hallmarked jewelry. | **DRAFT READY** |
| **Category** | Finance / Lifestyle | **DRAFT READY** |
| **Content Rating** | Everyone / 3+ | **DRAFT READY** |
| **Target Audience** | 18+ (Gold investment & chit schemes) | **DRAFT READY** |
| **Contact Email** | `support@swastikjewellers.com` | **USER ACTION REQUIRED** |

---

## 22. Data Safety

- Created standalone draft: [`DATA_SAFETY_DRAFT.md`](file:///D:/kitty_app/DATA_SAFETY_DRAFT.md).
- Accurately details phone numbers, profile data, KYC document uploads, and payment processor boundaries.
- Status: **DOCUMENTATION COMPLETE**

---

## 23. Privacy Policy

- Created specification: [`PRIVACY_POLICY_REQUIREMENTS.md`](file:///D:/kitty_app/PRIVACY_POLICY_REQUIREMENTS.md).
- Status: **USER ACTION REQUIRED** (Legal counsel must publish URL on official domain).

---

## 24. Screenshot Checklist

A screenshot capture specification has been created in [`RELEASE_CHECKLIST.md`](file:///D:/kitty_app/RELEASE_CHECKLIST.md) covering:
1. Splash Screen & 3D Crystal Diamond.
2. Phone OTP Authentication.
3. Home Screen & Live 24K Gold Ticker.
4. Active Scheme Dashboard & Progress Gauge.
5. 12-Month Passbook Table & Bonus Month.
6. KYC Document Upload & Verification Status.
7. Payment Checkout Modal.
8. Digital Installment Receipt & PDF Launch.

---

## 25. Remaining User Actions

> [!IMPORTANT]
> **USER ACTION REQUIRED**:
> 1. **Production Keystore**: Place the signed upload certificate in `android/` and configure `android/key.properties`.
> 2. **Production Backend URL**: Deploy backend to production server (`https://api.swastikjewel.com`) with valid SSL certificates.
> 3. **GoKwik Production Credentials**: Input genuine merchant credentials in backend `.env` to enable live payments.
> 4. **Store Assets**: Provide 512x512 app icon, 1024x500 feature graphic, and device screenshots.
> 5. **Privacy Policy Link**: Publish the privacy policy web page on `swastikjewellers.com` and submit to Google Play Console.

---

## 26. External Dependencies

1. **GoKwik Payment Gateway**: Live payments depend on merchant onboarding and sandbox/production API keys.
2. **Cloudinary Asset Storage**: Backend KYC document persistence requires production Cloudinary credentials.
3. **MSG91 SMS Gateway**: Transactional OTP delivery requires active DLT-approved SMS template.

---

## 27. Release Blockers

There are **zero frontend code defects or compilation blockers**. Release blockers are strictly external business/environmental items:
- Missing production keystore (`key.properties`).
- Missing live backend hosting deployment.
- Missing live GoKwik merchant account.

---

## 28. Final Test Results

| Test Suite | Total Tests | Passed | Failed | Skipped | Pass Rate |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Unit Tests** | 224 | 224 | 0 | 0 | 100.0% |
| **Widget Tests** | 105 | 105 | 0 | 0 | 100.0% |
| **Live Backend Integration Tests** | 17 | 17 | 0 | 0 | 100.0% |
| **Total Automated Tests** | **346** | **346** | **0** | **0** | **100.0%** |
| **Static Code Analyzer** | **0 Issues** | — | — | — | **100.0%** |

---

## 29. Final Release Readiness

- **Flutter Codebase**: **PRODUCTION READY**
- **Android Packaging**: **PRODUCTION READY**
- **Security & Integrity**: **PRODUCTION READY**
- **Store Documentation**: **PREPARED**
- **Deployment Status**: **PENDING BUSINESS ACTIONS (Keystore, URL, Store Assets)**

---

## 30. Final Phase 20 Status

```
PHASE 20 COMPLETE WITH USER ACTION REQUIRED
```
