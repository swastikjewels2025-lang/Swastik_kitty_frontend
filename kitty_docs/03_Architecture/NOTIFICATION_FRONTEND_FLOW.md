# Notification Frontend Flow Specification — Kitty App

**Project**: Swastik Jewellers Kitty App (Sub-Brand: Kitty Vault)  
**Primary Codebase**: `D:\kitty_app\`  
**Document Status**: Synchronized with Current Implementation  
**Last Audit Date**: 2026-09-23  

---

## 1. Notification Architecture & Surfaces

In-app notifications are surfaced across three distinct UI touchpoints:

1. **Sticky Header Bell Indicator (`NotificationBellBadge`)**:
   - Positioned on the right side of `HeaderNavBar` next to the hamburger drawer toggle.
   - Shows a gold badge counter if `unreadNotificationsCount > 0`.
2. **Drawer & Menu Badge**:
   - Displays unread counter next to "Notifications" in `LuxuryNavDrawer`.
3. **Dedicated Notification Center (`NotificationsScreen` / `/notifications`)**:
   - Fullscreen feed of transactional and promotional messages.

---

## 2. Notification Center Features (`NotificationsScreen`)

### 2.1 Category Filtering
* **All**: Chronological feed of all incoming patron alerts.
* **Scheme Alerts**: Installment due date warnings (5-day, 2-day, and same-day countdowns), payment confirmations, bonus month accreditation, and **Doorstep Cash Pickup notifications** (pickup scheduled confirmation, assigned agent details, and 6-digit handover OTP).
* **Privileges & Draws**: Festival gold coin promotions, Akshaya Tritiya / Diwali previews, and showroom lucky draw invitations.

### 2.2 Read / Unread Status Management
* Unread items feature a subtle champagne gold border and a solid gold status indicator dot.
* Tapping an unread notification opens the `NotificationDetailSheet`, marks the item as read, and decrements `unreadNotificationsCount`.
* The header provides a "Mark All as Read" action that updates all notification records in local state.

### 2.3 Deep Link Actions
* Installment Due Alert $\rightarrow$ Deep links directly to `/checkout`.
* Cash Pickup Status Alert $\rightarrow$ Opens scheduled pickup details with handover OTP.
* Scheme Maturity Notice $\rightarrow$ Deep links to `/dashboard`.
* Festival Offer $\rightarrow$ Deep links to `/offers` or `/coin-rates`.

### 2.4 Notification Types & Iconography
Every notification tile displays a category badge, formatted timestamp, title, message preview, and an icon enclosed in a circular container tailored to the financial/jewellery theme:
* **`TRANSACTION`**:
  - Icon: `Icons.payments_rounded`
  - Icon & Accent Color: `AppColors.goldPrimary` (`#D4A34A`)
* **`SCHEME` (Gold Scheme Alerts)**:
  - Icon: `Icons.workspace_premium_rounded`
  - Category Heading & Text Color: Strictly rendered in canonical honey gold (`AppColors.honeyGoldAccent` / `#D4A34A`).
  - Icon Color: `AppColors.honeyGoldAccent`
* **`OFFER` (Patron Privileges)**:
  - Icon: `Icons.loyalty_rounded`
  - Accent Color: Amber privilege gold (`#D97706`)
* **`SYSTEM` (Security & Compliance)**:
  - Icon: `Icons.verified_user_rounded`
  - Accent Color: Secure emerald (`#059669`)
* **`UNKNOWN` (Notices & News)**:
  - Icon: `Icons.notifications_active_rounded`
  - Accent Color: Refined slate gray (`#64748B`)

---

## 3. Empty & Error States

* **Empty State**: Displays `KittyEmptyState` with a bell icon, title "No New Notifications", and description "You are all caught up with your kitty payments and Swastik privileges."
* **Loading State**: Shimmer skeleton placeholder rows mimicking notification cards.
