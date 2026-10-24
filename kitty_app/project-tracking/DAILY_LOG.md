# Kitty App — Daily Work Log

---

## 2026-10-22

### Working Session 1: Environment Setup, Run & Real Phone Testing (14:30 – 15:35 IST)

- **Work Completed**:
  - Inspected repository structure: located Flutter frontend at `Swastik_kitty_frontend/kitty_app` and Node.js backend at `Swastik_kitty_backend`.
  - Audited dependencies: verified Node.js v22.12.0, npm 11.6.1, Flutter 3.47.4, Dart 3.13.3.
  - Resolved backend packages with `npm ci` (216 packages installed cleanly).
  - Created `.env` from `.env.example` targeting local MongoDB service (`mongodb://127.0.0.1:27017/swastik_kitty`) and port 5000.
  - Seeded database via `src/seed.js` with benchmark gold rates (24K/22K), 3 official 11+1 schemes, and master admin.
  - Detected computer's active Wi-Fi LAN IPv4 (`192.168.29.42`) and updated `server_ip.dart`.
  - Added `192.168.29.42` to Android `network_security_config.xml` to permit development cleartext HTTP traffic.
  - Verified ADB device connection with physical phone (`Redmi 2406ERN9CI`, Android 15 API 35).
  - Built debug APK (`build\app\outputs\flutter-apk\app-debug.apk`, 203.6 MB) with `--dart-define=BASE_URL=http://192.168.29.42:5000`.
  - Configured ADB reverse bridge `tcp:5000 -> tcp:5000`.
  - Pushed APK to `/sdcard/Download/SwastikKittyApp.apk`, installed via `pm install -r`, and launched `com.swastikjewel.kittyapp/.MainActivity`.
  - Confirmed live incoming HTTP requests from the physical phone hitting the backend server (`GET /api/v1/users/profile` 401).

- **Files Modified**:
  - `Swastik_kitty_backend/.env`
  - `Swastik_kitty_frontend/kitty_app/lib/core/config/server_ip.dart`
  - `Swastik_kitty_frontend/kitty_app/android/app/src/main/res/xml/network_security_config.xml`

- **Issues Discovered**:
  - Physical phone ADB authorization was initially unapproved (`unauthorized` status); resolved once user accepted the USB debugging RSA key on screen.
  - Direct streamed ADB install returned `INSTALL_FAILED_USER_RESTRICTED` due to Xiaomi HyperOS security restrictions; resolved by staging APK to `/data/local/tmp/app.apk` and installing via `pm install -r`.
  - Port 5000 was held by a background daemon process, preventing user's terminal from capturing stdout; resolved by terminating the daemon and freeing port 5000 for interactive terminal usage.

- **Tests Performed & Results**:
  - `GET http://localhost:5000/api/v1/health` -> `200 OK`, `HEALTHY`, `database: CONNECTED`.
  - `GET http://192.168.29.42:5000/api/v1/rates/gold` -> `200 OK`, 24K: ₹7850, 22K: ₹7195.
  - `GET http://192.168.29.42:5000/api/v1/schemes/active` -> `200 OK`, 3 active schemes returned.
  - `POST http://192.168.29.42:5000/api/v1/auth/send-otp` -> `200 OK`, OTP dispatched.
  - `POST http://192.168.29.42:5000/api/v1/auth/verify-otp` -> `200 OK`, Bearer JWT generated.

---

### Working Session 2: Change Log System & Three-Step Form UI Redesign (16:00 – 16:25 IST)

- **Work Completed**:
  - Created dedicated tracking directory `project-tracking/` containing `README.md`, `CHANGELOG.md`, `DAILY_LOG.md`, and `FRONTEND_BACKEND_COORDINATION.md`.
  - Redesigned all three onboarding forms in `RegisterProfileScreen`:
    - **Step 1 (User Details)**: Centered unified white form card (`maxWidth: 500`, `borderRadius: 20`, light border, subtle shadow), eliminated external labels, placed internal placeholders (`Enter first name`, `Enter last name`, `Enter 10-digit mobile number`, `Enter email address`), preserved cream-colored icon boxes (`#FAF5EB`, gold icon `#C88A35`), `NEXT: ADDRESS & BIRTH DATE` CTA.
    - **Step 2 (Address & Birth Date)**: Centered unified white form card, internal placeholders (`DD/MM/YYYY`, `Enter house / flat / street address`, `Enter city`, `Enter 6-digit pincode`), responsive `LayoutBuilder` (side-by-side on wide screens, stacked on narrow), calendar picker dialog, `NEXT: NOMINEE DETAILS` CTA, skippable actions preserved.
    - **Step 3 (Nominee Details)**: Centered unified white form card, internal placeholders (`Enter nominee full name`, `Enter nominee mobile number`), styled relationship dropdown with cream icon container, preserved green-tinted Nominee Protection statutory banner, `CONFIRM & PROCEED TO KYC` CTA, `Skip nominee for now` action.
  - Preserved all existing controllers, validators, widget keys, Riverpod auth state updating, and navigation behavior.
  - Built incremental debug APK (`build\app\outputs\flutter-apk\app-debug.apk`) with `--dart-define=BASE_URL=http://192.168.29.42:5000`.
  - Pushed to device storage and updated app on connected phone (`Redmi 2406ERN9CI`) via `pm install -r`.
  - Relaunched `MainActivity` on device, displaying redesigned card forms live.

- **Files Modified**:
  - `Swastik_kitty_frontend/kitty_app/lib/features/auth/presentation/screens/register_profile_screen.dart`
  - `Swastik_kitty_frontend/kitty_app/test/widget/auth/register_profile_card_form_test.dart`
  - `Swastik_kitty_frontend/kitty_app/project-tracking/README.md`
  - `Swastik_kitty_frontend/kitty_app/project-tracking/CHANGELOG.md`
  - `Swastik_kitty_frontend/kitty_app/project-tracking/DAILY_LOG.md`
  - `Swastik_kitty_frontend/kitty_app/project-tracking/FRONTEND_BACKEND_COORDINATION.md`

- **Issues Discovered**:
  - Deprecated `value` in `DropdownButtonFormField` flagged by Flutter analyzer; resolved using `initialValue`.

- **Tests Performed & Results**:
  - `flutter analyze` on `kitty_app`: Verified (0 errors, 0 warnings).
  - `flutter test test/widget/auth/register_profile_screen_test.dart`: All 3 tests passed.
  - `flutter test test/widget/auth/register_profile_card_form_test.dart`: All 3 tests passed.
  - Device installation: `Success`. Relaunched top activity: `com.swastikjewel.kittyapp/.MainActivity`.

- **Pending Tasks**:
  - Real KYC Document verification flow integration with backend Cloudinary credentials.
  - Push notification testing with MSG91 / Firebase once production credentials are ready.

- **Next Steps**:
  - Test user details registration, date picker, address entry, and nominee details live on phone.
  - Proceed with KYC document capture and live scheme enrollment testing.

