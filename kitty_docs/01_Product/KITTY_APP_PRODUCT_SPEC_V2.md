# Kitty App Product Specification V2 (Kitty-First & Extreme Simplification)

**Project**: Swastik Jewellers Kitty App  
**Document Status**: Official Master Product Specification (V2)  
**Effective Date**: 2026-09-29  
**Replaces**: `01_PRD.md` (V1.0)  
**Target Platform**: Flutter Mobile (Android & iOS) + Web  

---

## 1. Product Vision & Core Goal

### 1.1 The Primary Goal
> **"Make the entire app extremely simple and easy to understand so that even a user with limited technical/digital literacy can use it confidently without needing help."**

The Swastik Jewellers application is fundamentally reimagined as a **Kitty-First Application**. While Swastik Jewellers offers fine jewelry, coins, and showroom services, the mobile app's primary identity and daily reason-for-use is **managing and growing the patron's Kitty savings scheme**.

At the same time, the app remains:
* **Attractive & Modern**: Rich emerald and warm pearl aesthetic with antique gold accents.
* **Premium & Trustworthy**: Clear hallmark disclosures, sovereign assay transparency, and real-time passbook reconciliation.
* **Fast & Effortless**: Core daily actions (paying monthly installment, checking gold rate) reachable within **1 to 2 taps** (guaranteeing the 3-Tap Rule).
* **Uncompromisingly Simple**: Elimination of financial jargon, dense matrices, competing calls to action, and decorative visual noise.

---

## 2. Target Audience & Digital Literacy Profiles

The application is engineered for the broadest possible demographic in tier-1, tier-2, and tier-3 Indian households, specifically serving patrons who may not be comfortable with modern complex financial apps.

| User Archetype | Demographic & Persona | Key Pain Points in Current Apps | V2 Product Design Requirement |
| :--- | :--- | :--- | :--- |
| **Elderly Patron / Homemaker** | 45–70 years old; primary caretaker of household gold savings; prefers Hindi/vernacular context; low vision/fine-motor agility. | Intimidated by small fonts, tiny buttons, abstract icons, and terms like "reconciliation" or "benchmark bullion". | Huge touch targets (min 52px), 18px+ amounts, clear rupee symbols, zero jargon, single prominent "PAY NOW" button. |
| **First-Time Smartphone User** | 20–60 years old; uses mobile primarily for WhatsApp and YouTube; unfamiliar with multi-tier digital banking. | Gets lost in deep nested menus, tabs inside tabs, and multi-step forms. | "Show what to do rather than making them search." Everything visible on Home or 1 tap away. |
| **Existing Kitty Patron** | Active participant in an offline Swastik Suvarna Varsha group; visits showroom monthly or sends cash. | Forgets due dates, worries about paper receipt loss, wants quick online payment option. | Big home status card: "Month 8 of 12 Deposited • Due 5 Oct", 1-tap UPI payment, instant digital tax receipt. |
| **New Kitty Saver** | Young professional or bride-to-be saving for upcoming wedding jewellery. | Hesitates when presented with complicated terms & conditions without clear bottom-line math. | Crystal clear visual formula: "You pay 11 months, Swastik pays 1 month bonus. Pay ₹5,000/mo → Get ₹60,000 gold." |

---

## 3. Core User Goals & Feature Prioritization

The application strictly prioritizes Kitty operations over generic jewellery e-commerce.

```
PRIORITY 1: KITTY CORE (80% of App Focus)
│
├── 1. Understand Kitty Plans (Simple 11+1 month benefits, duration, bonus math)
├── 2. Start a New Kitty (Select monthly amount, choose lucky number, pay Month 1)
├── 3. Choose & Book Kitty Number (Visual grid: Available vs Booked vs Selected)
├── 4. Pay Monthly Kitty Installment (1-tap UPI / Card / Doorstep Cash Collection)
├── 5. Pay Multiple Installments (Advance pay 2 or 3 months when funds are available)
├── 6. Pay Full Remaining Amount (Clear balance to redeem jewellery)
├── 7. Track Active Kitty Progress (Simple passbook history, paid/due count)
├── 8. Check Today's Live Gold Rates (24K, 22K, 18K, 14K rates updated daily)
└── 9. Receive Friendly Due Reminders (Actionable alerts before 5th of each month)

PRIORITY 2: SECONDARY SERVICES (20% of App Focus — Accessible via Hamburger Menu or Utilities)
│
├── 10. Gold & Silver Coins (Moved from bottom bar to Hamburger Menu → Coins)
├── 11. Official Showroom Jewellery Catalog (Embedded live web experience in bottom bar)
├── 12. Gold Value Calculator (Dedicated utility tab in bottom bar)
├── 13. Digital Receipts & Tax Invoices (PDF view and download)
├── 14. Statutory KYC Identity Verification (Aadhaar / PAN compliance)
└── 15. Showroom Concierge & WhatsApp Support (1-tap dialer and chat)
```

---

## 4. Fundamental UX Simplification Principles

Every screen and component must satisfy the following golden rules:

1. **The 3-to-5 Second Understanding Rule**: Can a user open any screen and understand its single primary action within 3 to 5 seconds? If not, strip away secondary information.
2. **The 3-Tap Action Guarantee**: 
   - Pay Kitty Installment: **2 Taps** from cold start (`Home` $\rightarrow$ `[Pay Now]` $\rightarrow$ `[Confirm UPI]`).
   - Check Live Gold Rate: **1 Tap** from bottom bar (`Live Rates`).
   - Start Kitty: **3 Taps** (`Kitty Plans` $\rightarrow$ `Pick Number` $\rightarrow$ `[Pay Month 1]`).
3. **One Dominant Primary Action**: Never present multiple competing buttons of the same visual weight. One large Emerald/Gold CTA; secondary actions relegated to text links or outline pills.
4. **Zero Jargon Terminology**:
   - Replace *"Installment"* with **"Monthly Payment"** (*Kist*).
   - Replace *"Chit Token"* with **"Kitty Number"**.
   - Replace *"Dashboard"* with **"My Kitty"**.
   - Replace *"Passbook Ledger"* with **"Savings History"**.
   - Replace *"Statutory KYC"* with **"ID Verification"**.
5. **Multi-Modal Visual Status**: Never convey status by color alone. Every badge, number chip, or timeline item must pair color with an **icon** and an **explicit text label** (ensuring accessibility for elderly and color-blind users).
6. **No Placeholder Catalogs**: Remove mock 12-item jewellery listings; replace with an in-app luxury web bridge to the official Swastik Jewellers live website.

---

## 5. Brand Identity & Visual Language

* **Primary Brand Emerald**: `#063D2E` (Sidebar, primary CTAs, active states)
* **Secondary Vibrant Emerald**: `#0A6B4F` (Live indicators, status badges)
* **Luxury Antique Gold**: `#D4A34A` / `#FFE28A` (Brand crest, highlights, accents)
* **Canvas Background**: `#F9F7F2` (Warm Pearl / clean off-white; replaces dirty beiges)
* **Card Surface**: `#FFFFFF` (Pure white cards with subtle 1px border `#EAE6DF`)
* **Typography**: Plus Jakarta Sans (Primary body & UI), Cormorant Garamond / Cinzel (Display accents)
* **Touch Targets**: Minimum **52px height** for all interactive buttons.
