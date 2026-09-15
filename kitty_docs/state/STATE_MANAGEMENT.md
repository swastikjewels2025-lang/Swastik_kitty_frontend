# State Management Architecture & Plan

## 1. Overview & Technology Selection
The Kitty App utilizes **Riverpod** (recommended for Flutter) as its primary state management framework. Riverpod provides compile-time safety, seamless testability, dependency injection, and fine-grained reactivity.

The application strictly categorizes state into three distinct scopes:
1. **Global Application State:** Persistent throughout the app session.
2. **Feature / Domain State:** Scoped to specific features, managing data fetching and business flows.
3. **Local UI State:** Ephemeral component-level state managed within the view.

---

## 2. Global State Scope

Global state resides in top-level providers that are accessible from any screen in the application.

```dart
// Global State Providers Structure
final authSessionProvider = StateNotifierProvider<AuthSessionNotifier, AuthSessionState>(...);
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfileState>(...);
final networkConnectivityProvider = StreamProvider<ConnectivityStatus>(...);
final liveGoldRateProvider = StateNotifierProvider<LiveGoldRateNotifier, LiveGoldRateState>(...);
```

### 2.1 `authSessionProvider`
* **Data Held:**
  - `status`: `Unauthenticated`, `Authenticating`, `Authenticated`
  - `jwtToken`: String?
  - `isNewUser`: Boolean
* **Lifecycle:** Initialized at splash launch; cleared on explicit logout or HTTP 401 interception.

### 2.2 `userProfileProvider`
* **Data Held:**
  - `user`: UserModel? (`id`, `name`, `phone`, `tier`, `kycStatus`)
  - `kycVerified`: Boolean
* **Lifecycle:** Populated immediately after OTP verification; updated whenever KYC documents are submitted.

### 2.3 `liveGoldRateProvider`
* **Data Held:**
  - `rate24k`: Double (e.g. `7485.50`)
  - `rate22k`: Double (e.g. `6860.00`)
  - `rateChangePct`: Double (`+0.62%`)
  - `lastUpdated`: DateTime
* **Lifecycle:** Polled every 5 minutes while app is active; consumed across Home, Dashboard, and Header ticker.

### 2.4 `networkConnectivityProvider`
* **Data Held:** `isConnected`: Boolean (`true` / `false`).
* **Lifecycle:** Real-time stream listening to network hardware events. Triggers global offline warning banner.

---

## 3. Feature State Scope

Feature state is managed using the `AsyncValue<T>` pattern, explicitly modeling the six core production states:
1. **`Initial`:** Pre-fetch or idle state.
2. **`Loading`:** Active API request (renders skeleton / shimmer).
3. **`Loaded / Success`:** Complete domain payload ready for rendering.
4. **`Empty`:** Valid response returned but dataset is empty (e.g. zero schemes joined).
5. **`Updating`:** Background mutation in progress (e.g. processing payment).
6. **`Error`:** Failure object containing human-readable message and retry action.

### 3.1 Feature: Authentication (`AuthFeatureState`)
* **States:**
  - `Idle`: User on initial option selection.
  - `OtpSending`: "Continue" button loading spinner.
  - `OtpSent`: 30-second countdown timer active.
  - `Verifying`: 6-digit OTP boxes disabled with validating indicator.
  - `Verified`: Success card displayed.
  - `Error`: Inline red alert ("Incorrect code entered").

### 3.2 Feature: Active Scheme Dashboard (`DashboardFeatureState`)
* **Provider:** `dashboardStateProvider`
* **States:**
  - `Loading`: Dashboard skeleton loader displayed.
  - `Loaded`: `DashboardSummaryModel` available -> renders circular progress gauge, 2x2 grid, due banner.
  - `Empty`: User has no active schemes -> displays `EmptyStateCard` with CTA "Explore Kitty Plans".
  - `Error`: Network/server failure -> renders error card with "Retry" button.

### 3.3 Feature: 12-Month Passbook (`PassbookFeatureState`)
* **Provider:** `passbookStateProvider`
* **States:**
  - `Loading`: Table shimmer rows.
  - `Loaded`: List of 12 `PassbookEntryModel` items.
  - `Empty`: Zero transactions recorded.
  - `Updating`: Payment verified, appending new receipt.
  - `Error`: Error message with pull-to-refresh.

### 3.4 Feature: KYC Document Submission (`KycFeatureState`)
* **Provider:** `kycFormStateProvider`
* **States:**
  - `Idle`: Empty form.
  - `PhotoSelected`: Live image thumbnail preview displayed.
  - `Uploading`: Progress percentage bar active.
  - `Success`: Reference badge `#KYC-849201` rendered.
  - `Error`: Validation alert (file too large, invalid format).

### 3.5 Feature: Payment Processing (`PaymentCheckoutState`)
* **Provider:** `paymentCheckoutProvider`
* **States:**
  - `SelectingMethod`: Modal sheet open, user picking Instant UPI vs NetBanking.
  - `InitiatingOrder`: Calling `/api/payments/initiate`.
  - `GatewayActive`: GoKwik SDK / Webview open.
  - `PollingWebhook`: Checking transaction reconciliation with backend.
  - `Success`: Green checkmark animation + auto-close modal.
  - `Failed`: Rejection notice with "Try Again" trigger.

---

## 4. Local UI State Scope (Ephemeral)

Local UI state is kept **strictly inside the widget tree** (using `StatefulWidget` or `flutter_hooks`) and must **NOT** be stored in global providers.

| Local UI State Element | Screen / Component | Justification for Local Scope |
| :--- | :--- | :--- |
| **Selected Passbook View (Table vs Timeline)** | `passbook.html` | Visual preference only; does not affect data. |
| **Selected Category Filter Tab** | `offers.html` | Temporary filtering of loaded list. |
| **Carousel Slide Index** | `home.html` | Ephemeral carousel position (Slide 0, 1, 2). |
| **Mobile Number Text & Masking** | `login.html` | Form input before submit. |
| **6-Digit OTP Box Focus Nodes** | `login.html` | Hardware keyboard focus management. |
| **Consent Checkbox Toggled** | `kyc.html` | Local form readiness state. |
| **Navigation Drawer Open / Closed** | App-wide | Visual modal animation state. |
| **Payment Modal Open / Closed** | Dashboard | Modal overlay visibility. |
| **Product Wishlist Heart Toggle** | `home.html` | Ephemeral visual toggle in demo catalog. |

---

## 5. What Must NEVER Be in Global State

To maintain clean memory bounds, avoid race conditions, and keep components decoupled:

1. **TextEditingControllers & FocusNodes:** Never place controllers in Riverpod providers. Keep them in the widget's `State` lifecycle.
2. **Ephemeral Animations & Scroll Offsets:** Scroll controller positions and animation controller tickers belong in widget state.
3. **Draft Form Data before Submission:** Unsubmitted text belongs in local controllers until submitted to the feature notifier.
4. **Temporary Filter Dropdowns & Modals:** Modal visibility booleans should be triggered via Navigator / Sheets rather than global boolean flags.
5. **Raw HTTP Response Objects:** Always map raw network responses into clean immutable domain models before exposing to providers.
