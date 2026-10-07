# Environment Configuration & Deployment Specification

**Project**: Swastik Jewellers Kitty Savings App  
**Location**: `kitty_frontend/kitty_docs/00_Project/ENVIRONMENT_CONFIGURATION.md`  
**Status**: Complete Specification (Sanitized Secrets)  

---

## 1. Security Directive on Secrets & Credentials

> [!CAUTION]
> **ZERO SECRETS POLICY:**  
> Never commit actual production API keys, JWT secrets, database connection passwords, or service-account JSON credentials into source control or documentation.  
> All configuration files must use placeholder variables.

---

## 2. Backend Environment Variables (`.env.example`)

The Node.js Express backend (`Swastik_kitty_backend`) requires the following environment variables:

```bash
# Server Configuration
PORT=5000
NODE_ENV=development

# Database Configuration (MongoDB Replica Set)
MONGO_URI=mongodb://localhost:27017/swastik_kitty

# JWT Authentication
JWT_SECRET=<32_CHARACTER_CRYPTOGRAPHIC_RANDOM_STRING>
JWT_EXPIRES_IN=30d

# GoKwik Payment Gateway
GOKWIK_APP_ID=<GOKWIK_APP_IDENTIFIER>
GOKWIK_APP_SECRET=<GOKWIK_APP_SECRET_KEY>
GOKWIK_BASE_URL=https://sandbox.gokwik.co
GOKWIK_WEBHOOK_SECRET=<GOKWIK_HMAC_WEBHOOK_SIGNING_SECRET>

# Cloudinary Asset Storage (KYC Documents & Receipt PDFs)
CLOUDINARY_CLOUD_NAME=swastik
CLOUDINARY_API_KEY=<CLOUDINARY_API_KEY>
CLOUDINARY_API_SECRET=<CLOUDINARY_API_SECRET>

# SMS / Notification Gateway (Twilio / MSG91)
SMS_GATEWAY_PROVIDER=msg91
MSG91_AUTH_KEY=<MSG91_AUTH_KEY>
MSG91_SENDER_ID=SWASTK
MSG91_OTP_TEMPLATE_ID=<TEMPLATE_ID>

# CORS & Allowed Origins
CORS_ORIGIN=http://localhost:3000,http://localhost:5000
```

---

## 3. Mobile Client Configuration (`Flutter`)

The Flutter application (`kitty_app`) configures its remote API gateway using `AppConstants` and optional compile-time `--dart-define` parameters:

### 3.1 Network Addresses

| Environment | Host Address | Target Device | Notes |
| :--- | :--- | :--- | :--- |
| **Local Emulator** | `http://10.0.2.2:5000` | Android Studio Emulator | Android loopback interface to host machine. |
| **Local Physical Device** | `http://192.168.29.46:5000` | Physical Android / iOS over Wi-Fi | Local development LAN IP. |
| **Staging Cloud** | `https://staging-api.swastikjewel.com` | TestFlight / Internal Testing APK | Staging server with mock GoKwik sandbox. |
| **Production Cloud** | `https://api.swastikjewel.com` | Play Store / App Store Release | Production environment with live payments. |

### 3.2 Compile-Time Defines Example
```bash
flutter build apk --dart-define=API_BASE_URL=https://api.swastikjewel.com
```

### 3.3 Android Network Security Configuration
Already implemented in `android/app/src/main/res/xml/network_security_config.xml`:
* Cleartext HTTP is permitted for `10.0.2.2`, `localhost`, `127.0.0.1`, and `192.168.29.46` during local debugging.
* All other host traffic requires valid TLS certificates.
