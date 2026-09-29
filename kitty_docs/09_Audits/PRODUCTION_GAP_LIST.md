# MASTER PRODUCTION GAP LIST — KITTY APP

**Project**: Flutter Kitty App (Swastik Jewellers)  
**Audit Date**: 2026-09-18  
**Priority Legend**:
- **P0 — RELEASE BLOCKER**: Cannot release or publish under any circumstances until resolved.
- **P1 — CRITICAL**: High operational, compliance, or security risk; must be fixed before opening to real public users.
- **P2 — MAJOR**: Important store listing, asset, or functional gap; significantly impairs production quality.
- **P3 — MINOR**: Secondary feature enhancement, future backend optimization, or non-blocking improvement.
- **P4 — COSMETIC**: Visual polish, animation refinement, or minor wording tweak.

---

## 1. Consolidated Gaps Matrix

| ID | Title / Issue | Priority | Domain Tags | File / Component Reference | Remediation Required |
| :-: | :--- | :---: | :--- | :--- | :--- |
| **GAP-01** | **Production Keystore (`.jks`) & Release Signing** | **P0** | `CONFIG`, `SECURITY`, `PLAY STORE`, `USER ACTION` | `android/app/build.gradle.kts:34-52`, `android/key.properties.example` | User/business must generate genuine RSA-4096 release keystore, create `android/key.properties`, and rebuild signed AAB. Debug-signed AAB will be rejected by Google Play Console. |
| **GAP-02** | **Production Backend Hosting & HTTPS Domain** | **P0** | `CONFIG`, `BACKEND`, `SECURITY`, `USER ACTION` | `lib/core/config/app_config.dart:116`, `D:\Kitty_backend\` | Deploy backend to production cloud server (e.g. AWS, Render, DigitalOcean) with valid SSL/TLS certificate mapped to `https://api.swastikjewel.com`. Currently running on `127.0.0.1:5000`. |
| **GAP-03** | **GoKwik Production Gateway Credentials** | **P0** | `BACKEND`, `EXTERNAL DEPENDENCY`, `USER ACTION` | `D:\Kitty_backend\Swastik_kitty_backend\src\config\env.js:15-20` | Obtain official production `GOKWIK_APP_ID`, `GOKWIK_APP_SECRET`, and `GOKWIK_WEBHOOK_SECRET`. Configure in backend production `.env` to enable real UPI/Card payment processing. |
| **GAP-04** | **Published Privacy Policy & Account Deletion URLs** | **P0** | `LEGAL/COMPLIANCE`, `PLAY STORE`, `USER ACTION` | `PRIVACY_POLICY_REQUIREMENTS.md`, Google Play Console | Publish official Privacy Policy and Account Deletion request webpage on `swastikjewellers.com`. Mandatory for Google Play Console submission. |
| **GAP-05** | **Legal Review of "Lucky Draw / Winner" Backend Feature** | **P0** | `LEGAL/COMPLIANCE`, `BACKEND` | `src/controllers/admin.controller.js:20`, `src/models/Membership.model.js:46` | Counsel must review `recordDrawWinnerController` against the *Prize Chits and Money Circulation Schemes (Banning) Act, 1978*. If informal lottery/prize draw, decommission from production backend to eliminate regulatory liability. |
| **GAP-06** | **Network Security Config LAN Subnet Hardening** | **P1** | `CONFIG`, `SECURITY`, `CODE` | `android/app/src/main/res/xml/network_security_config.xml:18` | Remove `<domain includeSubdomains="true">192.168.29.46</domain>` before final release build. Production manifest must allow cleartext traffic only for local debug/emulator, never arbitrary LAN IPs in release. |
| **GAP-07** | **Cloudinary PDF Receipt Upload Persistence** | **P1** | `BACKEND`, `CODE` | `src/services/payment.service.js:210`, `src/models/Payment.model.js:37` | In `payment.service.js`, un-comment and implement streaming of `generateReceiptPdf()` buffer to Cloudinary, and save the returned HTTPS URL in `Payment.receiptUrl`. Currently, receipts are generated in-memory but not uploaded. |
| **GAP-08** | **Google Play Financial Features Category Selection** | **P1** | `PLAY STORE`, `LEGAL/COMPLIANCE`, `USER ACTION` | Google Play Console Declaration Form | Determine whether to declare under "crowdfunding and chit funds" or standard retail advance purchase, aligned with Swastik Jewellers' legal entity registration. |
| **GAP-09** | **Production Store Assets (Icon, Feature Graphic, Screenshots)** | **P2** | `PLAY STORE`, `UI`, `USER ACTION` | `RELEASE_CHECKLIST.md` | Provide 512x512 32-bit PNG app icon, 1024x500 JPG/PNG feature graphic banner, and minimum 4 high-resolution mobile screenshots for store listing. |
| **GAP-10** | **Terms & Conditions and Grievance Officer Web Links** | **P2** | `LEGAL/COMPLIANCE`, `UI` | `lib/features/settings/presentation/widgets/terms_and_compliance_modal.dart` | Replace placeholder text in `TermsAndComplianceModal` with active web links to published legal terms and contact details of the official Grievance Officer. |
| **GAP-11** | **Terminology Refinement: "Chit Token" $\rightarrow$ "Plan Token"** | **P2** | `LEGAL/COMPLIANCE`, `UI`, `BACKEND` | `lib/shared/widgets/badges/kitty_chit_token_pill.dart`, `Membership.model.js:63` | If operating as an advance purchase scheme rather than a registered Chit Fund, replace "Chit Token" with "Patron ID" or "Plan Token" across UI and virtual models. |
| **GAP-12** | **In-App Notifications Backend Persistence** | **P3** | `BACKEND`, `CODE` | `lib/features/notifications/data/repositories/notification_repository_impl.dart` | (Post-launch enhancement) Build backend `Notification` Mongoose model and REST routes (`GET /api/v1/notifications`) to transition in-app notification feed from mock to persistent database. |
| **GAP-13** | **Jewellery Product Catalog ERP Integration** | **P3** | `BACKEND`, `CODE` | `lib/features/home/data/repositories/home_repository_impl.dart` | (Post-launch enhancement) Connect jewellery showcase grid to Swastik Jewellers' live retail inventory ERP instead of bundled mock product entities. |
| **GAP-14** | **Rich Micro-Interactions & Audio Feedback Polish** | **P4** | `UI`, `COSMETIC` | `lib/features/checkout/presentation/widgets/payment_result_view.dart` | Add optional subtle haptic feedback or sound on payment success and carousel swipe. |

---

## 2. Remediation Roadmap

```
PHASE A: IMMEDIATE BLOCKERS (P0)
├── 1. Generate Release Keystore (RSA-4096) & Configure key.properties
├── 2. Provision Cloud Server with SSL & Deploy Backend (MongoDB Atlas + Express)
├── 3. Input GoKwik Production Merchant Keys in Backend .env
├── 4. Publish Privacy Policy & Deletion Form on swastikjewellers.com
└── 5. Legal Counsel Review of Scheme Rules & Lucky Draw Decommissioning

PHASE B: CRITICAL HARDENING (P1)
├── 1. Remove LAN IP (192.168.29.46) from network_security_config.xml
├── 2. Wire up Cloudinary stream in payment.service.js to save receiptUrl
└── 3. Complete Google Play Console Financial Features Declaration

PHASE C: STORE ASSETS & METADATA (P2)
├── 1. Finalize 512x512 App Icon & 1024x500 Feature Graphic
├── 2. Capture Production Screenshots (Phone & Tablet)
└── 3. Link Published Grievance Officer Details in Settings Modal
```
