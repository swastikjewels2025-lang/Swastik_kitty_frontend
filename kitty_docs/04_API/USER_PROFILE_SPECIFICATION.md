# User Profile Specification

**Project**: Swastik Jewellers Kitty Savings App  
**Location**: `kitty_frontend/kitty_docs/04_API/USER_PROFILE_SPECIFICATION.md`  
**Status**: Complete Specification  

---

## 1. Domain Overview & Profile Model

Every patron registered on the Swastik Kitty App maintains a patron identity document containing demographic, KYC compliance, and tier status details.

### 1.1 Field Inventory & Schema

| Field Name | Type | Mutability | Required | Description |
| :--- | :---: | :---: | :---: | :--- |
| **`id`** | String (ObjectId) | Immutable | Yes | MongoDB primary key. |
| **`phone`** | String | Immutable | Yes | Primary account identifier (`+91XXXXXXXXXX`). |
| **`name`** | String | Mutable | Yes | Patron's first name (min 2 chars, max 60 chars). |
| **`surname`** | String | Mutable | No | Patron's last / family name. |
| **`email`** | String | Mutable | No | Contact email for payment receipt PDFs. |
| **`dateOfBirth`** | String (ISO-8601) | Mutable | No | Date of birth for statutory age compliance (>= 18 years). |
| **`role`** | String (Enum) | Admin Only | Yes | `CUSTOMER` (default), `STAFF`, `ADMIN`, `SUPER_ADMIN`. |
| **`tier`** | String | Server Calculated | Yes | `Standard Member`, `Privilege Member`, `Royal Patron`. |
| **`kyc`** | Object | Server Managed | Yes | Embedded KYC status summary (see KYC Specification). |
| **`createdAt`** | String (ISO-8601) | Immutable | Yes | Registration timestamp. |

---

## 2. Profile Retrieval Endpoint

* **Endpoint**: `GET /api/v1/users/profile`
* **Implementation Status**: `[IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Controller**: `src/controllers/user.controller.js` (`getProfileController`)
* **Auth Required**: Bearer JWT
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "User profile retrieved.",
    "data": {
      "user": {
        "id": "67039a48b71d4a001234abcd",
        "name": "Rihan Saifi",
        "phone": "+919876543210",
        "email": "rihan@swastik.in",
        "role": "CUSTOMER",
        "tier": "Privilege Member",
        "kyc": {
          "isVerified": true,
          "documentType": "AADHAAR",
          "documentNumberMasked": "XXXX XXXX 3210",
          "documentUrl": "https://res.cloudinary.com/swastik/image/upload/kyc/kyc-123456.jpg",
          "status": "VERIFIED",
          "referenceId": "KYC-481920"
        },
        "createdAt": "2026-09-15T12:00:00.000Z"
      }
    }
  }
  ```
* **Frontend Usage**:
  * `lib/features/settings/data/repositories/profile_repository_impl.dart`
  * `lib/shared/widgets/navigation/header_nav_bar.dart` (greets patron by first name)
  * `lib/features/menu/presentation/widgets/kitty_menu_sheet.dart` (profile card, badge, avatar)
  * `lib/features/settings/presentation/screens/settings_screen.dart` (patron info card)

---

## 3. Profile Update Endpoint

* **Endpoint**: `PUT /api/v1/users/profile` (or `PATCH /api/v1/users/profile`)
* **Implementation Status**: `[REQUIRED / NOT CURRENTLY IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Auth Required**: Bearer JWT
* **Request Body**:
  ```json
  {
    "name": "Rihan",
    "surname": "Saifi",
    "email": "rihan@swastik.in",
    "dateOfBirth": "1995-08-15T00:00:00.000Z"
  }
  ```
* **Validation Rules**:
  * `name`: Optional on partial update, but if provided, must be trimmed string (2–60 chars).
  * `surname`: Optional string (max 60 chars).
  * `email`: Optional, must be valid email format if provided (`^[^\s@]+@[^\s@]+\.[^\s@]+$`).
  * `dateOfBirth`: Optional ISO-8601 string, patron must be at least 18 years old.
  * `phone`: **Strictly rejected if sent**. Phone numbers cannot be altered via profile update (requires specialized mobile re-verification flow).
* **Expected Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Profile updated successfully.",
    "data": {
      "user": {
        "id": "67039a48b71d4a001234abcd",
        "name": "Rihan Saifi",
        "phone": "+919876543210",
        "email": "rihan@swastik.in",
        "role": "CUSTOMER",
        "tier": "Privilege Member"
      }
    }
  }
  ```
* **Frontend Usage**:
  * `lib/features/auth/presentation/screens/register_profile_screen.dart` (First-time user onboarding step)
  * `lib/features/menu/presentation/widgets/kitty_menu_sheet.dart` (Edit details bottom sheet)

---

## 4. Current Client-Side Workaround & Mismatch Notice

In `lib/features/settings/data/repositories/profile_repository_impl.dart`:
```dart
  @override
  Future<ProfileEntity> updateProfile({
    String? name,
    String? email,
    String? avatarUrl,
  }) async {
    // The backend does not expose a PUT /api/v1/users/profile endpoint.
    // Return the active profile safely without invoking nonexistent remote routes.
    final ProfileEntity current = await getProfile();
    return current.copyWith(
      name: name ?? current.name,
      email: email ?? current.email,
      avatarUrl: avatarUrl ?? current.avatarUrl,
    );
  }
```
**Action for Backend Engineer**: Implementing `PUT /api/v1/users/profile` in `user.routes.js` and `user.controller.js` will immediately activate remote persistence for this flow without needing any Dart code changes.
