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

## 2. Documentation Map (`kitty_docs/`)

All architecture, product requirements, API specifications, and design decisions are organized in `kitty_docs/`:

```text
kitty_docs/
├── README.md                                 # Master project guide & index (this file)
├── SOURCE_ANALYSIS.md                        # Audit trail of all analyzed UI & planning files
│
├── product/
│   └── PRD.md                                # Complete Product Requirements Document
│
├── architecture/
│   ├── SYSTEM_FLOW.md                        # End-to-end user flows, sequence diagrams, lifecycles
│   ├── FRONTEND_ARCHITECTURE.md              # Multi-layer architecture, principles, boundaries
│   ├── FRONTEND_FOLDER_STRUCTURE.md          # Feature-first modular directory layout
│   ├── FRONTEND_BACKEND_RESPONSIBILITIES.md  # Detailed task & ownership matrix
│   ├── FRONTEND_BACKEND_INTEGRATION.md       # Master integration, connectivity & env config guide
│   └── NAVIGATION.md                         # Route tables, guards, drawer & modal behavior
│
├── api/
│   ├── BACKEND_CONTRACT_FREEZE.md            # Master Frozen API Contract (Single Source of Truth)
│   ├── BACKEND_DEVELOPER_IMPLEMENTATION_GUIDE.md # Backend Developer Implementation Guide & Checklist
│   ├── API_CONTRACT.md                       # Master endpoint contract, envelopes & HTTP status rules
│   ├── DATA_CONTRACT.md                      # Type specifications, UTC dates & integer money rules
│   ├── ENUMS_AND_STATUS_CONTRACT.md          # Domain enums & defensive unknown-value fallbacks
│   ├── API_INTEGRATION_PLAN.md               # Complete REST API specifications & payloads
│   ├── DATA_MODELS.md                        # Strongly typed client domain models
│   └── BACKEND_HANDOFF.md                    # Master handoff guide & 11-step handshake process
│
├── ui/
│   ├── DESIGN_SYSTEM.md                      # Color tokens, typography, spacing, elevations
│   └── UI_COMPONENT_ARCHITECTURE.md          # Reusable widget catalog, props, variants, states
│
├── state/
│   └── STATE_MANAGEMENT.md                   # Riverpod provider architecture & state scoping
│
├── quality/
│   ├── TESTING_STRATEGY.md                   # Unit, widget, and integration test plan
│   └── FRONTEND_SECURITY.md                  # Secure storage, PII handling, HTTPS, logging
│
├── planning/
│   ├── FRONTEND_IMPLEMENTATION_PLAN.md       # Master 21-phase execution plan & dependency graph
│   ├── FRONTEND_PHASE_CHECKLIST.md           # Milestone checklist for every implementation phase
│   ├── FRONTEND_IMPLEMENTATION_STATUS.md     # Living status tracking log (initially NOT STARTED)
│   ├── FRONTEND_DEVELOPMENT_ROADMAP.md       # 10-phase development plan from setup to release
│   ├── REQUIREMENTS_TRACEABILITY.md          # 40-item requirements traceability matrix
│   ├── MOCK_API_STRATEGY.md                  # Mock repository swapping & 5 testing scenarios
│   └── BACKEND_INTEGRATION_DEFINITION_OF_DONE.md # Formal verification checklist & sign-off gate
│
└── decisions/
    ├── OPEN_QUESTIONS.md                     # Contradictions log, platform choices, open questions
    └── INTEGRATION_CONFLICTS.md              # In-depth 10-point technical conflict & risk analysis
```

---

## 3. Technology Stack & Framework Choices

* **Target Mobile Application:** **Flutter** (Dart) for native iOS and Android deployment.
* **Architecture Pattern:** **MVVM (Model-View-ViewModel) with Riverpod** for state management and dependency injection.
* **HTTP Client:** **Dio** with global logging, timeout (15s), and HTTP 401 token refresh interceptors.
* **Secure Storage:** **`flutter_secure_storage`** backed by Android KeyStore (AES-256 GCM) and iOS Keychain.
* **Routing:** **`GoRouter`** supporting deep linking, route guards, and modal routes.
* **Payment Gateway:** **GoKwik SDK / In-App Webview** for seamless UPI, Net Banking, and Cards.
* **Typography:** **Google Fonts** (`Cinzel` for royal brand headings; `Plus Jakarta Sans` for financial tables).
* **Reference Prototype:** High-fidelity responsive HTML5/CSS3/Vanilla JS mockups located in root workspace (`d:\ui design`).

---

## 4. Dual-Surface Design System Summary

| Surface Realm | Color Palette | Intended Experience | Screens |
| :--- | :--- | :--- | :--- |
| **Surface Dark** | Deep Emerald (`#05241C`, `#092B22`)<br>Metallic Gold (`#C59B27`, `#DFC178`) | Royal Indian Heritage, Prestige, Sensory Luxury | Splash (3D Diamond), Login, KYC, Hero Pass, Checkout Modals |
| **Surface Light** | Soft Off-White (`#F8F9FA`)<br>Crisp White Cards (`#FFFFFF`)<br>Deep Slate Text (`#0F172A`) | Bank-Grade Clarity, High Density, Legibility | 12-Month Passbook, Data Tables, Settings & Preferences |

---

## 5. Development Approach & Mock-First Strategy

To develop the frontend without waiting for backend API deployment:

1. **Mock Repositories:** All data access is mediated through abstract interfaces (`IAuthRepository`, `ISchemeRepository`, `IPaymentRepository`).
2. **Offline Dev Sandbox:** By default, the application runs with `USE_MOCK_API=true`, utilizing pre-constructed JSON fixtures located in `test/mocks/fixtures/` (e.g. valid test OTP `123456`, pre-populated 12-month passbook `#SW-042`).
3. **Backend Integration Day:** When the backend developer deploys the Node.js / Express server, set `USE_MOCK_API=false` and configure `API_BASE_URL` in `core/config/app_config.dart`. Zero UI code changes required.

---

## 6. How a Developer Continues This Project

1. **Review Specifications:** Read [`PRD.md`](file:///d:/ui%20design/kitty_docs/product/PRD.md), [`FRONTEND_ARCHITECTURE.md`](file:///d:/ui%20design/kitty_docs/architecture/FRONTEND_ARCHITECTURE.md), and [`DESIGN_SYSTEM.md`](file:///d:/ui%20design/kitty_docs/ui/DESIGN_SYSTEM.md).
2. **Inspect Interactive Prototypes:** Open `d:\ui design\login.html`, `d:\ui design\home.html`, `d:\ui design\dashboard.html`, and `d:\ui design\passbook.html` in a web browser to experience the exact animations, gestures, and layout expectations.
3. **Follow the Roadmap:** Proceed to **Phase 1** of [`FRONTEND_DEVELOPMENT_ROADMAP.md`](file:///d:/ui%20design/kitty_docs/planning/FRONTEND_DEVELOPMENT_ROADMAP.md) to initialize the project foundation and shared UI component library.
4. **Coordinate with Backend Developer:** Share [BACKEND_CONTRACT_FREEZE.md](file:///d:/ui%20design/kitty_docs/api/BACKEND_CONTRACT_FREEZE.md) and [BACKEND_DEVELOPER_IMPLEMENTATION_GUIDE.md](file:///d:/ui%20design/kitty_docs/api/BACKEND_DEVELOPER_IMPLEMENTATION_GUIDE.md) directly with the backend developer as the master handoff specifications.
