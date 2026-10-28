# Frontend & Backend Coordination Registry

This document tracks all API contracts, shared dependencies, authentication specifications, and integration tasks between the Frontend (Flutter) and Backend (Node.js/Express) teams.

---

## 🌐 Network & Environment Baseline

| Parameter | Current Value | Notes |
| :--- | :--- | :--- |
| **Development Host** | `http://192.168.29.42:5000` | Active computer Wi-Fi IPv4 address |
| **API Version Prefix** | `/api/v1` | All REST endpoints prefixed with `/api/v1` |
| **Cleartext HTTP** | Enabled for `192.168.29.42` & `10.0.2.2` | Configured in `network_security_config.xml` |
| **ADB Reverse Bridge** | `tcp:5000 -> tcp:5000` | Allows physical USB debugging over `localhost:5000` |
| **Authentication Scheme** | `Bearer <JWT_TOKEN>` | Injected via `AuthInterceptor` in Dio client |

---

## 📡 Active API Endpoints Matrix

### 1. Authentication (`/api/v1/auth`)

* **Google iOS Client ID:** `720641978952-amt2equ03qkeodsk7pnrct862rbnvtuf.apps.googleusercontent.com`
* **Google iOS Reversed Scheme:** `com.googleusercontent.apps.720641978952-amt2equ03qkeodsk7pnrct862rbnvtuf`
* **Apple Auth:** Native iOS `AuthenticationServices` framework via Swift Package Manager (No CocoaPods).

| Endpoint | Method | Request Payload | Response Data | Auth Req | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `/auth/send-otp` | `POST` | `{"phone": "+91XXXXXXXXXX"}` | `{"phone", "expiresInSeconds", "isExistingUser", "userName"}` | No | ✅ Verified Live |
| `/auth/verify-otp` | `POST` | `{"phone": "+91XXXXXXXXXX", "otp": "XXXXXX"}` | `{"token", "isNewUser", "user": {...}}` | No | ✅ Verified Live |
| `/auth/google` | `POST` | `{"idToken", "email", "name", "phone"}` | `{"token", "isNewUser", "requiresPhoneVerification", "user": {...}}` | No | ✅ Integrated & Tested |
| `/auth/apple` | `POST` | `{"identityToken", "userIdentifier", "email", "name"}` | `{"token", "isNewUser", "requiresPhoneVerification", "user": {...}}` | No | ✅ Integrated & Tested |
| `/auth/link-phone` | `POST` | `{"phone", "otp"}` | `{"user": {...}}` | Yes | ✅ Integrated & Tested |
| `/auth/logout` | `POST` | `{}` | `{"message": "Logged out successfully."}` | Yes | ✅ Integrated |

### 2. User Profile & Registration (`/api/v1/users`)

| Endpoint | Method | Request Payload | Response Data | Auth Req | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `/users/profile` | `GET` | _None_ | `{"id", "name", "email", "phone", "dateOfBirth", "address", "city", "pincode", "nominee", "kyc": {...}}` | Yes | ✅ Verified Live |
| `/users/profile` | `PUT` | `{"name", "email", "phone", "dateOfBirth", "address", "city", "pincode", "nominee": {"name", "relationship", "phone"}}` | Updated `user` object | Yes | ✅ Integrated |
| `/users/kyc` | `POST` | Multipart (`file`, `documentType`, `documentNumber`) | `{"kyc": {"status", "documentUrl", ...}}` | Yes | ✅ Integrated |

### 3. Savings Schemes & Discovery (`/api/v1/schemes`)

| Endpoint | Method | Request Payload | Response Data | Auth Req | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `/schemes/active` | `GET` | Optional query `?duration=12` | `{"schemes": [...]}` | No | ✅ Verified Live |

### 4. Memberships & Passbook (`/api/v1/memberships`)

| Endpoint | Method | Request Payload | Response Data | Auth Req | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `/memberships/join` | `POST` | `{"schemeId", "paymentFrequency", "paymentMethod"}` | `{"membership": {...}}` | Yes | ✅ Integrated |
| `/memberships/my-dashboard` | `GET` | _None_ | `{"memberships", "totalGoldWeightGrams", "nextInstallmentDue", "passbook": [...]}` | Yes | ✅ Integrated |

### 5. Payments (`/api/v1/payments`)

| Endpoint | Method | Request Payload | Response Data | Auth Req | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `/payments/initiate` | `POST` | `{"membershipId", "amount", "monthIndex", "paymentMethod"}` | `{"orderId", "paymentUrl", "gatewayOrderId"}` | Yes | ✅ Integrated |
| `/payments/status/:orderId` | `GET` | Path param `orderId` | `{"orderId", "status", "receiptUrl", ...}` | Yes | ✅ Integrated |

### 6. Live Rates Benchmark (`/api/v1/rates`)

| Endpoint | Method | Request Payload | Response Data | Auth Req | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `/rates/gold` | `GET` | _None_ | `{"rate24k", "rate22k", "rateChangePct", "unit", "currency"}` | No | ✅ Verified Live |

---

## 🔄 Pending Backend / Frontend Action Items

| Item | Responsible | Description | Status |
| :--- | :--- | :--- | :--- |
| **Live SMS Gateway** | Backend Developer | Wire MSG91 API credentials into `.env` for production SMS delivery. Current dev environment logs OTP to console and supports sandbox OTP `123456`. | Pending confirmation |
| **Cloudinary Production Keys** | Backend Developer | Provide real Cloudinary credentials for KYC document and receipt storage. | Pending confirmation |
| **GoKwik Production Webhooks** | Backend Developer | Configure production webhook secrets and sandbox credentials. | Pending confirmation |
| **Onboarding Form UI Redesign** | Frontend Developer | Redesign 3 onboarding screens into unified, centered card forms with internal placeholders. | ✅ Completed |
