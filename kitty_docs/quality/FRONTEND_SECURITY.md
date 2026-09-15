# Frontend Security Checklist & Guidelines

## 1. Overview & Security Boundary
This document establishes security practices and non-negotiable guidelines for the Swastik Jewel Kitty App frontend.

> [!IMPORTANT]
> **Boundary Reminder:** Frontend security measures are designed for defense-in-depth and client-side protection. True authorization enforcement, transaction idempotency, database security, payment signature verification, and sensitive cryptographic secrets remain exclusively the **Backend Developer's responsibility**.

---

## 2. Frontend Security Checklist

### 2.1 Token & Session Storage
- [x] **Platform Hardware Keychain:** JWT access tokens must **never** be stored in plaintext `SharedPreferences` (Android) or `NSUserDefaults` (iOS). Use `flutter_secure_storage`, which utilizes Android KeyStore (`EncryptedSharedPreferences` with AES-256 GCM) and iOS Keychain (protected with `kSecAttrAccessibleAfterFirstUnlock`).
- [x] **Web Storage Consideration:** For web prototypes or PWA builds, avoid storing sensitive tokens in unencrypted `localStorage` if XSS vulnerability exists. Prefer secure, HttpOnly session cookies where supported, or clear storage immediately upon tab closure.
- [x] **Memory Sanitization:** Clear token variables in memory immediately upon user logout.

---

### 2.2 Sensitive Data & PII (Personally Identifiable Information)
- [x] **Aadhaar Masking:** Statutory UIDAI regulations require masking of Aadhaar numbers. The UI must format and display only the last 4 digits (`XXXX XXXX 1234`) on review screens and settings.
- [x] **Camera & Gallery Ephemeral Caching:** Images captured via native camera for KYC must be stored in temporary app cache directories and wiped immediately after upload completion.
- [x] **Screen Capture / Screen Recording Protection:** On Android, flag `FLAG_SECURE` can be enabled on payment and KYC screens to prevent unauthorized background screenshots or screen recorders.

---

### 2.3 Secrets & API Keys
- [x] **Zero Server Secrets in Source Code:** Never embed database connection URIs, Twilio API tokens, Cloudinary API secrets, or GoKwik private secret keys in the frontend repository or compiled APK/IPA bundles.
- [x] **Environment Variables:** Only public client identifiers (such as `GOKWIK_APP_ID` or `API_BASE_URL`) may be injected via `--dart-define` at compile time.

---

### 2.4 Transport Security & HTTPS
- [x] **Enforce HTTPS:** All network requests to backend APIs must strictly utilize TLS 1.3 / HTTPS. Cleartext HTTP traffic must be rejected by Android Network Security Config and iOS App Transport Security (`NSAppTransportSecurity`).
- [x] **SSL Certificate Pinning (Production Recommendation):** In production builds, consider certificate pinning for the primary domain (`api.swastikjewels.com`) to prevent Man-in-the-Middle (MitM) inspection on compromised networks.

---

### 2.5 Input Sanitization & Client Validation
- [x] **Syntactic Format Enforcement:**
  - Phone input restricted to digits with international code validation.
  - Aadhaar input restricted to 12 digits.
  - PAN card formatted to strict statutory uppercase alphanumeric string (`[A-Z]{5}[0-9]{4}[A-Z]{1}`).
  - OTP fields restricted to numeric characters only.
- [x] **File Upload Restrictions:**
  - Enforce client-side file size cap at 10 MB before initiating upload.
  - Whitelist allowed MIME types (`image/jpeg`, `image/png`, `image/webp`, `application/pdf`).

---

### 2.6 Session Lifecycle & Interception
- [x] **HTTP 401 Unauthorized Interceptor:** The HTTP client interceptor must immediately catch any `401` response, wipe all cached session credentials, and redirect the user to `/auth/login` with a clear message: *"Session expired. Please sign in again."*
- [x] **Complete Logout Cleanup:**
  - Delete JWT from Keychain.
  - Delete cached user profile.
  - Reset all Riverpod state providers.
  - Clear temporary files directory.
  - Reset navigation stack to prevent back-navigation into protected screens.

---

### 2.7 Secure Telemetry & Logging
- [x] **Strip Sensitive Data in Production:** All `print()` or `console.log()` statements containing phone numbers, OTP codes, JWT tokens, or KYC numbers must be stripped or disabled in release builds (`if (kReleaseMode) { ... }`).
- [x] **Crash Reporting Sanitation:** Ensure Firebase Crashlytics or Sentry logs do not attach authorization headers or user identity documents to crash reports.

---

### 2.8 Biometric & MPIN Security
- [x] **Native Biometric Bridge:** Implement local biometric authentication (`local_auth` package) for opening the 12-Month Passbook or confirming high-value payments when enabled by user in `settings.html`.
- [x] **Biometric Fallback:** If biometric hardware fails or is unavailable, fallback to the user's 4-digit MPIN.
