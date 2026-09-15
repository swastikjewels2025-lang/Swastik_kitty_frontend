# Frontend Architecture Document

## 1. Architectural Principles

This application architecture is designed specifically for a **Frontend-Only** engineering lifecycle where a separate backend engineer develops the server and databases concurrently. To ensure seamless parallel progress without blockers or costly refactoring, the frontend adheres to six core principles:

1. **Strict Separation of Concerns:** UI widgets/components do not make HTTP calls or handle raw data parsing directly.
2. **Backend Independence via Mockable Repositories:** Every data source is accessed through an abstract interface. The frontend can run in 100% offline Sandbox/Mock mode (as prototyped in `auth.js`) during local development and seamlessly switch to the live backend by toggling an environment flag.
3. **Unidirectional Data Flow:** State flows downward to presentation components; user interactions dispatch events/intents upward to state controllers.
4. **Resilient Contract Boundary:** Backend responses are sanitized and mapped into strongly typed client domain models immediately at the data boundary. Null or malformed backend fields never crash the UI.
5. **Reusable Design System:** All UI elements conform to predefined design tokens (typography, colors, spacing, borders) rather than ad-hoc inline styles.
6. **Zero Leaked Business Logic:** Financial calculations that require business authorization (such as the dynamic EMI formula `targetAmount / (duration - joinedMonth + 1)`) are calculated by the backend and merely rendered and validated by the frontend.

---

## 2. Multi-Layer Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   PRESENTATION / UI LAYER               │
│  - Screens / Pages (Home, Dashboard, Passbook, etc.)    │
│  - Reusable Widgets & Components (Gauge, Cards, Modals) │
│  - Design System Tokens (Colors, Typography, Themes)    │
└────────────────────────────┬────────────────────────────┘
                             │ Observes State / Emits Events
┌────────────────────────────▼────────────────────────────┐
│                  STATE MANAGEMENT LAYER                 │
│  - Riverpod StateNotifiers / Notifier Providers         │
│  - ViewModels / Page Controllers (Auth, Dashboard)      │
│  - UI State Machines (Loading, Loaded, Empty, Error)    │
└────────────────────────────┬────────────────────────────┘
                             │ Calls Use Cases / Actions
┌────────────────────────────▼────────────────────────────┐
│                    DOMAIN / USE CASE LAYER              │
│  - Pure Business Entities & Value Objects               │
│  - Client Validation Rules (Phone, Aadhaar, PAN regex)  │
│  - Formatters (Currency ₹, Gold grams, Date formatting) │
└────────────────────────────┬────────────────────────────┘
                             │ Delegates Data Fetching
┌────────────────────────────▼────────────────────────────┐
│              REPOSITORY / SERVICE INTERFACE LAYER       │
│  - AuthRepository, SchemeRepository, PaymentRepository  │
│  - Abstract Contracts (IAuthService, ISchemeService)    │
└────────────────────────────┬────────────────────────────┘
              ┌──────────────┴──────────────┐
              ▼                             ▼
┌───────────────────────────┐ ┌───────────────────────────┐
│   LIVE HTTP REPOSITORY    │ │    MOCK / SANDBOX REPO    │
│  - Dio / Http Client      │ │  - Offline Static Fixtures│
│  - JSON Serialization     │ │  - Immediate UI Feedback  │
│  - Auth Token Interceptors│ │  - Unit/Widget Test Stubs │
└─────────────┬─────────────┘ └───────────────────────────┘
              │ Network REST
┌─────────────▼───────────────────────────────────────────┐
│               EXTERNAL BACKEND & THIRD PARTIES          │
│  - Node.js / Express REST API Gateway                   │
│  - GoKwik Payment Gateway Webview / SDK                 │
│  - Cloudinary Media Storage (PDF Receipts & KYC)        │
└─────────────────────────────────────────────────────────┘
```

---

## 3. Layer Responsibilities & Boundaries

### 3.1 Presentation / UI Layer
* **Role:** Pure visual rendering and user gesture capture.
* **Contains:** Screen layouts, stateless and stateful widgets, custom painters (circular gauge), modal dialogs, animations.
* **Rule:** Contains **NO** direct HTTP logic, database references, or raw JSON parsing.

### 3.2 State Management Layer (Riverpod / ViewModel)
* **Role:** Orchestrates the lifecycle of user interactions and manages reactive view state.
* **Contains:** State models representing exact UI states (`AsyncValue`, `Initial`, `Loading`, `Success`, `Error`, `Empty`).
* **Rule:** Never manipulates low-level platform APIs directly; calls Repositories and provides clean, immutable state to widgets.

### 3.3 Domain & Use Cases Layer
* **Role:** Encapsulates client-side formatting, business logic validation, and domain entities.
* **Contains:** Currency formatters (e.g. `₹50,000`), gold gram weight formatters (`5.482 g`), date helpers, form validation regex rules.
* **Rule:** Pure Dart/JavaScript code with zero dependencies on UI framework widgets or HTTP clients.

### 3.4 Repository / Service Interface Layer
* **Role:** Defines the data contract for the application.
* **Contains:** Abstract classes and interfaces:
  - `IAuthRepository`: `sendOtp()`, `verifyOtp()`, `logout()`
  - `ISchemeRepository`: `getActiveSchemes()`, `getMyDashboard()`, `joinScheme()`
  - `IPaymentRepository`: `initiatePayment()`, `getPaymentStatus()`, `getReceiptUrl()`
  - `IKycRepository`: `submitKyc()`, `getKycStatus()`

### 3.5 Infrastructure & Network Layer
* **Role:** Executes raw network requests and local disk operations.
* **Contains:**
  - `HttpClient`: Centralized Dio client with request/response logging, timeout handling (15,000ms), and header injection.
  - `SecureStorageService`: Encrypted local persistence (Android KeyStore / iOS Keychain).
  - `KeyValueStorage`: SharedPreferences for fast non-sensitive cache.

### 3.6 Centralized Network Interceptors
All outbound requests and inbound responses pass through an interceptor pipeline:
* `AuthInterceptor`: Injects `Authorization: Bearer <token>` into every protected request. Automatically intercepts HTTP 401 responses, wipes `SecureStorage`, and broadcasts a session expiry event to route the user to login.
* `ErrorInterceptor`: Catches raw Dio errors (SocketException, TimeoutException) and converts them into strongly typed `AppException` domain errors.
* `LoggingInterceptor`: Dumps formatted HTTP telemetry to console in debug mode (completely stripped in release builds).
* `RetryInterceptor`: Implements exponential backoff retry (1s, 2s, 4s) for idempotent GET operations upon transient network drops.

### 3.7 DTO to Domain Entity Mapper Boundary
* **Data Transfer Objects (DTOs):** Mirror exact backend JSON schema (`camelCase`). They are mutable, tolerate nulls, and handle serialization (`fromJson`/`toJson`).
* **Domain Entities:** Pure Dart models that represent business truth in the application. They are immutable (`@immutable`), strictly typed, and completely decoupled from backend naming quirks.
* **Mappers:** Pure mapping functions (`DashboardMapper.toEntity(dto)`) provide an impenetrable firewall preventing backend schema drift from corrupting UI widgets.

---

## 4. Division of Ownership: Frontend vs. Backend

| Domain Area | Frontend Owns | Backend Owns |
| :--- | :--- | :--- |
| **User Interface** | 100% of layouts, responsive scaling, 3D animations, modals, typography, design tokens. | Zero UI responsibility. |
| **Authentication** | Phone number input UI, 6-digit box auto-focus, countdown timer, JWT storage in Keychain. | Generating OTP, SMS gateway integration (Twilio/MSG91), verifying OTP, issuing signed JWT. |
| **KYC Verification** | Camera capture trigger, image picker, client-side thumbnail preview, Aadhaar/PAN regex validation, statutory consent UI. | Receiving multipart file stream, uploading to Cloudinary, saving Cloudinary URL to database, verifying document authenticity. |
| **Scheme Calculations** | Rendering circular progress SVG, displaying monthly rate, formatting currency and gold weights. | Dynamic EMI math (`targetAmount / (duration - joinedAtMonth + 1)`), member chit allocation, maturity dates. |
| **Payments** | Triggering checkout modal, opening GoKwik SDK / Webview, showing success checkmark animation. | Creating GoKwik order, handling GoKwik webhook with ACID multi-document transaction, updating ledger. |
| **Receipts** | "View Receipt" button, modal presentation, triggering in-app browser or native PDF print. | Generating PDF using `pdfkit`, uploading stream to Cloudinary, sending WhatsApp link to customer. |
| **Monthly Draw** | Displaying winner status chip if membership status is `WINNER`. | Conducting physical draw, entering winning chit number in Admin CRM, broadcasting notifications. |

---

## 5. Frontend ↔ Backend Contract Boundary

To enable both developers to work in complete isolation without blocking each other:

### 5.1 Repository Implementation Swapping
The frontend application uses dependency injection to instantiate repositories:
```dart
// Dependency Injection Configuration
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  const isMockMode = String.fromEnvironment('USE_MOCK_API', defaultValue: 'false');
  if (isMockMode == 'true') {
    return MockAuthRepository(); // Offline mock implementation
  }
  return HttpAuthRepository(client: ref.read(apiClientProvider));
});
```

### 5.2 Deterministic Mock Contracts
When running in `MockAuthRepository` or `MockSchemeRepository`, the frontend returns pre-constructed fixtures that precisely match the contract specified in `API_INTEGRATION_PLAN.md` and `DATA_MODELS.md`. This allows frontend developers to build and verify 100% of the UI screens and edge-case states (empty schemes, payment failures, expired tokens) before the backend developer writes a single line of server code.

### 5.3 Backend Integration Day Zero
When the backend developer deploys the Node.js / Express API:
1. Update `apiBaseUrl` in the frontend environment configuration.
2. Toggle `USE_MOCK_API=false`.
3. The frontend immediately communicates with real endpoints without requiring any changes to presentation widgets or state controllers.
