# Frontend Folder Structure & Architectural Boundary

## 1. Audit Assessment: Production-Ready (Grade: A)

Following an in-depth audit against all enterprise Flutter architectural requirements, the folder structure has been hardened to enforce a **Feature-First + Clean Data/Domain/Presentation Layering** pattern.

This structure guarantees:
* **Zero Direct Screen-to-HTTP Coupling:** UI widgets only communicate with Riverpod StateNotifiers / ViewModels.
* **Separation of Network DTOs from Domain Entities:** Raw backend JSON is parsed into Data Transfer Objects (`DTOs`) and converted via explicit `Mappers` to immutable `Domain Entities`.
* **Plug-and-Play Mock Repositories:** Concrete repositories implement domain interfaces, allowing instantaneous switching between `MockRepository` and `HttpRepository` via dependency injection without touching UI code.
* **Centralized Environment Profiles:** Environment switching (Development, Staging, Production) is driven by `core/config/app_environment.dart` via `--dart-define`.

---

## 2. Complete Production Directory Tree

```text
kitty_app/
├── android/                                 # Native Android host platform
├── ios/                                     # Native iOS host platform
├── assets/                                  # Static binary assets
│   ├── icons/                               # Vector SVG brand icons & symbols
│   ├── images/                              # High-resolution jewelry photography & banners
│   └── patterns/                            # Damask wallpaper & mandala background textures
│
├── lib/
│   ├── main.dart                            # Application bootstrapper (env initialization)
│   ├── app.dart                             # MaterialApp setup, GoRouter configuration, theme
│   │
│   ├── core/                                # System-wide foundational infrastructure
│   │   ├── config/                          # Environment variables & feature toggles
│   │   │   ├── app_environment.dart         # Dev, Staging, Production environment profiles
│   │   │   ├── api_endpoints.dart           # Canonical REST URI constants (/api/v1/...)
│   │   │   └── app_constants.dart           # Numeric limits, timeouts (15s), storage keys
│   │   │
│   │   ├── errors/                          # Centralized error & exception hierarchy
│   │   │   ├── app_exception.dart           # NetworkException, AuthException, ServerException
│   │   │   ├── failure.dart                 # UI-facing Failure value objects with messages
│   │   │   └── error_handler.dart           # Global exception-to-failure translation mapper
│   │   │
│   │   ├── network/                         # Centralized HTTP client & interceptors
│   │   │   ├── http_client.dart             # Configured Dio singleton client
│   │   │   ├── network_info.dart            # Connectivity service (WiFi/Cellular listener)
│   │   │   ├── interceptors/
│   │   │   │   ├── auth_interceptor.dart    # Injects 'Authorization: Bearer <token>', handles 401
│   │   │   │   ├── logging_interceptor.dart # Debug console telemetry (stripped in release)
│   │   │   │   ├── error_interceptor.dart   # Translates HTTP status codes to AppExceptions
│   │   │   │   └── retry_interceptor.dart   # Idempotent GET automatic retry policy
│   │   │   └── api_response_envelope.dart   # Generic ApiResponse<T> deserializer
│   │   │
│   │   ├── routing/                         # Navigation & deep link architecture
│   │   │   ├── app_router.dart              # GoRouter route declarations
│   │   │   ├── route_paths.dart             # Static string route constants (/splash, /dashboard)
│   │   │   └── guards/
│   │   │       ├── auth_guard.dart          # Redirects unauthenticated users to /auth/login
│   │   │       └── kyc_guard.dart           # Blocks transaction flow if KYC is unverified
│   │   │
│   │   ├── storage/                         # Encrypted local persistence
│   │   │   ├── secure_storage_service.dart  # FlutterSecureStorage (KeyStore / Keychain)
│   │   │   └── key_value_storage.dart       # SharedPreferences for non-sensitive cache
│   │   │
│   │   ├── theme/                           # Dual-surface luxury design system
│   │   │   ├── app_colors.dart              # Emerald (#05241C), Gold (#C59B27), Off-white (#F8F9FA)
│   │   │   ├── app_typography.dart          # Cinzel (Headings) & Plus Jakarta Sans (Body)
│   │   │   ├── app_decorations.dart         # Border radius, shadows, glassmorphism filters
│   │   │   └── app_theme.dart               # ThemeData configurations
│   │   │
│   │   └── utils/                           # Formatters, masks & validators
│   │       ├── currency_formatter.dart      # ₹ Indian Rupee format (e.g. ₹50,000)
│   │       ├── gold_weight_formatter.dart   # 24K Gram weight format (e.g. 5.482 g)
│   │       ├── date_time_formatter.dart     # ISO 8601 UTC to localized display converter
│   │       ├── input_masks.dart             # Aadhaar 4-4-4 spacing & PAN uppercase masks
│   │       └── input_validators.dart        # Regex rules for Phone, Aadhaar, PAN, OTP
│   │
│   ├── features/                            # Independent, self-contained business modules
│   │   ├── splash/                          # 3D faceted crystal diamond animation loader
│   │   │   ├── presentation/
│   │   │   │   ├── screens/splash_screen.dart
│   │   │   │   └── widgets/diamond_canvas_painter.dart
│   │   │   └── state/splash_controller.dart
│   │   │
│   │   ├── auth/                            # Mobile phone OTP & Google SSO
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── auth_remote_datasource.dart     # Raw HTTP calls to /api/v1/auth/*
│   │   │   │   │   └── auth_local_datasource.dart      # Reads/writes JWT in SecureStorage
│   │   │   │   ├── dtos/
│   │   │   │   │   ├── auth_response_dto.dart          # JSON deserializer for verify-otp response
│   │   │   │   │   └── user_dto.dart                   # Raw backend user JSON model
│   │   │   │   ├── mappers/user_mapper.dart            # Converts UserDto -> UserEntity
│   │   │   │   └── repositories/
│   │   │   │       ├── auth_repository_impl.dart       # Concrete live HTTP repository
│   │   │   │       └── mock_auth_repository.dart       # Offline sandbox mock (test OTP 123456)
│   │   │   ├── domain/
│   │   │   │   ├── entities/user_entity.dart           # Immutable domain user model
│   │   │   │   └── repositories/i_auth_repository.dart # Abstract contract interface
│   │   │   ├── presentation/
│   │   │   │   ├── screens/login_screen.dart
│   │   │   │   └── views/
│   │   │   │       ├── login_method_view.dart          # View 0: Method selection
│   │   │   │       ├── phone_input_view.dart           # View 1: Mobile phone entry
│   │   │   │       ├── otp_verification_view.dart      # View 2: 6-digit OTP grid
│   │   │   │       └── auth_success_view.dart          # View 3: Patron tier confirmation
│   │   │   └── state/
│   │   │       ├── auth_session_notifier.dart          # Global session state
│   │   │       └── otp_timer_notifier.dart             # 30-second resend countdown timer
│   │   │
│   │   ├── kyc/                             # Statutory RBI/PMLA identity verification
│   │   │   ├── data/
│   │   │   │   ├── datasources/kyc_remote_datasource.dart
│   │   │   │   ├── dtos/kyc_upload_dto.dart
│   │   │   │   ├── mappers/kyc_mapper.dart
│   │   │   │   └── repositories/
│   │   │   │       ├── kyc_repository_impl.dart
│   │   │   │       └── mock_kyc_repository.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/kyc_document_entity.dart
│   │   │   │   └── repositories/i_kyc_repository.dart
│   │   │   ├── presentation/
│   │   │   │   ├── screens/kyc_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── doc_selector_tabs.dart          # Aadhaar vs PAN switcher
│   │   │   │       ├── kyc_dropzone_card.dart          # Camera/gallery upload target
│   │   │   │       ├── preview_thumbnail_card.dart     # Real-time preview with delete
│   │   │   │       └── statutory_consent_checkbox.dart # Mandatory legal consent
│   │   │   └── state/kyc_form_notifier.dart            # Form validation & upload progress
│   │   │
│   │   ├── home/                            # Showcase catalog, carousel & live gold rate
│   │   │   ├── presentation/
│   │   │   │   ├── screens/home_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── active_privilege_banner.dart    # Quick scheme progress snapshot
│   │   │   │       ├── kitty_promo_carousel.dart       # Touch/swipe scheme offers
│   │   │   │       ├── category_scroll_track.dart      # Horizontal rings/bangles track
│   │   │   │       ├── curated_product_grid.dart       # 2-column jewelry cards with wishlist
│   │   │   │       └── trust_rate_strip.dart           # Live gold rate ticker & hallmark badge
│   │   │   └── state/
│   │   │       ├── home_view_controller.dart
│   │   │       └── live_gold_rate_notifier.dart
│   │   │
│   │   ├── kitty/                           # Core Kitty Vault & Dashboard features
│   │   │   ├── data/
│   │   │   │   ├── datasources/scheme_remote_datasource.dart
│   │   │   │   ├── dtos/
│   │   │   │   │   ├── dashboard_summary_dto.dart
│   │   │   │   │   ├── scheme_dto.dart
│   │   │   │   │   └── membership_dto.dart
│   │   │   │   ├── mappers/dashboard_mapper.dart
│   │   │   │   └── repositories/
│   │   │   │       ├── scheme_repository_impl.dart
│   │   │   │       └── mock_scheme_repository.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── dashboard_summary_entity.dart
│   │   │   │   │   ├── scheme_entity.dart
│   │   │   │   │   └── membership_entity.dart
│   │   │   │   └── repositories/i_scheme_repository.dart
│   │   │   ├── presentation/
│   │   │   │   ├── screens/dashboard_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── scheme_hero_pass_card.dart      # VIP card with chit token
│   │   │   │       ├── circular_progress_gauge.dart    # SVG/Painter circle (8/12, 67%)
│   │   │   │       ├── financial_stats_grid.dart       # 2x2 grid (Target, Paid, Gold, Gain)
│   │   │   │       └── next_emi_due_card.dart          # Month 9 due banner & countdown
│   │   │   └── state/dashboard_state_notifier.dart
│   │   │
│   │   ├── passbook/                        # 12-Month Installment Ledger & Receipts
│   │   │   ├── data/
│   │   │   │   ├── datasources/passbook_remote_datasource.dart
│   │   │   │   ├── dtos/passbook_entry_dto.dart
│   │   │   │   ├── mappers/passbook_mapper.dart
│   │   │   │   └── repositories/
│   │   │   │       ├── passbook_repository_impl.dart
│   │   │   │       └── mock_passbook_repository.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/passbook_entry_entity.dart
│   │   │   │   └── repositories/i_passbook_repository.dart
│   │   │   ├── presentation/
│   │   │   │   ├── screens/passbook_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── passbook_table_view.dart        # 12-row desktop/mobile table
│   │   │   │       ├── passbook_timeline_view.dart     # Responsive card timeline
│   │   │   │       ├── passbook_status_badge.dart      # PAID, CURRENT, BONUS pills
│   │   │   │       └── digital_receipt_modal.dart      # Official invoice with print trigger
│   │   │   └── state/
│   │   │       ├── passbook_state_notifier.dart
│   │   │       └── passbook_view_toggle_notifier.dart  # Table vs Card preference
│   │   │
│   │   ├── payments/                        # GoKwik checkout & payment monitoring
│   │   │   ├── data/
│   │   │   │   ├── datasources/payment_remote_datasource.dart
│   │   │   │   ├── dtos/payment_order_dto.dart
│   │   │   │   ├── mappers/payment_mapper.dart
│   │   │   │   └── repositories/
│   │   │   │       ├── payment_repository_impl.dart
│   │   │   │       └── mock_payment_repository.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/payment_order_entity.dart
│   │   │   │   └── repositories/i_payment_repository.dart
│   │   │   ├── presentation/
│   │   │   │   ├── sheets/payment_checkout_sheet.dart  # UPI, NetBanking, Card selector
│   │   │   │   └── screens/gokwik_webview_screen.dart  # Gateway host view
│   │   │   └── state/
│   │   │       ├── payment_checkout_notifier.dart
│   │   │       └── webhook_polling_service.dart        # Status reconciliation poller
│   │   │
│   │   ├── offers/                          # Scheme catalog & late-joiner enrollment
│   │   │   ├── presentation/
│   │   │   │   ├── screens/offers_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── scheme_filter_tabs.dart         # All, Classic, Express, Bridal
│   │   │   │       ├── offer_plan_card.dart            # Card with bonus highlights
│   │   │   │       └── enrollment_confirm_modal.dart   # Fast-track enrollment sheet
│   │   │   └── state/offers_filter_notifier.dart
│   │   │
│   │   └── settings/                        # Preferences, security & legal
│   │       ├── presentation/
│   │       │   ├── screens/settings_screen.dart
│   │       │   └── widgets/
│   │       │       ├── settings_item_tile.dart         # Standard settings row
│   │       │       ├── mpin_change_dialog.dart         # 4-digit MPIN modal
│   │       │       └── logout_confirm_dialog.dart      # Destructive sign-out dialog
│   │       └── state/
│   │           ├── settings_notifier.dart
│   │           └── biometric_auth_controller.dart      # Local authentication bridge
│   │
│   └── shared/                              # Universally reused widgets & services
│       ├── components/
│       │   ├── buttons/
│       │   │   ├── gold_primary_button.dart        # Prominent metallic CTA
│       │   │   ├── secondary_outline_button.dart   # Neutral receipt/print action
│       │   │   └── circular_icon_button.dart       # 40px circular back button
│       │   ├── feedback/
│       │   │   ├── swastik_toast.dart              # Global toast overlay
│       │   │   ├── empty_state_card.dart           # Reusable empty illustration & CTA
│       │   │   ├── offline_warning_banner.dart     # Network disconnect indicator
│       │   │   └── dashboard_skeleton_loader.dart  # Shimmer placeholder
│       │   └── navigation/
│       │       ├── header_nav_bar.dart             # Universal sticky top header
│       │       └── luxury_nav_drawer.dart          # Slide-out navigation drawer
│       └── services/
│           ├── image_picker_service.dart           # Camera & gallery abstraction
│           └── print_spooler_service.dart          # In-app receipt printing
│
└── test/                                    # Automated testing suite
    ├── unit/
    │   ├── domain/                                 # Dynamic EMI math & gauge angle tests
    │   ├── mappers/                                # DTO -> Entity serialization tests
    │   └── utils/                                  # Phone, Aadhaar, PAN validator tests
    ├── widget/
    │   ├── components/                             # Isolated button & input tests
    │   └── screens/                                # Screen loading, empty, error golden tests
    ├── integration/                                # End-to-end user flows with mock repos
    └── mocks/
        ├── mock_repositories.dart                  # Riverpod overrides
        └── fixtures/                               # Static JSON payloads matching API contract
            ├── auth_verify_success.json
            ├── dashboard_active_suvarna.json
            ├── dashboard_empty.json
            ├── passbook_12_months.json
            └── live_gold_rate.json
```

---

## 3. Strict Boundary Rules

1. **No Data Source Calls in Widgets:** A presentation widget must **never** call Dio or invoke an API service directly. It only observes a StateNotifier.
2. **Feature Isolation:** Feature folders must not cross-import another feature's internal `data/` or `presentation/widgets/` directories. Cross-cutting entities reside in `shared/` or are accessed via domain repositories.
3. **DTO vs. Entity Separation:** DTOs (`*Dto`) represent external JSON contracts and are mutable. Domain Entities (`*Entity`) are pure, immutable, and decoupled from backend naming conventions.
4. **Environment Isolation:** Secrets and base URLs are injected strictly at build time via `AppEnvironment`; no hardcoded URLs exist in feature code.
