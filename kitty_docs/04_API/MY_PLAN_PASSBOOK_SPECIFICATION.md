# My Plan & Passbook Specification

**Project**: Swastik Jewellers Kitty Savings App  
**Location**: `kitty_frontend/kitty_docs/04_API/MY_PLAN_PASSBOOK_SPECIFICATION.md`  
**Status**: Complete Specification  

---

## 1. Domain Concept: The Digital Gold Passbook

The **My Plan (Passbook)** feature is the primary engagement screen for active patrons. It provides real-time visibility into:
1. **Active Kitty Summary**: Chit token number (e.g. `SW-ROYAL-007`), scheme name, target maturity amount, and monthly installment.
2. **Savings Progress**: Months paid out of 12, total money paid, and remaining balance.
3. **Gold Asset Accumulation**: Total 24K gold weight accumulated to date (grams with 3 decimals) and live market valuation based on today's gold rate.
4. **Next EMI Countdown**: Next payable installment month, amount, due date (default 15th of each month), and remaining days.
5. **Installment Timeline Table (Passbook)**: Complete 12-month ledger detailing transaction IDs, payment methods, dates, gold credits, and digital receipt PDFs.

---

## 2. Dashboard & Passbook Endpoint

* **Endpoint**: `GET /api/v1/memberships/my-dashboard`
* **Implementation Status**: `[IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Controller**: `src/controllers/membership.controller.js` (`getMyDashboardController`)
* **Service**: `src/services/dashboard.service.js` (`synthesizeDashboard`)
* **Auth Required**: Yes (`Authorization: Bearer <TOKEN>`)

### 2.1 Response Payload Structure (`200 OK`)

```json
{
  "success": true,
  "message": "Dashboard data retrieved.",
  "data": {
    "hasActiveScheme": true,
    "dashboard": {
      "membershipId": "67039a48b71d4a0012349001",
      "chitToken": "SW-ROYAL-007",
      "schemeName": "Swastik Royal Gold Kitty (11+1)",
      "targetAmount": 120000,
      "customMonthlyEmi": 10000,
      "totalMonths": 12,
      "monthsPaid": 8,
      "totalPaidAmount": 80000,
      "remainingAmount": 30000,
      "accumulatedGoldGrams": 10.688,
      "currentValuation": 80000,
      "valuationGainPct": 0.0,
      "nextInstallment": {
        "month": 9,
        "amount": 10000,
        "dueDate": "2026-10-15T00:00:00.000Z",
        "daysRemaining": 8
      },
      "passbook": [
        {
          "month": 1,
          "label": "Month 1",
          "amount": 10000,
          "status": "PAID",
          "paidAt": "2026-02-14T10:30:00.000Z",
          "paymentMethod": "ONLINE",
          "transactionId": "TXN-SW-90011",
          "goldGrams": 1.336,
          "receiptUrl": "https://res.cloudinary.com/swastik/image/upload/receipts/rec_1.pdf"
        },
        {
          "month": 9,
          "label": "Month 9",
          "amount": 10000,
          "status": "CURRENT",
          "dueDate": "2026-10-15T00:00:00.000Z"
        },
        {
          "month": 10,
          "label": "Month 10",
          "amount": 10000,
          "status": "UPCOMING",
          "dueDate": "2026-11-15T00:00:00.000Z"
        },
        {
          "month": 12,
          "label": "Month 12",
          "amount": 10000,
          "status": "BONUS",
          "bonusNote": "100% Jeweler Bonus Deposit on completion"
        }
      ]
    }
  }
}
```

### 2.2 Empty State (No Active Schemes)
If the user has not yet enrolled in any scheme:
```json
{
  "success": true,
  "message": "Dashboard data retrieved.",
  "data": {
    "hasActiveScheme": false,
    "dashboard": null
  }
}
```
* **Frontend Handling**: Renders `HomeNoActiveKittyCard` with "Explore Kitty Plans" call-to-action button routing to `/offers`.

---

## 3. Passbook Status State Machine

Each row in the `passbook` array represents one month of the 12-month tenure:

| Row Status | Visual Badge | Meaning & Behavior |
| :--- | :---: | :--- |
| **`PRE_JOIN`** | Muted Grey | Months before the patron joined (for late joiners). |
| **`PAID`** | Emerald Green | Installment has been successfully paid and reconciled. Tapping opens digital receipt modal. |
| **`CURRENT`** | Amber / Gold | The currently due installment. Features prominent `[PAY NOW]` or `[PICK CASH]` action. |
| **`UPCOMING`** | Neutral Border | Future installments scheduled for subsequent months. |
| **`BONUS`** | Luxury Purple | Month 12 bonus paid 100% by Swastik Jewellers on scheme completion. |

---

## 4. Multi-Scheme Dashboard Extension Requirement

* **Current Backend**: Returns single `membership` populated in `my-dashboard`.
* **Frontend Architecture**: Supports patrons holding multiple active schemes simultaneously (e.g. 1 Royal Gold + 1 Coin Accumulator).
* **Recommended Backend Update**: Extend `my-dashboard` or provide `GET /api/v1/memberships/my-schemes` returning an array of active scheme dashboards (`dashboards: [...]`) so the mobile client can render horizontal swipe cards for each active scheme.

---

## 5. Frontend Usage

* `lib/features/dashboard/presentation/screens/dashboard_screen.dart` (Full My Plan / Dashboard screen)
* `lib/features/passbook/presentation/screens/passbook_screen.dart` (Detailed passbook ledger & timeline table)
* `lib/features/home/presentation/widgets/home_active_kitty_card.dart` (Home screen active plan widget)
* `lib/features/dashboard/presentation/widgets/dashboard_next_emi_card.dart` (Next installment alert card)
* `lib/features/receipt/presentation/widgets/digital_receipt_modal.dart` (Receipt viewer)
