# Complete System Flow & State Lifecycle Documentation

## 1. Complete End-to-End Execution Flow

Every user action in the Kitty App transitions through a strictly managed 12-stage unidirectional lifecycle:

```mermaid
sequenceDiagram
    autonumber
    actor User as Patron
    participant UI as Presentation Widget
    participant State as StateNotifier (ViewModel)
    participant Repo as Repository Layer
    participant Client as HTTP Client & Interceptors
    participant Backend as Backend REST API
    participant DB as MongoDB Database

    User->>UI: Triggers Action (e.g. Tap "PAY NEXT EMI")
    UI->>State: Dispatches Intent / Event
    State->>State: Mutates state to 'Loading' / 'Updating'
    State-->>UI: Emits Loading State (Disables CTA, shows Spinner)
    State->>Repo: Calls Domain Repository method
    Repo->>Client: Invokes HTTP Client with Bearer Token
    Client->>Backend: Dispatches HTTPS Request
    Backend->>DB: Executes Query / ACID Transaction
    DB-->>Backend: Data Committed
    Backend-->>Client: Returns JSON Response Envelope
    alt Success (200 / 201)
        Client-->>Repo: Returns Deserialized DTO
        Repo->>Repo: Maps DTO to Immutable Domain Entity
        Repo-->>State: Delivers Domain Entity
        State->>State: Mutates state to 'Success' / 'Loaded'
        State-->>UI: Emits Loaded State (Re-renders Progress, triggers Toast)
    else Failure (4xx / 5xx / Network Timeout)
        Client-->>Repo: Throws AppException via ErrorInterceptor
        Repo-->>State: Catches exception, translates to Failure
        State->>State: Mutates state to 'Error'
        State-->>UI: Emits Error State (Renders inline banner, enables Retry)
    end
```

---

## 2. Application Startup & Cold Restart Flow

```mermaid
graph TD
    A[Cold App Launch / Device Restart] --> B[3D Diamond WebGL / Canvas Initializer]
    B --> C[Bootstrap Core Systems: AppEnvironment, DioClient, SecureStorage]
    C --> D[Read Stored Token & Profile from SecureStorage]
    D --> E{Is JWT Token Present?}
    E -- No --> F[Route to /auth/login]
    E -- Yes --> G[Dispatch Lightweight Session Check: GET /api/v1/users/profile]
    G --> H{API Response Status}
    H -- 200 OK (Valid) --> I{Check KYC & Scheme Membership}
    H -- 401 Unauthorized (Expired) --> J[Clear SecureStorage & Route to /auth/login with Toast]
    H -- Network Offline / Timeout --> K[Load Cached Profile & Route to /dashboard with Offline Banner]
    I -- Has Active Scheme --> L[Route to /dashboard with Active Scheme Pass]
    I -- No Active Scheme --> M[Route to /offers with Curated Plans]
    I -- KYC Incomplete --> N[Route to /dashboard with Persistent KYC Warning Chip]
```

### Warm Resume vs. Cold Start:
* **Cold Start (Process Killed):** Reads environment, boots Riverpod container, reads KeyStore/Keychain tokens, performs startup check.
* **Warm Resume (App in Background):** App resumes instantly without splash; background service polls `GET /api/v1/rates/gold` to refresh the gold benchmark rate if more than 5 minutes elapsed.

---

## 3. Detailed Edge-Case State Matrix

The UI handles all 9 critical frontend lifecycle states cleanly:

| State | Trigger / Scenario | Visual Presentation | User Action & Recovery Path |
| :--- | :--- | :--- | :--- |
| **Initial / Idle** | Screen first mounted prior to user interaction. | Clean form inputs, default action buttons enabled. | User enters input or selects tab. |
| **Loading** | Active network request in flight. | Shimmer skeleton placeholders matching exact card geometry; CTA shows spinner; inputs disabled. | Interactive elements locked to prevent double-submissions. |
| **Loaded / Success** | Valid 200/201 response received. | Smooth transition to populated cards; green success badge; toast confirmation. | User proceeds with next feature step. |
| **Empty State** | Valid 200 response with zero records (e.g. no active kitty joined). | Reusable `EmptyStateCard` featuring jewelry box illustration, friendly copy, and primary action button. | Tap CTA: "Explore Curated Kitty Plans" $\rightarrow$ routes to `/offers`. |
| **Validation Error** | Client-side format check fails (invalid phone, wrong Aadhaar length, unselected checkbox). | Red border around input field; inline error text below box; primary CTA disabled. | User corrects input; error clears in real-time as valid pattern matches. |
| **API Error (400/422/500)**| Backend responds with error code (e.g. scheme capacity full, invalid OTP). | Red-tinted alert card (`#FEF2F2`) with specific message extracted from backend error envelope. | "Try Again" or dismiss trigger. Form remains editable without losing entered text. |
| **Network Offline** | Device loses internet connection (detected via `Connectivity` stream). | Subtle top warning bar: *"You are offline. Showing cached passbook data."* | Read-only access to cached passbook; write actions disabled. Banner auto-dismisses on reconnection. |
| **Timeout (15s)** | Server fails to respond within 15,000ms. | Friendly dialog: *"Request timed out. The server took too long to respond."* | Prominent "Retry Now" button re-dispatches the exact failed request. |
| **Session Expired (401)**| Token expired or revoked. | Screen blurs; toast: *"Your session has expired. Please sign in again."* | Auto-redirects to `/auth/login`; navigation stack wiped clean. |

---

## 4. Data Refresh & Pull-to-Refresh Flow

```mermaid
graph TD
    A[User Pulls Down on Dashboard / Passbook] --> B[Trigger RefreshIndicator onRefresh callback]
    B --> C[Riverpod Notifier calls ref.refresh on schemeRepositoryProvider]
    C --> D[Dispatch GET /api/v1/memberships/my-dashboard]
    D --> E{API Response}
    E -- 200 OK --> F[Overwrite Memory State with Fresh Ledger]
    F --> G[Write Fresh State to KeyValueStorage Cache]
    G --> H[Dismiss RefreshIndicator with Haptic Feedback]
    E -- Error / Offline --> I[Retain Existing State]
    I --> J[Display Toast: 'Could not refresh. Displaying existing data.']
    J --> H
```

---

## 5. Authentication Flow & State Machine

```mermaid
stateDiagram-v2
    [*] --> View0_MethodSelect: User Opens Login
    View0_MethodSelect --> View1_PhoneInput: Tap 'Continue with mobile'
    View0_MethodSelect --> GoogleSSO: Tap 'Continue with Google'
    
    View1_PhoneInput --> View1_PhoneInput: Real-time Phone Validation
    View1_PhoneInput --> View1_SendingOtp: Tap 'Continue' (Valid Number)
    View1_SendingOtp --> View1_PhoneInput: 400 Bad Request (Show Error)
    View1_SendingOtp --> View2_OtpVerify: 200 OK (OTP Sent)

    state View2_OtpVerify {
        [*] --> OtpEntry
        OtpEntry --> OtpValidating: 6 Digits Entered
        OtpValidating --> OtpEntry: 400 Incorrect OTP (Shake & Red Text)
        OtpEntry --> ResendTimerActive: 30s Countdown Running
        ResendTimerActive --> ResendEnabled: Timer Expired (00:00)
        ResendEnabled --> OtpEntry: Tap 'Resend OTP' (Restart 30s)
    }

    View2_OtpVerify --> View3_SuccessCard: 200 OK (Token Verified)
    View3_SuccessCard --> AppShell: Tap 'Enter Kitty Vault'
    GoogleSSO --> AppShell: Google Auth Success
```

---

## 6. End-to-End Payment & Webhook Reconciliation Flow

```mermaid
sequenceDiagram
    autonumber
    actor Patron
    participant UI as Dashboard / Passbook
    participant Modal as Payment Checkout Sheet
    participant Service as Payment Service
    participant Backend as Node.js API Gateway
    participant Gateway as GoKwik Gateway
    participant DB as MongoDB Replica Set
    participant Cloudinary as Cloudinary Storage

    Patron->>UI: Tap "PAY NEXT EMI (₹5,000)"
    UI->>Modal: Open Payment Sheet (Summary: ₹5,000, Month 9)
    Patron->>Modal: Select "Instant UPI" -> Tap "Confirm & Pay"
    Modal->>Service: initiatePayment(membershipId, month 9)
    Service->>Backend: POST /api/v1/payments/initiate { membershipId, month: 9 }
    Backend->>Gateway: Create Order API
    Gateway-->>Backend: Return orderId: "gokwik_ord_123"
    Backend-->>Service: 200 OK { orderId, amount: 5000 }
    Service-->>Modal: Launch GoKwik SDK / Webview
    Modal->>Gateway: Present UPI / Card Gateway Screen
    Patron->>Gateway: Authorizes UPI PIN in PhonePe/GPay

    alt Webhook Commits Successfully
        Gateway->>Backend: POST /api/v1/payments/webhook (HMAC Signature)
        Backend->>Backend: Verify Crypto Signature
        Note over Backend,DB: Start ACID Session: Update Payment SUCCESS, totalPaidAmount += 5000
        Backend->>Cloudinary: Upload Generated Receipt PDF
        Backend-->>Gateway: 200 OK
        Patron->>Modal: User returns to App from Gateway
        Modal->>Service: Start Polling GET /api/v1/payments/status/:orderId
        Service->>Backend: GET /api/v1/payments/status/:orderId
        Backend-->>Service: 200 OK { status: 'SUCCESS', receiptUrl: '...' }
        Service-->>Modal: Reconciled Successfully
        Modal-->>UI: Close Sheet, Trigger Checkmark Animation, Animate Progress Gauge (8/12 -> 9/12)
    else Gateway Cancelled / Rejected
        Patron->>Modal: User dismisses Gateway or Payment Declines
        Modal-->>UI: Show Error Dialog: "Payment was not completed. No money was deducted."
    end
```

---

## 7. Logout & Session Termination Flow

```mermaid
graph TD
    A[User taps 'Log Out of Account' in settings.html] --> B[Display Native Confirmation Dialog]
    B -- Cancel --> C[Dismiss Dialog & Retain State]
    B -- Confirm Logout --> D[Invoke AuthNotifier.logout]
    D --> E[Delete swastik_jwt_token from SecureStorage]
    D --> F[Delete swastik_user_profile from KeyValueStorage]
    D --> G[Reset all Riverpod Providers to initial states]
    D --> H[Wipe Navigation History Stack]
    H --> I[Navigate to /auth/login with Toast: 'Signed out successfully']
```
