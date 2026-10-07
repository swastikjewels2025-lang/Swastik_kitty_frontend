# KYC Statutory Compliance Specification

**Project**: Swastik Jewellers Kitty Savings App  
**Location**: `kitty_frontend/kitty_docs/04_API/KYC_COMPLIANCE_SPECIFICATION.md`  
**Status**: Complete Specification  

---

## 1. Regulatory Context & Objectives

Under Indian statutory guidelines governing bullion transactions and gold savings schemes (Prevention of Money Laundering Act / PMLA and Chit Fund compliance):
* Patrons enrolling in gold savings schemes or purchasing bullion must verify their identity using government-issued identification (**Aadhaar** or **PAN**).
* Scheme enrollment (`POST /api/v1/memberships/join`) is strictly blocked by the backend (`403 KYC_REQUIRED`) unless the patron has submitted KYC documentation.

---

## 2. KYC Submission Endpoint

* **Endpoint**: `POST /api/v1/users/kyc`
* **Implementation Status**: `[IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Controller**: `src/controllers/user.controller.js` (`submitKycController`)
* **Service**: `src/services/kyc.service.js`
* **Auth Required**: Bearer JWT
* **Content-Type**: `multipart/form-data`

### 2.1 Request Fields & Validation

| Field | Type | Required | Validation Rules & Hints |
| :--- | :---: | :---: | :--- |
| **`documentType`** | String | Yes | Must be `'AADHAAR'` or `'PAN'` (case-insensitive on ingest, normalized to uppercase). |
| **`documentNumber`** | String | Yes | • **AADHAAR**: Exactly 12 numeric digits (`^\d{12}$`).<br>• **PAN**: Exactly 10 alphanumeric characters in statutory format: 5 letters, 4 digits, 1 letter (`^[A-Z]{5}[0-9]{4}[A-Z]{1}$`, e.g. `ABCDE1234F`). |
| **`consentAgreed`** | Boolean / String | Yes | Must evaluate to boolean `true` or string `'true'`. Confirms acceptance of statutory terms and consent for identity verification. |
| **`file`** | Binary File | Yes | Multipart single file attachment.<br>• Allowed MIME types: `image/jpeg`, `image/png`, `image/jpg`, `application/pdf`.<br>• Maximum file size: **10 MB** (`10 * 1024 * 1024` bytes). |

### 2.2 Storage & Security Processing
1. **Multer Memory Storage**: Ingests file safely in memory.
2. **Cloud Storage**: Streamed to Cloudinary secure asset storage under `swastik_kyc/`.
3. **Data Masking**:
   * Aadhaar: Masked as `XXXX XXXX 1234` (last 4 digits exposed).
   * PAN: Masked as `XXXXXX1234F` (last 4 digits + checksum letter exposed).
   * Full unmasked number is stored encrypted at rest.
4. **Reference ID**: Unique human-readable ID generated for support tracking (`KYC-XXXXXX`, e.g. `KYC-582194`).

### 2.3 Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "KYC document submitted successfully.",
  "data": {
    "referenceId": "KYC-582194",
    "status": "PENDING",
    "documentType": "AADHAAR",
    "documentNumberMasked": "XXXX XXXX 3210",
    "documentUrl": "https://res.cloudinary.com/swastik/image/upload/kyc/kyc-582194.jpg"
  }
}
```

### 2.4 Error Responses
* `400 Bad Request (VALIDATION_ERROR)`:
  * Missing consent: `"Statutory compliance consent is required."`
  * Invalid document type: `"Invalid document type. Allowed types are AADHAAR or PAN."`
  * Invalid number: `"Invalid AADHAAR format. Aadhaar must be a 12-digit number."`
  * Missing file: `"Document image or PDF file is required."`
* `400 Bad Request (FILE_LIMIT_EXCEEDED)`: File exceeds 10MB.
* `400 Bad Request (INVALID_FILE_TYPE)`: File extension not JPEG, PNG, or PDF.

---

## 3. KYC Status Lifecycle

```
[NOT_SUBMITTED]
      │
      │ User submits document + consent (POST /api/v1/users/kyc)
      ▼
  [PENDING]
      │
      ├───────────────────────────────┐
      │ Admin reviews & approves       │ Admin rejects with reason
      ▼                               ▼
  [VERIFIED]                      [REJECTED]
(Full access to join schemes)   (Displays rejection banner; user can re-upload)
```

### Admin KYC Review Endpoint
* **Endpoint**: `PATCH /api/v1/admin/kyc/:userId`
* **Implementation Status**: `[IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Controller**: `src/controllers/admin.controller.js` (`reviewKycController`)
* **Auth Required**: `ADMIN` / `SUPER_ADMIN`
* **Request Body**:
  ```json
  {
    "status": "VERIFIED",
    "rejectionReason": null
  }
  ```

---

## 4. Frontend Usage

* **Primary Screen**: `lib/features/kyc/presentation/screens/kyc_screen.dart`
  * Camera or gallery image selection via `image_picker`.
  * Real-time regex validation for Aadhaar and PAN formatting.
  * Statutory consent checkbox.
  * Status display card (Pending review badge, verified tick, or rejection alert).
* **Guards & Navigation**:
  * If a user tries to tap "Join Scheme" without verified KYC, client triggers `KycStatusViews` bottom sheet or routes to `/kyc`.
