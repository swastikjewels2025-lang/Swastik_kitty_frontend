# Information Architecture V2 — Kitty App

**Project**: Swastik Jewellers Kitty App  
**Document Status**: Official Information Architecture & Navigation Spec (V2)  
**Effective Date**: 2026-09-29  
**Replaces**: `02_PRODUCT_FLOW.md` & `03_SCREEN_FLOW.md` navigation models  

---

## 1. Master System Information Architecture

The application adopts a clean, non-competing dual-tier navigation system:
1. **Primary Bottom Navigation Dock (5 Fixed Tabs)**: Dedicated exclusively to high-frequency daily patron workflows (rates, active savings, plan catalog, calculation, showroom showcase).
2. **Slide-Out Hamburger Menu**: Houses secondary management, account compliance, bullion coins, order history, and support.

```
KITTY APP V2 MASTER NAVIGATION ARCHITECTURE
│
├── [HEADER BAR] (Sticky Across Shell)
│   ├── Left: Authentic Swastik Jewellers Brand Crest (Tapping switches to Home)
│   ├── Right-1: In-App Notifications Bell (with unread badge counter)
│   └── Right-2: Hamburger Toggle [☰] (Slides out luxury secondary drawer)
│
├── [PRIMARY BOTTOM NAVIGATION DOCK] (5 Fixed Tabs)
│   ├── TAB 1: Live Rates (/live-rates)
│   │   ├── Today's Gold Rates (24K, 22K, 18K, 14K per gram)
│   │   ├── Today's Silver Rate (999 Fine Silver per gram & 10g)
│   │   ├── Last updated timestamp & refresh trigger
│   │   └── Direct Action: [ Calculate Gold Value ]
│   │
│   ├── TAB 2: My Kitty (/my-kitty)
│   │   ├── Active Kitty Hero Card (Months paid, next due date, status)
│   │   ├── Big Primary CTA: [ Pay ₹5,000 Installment Now ]
│   │   ├── Action: [ Pay Multiple Months ]
│   │   ├── Action: [ Pay Full Remaining Amount ]
│   │   ├── Multiple Kitties Swiper (if patron holds >1 active scheme)
│   │   └── Link: [ View Full Passbook & Statements → ]
│   │
│   ├── TAB 3: Kitty Plans (/kitty-plans)
│   │   ├── Curated Gold Savings Schemes (e.g. Swastik Suvarna Varsha 11+1)
│   │   ├── Clear visual math (Monthly payment vs Jeweller bonus deposit)
│   │   ├── Benefit highlights (Making charge waivers, 100% bonus month)
│   │   └── Primary Action: [ Start Kitty / Select Number → ]
│   │
│   ├── TAB 4: Calculator (/calculator)
│   │   ├── Mode 1: By Weight ("I have grams, calculate rupees")
│   │   ├── Mode 2: By Budget ("I have rupees, calculate gold grams")
│   │   ├── Karat selector: 24K Pure | 22K Hallmark | 18K Diamond
│   │   ├── Instant bold calculation result in rupees & 3-decimal grams
│   │   └── Direct Action: [ Start Kitty with this Budget ]
│   │
│   └── TAB 5: Jewellery (/jewellery)
│       ├── Embedded luxury WebView loading official Swastik Jewellers catalog
│       ├── Sticky sub-bar with Refresh, Share, and WhatsApp Concierge
│       └── Android back-button interception (navigates web history before app pop)
│
├── [SLIDE-OUT HAMBURGER DRAWER] (Secondary & Account Features)
│   ├── 1. Patron Profile Card (Avatar initial, Name, Phone, Tier badge)
│   ├── 2. Savings History & Tax Receipts (/passbook & /receipt/:id)
│   ├── 3. Gold & Silver Coins (/coins — Moved from bottom dock; full bullion booking)
│   ├── 4. My Orders & Bookings (/orders — Coins, bespoke jewellery, Kitty redemptions)
│   ├── 5. ID Verification / KYC (/kyc — Aadhaar & PAN verification)
│   ├── 6. Notifications & Reminders (/notifications — Alert feed)
│   ├── 7. Settings & Security (/settings — MPIN, Biometrics, Nominee details)
│   ├── 8. Showroom Concierge & Help (1-tap Showroom Phone & WhatsApp chat)
│   ├── 9. About Swastik Jewellers & Showroom Location
│   └── 10. Log Out of Account
│
└── [MODALS & GUIDED STACK FLOWS]
    ├── Start Kitty Flow (Amount $\rightarrow$ Number Selection $\rightarrow$ Month 1 Checkout)
    ├── Payment Checkout Sheet (/checkout — UPI, NetBanking, Card, Pick Cash)
    ├── Doorstep Cash Pickup Sheet ("Pick Cash" slot, address, executive OTP)
    └── Digital Tax Invoice Modal (/receipt/:id — with PDF download)
```

---

## 2. Detailed Home Screen Structural Hierarchy

The Home page acts as an intelligent, dynamic launchpad that adapts based on whether the patron has an active Kitty:

### 2.1 State A: User With Active Kitty (The 90% Daily Use Case)

```
┌────────────────────────────────────────────────────────┐
│ [Swastik Crest]                   (🔔 2)  [ ☰ Menu ]   │
├────────────────────────────────────────────────────────┤
│ 1. TODAY'S GOLD BENCHMARK (Compact Header Strip)       │
│    24K: ₹15,268/g  │  22K: ₹13,995/g  │ Updated 10:30 AM│
├────────────────────────────────────────────────────────┤
│ 2. ACTIVE KITTY HERO CARD (Dominant Visual Fold)       │
│    ┌─────────────────────────────────────────────────┐ │
│    │ Swastik Suvarna Varsha (No. 42)                 │ │
│    │ Progress: 8 of 12 Months Deposited (● On Track) │ │
│    │                                                 │ │
│    │ Next Payment:  ₹5,000                           │ │
│    │ Due Date:      5 October 2026                   │ │
│    │                                                 │ │
│    │  ┌───────────────────────────────────────────┐  │ │
│    │  │       [ PAY ₹5,000 NOW ]                  │  │ │
│    │  └───────────────────────────────────────────┘  │ │
│    │  [ Pay 2+ Months ]       [ View Passbook → ]    │ │
│    └─────────────────────────────────────────────────┘ │
├────────────────────────────────────────────────────────┤
│ 3. MULTIPLE KITTIES CAROUSEL (Only if user has >1 plan)│
│    Shows secondary Kitty cards with balance & due dates│
├────────────────────────────────────────────────────────┤
│ 4. SPECIAL PRIVILEGES CAROUSEL (Simplified Banners)    │
│    "11 Paid + 12th Month 100% Jeweller Bonus"          │
│    "25% Off on Wedding Making Charges for Members"     │
├────────────────────────────────────────────────────────┤
│ 5. QUICK ACTIONS (Large 3-Tile Grid)                   │
│    ┌────────────────┐ ┌────────────────┐ ┌───────────┐ │
│    │ 🌟 Start New   │ │ 🧮 Calculate   │ │ 💎 Showroom││
│    │    Kitty Plan  │ │   Gold Value   │ │  Jewellery ││
│    └────────────────┘ └────────────────┘ └───────────┘ │
├────────────────────────────────────────────────────────┤
│ 6. SHOWROOM & CONCIERGE HELP                           │
│    [ Call Showroom: +91 98765 43210 ] [ WhatsApp Us ]  │
└────────────────────────────────────────────────────────┘
```

### 2.2 State B: User With No Active Kitty (First-Time / Completed Saver)

In State B, Section 2 transforms from a payment card into an inviting, high-trust onboarding hero:
* **Visual**: Golden jewellery box with 24K hallmark crest.
* **Heading**: **"Start Your Gold Savings Journey"**
* **Description**: *"Save monthly in pure 24K gold. Swastik Jewellers pays your 12th month installment as a 100% bonus."*
* **Primary CTA**: **[ Explore Kitty Plans & Pick Lucky Number ]**

---

## 3. Rationale for Removing the 5th Bottom Tab "Menu"

In the previous V1 architecture, the bottom navigation had a 5th tab labeled "Menu" which displayed a fullscreen page ([menu_screen.dart](file:///d:/kitty_app/lib/features/menu/presentation/screens/menu_screen.dart)) that was an **exact duplicate** of the top-right slide-out drawer ([luxury_nav_drawer.dart](file:///d:/kitty_app/lib/shared/widgets/navigation/luxury_nav_drawer.dart)).

**Problems in V1**:
* Confused patrons: Two different menu triggers doing the exact same thing.
* Wasted a prime slot on the bottom dock for redundant links.
* Left "Live Rates" scattered inside the "Coins" shopping page.

**V2 Solution**:
* **Eliminate** the bottom "Menu" tab.
* Retain the standard, universally understood **top-right Hamburger button** `[☰]` in the header to open the slide-out drawer for secondary account/support tasks.
* Use the reclaimed 5th bottom dock position to create a logical, high-value 5-tab structure:
  `Live Rates` | `My Kitty` | `Kitty Plans` | `Calculator` | `Jewellery`.
