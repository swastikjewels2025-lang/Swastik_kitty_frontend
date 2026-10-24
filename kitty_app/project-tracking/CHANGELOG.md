# Kitty App — Change Log

## 2026-10-24

### 16:35 IST — Frontend & Mobile Deployment — Fix Review Your Plan Screen Responsiveness and Flutter Overflow
- **Files changed:**
  - `lib/features/offers/presentation/screens/review_plan_screen.dart`
  - `test/widget/offers/review_plan_screen_test.dart`
  - `build/app/outputs/flutter-apk/app-debug.apk`
- **Root Causes:**
  - **Scheme Header Collisions:** The outer header `Row` contained an unconstrained inner `Row` for the scheme icon and title alongside an unconstrained `Edit` button. When scheme names were long (e.g., `Swastik Samriddhi 11+1 Plan`), the title expanded beyond the available horizontal space, colliding directly into the `Edit` button and causing a `RenderFlex overflowed by 2.1 pixels on the right`.
  - **Bonus Eligibility Overflow:** The `Bonus Eligibility` row rendered both its label (~115px) and description text (`Guaranteed bonus on completion`, ~215px) inside a rigid `Row` without `Expanded` or flex constraints. Together with card padding (18px each side) and page margins (20px each side), the total width (357px) exceeded the available card inner width on 320px–390px mobile screens, throwing a yellow-and-black `RenderFlex overflowed by 43 pixels on the right` warning indicator.
  - **Key-Value Row Flexibility:** `_buildDetailRow` lacked flex boundaries between labels and values. Long labels (e.g. `Total Target Contribution`) and long values (such as lengthy patron emails or addresses) risked horizontal collisions and text clipping.
  - **CTA Button Scaling:** The submit button lacked scalable down-fitting on narrow 320px screens.
- **Fixes Applied:**
  - **Scheme Header:** Replaced the unconstrained nested row with a single flattened `Row` containing the fixed 36x36 gold icon, `Expanded` for `_planTitle` with `maxLines: 2` and `TextOverflow.ellipsis`, 8px spacing, and the `Edit` button with `HitTestBehavior.opaque` touch target. Prevents overlap for any short or long scheme title without pushing the `Edit` button outside the card.
  - **Bonus Eligibility Responsiveness:** Introduced `_buildBonusEligibilityRow` utilizing `LayoutBuilder`:
    - On narrow card widths (`< 270px`, e.g. 320px screens): stacks label and description vertically with 4px separation for optimal readability and zero clipping.
    - On standard and wide screens (`>= 270px`, e.g. 360px, 390px, 430px): renders label on the left and the full description inside an `Expanded` right-aligned container that wraps naturally across multiple lines without truncating bonus data.
  - **Detail Rows Flexibility:** Redesigned `_buildDetailRow` with proportional flex constraints (`labelFlex: 5, valueFlex: 3` for scheme rows; `labelFlex: 3, valueFlex: 5` for patron details; `labelFlex: 4, valueFlex: 5` for nominee details). Inserted zero-width spaces (`\u200B`) after `@` and `.` characters in email addresses to enable clean, sensible word-breaking across lines.
  - **Patron & Nominee Card Headers:** Wrapped 'Patron Details' and 'Nominee Registration' titles in `Expanded` to prevent collision with their respective `Edit` buttons under high accessibility font scaling.
  - **Modal Bottom Sheet:** Made 'Select Plan Duration' and plan option list items fully responsive using `Expanded`.
  - **CTA Button:** Wrapped 'Enroll & Proceed to Payment' text in `FittedBox(fit: BoxFit.scaleDown)` to guarantee it scales smoothly on narrow viewports.
- **Testing:**
  - `flutter analyze`: Passed with 0 errors, 0 warnings across all project files.
  - `flutter test test/widget/offers/review_plan_screen_test.dart`: All 8 tests passed covering Screenshot 1 (`ddd`), Screenshot 2 (`Swastik Samriddhi 11+1 Plan`), responsive widths (320px, 360px, 390px, 430px), multi-line email/address, and modal duration sheet.
  - `flutter test test/widget/offers/start_kitty_flow_test.dart`: All 7 tests passed.
  - `flutter test test/widget/offers/kitty_number_picker_test.dart`: All 6 tests passed.
  - **Device Verification:** Built fresh debug APK, pushed to `/data/local/tmp/app.apk`, installed via `pm install -r` on connected physical phone (`Redmi 2406ERN9CI`, Android 15), confirmed app started cleanly (PID 27376), and verified zero error logs in Android logcat.
- **Status:** Completed.

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
