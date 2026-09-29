# Frontend-Backend Dependency Matrix V2 — Kitty App

**Project**: Swastik Jewellers Kitty App  
**Document Status**: Official Engineering Dependency & Scheduling Matrix (V2)  
**Effective Date**: 2026-09-29  

---

## 1. Executive Summary: What Can Start Today?

To maximize engineering velocity, frontend and backend development are decoupled:
* **`CAN START IMMEDIATELY (ZERO BACKEND BLOCKERS)`**: 70% of frontend UX simplification (Bottom navigation restructuring, Home screen redesign, live rates tab separation, calculator enhancements, jewellery in-app webview, terminology renaming, accessibility improvements) can be developed immediately using existing v1.0 APIs and local state mocks.
* **`BLOCKED PENDING CONTRACT FREEZE`**: Kitty number grid selection and multi-month payment flows can begin frontend UI scaffolding immediately, but full backend integration requires the V2 API endpoints specified in [`KITTY_API_CONTRACT_V2.md`](file:///D:/kitty_frontend/kitty_docs/KITTY_API_CONTRACT_V2.md).
* **`BLOCKED PENDING BUSINESS POLICY`**: Future number reservation (₹100) and early full balance settlement must remain paused until management resolves [`KITTY_BUSINESS_RULES_PENDING_V1.md`](file:///D:/kitty_frontend/kitty_docs/KITTY_BUSINESS_RULES_PENDING_V1.md).

---

## 2. Granular Feature Dependency Table

| Feature / Screen | Frontend Scope | Backend Scope | API Status | DB Schema Status | Payment Gateway Impact | Business Decision Required? | Can Frontend Start Now? |
| :--- | :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| **1. Bottom Navigation Reorganization** | Restructure `AppBottomNavBar` & `app_router.dart` to 5 tabs (`Live Rates`, `My Kitty`, `Kitty Plans`, `Calculator`, `Jewellery`). | None. | 🟢 Existing | 🟢 None | ❌ None | ❌ None | 🟢 **YES — Day 1** |
| **2. Coins Relocation to Hamburger Drawer** | Move `/coin-rates` into `LuxuryNavDrawer`. Keep all existing bullion booking logic. | None. | 🟢 Existing | 🟢 None | ❌ None | ❌ None | 🟢 **YES — Day 1** |
| **3. Home Screen Redesign** | Implement Live Rate top strip, prominent Active Kitty Card with direct `[PAY NOW]` button, simplified carousels. | None. | 🟢 Existing (`homeData`, `my-schemes`) | 🟢 None | ❌ None | ❌ None | 🟢 **YES — Day 1** |
| **4. Dedicated Live Rates Tab** | Build clean rates board (24K, 22K, 18K, 14K, Silver) without coin buy clutter. | None. | 🟢 Existing (`/market/rates`) | 🟢 None | ❌ None | ❌ None | 🟢 **YES — Day 1** |
| **5. Gold Schemes / Kitty Plans Redesign** | Redesign scheme cards into clean benefit pills (11+1 month bonus math, making waiver). | None. | 🟢 Existing (`/schemes/catalog`) | 🟢 None | ❌ None | ❌ None | 🟢 **YES — Day 1** |
| **6. Jewellery In-App Web Bridge** | Embed official Swastik website via `webview_flutter` with luxury app bar & Android back interceptor. | None. | 🟢 Pure Web URL | 🟢 None | ❌ None | ❌ None | 🟢 **YES — Day 1** |
| **7. Terminology & Accessibility Polish** | Rename terms across all widgets ("Monthly Payment", "My Kitty", etc.); ensure 52px touch targets and AAA contrast. | None. | 🟢 None | 🟢 None | ❌ None | ❌ None | 🟢 **YES — Day 1** |
| **8. Kitty Number Selection Grid (UI Only)** | Build 5-column number grid (01–50) with visual states (`Available`, `Booked`, `Selected`). | None (UI Mock initially). | 🟡 Mock Data initially | 🟢 None | ❌ None | 🟡 Cap size (50) | 🟢 **YES — UI Scaffolding** |
| **9. Kitty Number Selection (API Integration)** | Wire number grid to real-time endpoint & pass `selectedNumber` on enrollment. | Build `GET /schemes/:id/numbers` and update `POST /schemes/enroll` with atomic lock. | 🔴 Proposed V2 API | 🟡 Add `scheme_slots` table | ❌ None | 🟡 Timeout policy | 🟡 **After Backend Milestone 1** |
| **10. Multi-Month Payment (2+ Months)** | Build multi-month selector sheet in checkout; show calculated total. | Update `POST /payments/create-order` to accept `months: [9, 10]` and calculate server total. | 🔴 Proposed V2 API | 🟡 Update `payment_orders` | 🟡 Multi-month order creation | 🟡 Consecutive rule | 🟡 **After Backend Milestone 2** |
| **11. Multiple Active Kitties Management** | Build horizontal swipe cards for patrons holding >1 active scheme. | Update `GET /schemes/my-schemes` to return array of memberships. | 🔴 Proposed V2 API | 🟢 Existing 1:N schema | ❌ None | 🟡 Max active cap | 🟡 **After Backend Milestone 3** |
| **12. Early Full Balance Settlement** | Build full balance summary card and early settlement checkout trigger. | Build `POST /payments/create-settlement-order` and settlement passbook allocation. | 🔴 Proposed V2 API | 🟡 Add `isEarlySettled` | 🟡 Lump-sum order | 🔴 **BLOCKED on BR-07, BR-08** | 🔴 **After Management Sign-off** |
| **13. Future Number Reservation (₹100)** | Build advance reservation dialog with lucky number search and ₹100 deposit CTA. | Build `POST /schemes/future-reservations` and `scheme_reservations` collection. | 🔴 Proposed V2 API | 🔴 Add `scheme_reservations` | 🟡 ₹100 token order | 🔴 **BLOCKED on BR-03, BR-04** | 🔴 **After Management Sign-off** |
| **14. Doorstep Cash Pickup ("Pick Cash")** | Refine existing address & time-slot sheet; display executive verification OTP. | Add counter CRM counter-entry webhook to update passbook. | 🟡 Proposed Extension | 🟡 Add `pickupStatus` | ❌ Cash deposit | 🟡 Free vs fee policy | 🟢 **YES (Frontend exists)** |

---

## 3. Recommended Sequential Handoff Protocol

```
WEEK 1: Parallel Tracks
├── FRONTEND TEAM: Implements Phases 1 to 5 (Navigation, Home, Rates, Plans, WebView, Accessibility)
│   └── 100% Client-side. Zero backend blocking.
│
└── BACKEND TEAM: Implements Milestone 1 & 2 (Kitty Numbers API + Multi-Month Payment Order)
    └── Deploys to Staging API environment.

WEEK 2: Integration & Verification
├── FRONTEND TEAM: Wires Kitty Number Selection and Multi-Month Checkout to Staging API
└── MANAGEMENT: Signs off on Pending Business Decisions (BR-03, BR-07, BR-08)

WEEK 3: Full Settlement & Hardening
├── BACKEND TEAM: Implements Full Balance Settlement (based on approved decisions)
└── QA TEAM: End-to-end regression testing on Staging
```
