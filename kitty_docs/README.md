# Swastik Jewel Kitty App — Frontend Architecture & Documentation

Welcome to the **Swastik Jewel Kitty App** (Sub-Brand: **Kitty Vault**) documentation repository.

This project represents the complete frontend specification, system flow, design system, data contracts, and architectural blueprint for the digital gold savings and kitty chit application built for **Swastik Jewellers**.

---

## 1. Project Scope & Operational Boundary

> [!IMPORTANT]
> **WE ARE BUILDING ONLY THE FRONTEND.**
> A separate backend engineer is building the Node.js / Express API, MongoDB database, payment webhooks, and React Admin CRM.
>
> **Strict Rules:**
> * Do **NOT** create server-side business logic, backend APIs, or databases in the frontend.
> * Do **NOT** calculate critical financial liabilities (e.g. late-joiner dynamic EMI math) inside client code; consume them from backend contracts.
> * Maintain a clean, decoupled boundary so both developers can work independently using mock repositories.

---

> [!NOTE]
> **Active Implementation Blueprint & Readiness Status:**
> - [Implementation Readiness Report](Implementation_Readiness_Report.md) (`Implementation_Readiness_Report.md`)
> - [Phase-Wise Implementation Plan](07_Phases/KITTY_APP_PHASE_WISE_IMPLEMENTATION_PLAN.md) (`07_Phases/KITTY_APP_PHASE_WISE_IMPLEMENTATION_PLAN.md`)
> - [UX Redesign Audit](09_Audits/Kitty_App_Complete_UX_Navigation_User_Experience_Redesign_Audit.md) (`09_Audits/Kitty_App_Complete_UX_Navigation_User_Experience_Redesign_Audit.md`)
> - [Documentation Consolidation Report](Documentation_Consolidation_Report.md) (`Documentation_Consolidation_Report.md`)
> - [Master Frontend Implementation Completion Report](07_Phases/MASTER_FRONTEND_IMPLEMENTATION_COMPLETION_REPORT.md) (`07_Phases/MASTER_FRONTEND_IMPLEMENTATION_COMPLETION_REPORT.md`)
> - [Frontend Readiness & Backend Dependency Audit](07_Phases/Frontend_Readiness_Backend_Dependency_Audit.md) (`07_Phases/Frontend_Readiness_Backend_Dependency_Audit.md`)

---

## 2. Master Backend Handover Package (Approved October 2026 Baseline)

The following authoritative specifications provide the exact technical contracts, schemas, endpoint documentation, and integration roadmap for the backend engineering team (`Swastik_kitty_backend`):

| Document | Location | Purpose & Core Content |
| :--- | :--- | :--- |
| **Backend Handover Overview** | [`05_Backend/BACKEND_HANDOVER_OVERVIEW.md`](05_Backend/BACKEND_HANDOVER_OVERVIEW.md) | High-level system architecture, client/server boundaries, environments, and token protocol. |
| **Master API Contract** | [`04_API/API_CONTRACT.md`](04_API/API_CONTRACT.md) | Authoritative HTTP endpoints catalog, payloads, headers, envelopes, and status codes. |
| **Authentication Specification** | [`04_API/AUTHENTICATION_SPECIFICATION.md`](04_API/AUTHENTICATION_SPECIFICATION.md) | Phone OTP protocol, sandbox test bypass, rate limits, Google OAuth exchange, and JWT lifecycle. |
| **User Profile Specification** | [`04_API/USER_PROFILE_SPECIFICATION.md`](04_API/USER_PROFILE_SPECIFICATION.md) | Profile data models, retrieval endpoint, update requirements, and client fallback handling. |
| **KYC Statutory Compliance** | [`04_API/KYC_COMPLIANCE_SPECIFICATION.md`](04_API/KYC_COMPLIANCE_SPECIFICATION.md) | Aadhaar/PAN formats, multipart file upload limits, Cloudinary streaming, and verification lifecycle. |
| **Gold Plans & Schemes** | [`04_API/GOLD_PLANS_SCHEMES_SPECIFICATION.md`](04_API/GOLD_PLANS_SCHEMES_SPECIFICATION.md) | 11+1 month savings model, schemes catalog, 01–50 number grid, enrollment, and dynamic EMI math. |
| **My Plan & Passbook** | [`04_API/MY_PLAN_PASSBOOK_SPECIFICATION.md`](04_API/MY_PLAN_PASSBOOK_SPECIFICATION.md) | Active plan dashboard, 12-month passbook timeline table, digital receipt PDFs, and empty states. |
| **Live Gold Rates** | [`04_API/GOLD_RATES_SPECIFICATION.md`](04_API/GOLD_RATES_SPECIFICATION.md) | IBJA 24K and 22K rates, client-side karat derivations (18K, 14K), and admin publishing endpoint. |
| **Gold Coins & Bullion** | [`04_API/GOLD_COINS_SPECIFICATION.md`](04_API/GOLD_COINS_SPECIFICATION.md) | 4g and 5g 24K gold coins, custom minted weights, live price multiplier, and booking requirements. |
| **Bookings & Orders** | [`04_API/BOOKINGS_ORDERS_SPECIFICATION.md`](04_API/BOOKINGS_ORDERS_SPECIFICATION.md) | Bullion/coin orders, booking creation, history retrieval, and status state machine. |
| **Gold Calculator** | [`04_API/CALCULATOR_SPECIFICATION.md`](04_API/CALCULATOR_SPECIFICATION.md) | Pure client-side valuation math (wastage, making charges) and equivalent Kitty savings conversion. |
| **Orders & Payments** | [`06_Payments/ORDERS_PAYMENTS_SPECIFICATION.md`](06_Payments/ORDERS_PAYMENTS_SPECIFICATION.md) | GoKwik checkout, multi-month installment orders, doorstep cash pickup, and HMAC webhooks. |
| **In-App Notifications** | [`04_API/NOTIFICATIONS_SPECIFICATION.md`](04_API/NOTIFICATIONS_SPECIFICATION.md) | Notification feed, unread count badge, EMI due alerts, and read receipt updates. |
| **Master Error Contract** | [`04_API/ERROR_CONTRACT_SPECIFICATION.md`](04_API/ERROR_CONTRACT_SPECIFICATION.md) | Standard error JSON envelopes, HTTP status codes, and domain error codes dictionary. |
| **Environment Configuration** | [`00_Project/ENVIRONMENT_CONFIGURATION.md`](00_Project/ENVIRONMENT_CONFIGURATION.md) | Backend `.env.example`, mobile endpoint configurations, and network security policies. |
| **Integration Matrix** | [`05_Backend/FRONTEND_BACKEND_INTEGRATION_MATRIX.md`](05_Backend/FRONTEND_BACKEND_INTEGRATION_MATRIX.md) | Complete 29-item feature-by-feature API mapping and implementation status. |
| **Backend Gap Analysis** | [`05_Backend/BACKEND_GAP_ANALYSIS.md`](05_Backend/BACKEND_GAP_ANALYSIS.md) | Detailed analysis of available, modified, missing, and mismatched backend requirements. |

---

## 3. Technology Stack & Framework Choices

* **Target Mobile Application:** **Flutter** (Dart) for native iOS and Android deployment.
* **Architecture Pattern:** **MVVM (Model-View-ViewModel) with Riverpod** for state management and dependency injection.
* **HTTP Client:** **Dio** with global logging, timeout (15s), and HTTP 401 token refresh interceptors.
* **Secure Storage:** **`flutter_secure_storage`** backed by Android KeyStore (AES-256 GCM) and iOS Keychain.
* **Routing:** **`GoRouter`** supporting deep linking, route guards, and modal routes.
* **Payment Gateway:** **GoKwik SDK / In-App Webview** for seamless UPI, Net Banking, and Cards.
* **Typography:** **Google Fonts** (`Cinzel` for royal brand headings; `Plus Jakarta Sans` for financial tables).

---

## 4. Development Approach & Mock-First Strategy

To develop the frontend without waiting for backend API deployment:

1. **Mock Repositories:** All data access is mediated through abstract interfaces (`IAuthRepository`, `ISchemeRepository`, `IPaymentRepository`).
2. **Offline Dev Sandbox:** By default, the application runs with `USE_MOCK_API=true`, utilizing pre-constructed JSON fixtures located in `test/mocks/fixtures/` (e.g. valid test OTP `123456`, pre-populated 12-month passbook).
3. **Backend Integration Day:** When the backend developer deploys the Node.js / Express server, set `USE_MOCK_API=false` and configure `API_BASE_URL` in `core/config/app_config.dart`. Zero UI code changes required.

---

## 5. How a Backend Developer Continues This Project

1. Read [`05_Backend/BACKEND_HANDOVER_OVERVIEW.md`](05_Backend/BACKEND_HANDOVER_OVERVIEW.md) for architecture and token flows.
2. Review [`05_Backend/FRONTEND_BACKEND_INTEGRATION_MATRIX.md`](05_Backend/FRONTEND_BACKEND_INTEGRATION_MATRIX.md) to see existing vs missing endpoints.
3. Review [`05_Backend/BACKEND_GAP_ANALYSIS.md`](05_Backend/BACKEND_GAP_ANALYSIS.md) for milestone priorities and missing payloads.
4. Verify endpoints against [`04_API/API_CONTRACT.md`](04_API/API_CONTRACT.md).
