# Authentication Frontend Flow Specification — Kitty App

**Project**: Swastik Jewellers Kitty App (Sub-Brand: Kitty Vault)  
**Primary Codebase**: `D:\kitty_app\`  
**Document Status**: Synchronized with Current Implementation  
**Last Audit Date**: 2026-09-23  

---

## 1. Authentication Architecture & State Machine

The Kitty App authentication subsystem is implemented as a 5-step journey:

```text
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  /auth/login    │ ──► │   /auth/phone    │ ──► │    /auth/otp    │
│(Instagram/Phone)│     │ (10-Digit Phone) │     │  (6-Digit Grid) │
└─────────────────┘     └──────────────────┘     └────────┬────────┘
                                                          │ Verified
                                                          ▼
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│      /home      │ ◄── │  /auth/success   │ ◄── │  /auth/profile  │
│  (Shell Tab 0)  │     │ (Welcome Badge)  │     │ (Name, Email)   │
└─────────────────┘     └──────────────────┘     └─────────────────┘
```

---

## 2. Granular Step Specifications

### 2.1 Step 0: Login Choice (`/auth/login`)
* **Visual Atmosphere**: Deep emerald background (`#05241C`), damask wallpaper texture, and continuous 3D rotating jewelry constellation canvas (`JewelryConstellationPainter`).
* **Authentication Options**:
  1. **Continue with Instagram**:
     - Displays luxury pill button with Instagram brand gradient icon (`AppColors.instagramPink` to `AppColors.instagramOrange` gradient), gold text, and champagne border.
     - Triggers `authController.loginWithInstagram()`.
     - *Implementation Architecture*: Frontend state abstraction with local session establishment. In offline/mock mode, logs patron into a verified demo session.
     - *Backend Requirement*: Real OAuth requires Meta App registration, Instagram Basic Display API callback integration (`POST /api/v1/auth/instagram/callback`), and JWT exchange.
  2. **Continue with Mobile Number**: Pushes `/auth/phone`.

### 2.2 Step 1: Mobile Phone Number Entry (`/auth/phone`)
* **Country Prefix**: Default `+91` (India).
* **Validation**: Exactly 10 digits; must match `^[6-9]\d{9}$`.
* **Input Formatting**: Formats automatically with a space: `XXXXX XXXXX`.
* **Action**: Dispatches `POST /api/v1/auth/send-otp` via `authControllerProvider`.

### 2.3 Step 2: 6-Digit OTP Verification (`/auth/otp`)
* **Input Grid**: 6 individual text cells.
* **Auto-Advance**: Typing in cell $n$ automatically focuses cell $n+1$.
* **Backspace Handling**: Pressing backspace in an empty cell focuses cell $n-1$.
* **Paste Support**: Pasting a 6-digit clipboard text populates all cells instantly.
* **Error Animation**: If verification fails, card triggers a 400ms damped sinusoidal shake animation ($\pm 8$px) and device vibrates (`HapticFeedback.heavyImpact()`).
* **Resend Countdown**: 30-second timer before "Resend Code" becomes active.
* **Testing Sandbox Fallback**: Entering OTP `123456` in mock mode authenticates immediately.

### 2.4 Step 3: Patron Profile Registration (`/auth/profile`)
* **Screen Class**: `RegisterProfileScreen`
* **Trigger**: Activated if user is newly registered and profile is incomplete.
* **Fields**:
  - Full Legal Name (2–50 characters)
  - Email Address (valid email regex)
  - City (2–40 characters)
* **Storage**: Updates `appAuthStateProvider` and commits to `SecureStorageService`.

### 2.5 Step 4: Authentication Success Splash (`/auth/success`)
* **Visuals**: Pulsing metallic gold crest, patron greeting ("Welcome, Rihan Saifi"), and tier badge ("Tier 1 Verified Member").
* **CTA**: "Enter Vault" $\rightarrow$ Routes to `/home` (or `/kyc` if statutory KYC is pending).

---

## 3. Session Security, Expiration & Logout

1. **Storage Security**:
   - JWT tokens stored in hardware-backed `SecureStorageService` (AES-256 GCM on Android KeyStore, Apple Keychain on iOS).
2. **Silent Token Refresh**:
   - `DioClient` intercepts HTTP 401 Unauthorized responses and invokes `POST /api/v1/auth/refresh-token`.
3. **Session Invalidation**:
   - If refresh fails, `appAuthStateProvider` resets to `unauthenticated`, clears storage keys, and redirects to `/auth/login`.
4. **Patron Logout Flow**:
   - Available via `LuxuryNavDrawer` and `MenuScreen` (`/menu`).
   - Presents confirmation dialog: "Are you sure you want to log out?".
   - On confirmation: clears all secure tokens, resets controllers, and transitions to `/auth/login`.
