# Frontend State Management Specification — Kitty App

**Project**: Swastik Jewellers Kitty App (Sub-Brand: Kitty Vault)  
**Primary Codebase**: `D:\kitty_app\`  
**Document Status**: Synchronized with Current Implementation  
**Last Audit Date**: 2026-09-23  

---

## 1. State Architecture: Riverpod 2.x MVVM

The application utilizes **Riverpod 2.x** with un-bundled state immutability. State is decoupled into distinct tiers:

```text
┌────────────────────────────────────────────────────────┐
│ TIER 1: HARDWARE PERSISTENT STORAGE                    │
│ KeyStore/Keychain: JWT tokens, MPIN, Biometric pref    │
└───────────────────────────▲────────────────────────────┘
                            │ Read on boot / Written on auth
┌───────────────────────────┴────────────────────────────┐
│ TIER 2: GLOBAL SESSION STATE                           │
│ appAuthStateProvider, authRouterListenableProvider     │
└───────────────────────────▲────────────────────────────┘
                            │ Consumed by GoRouter
┌───────────────────────────┴────────────────────────────┐
│ TIER 3: FEATURE-LEVEL CONTROLLERS (StateNotifier)       │
│ homeController, dashboardController, passbookController│
│ paymentController, kycController, settingsController   │
└───────────────────────────▲────────────────────────────┘
                            │ Drives Screen Views
┌───────────────────────────┴────────────────────────────┐
│ TIER 4: LOCAL EPHEMERAL UI STATE                       │
│ Form keys, TextControllers, AnimationControllers, Tabs │
└────────────────────────────────────────────────────────┘
```

---

## 2. Global State Providers

### 2.1 `appAuthStateProvider`
* **File**: `lib/core/providers/auth_state_provider.dart`
* **Type**: `StateNotifierProvider<AppAuthStateNotifier, AppAuthState>`
* **State Class**: `AppAuthState` (immutable with `copyWith`)
* **State Properties**:
  - `status`: `initial`, `unauthenticated`, `authenticated`
  - `userName`: String (e.g. "Rihan Saifi")
  - `userPhone`: String (e.g. "+919876543210")
  - `userEmail`: String (e.g. "rihan@example.com")
  - `tier`: String (e.g. "Tier 1 Verified Member")
  - `isKycVerified`: bool (statutory guard trigger)
  - `authToken`: String? (JWT token)

### 2.2 `authRouterListenableProvider`
* **Type**: `Provider<AuthRouterListenable>`
* **Purpose**: Listens to changes in `appAuthStateProvider` and triggers GoRouter re-evaluation of redirect rules in real time.

---

## 3. Domain Feature State Controllers

| Controller Provider | State Model | Lifecycle / Scope | Key State Attributes |
| :--- | :--- | :--- | :--- |
| `homeControllerProvider` | `HomeState` | Cached with Pull-to-Refresh | `status` (initial, loading, loaded, error), `data` (`HomeDataEntity`), `errorMessage`. |
| `dashboardControllerProvider` | `DashboardState` | Cached with Pull-to-Refresh | `status`, `data` (`DashboardSummaryEntity`), `isPreJoin`, `nextInstallment`. |
| `passbookControllerProvider` | `PassbookState` | Cached with View Switcher | `status`, `entries` (List of 12 installments), `summary`, `isCardView` (bool). |
| `offersControllerProvider` | `OffersState` | Cached with Duration Filter | `status`, `schemes`, `products`, `selectedDurationMonths` (6, 12, 18). |
| `kycControllerProvider` | `KycState` | Scoped Form Flow | `selectedDocType` (Aadhaar/PAN), `docNumber`, `frontImage`, `backImage`, `hasConsent`, `isSubmitting`. |
| `paymentControllerProvider` | `PaymentState` | Transaction Scoped | `status` (idle, creatingOrder, awaitingGateway, polling, success, failed), `selectedChannel` (`PaymentChannel` enum: `upi`, `netbanking`, `card`, `pickCash`), `selectedMethod`, `orderId`, `receiptId`, `pollCount`. |
| `settingsControllerProvider` | `SettingsState` | Profile Cached | `user`, `preferences` (autoPay, biometric), `nominee`, `isUpdating`. |
| `notificationsControllerProvider` | `NotificationsState` | Persistent Local State | `notifications` (List), `unreadCount` (int), `isMarkingAllAsRead` (bool). |
| `receiptControllerProvider` | `ReceiptState` | Modal Scoped | `status`, `receipt` (`ReceiptEntity`), `isPrinting`, `pdfPath`. |

---

## 4. Local Ephemeral State Implementations

1. **Coin Rates Screen (`CoinRatesScreen`)**:
   - `_activeMetalTab` (`MetalTab.gold` vs `MetalTab.silver`)
   - `_selectedKarat` (`24K` vs `22K` — dynamically active for Gold; hidden for Silver)
   - `_selectedWeightIndex` (1g to 5g rectangular cards)
   - `_customGramsController` (`TextEditingController`)
   - `_isCustomInput` (bool)
2. **Gold Valuation Calculator (`CalculatorScreen`)**:
   - `_inputMode` (`shopByGram` vs `shopByMoney`)
   - `_selectedKarat` (`24K`, `22K`, `18K`)
   - `_gramController` and `_moneyController` with bi-directional reactive update guards
   - `_computedAmount` and `_computedGrams`
3. **Jewellery Screen (`JewelleryScreen`)**:
   - `_activeMetal` (`MetalType.gold` vs `MetalType.diamond`)
   - `_goldSelectedCategory` (Rings, Pendants, Necklace, Earrings, Bangles, Bracelets)
   - `_diamondSelectedCategory`
4. **Doorstep Cash Pickup (`PickCashSheet`)**:
   - `_formKey` (`GlobalKey<FormState>`)
   - `_addressController`, `_cityController`, `_pincodeController`, `_notesController`
   - `_selectedSlot` ('morning', 'afternoon', 'evening')
   - `_isSubmitting` (bool)
   - `_confirmedPickup` (`Map<String, dynamic>?` containing reference ID & handover OTP)
5. **Store Video Section (`HomeStoreVideoSection`)**:
   - `_isPlaying` (bool)
   - `_isMuted` (bool)
   - `_playbackProgress` (double, 0.0 to 1.0)
   - `_pulseController` (`AnimationController` repeating every 2s)

