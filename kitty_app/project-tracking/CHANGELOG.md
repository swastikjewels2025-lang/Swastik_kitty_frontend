# Kitty App — Change Log

## 2026-10-22

### 16:20 IST — Mobile Deployment — Installed Updated Redesign APK on Physical Device
- **Files changed:**
  - `build\app\outputs\flutter-apk\app-debug.apk`
- **Changes:**
  - Built fresh incremental debug APK incorporating the new centered card-form UI redesign and internal placeholders.
  - Pushed updated APK (`243.6 MB`) to device storage `/sdcard/Download/SwastikKittyApp.apk`.
  - Installed onto physical Android phone (`Redmi 2406ERN9CI`, device ID `6698ab0`, Android 15) via `pm install -r /data/local/tmp/app.apk`.
  - Launched `com.swastikjewel.kittyapp/.MainActivity` (Task ID 20, resumed and active in foreground).
- **Reason:**
  - Update user's physical connected phone with latest onboarding redesign for immediate real-world testing.
- **Functionality impact:**
  - Verified app starts cleanly on phone with Vulkan Impeller rendering and connects to local backend over LAN/reverse ADB.
- **Testing:**
  - ADB install command: Returned `Success`.
  - Active Activity verification: `topResumedActivity=ActivityRecord{423a21 u0 com.swastikjewel.kittyapp/.MainActivity t20}`.
- **Status:** Completed.

### 16:15 IST — Frontend — Three-Step Form UI Redesign
- **Files changed:**
  - `lib/features/auth/presentation/screens/register_profile_screen.dart`
  - `project-tracking/README.md`
  - `project-tracking/CHANGELOG.md`
  - `project-tracking/DAILY_LOG.md`
  - `project-tracking/FRONTEND_BACKEND_COORDINATION.md`
- **Changes:**
  - Redesigned all three onboarding screens (Step 1: User Details, Step 2: Address & Birth Date, Step 3: Nominee Details) from separate multi-card layouts into a unified, centered white card form (`maxWidth: 500`, `borderRadius: 20`, light border `#EFE8DE`, subtle shadow).
  - Replaced separate external text labels above each field with clean, descriptive internal placeholders (`Enter first name`, `Enter last name`, `Enter 10-digit mobile number`, `Enter email address`, `DD/MM/YYYY`, `Enter house / flat / street address`, `Enter city`, `Enter 6-digit pincode`, `Enter nominee full name`, `Enter nominee mobile number`).
  - Preserved light cream-colored icon containers (`#FAF5EB`) with gold icon accents (`#C88A35`) neatly beside each input field.
  - Implemented responsive `LayoutBuilder` for City and Pincode in Step 2: side-by-side row on standard screens, vertically stacked on narrow screens.
  - Styled Nominee Relationship dropdown using the unified card input design with cream icon box and dropdown indicator.
  - Retained the green-tinted statutory Nominee Protection information panel (`#E6F4F0`, `#063B2C`).
  - Preserved all widget keys (`input_profile_name`, `input_profile_dob`, `btn_profile_submit`, etc.), validation logic, skip actions, date picker dialog, and navigation flows.
- **Reason:**
  - Deliver a cleaner, more cohesive, and premium banking/jewelry aesthetic matching modern mobile standards, eliminating excessive whitespace and redundant field labels.
- **Functionality impact:**
  - Pure visual and structural UI layout improvement. Zero impact on data models, validation contracts, Riverpod auth state, or backend API submission.
- **Testing:**
  - `flutter analyze`: Passed with 0 errors, 0 warnings (clean codebase).
  - `flutter test test/widget/auth/register_profile_screen_test.dart`: All 3 tests passed.
  - `flutter test test/widget/auth/register_profile_card_form_test.dart`: All 3 tests passed.
  - Verification confirmed: Form validation, responsive city/pincode, step transitions, date picker dialog, and skip actions.
- **Status:** Completed.

### 15:30 IST — Full-Stack — Environment Setup, Run & Physical Phone Testing
- **Files changed:**
  - `Swastik_kitty_backend/.env`
  - `Swastik_kitty_frontend/kitty_app/lib/core/config/server_ip.dart`
  - `Swastik_kitty_frontend/kitty_app/android/app/src/main/res/xml/network_security_config.xml`
- **Changes:**
  - Installed all backend dependencies via `npm ci` matching lockfile.
  - Initialized backend `.env` with local MongoDB URI `mongodb://127.0.0.1:27017/swastik_kitty` and `PORT=5000`.
  - Executed database seed script `src/seed.js` populating live gold rates, 3 official schemes, and master admin.
  - Detected computer active Wi-Fi LAN IPv4 address `192.168.29.42` and updated `server_ip.dart`.
  - Updated Android `network_security_config.xml` to permit development cleartext HTTP traffic specifically for `192.168.29.42`.
  - Established ADB reverse bridge `tcp:5000 -> tcp:5000`.
  - Built debug APK `build\app\outputs\flutter-apk\app-debug.apk` with `--dart-define=BASE_URL=http://192.168.29.42:5000`.
  - Installed and launched app on physical Android device (`Redmi 2406ERN9CI`, device ID `6698ab0`, Android 15).
- **Reason:**
  - Project initialization, dependencies resolution, and physical mobile device verification.
- **Functionality impact:**
  - Enabled end-to-end communication between physical Android device and local Node.js backend.
- **Testing:**
  - Health check endpoint `GET /api/v1/health` verified operational with database connected.
  - `GET /api/v1/rates/gold` and `GET /api/v1/schemes/active` verified.
  - Live session check from physical phone `GET /api/v1/users/profile` (401) and OTP dispatch `POST /api/v1/auth/send-otp` verified.
- **Status:** Completed.
