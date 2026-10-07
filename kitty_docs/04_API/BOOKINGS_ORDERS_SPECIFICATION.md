# Bookings & Orders Specification

**Project**: Swastik Jewellers Kitty Savings App  
**Location**: `kitty_frontend/kitty_docs/04_API/BOOKINGS_ORDERS_SPECIFICATION.md`  
**Status**: Complete Specification  

---

## 1. Domain Concept

The **Bookings & Orders** domain tracks all non-installment customer transactions and reservations made across the app:
1. **Gold Coin Reservations**: Lock in gold prices for physical store collection of 24K coins.
2. **Jewellery Appointments**: Showroom viewing reservations generated from the jewellery web bridge.
3. **Advance Scheme Token Holds**: Future lucky number scheme reservations.

---

## 2. Endpoints Specification

### 2.1 Create Booking Endpoint
* **Endpoint**: `POST /api/v1/bookings`
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
    "notes": "Booked from Mobile App"
  }
  ```
* **Validation**:
  * `category`: Required enum (`SCHEMES`, `COINS`, `JEWELLERY`).
  * `itemName`: Required non-empty string.
  * `totalAmount`: Required positive number.
* **Success Response (`201 Created`)**:
  ```json
  {
    "success": true,
    "message": "Booking created successfully.",
    "data": {
      "bookingId": "BKG-SW-50291",
      "category": "COINS",
      "itemName": "4g Gold Coin 24K (999)",
      "totalAmount": 29942,
      "status": "CONFIRMED",
      "createdAt": "2026-10-07T12:00:00.000Z"
    }
  }
  ```

### 2.2 Get Bookings History Endpoint
* **Endpoint**: `GET /api/v1/bookings`
* **Implementation Status**: `[REQUIRED / NOT CURRENTLY IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Auth Required**: Yes (`Authorization: Bearer <TOKEN>`)
* **Query Parameters**:
  * `category`: Optional filter (`SCHEMES`, `COINS`, `JEWELLERY`).
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Bookings retrieved.",
    "data": {
      "bookings": [
        {
          "id": "BKG-SW-50291",
          "category": "COINS",
          "itemName": "4g Gold Coin 24K (999)",
          "weightGrams": 4.0,
          "totalAmount": 29942,
          "status": "CONFIRMED",
          "createdAt": "2026-10-07T12:00:00.000Z"
        }
      ]
    }
  }
  ```

---

## 3. Booking Status State Machine

```
[PENDING_CONFIRMATION]
          │
          ▼
     [CONFIRMED]
     │         │
     ▼         ▼
[FULFILLED]  [CANCELLED]
(Collected)   (Expired/Void)
```

---

## 4. Frontend Usage

* **Screen**: `lib/features/orders/presentation/screens/orders_screen.dart`
  * Tabbed filter: **All**, **Schemes**, **Coins**, **Jewellery**.
  * Dynamic list with item title, category badge, total amount, and status pill.
  * Empty state handling when no bookings exist.
* **Controller**: `lib/features/orders/presentation/providers/orders_controller.dart`
  * Currently stores bookings in reactive Riverpod memory; will bind directly to `/api/v1/bookings` once backend implementation is completed.
