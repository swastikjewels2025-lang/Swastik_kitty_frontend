# Open Questions & Architectural Contradictions

> [!IMPORTANT]
> **FINAL BACKEND HANDOFF INTEGRATION:**  
> All unresolved backend engineering decisions and open technical questions have been consolidated into:
> * [BACKEND_CONTRACT_FREEZE.md](file:///d:/ui%20design/kitty_docs/api/BACKEND_CONTRACT_FREEZE.md) — Flagged with `BACKEND DEVELOPER MUST CONFIRM`
> * [BACKEND_DEVELOPER_IMPLEMENTATION_GUIDE.md](file:///d:/ui%20design/kitty_docs/api/BACKEND_DEVELOPER_IMPLEMENTATION_GUIDE.md) — Section 14 ("Backend Developer Must Confirm Checklist")

## 1. Overview
During comprehensive inspection of the planning markdown documents (`design_ui_plan.md`, `design_backend_plan.md`, `design_db_schema.md`, `design_system_architecture.md`, `master_integration_plan.md`) and high-fidelity HTML/CSS prototypes, several discrepancies, ambiguities, and unresolved business questions were discovered.

This document cataloges every unresolved issue with its rationale, affected files, recommended decision, owner, and status.

---

## 2. Issues Log

### Issue 1: Primary Target Platform Ambiguity (Flutter Mobile vs. HTML/Web)
* **Question:** Is the customer application to be built exclusively as a Flutter native mobile app (iOS/Android) or as a responsive Web/PWA application?
* **Why it matters:** `design_ui_plan.md` and `master_integration_plan.md` state: *"Customer Mobile App (Flutter) using MVVM and Riverpod"*. Simultaneously, the repository contains a fully working HTML/CSS/Vanilla JS responsive prototype (mobile viewport 440–480px width) with interactive UI, modals, animations, and stylesheets.
* **Documents Affected:** `design_ui_plan.md`, `master_integration_plan.md`, `index.html`, `home.html`, `dashboard.html`.
* **Recommended Decision:** Treat the existing HTML/CSS/JS prototype as the **visual & interactive specification (high-fidelity design mockup)**, while building the production customer application in **Flutter (MVVM + Riverpod)** as specified in the UI and Master plans. Alternatively, if a web deployment is desired, the architecture documented in `kitty_docs` is 100% portable to a clean Web/PWA build.
* **Owner:** Product Manager / Client Lead
* **Status:** OPEN (Awaiting Client Confirmation)

---

### Issue 2: Late-Joiner Dynamic EMI UI Representation in Fixed Installment Passbook
* **Question:** When a customer joins in Month 3 of a 12-month scheme and has a higher dynamic EMI (`₹6,000/month` instead of `₹5,000/month`), how should the 12-month passbook grid display the past missed months (Month 1 and Month 2)?
* **Why it matters:** The backend plan dynamically calculates `customMonthlyEmi = targetAmount / (durationMonths - joinedAtMonth + 1)`. The passbook prototype (`passbook.html`) displays fixed 12 sequential months (Month 1 to Month 12). If Month 1 and 2 were not paid, displaying them as "DEFAULTED" or "UNPAID" would confuse the customer.
* **Documents Affected:** `design_backend_plan.md`, `design_system_architecture.md`, `passbook.html`, `dashboard.html`.
* **Recommended Decision:** For late joiners, mark months prior to `joinedAtMonth` with status `PRE_JOIN` (rendered with a subtle lock icon and subtitle: *"Scheme joined in Month N; custom installment applied"*), so only the active payable months are counted toward their target.
* **Owner:** Product Manager & Backend Developer
* **Status:** RESOLVED & CONFIRMED (Status enum `PRE_JOIN` approved)

---

### Issue 3: Discrepancy in Brand Color Palette Across Prototypes
* **Question:** Which exact color palette is the authoritative brand theme: the initial dark green/neon gold (`#064e3b` / `#facc15`), the luxury deep emerald (`#05241C` / `#C59B27`), or the modern off-white passbook palette (`#F8F9FA` / `#0F172A`)?
* **Why it matters:** UI prototypes show three distinct color implementations. Neon gold (`#facc15`) clashes with the luxury metallic gold (`#C59B27`) present in the SVG logos and high-res jewelry photography.
* **Documents Affected:** `design_ui_plan.md`, `styles.css`, `login.css`, `scheme.css`, `passbook.html`.
* **Recommended Decision:** Adopt the dual-surface Design System established in `DESIGN_SYSTEM.md`:
  - **Surface Dark:** Deep Emerald (`#05241C`, `#092B22`) + Metallic Gold (`#C59B27`, `#DFC178`) for Splash, Login, KYC, Hero Passes, and Modals.
  - **Surface Light:** Soft Off-White (`#F8F9FA`) + Deep Slate (`#0F172A`) + Crisp White Cards (`#FFFFFF`) for 12-Month Passbook, Settings, and Data Tables.
  - Reject `#facc15` as it lacks luxury refinement.
* **Owner:** UI Designer / Frontend Lead
* **Status:** RESOLVED IN DESIGN SYSTEM SPECIFICATION

---

### Issue 4: Active Scheme Data Inconsistencies Across Screens
* **Question:** What is the canonical mock scheme configuration for developer testing?
* **Why it matters:**
  - `home.html` displays: "Wedding Collection (12-Month Plan)", Target ₹3,60,000, EMI ₹30,000, 38.428g gold.
  - `dashboard.html` displays: "Swastik Suvarna Varsha", Target ₹60,000, EMI ₹5,000, 5.482g gold, Chit #SW-042.
  - `index.html` displays: EMI ₹25,000, 42.850g gold.
* **Documents Affected:** `home.html`, `dashboard.html`, `index.html`.
* **Recommended Decision:** Treat "Swastik Suvarna Varsha" (₹60,000 target, ₹5,000/month, 12 months, 8 paid, Chit #SW-042) as the **primary developer fixture** (`dashboard_active_suvarna.json`), and treat "Wedding Collection" as an alternate high-value bridal fixture.
* **Owner:** Frontend Developer
* **Status:** STANDARDIZED IN MOCK FIXTURES

---

### Issue 5: Payment Gateway Webhook Latency & In-App Polling
* **Question:** How does the frontend reliably confirm payment status immediately after the user completes the transaction in the GoKwik external webview?
* **Why it matters:** `design_backend_plan.md` only specifies a server-to-server webhook (`POST /api/payments/webhook`). Mobile app return callbacks often occur before the webhook has finished executing its multi-document ACID transaction, generating PDF receipts, and updating the database.
* **Documents Affected:** `design_backend_plan.md`, `design_system_architecture.md`.
* **Recommended Decision:** Backend developer must provide a lightweight polling endpoint `GET /api/payments/status/:orderId`. The frontend will poll this endpoint up to 5 times (every 2 seconds) upon returning from GoKwik before rendering the success checkmark.
* **Owner:** Backend Developer
* **Status:** PENDING BACKEND IMPLEMENTATION

---

### Issue 6: Live Gold Rate Source & Fallback
* **Question:** What is the official provider or mechanism for fetching the live 24K and 22K gold benchmark rates?
* **Why it matters:** The UI prominent displays live gold rates with percentage fluctuation in the header and calculates portfolio valuation dynamically.
* **Documents Affected:** `design_ui_plan.md`, `home.html`, `dashboard.html`.
* **Recommended Decision:** Backend management sets the store's official daily benchmark gold rate each morning via store admin controls (`Option B: Admin-Managed Daily Collection`).
* **Owner:** Backend Developer & Store Management
* **Status:** RESOLVED & CONFIRMED (Option B approved)

---

### Issue 7: Chit Draw Winner Flow on Frontend
* **Question:** What specific visual state should be presented to a customer when their token number is declared a winner in the monthly physical draw?
* **Why it matters:** `design_backend_plan.md` states that the admin endpoint `/api/admin/draw/record-winner` updates the membership status to `WINNER` and sends a WhatsApp broadcast. The frontend UI currently only models `ACTIVE` and `COMPLETED`.
* **Documents Affected:** `design_backend_plan.md`, `design_db_schema.md`, `dashboard.html`.
* **Recommended Decision:** When `membership.status === 'WINNER'`, replace the active scheme hero card banner with a celebration card: *"🎉 Congratulations Patron! Your chit token #SW-042 won the Month X Draw! Visit Swastik Jewellers showroom to claim your prize."* Disable further EMI payment CTAs for this scheme.
* **Owner:** Product Manager & UI Designer
* **Status:** PROPOSED REQUIREMENT
