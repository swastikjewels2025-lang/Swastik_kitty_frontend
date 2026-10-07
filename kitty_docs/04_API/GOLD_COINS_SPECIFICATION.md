# Gold Coins & Bullion Specification

**Project**: Swastik Jewellers Kitty Savings App  
**Location**: `kitty_frontend/kitty_docs/04_API/GOLD_COINS_SPECIFICATION.md`  
**Status**: Complete Specification  

---

## 1. Domain Concept: Physical Bullion & Minted Coins

The **Gold Coins** feature allows patrons of Swastik Jewellers to browse, calculate dynamic live prices for, and instantly book physical 24K and 22K certified gold coins and bullion bars.

### 1.1 Product Offerings
1. **Direct Available Coins**:
   * **4g 24K (999) Fine Gold Coin**: Tamper-proof assay blister pack, BIS hallmarked.
   * **5g 24K (999) Fine Gold Coin**: Tamper-proof assay blister pack, BIS hallmarked.
2. **Custom Gold Coin Builder**:
   * **Karats**: 24K (99.9% fine), 22K (91.6% hallmark), 18K (75.0% standard).
   * **Quick Weights**: 1g, 2g, 8g, 10g, 20g chips.
   * **Custom Weight Input**: Any custom weight in grams (e.g. 15.5g).

---

## 2. Dynamic Pricing Formula

Coin prices are calculated dynamically using the live gold rate (`GET /api/v1/rates/gold`):

$$\text{Coin Price} = \text{Weight (grams)} \times \left( \text{Base Rate}_{24K} \times \text{Purity Fraction} \right) + \text{Minting Fee}$$

* Minting Fee for standard coins: ₹0 (promotional zero making charge).
* Example: For a 4g 24K coin when rate is ₹7,485.50/g:
  $$\text{Price} = 4 \times 7485.50 = ₹29,942$$

---

## 3. Endpoints Specification

### 3.1 Coins Catalog Endpoint
* **Endpoint**: `GET /api/v1/coins`
* **Implementation Status**: `[REQUIRED / NOT CURRENTLY IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Auth Required**: No (Public)
* **Expected Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Coins catalog retrieved.",
    "data": {
      "coins": [
        {
          "id": "COIN-4G-999",
          "name": "4g 24K Gold Coin",
          "purity": "24K (999)",
          "purityFraction": 1.0,
          "weightGrams": 4.0,
          "inStock": true,
          "makingCharges": 0,
          "imageUrl": "assets/images/gold-coins.jpg"
        },
        {
          "id": "COIN-5G-999",
          "name": "5g 24K Gold Coin",
          "purity": "24K (999)",
          "purityFraction": 1.0,
          "weightGrams": 5.0,
          "inStock": true,
          "makingCharges": 0,
          "imageUrl": "assets/images/gold-coins.jpg"
        }
      ]
    }
  }
  ```

### 3.2 Coin Booking Endpoint
* **Endpoint**: `POST /api/v1/bookings` (or `POST /api/v1/orders/coin`)
* **Implementation Status**: `[REQUIRED / NOT CURRENTLY IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Auth Required**: Yes (`Authorization: Bearer <TOKEN>`)
* **Request Body**:
  ```json
  {
    "category": "COINS",
    "itemName": "4g Gold Coin 24K (999)",
    "karat": "24K",
    "weightGrams": 4.0,
    "unitPrice": 29942,
    "quantity": 1,
    "totalAmount": 29942,
    "notes": "Booked via App"
  }
  ```
* **Expected Response (`201 Created`)**:
  ```json
  {
    "success": true,
    "message": "Gold coin booking created successfully.",
    "data": {
      "bookingId": "BKG-SW-50291",
      "status": "CONFIRMED",
      "totalAmount": 29942,
      "collectionDeadline": "2026-10-10T18:00:00.000Z"
    }
  }
  ```

---

## 4. Frontend Implementation Reference

* **Screen**: `lib/features/coin_rates/presentation/screens/coin_rates_screen.dart`
  * Direct 4g & 5g cards with authentic radial gold coin graphics.
  * Karat selection pills and weight chips.
  * Live dynamic pricing strip with instant rate calculation.
  * Interactive booking confirmation modal saving to `OrdersController`.
* **Navigation**: Accessible directly from the hamburger navigation drawer under **Bullion & Mint / Gold Coins** (`RoutePaths.coinRates`).
