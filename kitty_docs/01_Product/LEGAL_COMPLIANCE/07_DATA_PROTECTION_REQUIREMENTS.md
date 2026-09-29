# Technical Security & Data Protection Requirements — Kitty App

**Project**: Swastik Jewellers Kitty App (Sub-Brand: Kitty Vault)  
**Primary Codebase**: `D:\kitty_app\`  
**Document Status**: Synchronized with Current Implementation  
**Last Audit Date**: 2026-09-23  

---

## 1. Technical Architecture & Cryptographic Safeguards

The Kitty App enforces bank-grade technical security standards to protect customer financial data and government identity records:

```text
┌────────────────────────────────────────────────────────┐
│ CLIENT CRYPTOGRAPHIC SAFEGUARDS                        │
├────────────────────────────────────────────────────────┤
│ • Transport Security: TLS 1.3 Mandatory                │
│ • Token Storage:      Android KeyStore (AES-256 GCM)   │
│                       Apple Keychain Protected         │
│ • Certificate Pinning:Production HTTPS Enforcement     │
│ • Logging Hygiene:    No PII or Tokens in System Logs  │
└────────────────────────────────────────────────────────┘
```

---

## 2. Mandatory Technical Controls

1. **Transport Layer Security (TLS)**:
   - All network traffic between Flutter mobile clients and the backend service must mandate **HTTPS with TLS 1.3** and strong cipher suites. Cleartext HTTP is blocked in release builds via Android `network_security_config.xml`.
2. **Local Token Hygiene**:
   - Authentication tokens (`swastik_jwt_token`, `swastik_refresh_token`) and MPIN hashes are stored exclusively in hardware-backed `SecureStorageService`.
   - Never write tokens or customer Aadhaar/PAN numbers into `SharedPreferences` or unencrypted local caches.
3. **Log Scrubbing**:
   - Production builds suppress `DioClient` logging interceptors to prevent sensitive customer payload exposure in device logcat.
4. **Isolated Payment Sandbox**:
   - Payment checkout is hosted within an isolated secure webview environment (`/gokwik-gateway`) preventing card details or UPI PINs from traversing the client application heap.
5. **Physical Pickup Data Protection & OTP Security**:
   - Patron physical street addresses and PIN codes collected for "Pick Cash" must be transmitted over TLS 1.3, encrypted at rest, and accessed exclusively by dispatch personnel on a need-to-know basis.
   - Handover OTPs are ephemeral tokens with a maximum lifespan of 24 hours, invalidated immediately upon status progression to `COLLECTED` or `EXPIRED`.

