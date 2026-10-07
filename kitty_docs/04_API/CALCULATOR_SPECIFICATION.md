# Gold Calculator & Kitty Conversion Specification

**Project**: Swastik Jewellers Kitty Savings App  
**Location**: `kitty_frontend/kitty_docs/04_API/CALCULATOR_SPECIFICATION.md`  
**Status**: Complete Specification  

---

## 1. Architectural Architecture: Strictly Frontend-Only Computation

> [!IMPORTANT]
> **NO BACKEND CALCULATION ENDPOINT REQUIRED:**  
> The gold calculator is implemented **100% client-side** in Flutter.  
> It does **NOT** invoke any remote API for calculating valuations, wastage, or making charges.  
> The only backend dependency is fetching the latest benchmark 24K gold rate via `GET /api/v1/rates/gold`.

---

## 2. Mathematical Valuation Formula Engine

The client performs real-time financial math using the following parameters:

### 2.1 User Inputs
1. **Weight ($W$)**: Gold weight in grams ($W > 0$).
2. **Karat ($K$)**: Purity selection:
   * **24K**: Purity fraction $F_{purity} = 1.0$ (99.9% pure)
   * **22K**: Purity fraction $F_{purity} = \frac{22}{24} \approx 0.9167$ (91.6% hallmark)
   * **18K**: Purity fraction $F_{purity} = \frac{18}{24} = 0.750$ (75.0% standard)
3. **Wastage Percentage ($P_{wastage}$)**: Melting loss / wastage (typically 0% to 15%, e.g. 5%).
4. **Making Charges per Gram ($M_{making}$)**: Craftsmanship charge in ₹/g (e.g. ₹450/g).

### 2.2 Calculation Steps

$$\text{Base Rate} = \text{Rate}_{24K} \quad (\text{from } \texttt{GET /api/v1/rates/gold})$$

$$\text{Effective Gold Rate} = \text{Base Rate} \times F_{purity}$$

$$\text{Pure Gold Value} = W \times \text{Effective Gold Rate}$$

$$\text{Wastage Value} = \text{Pure Gold Value} \times \frac{P_{wastage}}{100}$$

$$\text{Making Charges Value} = W \times M_{making}$$

$$\text{Total Estimated Valuation} = \text{Pure Gold Value} + \text{Wastage Value} + \text{Making Charges Value}$$

---

## 3. "Convert to Kitty Savings" Algorithm

The calculator includes a strategic conversion feature that demonstrates to the patron how joining a Swastik Kitty Scheme eliminates jewellery making charges:

$$\text{Equivalent Monthly Kitty Installment} = \left\lceil \frac{\text{Total Estimated Valuation}}{11} \right\rceil$$

### Value Proposition Displayed to Patron:
* *"Save ₹X in Making Charges with Swastik Royal Gold Scheme (11+1)!"*
* Direct CTA button: **"Start Kitty Scheme with this Goal"** → Routes directly to `/offers` pre-selecting the nearest matching monthly installment plan.

---

## 4. Frontend Implementation Reference

* **Screen**: `lib/features/calculator/presentation/screens/calculator_screen.dart`
* **Controller**: `lib/features/calculator/presentation/providers/start_kitty_flow_controller.dart`
* **Rate Source**: Listens to `liveRateControllerProvider` which polls `GET /api/v1/rates/gold`.
