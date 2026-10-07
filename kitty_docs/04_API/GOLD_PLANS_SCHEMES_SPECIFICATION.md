# Gold Plans & Kitty Schemes Specification

**Project**: Swastik Jewellers Kitty Savings App  
**Location**: `kitty_frontend/kitty_docs/04_API/GOLD_PLANS_SCHEMES_SPECIFICATION.md`  
**Status**: Complete Specification  

---

## 1. Domain Concept: The 11+1 Kitty Scheme

The traditional gold kitty savings scheme operated by Swastik Jewellers follows an **11+1 month benefit structure**:
1. **Tenure**: Exactly 12 months.
2. **Customer Obligation**: The patron pays installments for **11 months** (Months 1 through 11).
3. **Jeweler Bonus**: The **12th month installment is paid 100% by Swastik Jewellers** as a completion bonus.
4. **Maturity Benefits**:
   * Patrons redeem accumulated gold against 22K (916) or 18K (750) hallmarked jewellery or 24K pure bullion coins.
   * Flat **25% waiver on jewellery making charges**.
   * Purity: 24K 999 Hallmark Gold benchmark.

---

## 2. Scheme Catalog Endpoint

* **Endpoint**: `GET /api/v1/schemes/active`
* **Implementation Status**: `[IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Controller**: `src/controllers/scheme.controller.js` (`getActiveSchemesController`)
* **Auth Required**: No (Public)
* **Query Parameters**:
  * `duration`: Optional filter (e.g. `?duration=12`).
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Active schemes retrieved.",
    "data": {
      "schemes": [
        {
          "id": "67039a48b71d4a0012341001",
          "name": "Swastik Royal Gold Kitty (11+1)",
          "targetAmount": 120000,
          "durationMonths": 12,
          "monthlyInstallment": 10000,
          "maxCapacity": 50,
          "currentMembers": 28,
          "status": "OPEN",
          "benefits": [
            "1 Month Free: 11 Paid + 12th Month 100% Jeweler Bonus",
            "25% Flat Discount on Jewellery Making Charges",
            "Accumulate 24K 999 Hallmark Purity Gold"
          ],
          "bannerImageUrl": "assets/images/kitty_banner_royal_gold.jpg",
          "isPopular": true
        },
        {
          "id": "67039a48b71d4a0012341002",
          "name": "Swastik Gold Coin Accumulator",
          "targetAmount": 60000,
          "durationMonths": 12,
          "monthlyInstallment": 5000,
          "maxCapacity": 50,
          "currentMembers": 15,
          "status": "OPEN",
          "benefits": [
            "1 Month Free: 11 Paid + 12th Month 100% Jeweler Bonus",
            "Convert to 24K 999 Fine Gold Coins with Zero Making Charges",
            "Doorstep Insured Delivery on Maturity"
          ],
          "bannerImageUrl": "assets/images/kitty_banner_gold_coins.jpg",
          "isPopular": false
        }
      ]
    }
  }
  ```
* **Frontend Usage**:
  * `lib/features/offers/presentation/screens/offers_screen.dart` (Schemes tab)
  * `lib/features/home/presentation/widgets/home_gold_schemes_list.dart`

---

## 3. Lucky Number Selection Grid (01–50)

### 3.1 UX Requirement
During enrollment, patrons select their lucky chit token number from a 50-slot grid (Numbers 01 through 50).

### 3.2 Slot Status State Machine
Each slot has one of three statuses:
* **`AVAILABLE`**: Slot is open and can be selected by any patron.
* **`HELD`**: Slot is temporarily reserved (15-minute lock window) while a patron completes KYC or review.
* **`BOOKED`**: Slot is permanently assigned to an active membership.

### 3.3 Required Endpoint: Get Numbers Availability
* **Endpoint**: `GET /api/v1/schemes/:id/numbers`
* **Implementation Status**: `[REQUIRED / NOT CURRENTLY IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Auth Required**: Yes (`Authorization: Bearer <TOKEN>`)
* **Expected Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Scheme number slots retrieved.",
    "data": {
      "schemeId": "67039a48b71d4a0012341001",
      "totalSlots": 50,
      "numbers": [
        { "number": 1, "label": "01", "status": "BOOKED", "chitToken": "SW-ROYAL-001" },
        { "number": 2, "label": "02", "status": "AVAILABLE" },
        { "number": 7, "label": "07", "status": "HELD", "heldUntil": "2026-10-07T13:15:00.000Z" }
      ]
    }
  }
  ```
* **Frontend Usage**:
  * `lib/features/offers/presentation/widgets/kitty_number_picker_sheet.dart`
  * `lib/features/offers/presentation/screens/booking_screen.dart`

---

## 4. Plan Review & Enrollment Flow

The current approved Flutter frontend enrollment flow follows this sequence:
```
1. OffersScreen (View plans list & select scheme)
         ↓
2. KittyNumberPickerSheet / BookingScreen (Select lucky number 01–50)
         ↓
3. ReviewPlanScreen (Review scheme rules, EMI amount, bonus month, and selected number)
         ↓
4. Enrollment API Call (POST /api/v1/memberships/join)
         ↓
5. CheckoutScreen (Pay 1st installment via GoKwik or request Cash Pickup)
```

### 4.1 Enrollment Endpoint
* **Endpoint**: `POST /api/v1/memberships/join`
* **Implementation Status**: `[IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Controller**: `src/controllers/membership.controller.js` (`joinSchemeController`)
* **Service**: `src/services/emi.service.js` (`calculateDynamicEmi`)
* **Auth Required**: Yes (`Authorization: Bearer <TOKEN>`)
* **Request Body**:
  ```json
  {
    "schemeId": "67039a48b71d4a0012341001",
    "joinedAtMonth": 1,
    "selectedNumber": 7
  }
  ```
* **Backend Validations & Business Rules**:
  1. **Compliance Check**: Patron KYC must be `isVerified: true` (or pending in sandbox test mode). Violations return `403 KYC_REQUIRED`.
  2. **Duplicate Prevention**: Patron cannot enroll twice into the same active scheme. Violations return `409 DUPLICATE_MEMBERSHIP`.
  3. **Capacity Check**: Atomic increment on `currentMembers` ensuring it does not exceed `maxCapacity`. Violations return `400 SCHEME_CAPACITY_FULL`.
  4. **Late Joiner Math**: If patron joins after Month 1 (e.g. Month 3), `emi.service.js` dynamically recalculates `customMonthlyEmi` so the patron achieves the full `targetAmount` over the remaining customer months:
     $$\text{Remaining Customer Months} = (\text{durationMonths} - 1) - (\text{joinedAtMonth} - 1)$$
     $$\text{Customer Payable} = \text{targetAmount} - \text{bonusAmount}$$
     $$\text{customMonthlyEmi} = \lceil \frac{\text{Customer Payable}}{\text{Remaining Customer Months}} \rceil$$
* **Success Response (`201 Created`)**:
  ```json
  {
    "success": true,
    "message": "Enrolled in scheme successfully.",
    "data": {
      "membership": {
        "id": "67039a48b71d4a0012349001",
        "schemeId": "67039a48b71d4a0012341001",
        "schemeName": "Swastik Royal Gold Kitty (11+1)",
        "tokenNumber": 7,
        "chitToken": "SW-ROYAL-007",
        "customMonthlyEmi": 10000,
        "targetAmount": 120000,
        "totalPaidAmount": 0,
        "status": "ACTIVE",
        "joinedAtMonth": 1
      }
    }
  }
  ```
