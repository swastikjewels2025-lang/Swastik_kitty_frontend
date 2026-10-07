# Backend Handover & Architecture Overview

**Project**: Swastik Jewellers Kitty Savings App (Sub-Brand: **Kitty Vault**)  
**Target Backend Repository**: `D:\Kitty_backend\Swastik_kitty_backend\`  
**Target Mobile Client Repository**: `D:\kitty_app\`  
**Document Status**: Official Backend Engineering Handover Manual  
**Effective Date**: October 2026  

---

## 1. Project Purpose & High-Level Scope

The **Swastik Jewel Kitty App** is a digital gold savings scheme and installment management mobile application designed for patrons of **Swastik Jewellers**. It digitizes traditional Indian jewellery chit funds ("Kitty Schemes") with modern fintech transparency:

1. **Patron Onboarding & KYC**: Mobile OTP registration followed by mandatory statutory compliance (Aadhaar / PAN verification + document upload).
2. **Gold Savings Schemes (Kitty Plans)**: 11+1 month structured savings schemes where the jeweler pays the 12th installment as a 100% bonus deposit, accompanied by flat discounts on jewellery making charges.
3. **Lucky Number Selection**: Patrons choose their preferred lucky chit token number (01 to 50) upon joining.
4. **Transparent Passbook**: Digital tracking of paid installments, upcoming due dates, accumulated 24K gold weight, and live valuation.
5. **Flexible Payments**: Multi-month online checkout via GoKwik gateway (UPI, NetBanking, Cards) and doorstep cash pickup ("Pick Cash").
6. **Gold Bullion & Coins**: Real-time bullion rates and catalog for 24K 999 hallmark gold coins (4g, 5g, and custom weights).
7. **Gold Valuation Calculator**: Instant conversion of jewellery scrap/gold weights into equivalent Kitty scheme savings.
8. **In-App Jewellery Showroom**: Embedded luxury web bridge connecting patrons directly to the Swastik Jewellers catalog.

---

## 2. System Architecture & Component Responsibilities

The system follows a clean decoupled client-server architecture:

```
┌────────────────────────────────────────────────────────┐
│             Flutter Mobile Application                 │
│      (D:\kitty_app - Android & iOS Release Ready)      │
│  - Presentation: Riverpod State Management & GoRouter  │
│  - Data: Dio HTTP Client + SecureStorage KeyStore      │
└───────────────────────────┬────────────────────────────┘
                            │
               HTTPS REST API (JSON / Multipart)
               Bearer JWT Authentication
                            │
┌───────────────────────────▼────────────────────────────┐
│          Node.js / Express Backend API Gateway         │
│     (D:\Kitty_backend\Swastik_kitty_backend\src)       │
│  - Controllers & Business Logic Services               │
│  - JWT AuthGuard & Role-Based Access Control           │
│  - Multer Image / PDF Processing                       │
│  - PDFKit Digital Receipt Generator                    │
└─────────────┬───────────────────────────┬──────────────┘
              │                           │
┌─────────────▼──────────┐   ┌────────────▼──────────────┐
│  MongoDB Database      │   │ External Cloud Services   │
│  - Users & KYC         │   │ - GoKwik Payment Gateway  │
│  - Schemes & Members   │   │ - Cloudinary CDN Media    │
│  - Payments & Ledger   │   │ - Twilio / MSG91 SMS OTP  │
│  - Gold Rates & Audit  │   │ - WhatsApp Business API   │
└────────────────────────┘   └───────────────────────────┘
```

### 2.1 Separation of Responsibilities

| Responsibility | Frontend (Flutter) | Backend (Node.js/Express) |
| :--- | :---: | :---: |
| **UI & Animations** | Owner | None |
| **Input Form Validation (Client)** | Immediate visual feedback | Re-validates authoritatively |
| **User Authentication** | Submits credentials, stores JWT | Generates OTP, signs & validates JWT |
| **Financial Calculations & EMI** | Displays server figures | **Authoritative single source of truth** |
| **Scheme Capacity & Slot Locking** | Renders 01-50 availability grid | **Atomic race-condition locking** |
| **Payment Orders** | Launches GoKwik SDK / checkout | Creates GoKwik order, verifies HMAC |
| **Document Uploads** | Compresses image, sends multipart | Validates MIME, streams to Cloudinary |
| **Receipt Generation** | Displays PDF viewer modal | Generates cryptographically signed PDF |

---

## 3. Integration Flow & Environment Lifecycles

### 3.1 Local Development Environment
* **Backend**: Runs on `http://localhost:5000` via `npm run dev` (Node.js LTS).
* **Android Emulator**: Connects to `http://10.0.2.2:5000` (loopback bridge).
* **Physical Android Device / LAN**: Connects to `http://<DEV_MACHINE_IP>:5000` (e.g. `http://192.168.29.46:5000`).
* **Android Cleartext Config**: Already configured in `android/app/src/main/res/xml/network_security_config.xml` allowing `10.0.2.2`, `localhost`, `127.0.0.1`, and `192.168.29.46`.

### 3.2 Staging & Production Environments
* **Staging API**: `https://staging-api.swastikjewel.com/api/v1`
* **Production API**: `https://api.swastikjewel.com/api/v1`
* Bank-grade TLS 1.3 enforced. All cleartext HTTP traffic blocked in release builds.

---

## 4. Authentication Overview & Token Protocol

1. **Protocol**: HTTP Bearer Token (`Authorization: Bearer <JWT_TOKEN>`).
2. **Token Format**: Standard HS256 signed JSON Web Token.
3. **Token Payload Claims**:
   ```json
   {
     "id": "67039a48b71d4a001234abcd",
     "phone": "+919876543210",
     "role": "CUSTOMER",
     "iat": 1728280000,
     "exp": 1730872000
   }
   ```
4. **Token Expiry**: Default 30 days (`JWT_EXPIRES_IN=30d`).
5. **Storage**: Securely stored in device hardware keystore (`FlutterSecureStorage` using Android EncryptedSharedPreferences and iOS Keychain Services).
6. **Session Expiry (HTTP 401)**: The Flutter `DioClient` intercepts any 401 response, purges the local secure keystore, and transitions the app back to the login screen.
7. **Sandbox Test Account**: For automated tests and dev sessions, phone `+919876543210` accepts static OTP `123456`.
