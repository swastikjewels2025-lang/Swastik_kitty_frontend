# Frontend vs. Backend Responsibility Matrix

## 1. Overview
To ensure maximum engineering velocity, zero overlap, and absolute accountability, this document delineates the precise operational boundaries between the **Frontend Developer** and the **Backend Developer** for the Swastik Jewel Kitty App.

---

## 2. Comprehensive Responsibility Matrix

| Operational Area / Task | Frontend Responsibility | Backend Responsibility | Boundary / Contract Rule |
| :--- | :---: | :---: | :--- |
| **UI & Layout Rendering** | **YES** | **NO** | Frontend owns 100% of screens, responsive layout, animations, and modal presentation. |
| **Design Tokens & Theme** | **YES** | **NO** | Colors, typography, borders, shadows, and assets are defined entirely on the client. |
| **Client Routing & Navigation** | **YES** | **NO** | Stack, Drawer, and Modal route navigation managed in frontend router (`GoRouter`). |
| **Form Input Formatting & Masking** | **YES** | **NO** | Phone auto-formatting, Aadhaar 4-4-4 spacing, and PAN uppercase masking happen in real-time on client. |
| **Form Validation** | **YES** (Format check) | **YES** (Business & Auth) | Frontend validates syntax (regex, length); backend validates uniqueness, user existence, and security limits. |
| **OTP Generation & SMS Dispatch** | **NO** | **YES** | Backend connects to Twilio / MSG91 SMS gateway, generates 6-digit cryptographic OTP, and applies expiry. |
| **Authentication UI & Timer** | **YES** | **NO** | Frontend renders 6-box input, countdown timer (30s), resend actions, and success card. |
| **Session Management & Tokens** | **YES** (Secure Storage) | **YES** (Signing & Verify) | Backend issues signed JWT; frontend securely persists it in platform Keychain / EncryptedSharedPreferences. |
| **Authorization & Token Refresh** | **YES** (Handle 401) | **YES** (Enforcement) | Backend validates JWT on protected routes; frontend intercepts HTTP 401 to clear storage and redirect to login. |
| **KYC File Capture & Preview** | **YES** | **NO** | Frontend triggers device camera / file picker, renders thumbnail preview, and validates file size (<10MB). |
| **KYC File Storage & Cloudinary** | **NO** | **YES** | Backend receives multipart stream via `multer`, uploads to Cloudinary, and stores secure Cloudinary URL in DB. |
| **Database & Schema Management** | **NO** | **YES** | MongoDB schema design, replica set transactions, indexing, and data persistence belong entirely to backend. |
| **Dynamic EMI Calculation (Late-Joiner)**| **NO** (Display only) | **YES** (Calculate & Store)| Math `targetAmount / (duration - joinedAtMonth + 1)` executed exclusively by backend and stored in DB. |
| **Circular Progress & Gauge Math** | **YES** | **NO** | Frontend calculates SVG `stroke-dashoffset` from `monthsPaid` and `totalMonths` received from backend. |
| **Live Gold Rate Tracking** | **YES** (Display & Polling) | **YES** (Rate API Provider) | Backend exposes/proxies live IBJA rates; frontend calculates user portfolio valuation and percentage gains. |
| **Payment Order Creation** | **YES** (Trigger request) | **YES** (GoKwik Gateway API)| Backend communicates server-to-server with GoKwik to generate `orderId`; returns `orderId` to client. |
| **Payment UI Orchestration** | **YES** | **NO** | Frontend loads GoKwik SDK / Webview, presents payment options, and handles user return. |
| **Payment Webhook & Ledger Update** | **NO** | **YES** | Backend verifies GoKwik crypto signature, executes ACID transaction, updates `Payment` status to `SUCCESS`. |
| **PDF Receipt Generation** | **NO** | **YES** | Backend renders receipt PDF using `pdfkit`, uploads stream to Cloudinary, and returns URL. |
| **PDF Receipt Presentation & Print** | **YES** | **NO** | Frontend renders receipt modal preview and triggers system print / native download. |
| **WhatsApp Notification Engine** | **NO** | **YES** | Automated WhatsApp receipt messages dispatched by backend via Twilio / MSG91 API. |
| **Admin CRM Controls & Physical Draw** | **NO** | **YES** | Showroom cash recording and winner declaration interface built in separate Swastik CRM React panel. |
| **Offline Caching & State Persistence** | **YES** | **NO** | Frontend caches latest passbook and dashboard data locally for offline viewing. |
| **Global Error Presentation & Toasts** | **YES** | **NO** (Error Source) | Backend delivers standardized JSON error messages; frontend formats and displays localized toasts/alerts. |

---

## 3. Communication Protocol & Standards

1. **Protocol:** All client-server communication must use **HTTPS** with RESTful JSON payloads.
2. **Authentication Header:** Protected endpoints require the standard header:
   ```http
   Authorization: Bearer <jwt_token>
   ```
3. **Standardized Response Envelope:**
   ```json
   {
     "success": true,
     "message": "Operation description",
     "data": { ... }
   }
   ```
4. **Standardized Error Envelope:**
   ```json
   {
     "success": false,
     "message": "User-facing error explanation",
     "errorCode": "INVALID_OTP",
     "details": [ ... ]
   }
   ```
5. **No Breaking Schema Changes:** Field names agreed upon in `DATA_MODELS.md` must not be renamed or altered without updating the client model mappers.
