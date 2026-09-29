# Frontend Environment Configuration Specification — Kitty App

**Project**: Swastik Jewellers Kitty App (Sub-Brand: Kitty Vault)  
**Primary Codebase**: `D:\kitty_app\`  
**Document Status**: Synchronized with Current Implementation  
**Last Audit Date**: 2026-09-23  

---

## 1. Centralized Configuration Service (`AppConfig`)

Environment parameters are managed centrally via `AppConfig` (`lib/core/config/app_config.dart`), supporting compile-time `--dart-define` arguments:

```text
┌────────────────────────────────────────────────────────┐
│ AppConfig Singleton (lib/core/config/app_config.dart) │
├────────────────────────────────────────────────────────┤
│ • ENVIRONMENT:    mock | dev | staging | prod          │
│ • BASE_URL:       Dynamic endpoint override            │
│ • USE_MOCK_API:   true | false (Offline sandbox mode)  │
│ • TIMEOUTS:       Connect: 15s | Receive: 15s          │
└────────────────────────────────────────────────────────┘
```

---

## 2. Environment Profiles & Defaults

| Profile | Target Environment | Default API Base URL | Default `USE_MOCK_API` |
| :--- | :--- | :--- | :---: |
| `mock` | Local Offline Sandbox / Widget Tests | `https://mock.kittyapp.local` | **`true`** |
| `dev` | Local Express Server & Emulator | `http://10.0.2.2:5000` (Android Alias) | **`false`** |
| `staging`| Cloud QA / Merchant User Acceptance | `https://staging-api.swastikjewel.com` | **`false`** |
| `prod` | Live Production Play Store Release | `https://api.swastikjewel.com` | **`false`** |

---

## 3. Build & Run Command Cheatsheet

### 3.1 Local Offline Sandbox (Default in Debug)
```bash
flutter run
# Defaults to ENVIRONMENT=mock, USE_MOCK_API=true
```

### 3.2 Local Live Backend (Against Express on Port 5000)
```bash
flutter run --dart-define=ENVIRONMENT=dev --dart-define=USE_MOCK_API=false
```

### 3.3 Production Release Build (Play Store APK / AAB)
```bash
# Release APK
flutter build apk --release --dart-define=ENVIRONMENT=prod --dart-define=USE_MOCK_API=false

# Release App Bundle (Google Play)
flutter build appbundle --release --dart-define=ENVIRONMENT=prod --dart-define=USE_MOCK_API=false
```
