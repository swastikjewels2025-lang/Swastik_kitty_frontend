# CRM & Physical Showroom Frontend Integration Specification — Kitty App

**Project**: Swastik Jewellers Kitty App (Sub-Brand: Kitty Vault)  
**Primary Codebase**: `D:\kitty_app\`  
**Backend Workspace**: `D:\Kitty_backend\Swastik_kitty_backend\`  
**Document Status**: Synchronized with Current Implementation  
**Last Audit Date**: 2026-09-23  

---

## 1. Showroom Counter & Omnichannel Operational Boundaries

Swastik Jewellers operates a high-volume physical showroom in Lucknow, India. Many traditional patrons prefer depositing monthly installments in physical cash at the counter or redeeming jewelry in person. 

The client architecture provides seamless omnichannel integration between digital in-app activity and in-store transactions:

```text
┌────────────────────────────────────────────────────────┐
│ PHYSICAL SHOWROOM COUNTER                              │
│ Cashier POS / ERP, Physical Cash Deposit, Bill Receipt  │
└───────────────────────────▲────────────────────────────┘
                            │ POS Webhook / Sync API
┌───────────────────────────┴────────────────────────────┐
│ SWASTIK BACKEND SERVICE (MongoDB Ledger)               │
│ Emits updated passbook installment record (method: CASH)│
└───────────────────────────▲────────────────────────────┘
                            │ GET /api/v1/payments/history
┌───────────────────────────┴────────────────────────────┐
│ MOBILE CLIENT (PassbookScreen / ReceiptScreen)         │
│ Displays cash installment, voucher #, and tax receipt  │
└────────────────────────────────────────────────────────┘
```

---

## 2. In-App Integration Touchpoints

### 2.1 Passbook Walk-In Cash Entries
* When a patron pays cash at the physical showroom, the cashier records the payment in the POS system.
* On the patron's next app refresh, `PassbookScreen` renders the entry with:
  - Payment Method Badge: **CASH** (`emeraldPrimary` background).
  - Transaction Reference: Showroom voucher code (e.g., `CSH-LKO-9921`).
  - Cashier Stamp: Official receipt status.

### 2.2 In-App Showroom Concierge Actions
1. **Coin Rates Screen Booking**:
   - Booking gold coins (>10g bulk or standard) opens a pre-composed WhatsApp message to the Swastik Jewellers showroom sales desk with the patron's name, membership ID, requested gold grams, and estimated total price.
2. **Jewellery Reservation**:
   - The "Reserve Item" action on `JewelleryScreen` generates a reservation token that can be presented at the physical showroom to inspect the selected piece.
3. **Store Video Showcase**:
   - `HomeStoreVideoSection` allows showroom managers to upload craftsmanship and bridal collection preview videos directly from the store tablet.

### 2.3 Doorstep "Pick Cash" Omnichannel Collection Workflow
1. **Patron Booking**:
   - Patron selects "PICK CASH" in `/checkout`, reviews patron details, enters street address, city, and 6-digit postal code, and selects preferred slot (Morning/Afternoon/Evening).
2. **CRM Dispatch Desk Ingestion**:
   - The frontend generates a client-side pickup order object (`PCK-XXXXXX`) with a 6-digit handover OTP.
   - Forwarded to CRM backend for allocation to a bonded Swastik security courier.
3. **Physical Verification & Handover**:
   - The bonded courier arrives at the patron's address during the designated time window.
   - Patron verifies courier showroom badge and presents the 6-digit Handover OTP.
   - Courier enters the OTP in the Swastik CRM Mobile Field POS, receipts the physical cash, and syncs the ledger.
   - The patron's passbook is automatically updated to reflect the installment as `PAID` with payment method `CASH_PICKUP`.

