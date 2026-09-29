# UI States Matrix: Loading, Error, Empty & Offline — Kitty App

**Project**: Swastik Jewellers Kitty App (Sub-Brand: Kitty Vault)  
**Primary Codebase**: `D:\kitty_app\`  
**Document Status**: Synchronized with Current Implementation  
**Last Audit Date**: 2026-09-23  

---

## 1. Master UI State Matrix Across Screens

| Screen Name | Loading State | Empty State | Error State | Offline Behavior |
| :--- | :--- | :--- | :--- | :--- |
| **Splash** (`/splash`) | Solid emerald canvas root + 3D diamond rotation with breathing scale | N/A | Session recovery failure $\rightarrow$ `/auth/login` | Uses cached tokens in `SecureStorageService` |
| **Login** (`/auth/login`) | Button gold spinner + disabled input | N/A | Damped shake animation on card + red error banner | Test OTP `123456` activates automatically |
| **Home** (`/home`) | `HomeSkeletonLoader` with metallic gold shimmer | N/A (Standard brand fallback) | `KittyErrorState` with "Try Again" button | Shows floating toast; displays cached feed if available |
| **Coin Rates** (`/coin-rates`) | Skeleton card placeholders | N/A | Error card with "Reload Rates" CTA | Uses benchmark fallback rates (Gold: ₹7,550/g, Silver: ₹96.50/g) |
| **Jewellery** (`/jewellery`) | 2-column shimmer cards + image fade-in | `KittyEmptyState`: "No items in category" | `KittyErrorState` with retry button | Displays authentic showroom catalog fixtures |
| **Calculator** (`/calculator`) | Instantaneous reactive client calculation | Empty card: "Enter weight or budget to compute valuation" | Invalid numeric warning / PMLA alert | Computes against cached 24K, 22K, 18K benchmark rates |
| **Dashboard** (`/dashboard`) | `DashboardSkeletonLoader` | `KittyEmptyState`: "No Active Scheme — Explore Schemes" | Full-page error with retry button | Renders last cached scheme metrics |
| **Passbook** (`/passbook`) | `PassbookSkeletonLoader` | `KittyEmptyState`: "No payment records found" | `KittyErrorState` with retry button | Renders cached 12-month ledger |
| **Offers** (`/offers`) | `OffersSkeletonLoader` | `KittyEmptyState`: "No active promotional schemes" | Full-page error with retry button | Displays default Suvarna Varsha plan |
| **KYC** (`/kyc`) | Full-card gold loading indicator | Status: `NOT_SUBMITTED` | File upload error dialog + retry | Form retains document number locally |
| **Checkout** (`/checkout`) | Polling overlay with animated luxury ring | N/A | Gateway failure screen with retry CTA | Blocks payment initiation without connectivity |
| **Pick Cash** (Sheet) | "Scheduling Doorstep Pickup..." spinner | N/A | Form validation errors; PMLA ₹1,99,999 cash ceiling error | Requires network connectivity for request dispatch |
| **Receipt** (`/receipt/:id`) | Centralized gold skeleton box | N/A | "Unable to load receipt" error card | Displays offline receipt data if pre-fetched |
| **Notifications** (`/notifications`) | Shimmering notification rows | `KittyEmptyState`: "No New Notifications" | Error view with reload action | Displays locally stored alerts |
| **Settings** (`/settings`) | `SettingsSkeletonLoader` | N/A | Profile load error card with retry | Displays cached user name & phone |

---

## 2. Reusable State Feedback Widgets

1. **`KittyEmptyState`** (`lib/shared/widgets/feedback/kitty_empty_state.dart`):
   - Features gold outlined icon, Cinzel heading, body description, and gold outline action button.
2. **`KittyErrorState`** (`lib/shared/widgets/feedback/kitty_error_state.dart`):
   - Dual-surface support (`isDarkSurface` flag toggles text colors).
   - Features error icon, clear error message, and a prominent "Try Again" retry callback.
3. **`KittyShimmer`** (`lib/shared/widgets/feedback/kitty_shimmer.dart`):
   - Continuous gold gradient shimmer sweeping across placeholder skeletons.
