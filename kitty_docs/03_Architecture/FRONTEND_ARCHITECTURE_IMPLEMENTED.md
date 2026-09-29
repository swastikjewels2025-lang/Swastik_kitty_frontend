# Frontend Architecture Specification — Kitty App

**Project**: Swastik Jewellers Kitty App (Sub-Brand: Kitty Vault)  
**Primary Codebase**: `D:\kitty_app\`  
**Document Status**: Synchronized with Current Implementation  
**Last Audit Date**: 2026-09-23  

---

## 1. Architectural Paradigm: Feature-First MVVM + Riverpod

The application is structured as a **Feature-First Model-View-ViewModel (MVVM)** architecture powered by **Flutter Riverpod 2.x**:

```text
┌────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                   │
│  Widgets, Screens, Painters, Controllers (StateNotifier)│
└───────────────────────────▲────────────────────────────┘
                            │ Watches / Reads State
┌───────────────────────────┴────────────────────────────┐
│                      DOMAIN LAYER                      │
│      Entities, Value Objects, Repository Interfaces    │
└───────────────────────────▲────────────────────────────┘
                            │ Implements / Mediates
┌───────────────────────────┴────────────────────────────┐
│                      DATA LAYER                        │
│ Data Sources (Dio / Mock Fixtures), Models, Storage    │
└────────────────────────────────────────────────────────┘
```

---

## 2. Directory Layout & Module Organization

```text
D:\kitty_app\lib\
├── main.dart                          # Application entry point & ProviderScope bootstrap
├── app/
│   ├── app.dart                       # MaterialApp.router configuration
│   └── app_bootstrap.dart             # Async initialization (Storage, Config, Fonts)
│
├── core/                              # Shared cross-cutting infrastructure
│   ├── config/
│   │   ├── app_config.dart            # Environment profiles (mock/dev/staging/prod)
│   │   ├── app_constants.dart         # Global timeouts, limits, and URLs
│   │   └── app_environment.dart       # AppEnvironment enum
│   ├── constants/
│   │   ├── app_colors.dart            # Dual-surface color tokens (Emerald & Warm Luxury)
│   │   ├── app_dimensions.dart        # Responsive container constraints
│   │   ├── app_spacing.dart           # Standard spacing & border radii
│   │   └── app_typography.dart        # Cinzel, Playfair Display & Montserrat styles
│   ├── enums/
│   │   └── app_enums.dart             # Status enums with defensive .unknown deserializers
│   ├── errors/
│   │   ├── app_exception.dart         # Mapped application exceptions
│   │   └── failure.dart               # Domain failure wrappers
│   ├── mock/
│   │   └── mock_fixtures.dart         # Static JSON payloads for all 18 backend contracts
│   ├── network/
│   │   ├── dio_client.dart            # Dio HTTP instance with interceptors
│   │   └── api_endpoints.dart         # URL route constant mappings
│   ├── providers/
│   │   └── auth_state_provider.dart   # Global AppAuthState & router listenable
│   ├── routing/
│   │   ├── app_router.dart            # GoRouter configuration & auth guards
│   │   ├── route_names.dart           # Type-safe AppRoute enum
│   │   ├── route_paths.dart           # URI path constants
│   │   └── route_transitions.dart     # Custom page transition builders
│   ├── storage/
│   │   └── secure_storage_service.dart# Hardware-backed AES-256 KeyStore storage
│   ├── theme/
│   │   └── app_theme.dart             # ThemeData definitions
│   └── utils/
│       ├── currency_formatter.dart    # Indian Rupee (₹) formatting
│       ├── date_formatter.dart        # IST timezone datetime formatting
│       └── phone_formatter.dart       # 10-digit Indian phone auto-spacing
│
├── features/                          # Domain feature modules
│   ├── auth/                          # Login (Instagram SSO/Mobile), Phone, OTP, Profile Registration, Success
│   ├── calculator/                    # Gold Valuation Calculator (Shop by Gram/Money, Karat benchmarks)
│   ├── checkout/                      # Payment checkout modal, interactive methods & Pick Cash sheet
│   ├── coin_rates/                    # Gold & Silver coin rate cards, 1g-5g denominations, Karat selector
│   ├── dashboard/                     # Active kitty tracker, circular gauge, next EMI card
│   ├── home/                          # Brand feed, top offers carousel, video showcase, curated jewelry
│   ├── jewellery/                     # Authentic photo catalog, Gold & Diamond dropdowns, 6 categories
│   ├── kyc/                           # Aadhaar/PAN upload, document masking, statutory consent
│   ├── menu/                          # Fullscreen Warm Luxury menu page
│   ├── notifications/                 # In-app notifications feed and header badge
│   ├── offers/                        # Scheme tiers, duration tabs, enrollment
│   ├── passbook/                      # 12-month installment table/card ledger, perks
│   ├── payment_gateway/               # GoKwik webview bridge
│   ├── receipt/                       # Digital GST tax invoice receipt & PDF export
│   ├── settings/                      # Profile card, MPIN, Biometrics, Nominee modal
│   └── splash/                        # Smooth startup canvas & 3D diamond crest dissolution
│
└── shared/                            # Universal reusable components
    ├── screens/
    │   └── not_found_screen.dart      # 404 route fallback
    └── widgets/
        ├── badges/                    # Status chips, chit token pills
        ├── buttons/                   # Primary gold button, outline button
        ├── display/                   # Image views, patron avatars
        ├── feedback/                  # Skeleton shimmers, empty states, error cards
        ├── navigation/                # AppShellScaffold, HeaderNavBar, LuxuryNavDrawer, AppBottomNavBar
        └── progress/                  # KittyCircularProgressGauge
```

---

## 3. Core Technical Subsystems

### 3.1 Network & API Abstraction (`DioClient`)
* **HTTP Client**: Built on `Dio 5.x`.
* **Timeout Budget**: 15 seconds connect, 15 seconds receive, 15 seconds send (`AppConstants.connectTimeout`).
* **Interceptors**:
  1. `AuthInterceptor`: Attaches `Authorization: Bearer <token>` from `SecureStorageService`.
  2. `LoggingInterceptor`: Pretty-prints requests and responses in debug mode; suppressed in production.
  3. `TokenRefreshInterceptor`: On HTTP 401, attempts token refresh via `/api/v1/auth/refresh-token`; clears session and redirects to `/auth/login` on failure.

### 3.2 Secure Storage Layer (`SecureStorageService`)
* Wrapped around `flutter_secure_storage`.
* **Android**: Uses Android KeyStore with AES-256 GCM encryption.
* **iOS**: Stored in Apple Keychain with `kSecAttrAccessibleAfterFirstUnlock`.
* Stores sensitive tokens:
  - `swastik_jwt_token` (Access token)
  - `swastik_refresh_token` (Refresh token)
  - `swastik_mpin_hash` (Local offline MPIN hash)
  - `swastik_biometric_enabled` (Boolean preference)

### 3.3 Hardware-Back PopScope System
Managed centrally in `AppShellScaffold`:
```dart
PopScope(
  canPop: false,
  onPopInvokedWithResult: (didPop, result) {
    if (didPop) return;
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeDrawer();
      return;
    }
    if (navigationShell.currentIndex != 0) {
      navigationShell.goBranch(0); // Return to Home before exiting
      return;
    }
  },
  child: ...
)
```
