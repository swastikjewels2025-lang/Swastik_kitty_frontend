# Swastik Kitty App — Release Checklist

**Application Name**: Swastik Kitty  
**Target Release**: Google Play Store (Production Track)  
**Package Name**: `com.swastikjewel.kittyapp`  
**Version**: `1.0.0+1` (Version Name: `1.0.0`, Version Code: `1`)  
**Audit Date**: 2026-09-18  

---

## 1. Technical & Engineering Checklist

| Item | Status | Evidence / Notes |
| :--- | :---: | :--- |
| **Production Application ID** | [x] **READY** | Configured as `com.swastikjewel.kittyapp` in `build.gradle.kts` and `MainActivity.kt`. |
| **Production App Label** | [x] **READY** | Configured as `Swastik Kitty` in `AndroidManifest.xml`. |
| **App Versioning** | [x] **READY** | Configured as `1.0.0+1` in `pubspec.yaml` (`versionCode 1`, `versionName 1.0.0`). |
| **Static Code Quality** | [x] **PASS** | `flutter analyze` passes with **0 errors, 0 warnings, 0 lints**. |
| **Automated Test Suite** | [x] **PASS** | **346 of 346 tests pass** (224 unit, 105 widget, 17 live backend). |
| **Network Security Config** | [x] **PASS** | `cleartextTrafficPermitted="false"` by default; system trust anchors only. |
| **Android Backup Disabled** | [x] **PASS** | `android:allowBackup="false"` in `AndroidManifest.xml`. |
| **Release MPIN Hashing** | [x] **PASS** | PBKDF2-HMAC-SHA256 (10,000 rounds, 128-bit random salt, constant-time verification). |
| **PII / Telemetry Redaction** | [x] **PASS** | Sensitive credentials, tokens, OTPs, Aadhaar, PAN redacted in telemetry. |
| **Mock API Production Guard** | [x] **READY** | `AppConfig` enforces `kReleaseMode` defaults: `AppEnvironment.prod` and `useMockApi = false`. |
| **Release Keystore Setup** | [x] **READY** | `android/key.properties.example` created; `build.gradle.kts` loads properties conditionally. |
| **Git & Secret Isolation** | [x] **PASS** | `key.properties`, `*.jks`, `*.keystore`, `.env` explicitly excluded in `.gitignore`. |
| **Release APK Build** | [x] **PASS** | `build\app\outputs\flutter-apk\app-release.apk` compiled (67.8 MB). |
| **Release AAB Build** | [x] **PASS** | `build\app\outputs\bundle\release\app-release.aab` compiled (65.8 MB). |

---

## 2. Business & Store Publishing Checklist (USER ACTION REQUIRED)

| Item | Status | Action Required |
| :--- | :---: | :--- |
| **Production Signing Keystore** | **USER ACTION REQUIRED** | Generate genuine production `.jks` file, create `android/key.properties`, and rebuild signed AAB. |
| **Production API Deployment** | **USER ACTION REQUIRED** | Deploy backend to live cloud server (`https://api.swastikjewel.com`) with valid SSL/TLS certificate. |
| **GoKwik Production Credentials** | **USER ACTION REQUIRED** | Obtain production Merchant App ID, App Secret, and Webhook Secret from GoKwik dashboard. |
| **High-Res App Icon (512x512)** | **USER ACTION REQUIRED** | Provide 512x512 PNG app icon following Google Play design guidelines for store listing. |
| **Feature Graphic (1024x500)** | **USER ACTION REQUIRED** | Provide 1024x500 PNG banner showcasing Swastik Jewellers gold scheme branding. |
| **Store Screenshots** | **USER ACTION REQUIRED** | Capture high-resolution screenshots (minimum 4, maximum 8) across phone and tablet viewports. |
| **Official Privacy Policy URL** | **USER ACTION REQUIRED** | Publish privacy policy on `swastikjewellers.com` domain and input link into Google Play Console. |
| **Data Safety Form** | **USER ACTION REQUIRED** | Complete Google Play Data Safety questionnaire using [`DATA_SAFETY_DRAFT.md`](file:///D:/kitty_app/DATA_SAFETY_DRAFT.md). |
| **Google Play Developer Account** | **USER ACTION REQUIRED** | Register / sign in to Google Play Console with Swastik Jewellers organization account. |
| **Merchant Account & Pricing** | **USER ACTION REQUIRED** | App is Free to install; transactions are savings deposits processed via external payment gateway. |
