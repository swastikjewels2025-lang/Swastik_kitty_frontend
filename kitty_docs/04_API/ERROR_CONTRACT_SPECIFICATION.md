# Master Error Contract Specification

**Project**: Swastik Jewellers Kitty Savings App  
**Location**: `kitty_frontend/kitty_docs/04_API/ERROR_CONTRACT_SPECIFICATION.md`  
**Status**: Complete Specification  

---

## 1. Global Error Architecture

The Swastik Kitty system enforces strict error contract normalization:
1. **Never Return Plain HTML**: Express error handlers must always return `application/json`.
2. **Defensive Client Parsing**: The Flutter Dio client expects an `error` dictionary inside `{ success: false, message: ..., error: { code, details } }`.
3. **User-Friendly Messaging**: `message` must always contain safe, human-readable prose that can be directly presented in a SnackBar or ErrorCard.

---

## 2. Standard Error Envelope Structure

```json
{
  "success": false,
  "message": "Human-readable explanation of what went wrong.",
  "error": {
    "code": "STANDARD_ERROR_CODE",
    "details": {
      "field": "phone",
      "reason": "Invalid E.164 pattern"
    }
  }
}
```

---

## 3. HTTP Status Codes & Semantic Meanings

| Code | HTTP Meaning | Backend Trigger | Mobile Client Behavior |
| :---: | :--- | :--- | :--- |
| **`200`** | OK | Request processed successfully. | Deserializes response data. |
| **`201`** | Created | New entity created (Membership, Booking). | Navigates to success / next step. |
| **`400`** | Bad Request | Form validation failure, malformed JSON. | Displays red input border & field error. |
| **`401`** | Unauthorized | Bearer token missing, expired, or invalid. | Clears local Keystore; redirects to `/auth/login`. |
| **`403`** | Forbidden | Action blocked (e.g. KYC not verified). | Opens KYC verification modal sheet. |
| **`404`** | Not Found | Resource ID does not exist. | Displays `KittyEmptyState` with back action. |
| **`409`** | Conflict | Duplicate membership, slot already booked. | Shows conflict SnackBar / refreshes grid. |
| **`422`** | Unprocessable | Semantically invalid payload. | Displays specific domain validation error. |
| **`429`** | Rate Limited | Too many requests (e.g. OTP quota). | Disables CTA button with countdown timer. |
| **`500`** | Server Error | Uncaught backend runtime exception. | Displays `KittyErrorState` with "Retry" button. |

---

## 4. Canonical Domain Error Codes Dictionary

| Error Code | HTTP Status | Context / Trigger | Client User Message |
| :--- | :---: | :--- | :--- |
| `VALIDATION_ERROR` | 400 | Form field failed regex or constraint. | "Please check the entered information." |
| `RATE_LIMIT_EXCEEDED` | 429 | Exceeded 3 OTP requests in 15 mins. | "Please wait before requesting another OTP." |
| `INVALID_OTP` | 400 | Entered OTP code did not match cache. | "Incorrect OTP entered. X attempts remaining." |
| `OTP_EXPIRED` | 400 | OTP entered after 300-second TTL. | "OTP has expired. Please request a new OTP." |
| `OTP_LOCKED` | 400 | 3 failed OTP attempts exhausted. | "Too many failed attempts. Request a new OTP." |
| `KYC_REQUIRED` | 403 | Attempting to join scheme without KYC. | "Statutory KYC verification is required." |
| `DUPLICATE_MEMBERSHIP` | 409 | Patron already enrolled in scheme. | "You already have an active plan in this scheme." |
| `SCHEME_CAPACITY_FULL` | 400 | Scheme reached maximum 50 members. | "This scheme is currently full." |
| `NUMBER_ALREADY_BOOKED` | 409 | Selected slot claimed by another user. | "This number was just booked. Select another." |
| `USER_NOT_FOUND` | 404 | User document missing in database. | "User account not found." |
| `PAYMENT_FAILED` | 400 | GoKwik transaction failed or declined. | "Payment could not be processed. Please retry." |
| `INVALID_SIGNATURE` | 401 | Webhook HMAC hash mismatch. | Logged internally. |

---

## 5. Mobile Error Handling Components

* `lib/shared/widgets/feedback/kitty_error_state.dart`: Fullscreen and widget-level error states with animated luxury retry button.
* `lib/shared/widgets/feedback/kitty_empty_state.dart`: Empty state graphics for zero active schemes, zero notifications, or zero bookings.
* `lib/core/network/dio_client.dart`: Centralized Dio interceptor that transforms DioException into domain `ApiException` containing status code and error code.
