# Live Gold Rates Specification

**Project**: Swastik Jewellers Kitty Savings App  
**Location**: `kitty_frontend/kitty_docs/04_API/GOLD_RATES_SPECIFICATION.md`  
**Status**: Complete Specification  

---

## 1. Market Rate Architecture

The Swastik Kitty App displays live benchmark gold and silver rates across all primary surfaces:
* Top rate ticker strip on the Home screen
* Dedicated Live Rates navigation screen
* Gold Coins dynamic price calculation
* Valuation and conversion in the Gold Calculator

### 1.1 Source & Benchmark Standards
* **Benchmark**: Official **IBJA (India Bullion and Jewellers Association)** daily benchmark rates.
* **Base Currency**: Indian Rupee (`INR`).
* **Base Unit**: 1 Gram (`1 gram`).
* **Update Frequency**: Live polling or daily morning rate publication (typically updated at 11:30 AM and 3:30 PM IST on business days).

---

## 2. Live Rate Endpoint

* **Endpoint**: `GET /api/v1/rates/gold`
* **Implementation Status**: `[IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Controller**: `src/controllers/rate.controller.js` (`getLiveGoldRateController`)
* **Model**: `src/models/GoldRate.model.js`
* **Auth Required**: No (Public)

### 2.1 Response Payload Structure (`200 OK`)

```json
{
  "success": true,
  "message": "Live gold rates retrieved.",
  "data": {
    "rate24k": 7485.50,
    "rate22k": 6860.00,
    "rateChangePct": 0.62,
    "unit": "1 gram",
    "currency": "INR",
    "benchmark": "IBJA Official",
    "updatedAt": "2026-10-07T06:30:00.000Z",
    "silverRatePerGram": 92.50
  }
}
```

---

## 3. Client-Side Karat Purity Derivations

The backend provides the authoritative 24K (99.9% fine) and 22K (91.6% hallmark) rates. The mobile client dynamically derives subordinate karats using standard statutory purity fractions:

$$\text{Rate}_{24K} = \text{Authoritative Base Rate (from Backend)}$$
$$\text{Rate}_{22K} = \text{Authoritative 22K (from Backend)} \quad \text{or} \quad \text{Rate}_{24K} \times \frac{22}{24}$$
$$\text{Rate}_{18K} = \text{Rate}_{24K} \times \frac{18}{24} = \text{Rate}_{24K} \times 0.750$$
$$\text{Rate}_{14K} = \text{Rate}_{24K} \times \frac{14}{24} = \text{Rate}_{24K} \times 0.5833$$

This approach guarantees mathematically coherent prices across all screens with zero round-trip latency.

---

## 4. Admin Rate Publishing Endpoint

* **Endpoint**: `POST /api/v1/admin/rates/gold`
* **Implementation Status**: `[IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Controller**: `src/controllers/admin.controller.js` (`updateDailyGoldRateController`)
* **Auth Required**: `ADMIN` / `SUPER_ADMIN`
* **Request Body**:
  ```json
  {
    "rate24k": 7520.00,
    "rate22k": 6890.00,
    "rateChangePct": 0.45,
    "benchmark": "IBJA Official"
  }
  ```
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Daily gold rate updated successfully.",
    "data": {
      "rate24k": 7520.00,
      "rate22k": 6890.00,
      "updatedAt": "2026-10-07T12:00:00.000Z"
    }
  }
  ```

---

## 5. Frontend Usage

* `lib/features/home/presentation/widgets/home_gold_rate_strip.dart` (Top header rate strip)
* `lib/features/home/presentation/widgets/home_gold_silver_rate_carousel.dart` (Home rate cards)
* `lib/features/home/presentation/widgets/home_today_gold_rates.dart` (Rate board)
* `lib/features/live_rates/presentation/screens/live_rates_screen.dart` (Dedicated Live Rates tab)
* `lib/features/coin_rates/presentation/screens/coin_rates_screen.dart` (Coin price multiplier)
* `lib/features/calculator/presentation/screens/calculator_screen.dart` (Valuation formula engine)
