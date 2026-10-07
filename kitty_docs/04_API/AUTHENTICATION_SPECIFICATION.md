# Authentication Specification & Protocol

**Project**: Swastik Jewellers Kitty Savings App  
**Location**: `kitty_frontend/kitty_docs/04_API/AUTHENTICATION_SPECIFICATION.md`  
**Status**: Complete Specification  

---

## 1. Authentication Overview

The Swastik Kitty App uses mobile phone-based One-Time-Password (OTP) authentication as its primary identity mechanism, accompanied by optional Google OAuth2 Sign-In:

1. **Patron Identification**: Each patron is uniquely identified in MongoDB by their validated Indian phone number (`phone: String`, unique index, E.164 standard `+91XXXXXXXXXX`).
2. **Session Credential**: Upon successful OTP or Google authentication, the backend issues an industry-standard signed JSON Web Token (JWT) with HMAC-SHA256.
3. **Client Session Storage**: The JWT is stored in hardware-encrypted secure storage (`FlutterSecureStorage` using Android Keystore and iOS Keychain Services).
4. **Request Authorization**: Injected automatically by the Dio HTTP interceptor into the `Authorization: Bearer <TOKEN>` header on every authenticated request.
5. **Session Expiry & Eviction**: On receiving HTTP 401 Unauthorized, the mobile client purges the secure keystore and routes the user back to `/auth/login`.

---

## 2. Phone + OTP Authentication Protocol

### 2.1 OTP Generation & Dispatch
* **Endpoint**: `POST /api/v1/auth/send-otp`
* **Implementation Status**: `[IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Controller**: `src/controllers/auth.controller.js`
* **Service**: `src/services/auth.service.js`
* **Validation**:
  * Phone must match regex: `/^\+91[6-9]\d{9}$/`
* **Security & Rate Limiting**:
  * Max 3 OTP requests allowed per 15-minute sliding window.
  * 60-second cooldown required between consecutive requests for the same phone.
  * Violations return `429 Too Many Requests` with `RATE_LIMIT_EXCEEDED`.
* **OTP Characteristics**:
  * Cryptographically random 6-digit number (`100000` to `999999`).
  * Time-To-Live (TTL): 300 seconds (5 minutes).
  * Maximum incorrect attempts: 3. Upon 3 failures, OTP is permanently invalidated (`OTP_LOCKED`).

### 2.2 Sandbox & Testing Credentials
To facilitate development, automated QA, and Play Store review without draining SMS credits:
* **Test Phone**: `+919876543210`
* **Static Bypass OTP**: `123456`
* Any request with OTP `123456` against `+919876543210` bypasses SMS and validates immediately in all environments.

### 2.3 OTP Verification & Token Issuance
* **Endpoint**: `POST /api/v1/auth/verify-otp`
* **Implementation Status**: `[IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Workflow**:
  1. Validates OTP against in-memory or Redis OTP store.
  2. Queries `User` collection. If user does not exist, atomically creates new user document with `role: 'CUSTOMER'` and `tier: 'Standard Member'`.
  3. Signs JWT containing `id`, `phone`, `role`.
  4. Returns `{ token, isNewUser, user }`.

---

## 3. Google Sign-In Specification

* **Endpoint**: `POST /api/v1/auth/google`
* **Implementation Status**: `[REQUIRED / NOT CURRENTLY IMPLEMENTED]`
* **Frontend Screen**: `lib/features/auth/presentation/screens/login_screen.dart` (Google button).
* **Backend Requirement**:
  * Accept Google `idToken` from mobile client.
  * Verify token integrity using Google Public Keys (`google-auth-library` or `googleapis`).
  * Extract verified email, name, and subject ID.
  * Link with existing User document if phone or email matches, or create a new user profile with Google metadata.
  * Return identical `{ token, isNewUser, user }` session response.

---

## 4. JWT Token Lifecycle & Claims

### 4.1 Token Schema
* **Algorithm**: HMAC-SHA256 (HS256)
* **Secret**: Managed via `process.env.JWT_SECRET`
* **Payload Structure**:
  ```json
  {
    "id": "67039a48b71d4a001234abcd",
    "phone": "+919876543210",
    "role": "CUSTOMER",
    "iat": 1728280000,
    "exp": 1730872000
  }
  ```

### 4.2 Expiry & Refresh Behavior
* **Token Expiry**: 30 days (`JWT_EXPIRES_IN=30d`).
* **Refresh Tokens**: Currently not required; mobile banking UX uses persistent 30-day session with biometrics / MPIN gating (`local_auth`) for high-security actions.
* **Revocation / Logout**: `POST /api/v1/auth/logout` invalidates token client-side and removes server-side session cache.

---

## 5. Security & Biometric Integration

* **Biometric Lock (FaceID / Fingerprint)**: Handled on the Flutter device via `local_auth`. Used as an extra layer before opening passbook or initiating transactions.
* **No Plaintext Passwords**: The system is completely passwordless, preventing credential stuffing attacks.
