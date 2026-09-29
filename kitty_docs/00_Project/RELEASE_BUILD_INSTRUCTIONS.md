# Swastik Kitty App — Release Build Instructions

This guide provides the exact terminal commands and steps required to generate signed production artifacts (APK and Android App Bundle) for the Swastik Kitty App.

---

## 1. Prerequisites

1. **Flutter SDK**: 3.47.4 or newer (Channel `stable`).
2. **Java JDK**: Version 17 (recommended for Gradle 8.x / 9.x compatibility).
3. **Android SDK Platform Tools**: API Level 34 installed.
4. **Production Keystore File**: Your organization's signed `.jks` or `.keystore` certificate.

---

## 2. Setting Up Production Signing

1. Copy the example configuration template:
   ```bash
   cp android/key.properties.example android/key.properties
   ```
2. Edit `android/key.properties` with your real production keystore credentials:
   ```properties
   storePassword=YourKeystorePasswordHere
   keyPassword=YourKeyPasswordHere
   keyAlias=your-key-alias-here
   storeFile=C:\\path\\to\\your\\upload-keystore.jks
   ```
   *(Note: On Windows, use double backslashes `\\` in `storeFile` paths, or place `upload-keystore.jks` in the `android/` directory and use `storeFile=../upload-keystore.jks`)*.
3. Verify that `android/key.properties` is NOT tracked by Git (`git status`).

---

## 3. Generating Release Android App Bundle (AAB for Google Play)

Google Play Store requires Android App Bundles (`.aab`) for all new app submissions.

Run from the project root (`D:\kitty_app`):

```bash
# Clean previous build caches
flutter clean

# Fetch project dependencies
flutter pub get

# Build the release Android App Bundle
flutter build appbundle --release
```

**Artifact Location**:
```
build/app/outputs/bundle/release/app-release.aab
```

### With Compile-Time Environment Overrides (Optional):
If overriding the production API host at compile time:
```bash
flutter build appbundle --release --dart-define=BASE_URL=https://api.swastikjewellers.com/api/v1 --dart-define=ENVIRONMENT=prod
```

---

## 4. Generating Release APK (For Internal Device Testing & QA)

If you need a standalone APK for manual installation or internal testing:

```bash
flutter build apk --release
```

**Artifact Location**:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 5. Verifying the Generated Artifact

### Verify Keystore Signature
To ensure the AAB/APK was signed with your genuine key:
```bash
# For APK:
apksigner verify --verbose --print-certs build/app/outputs/flutter-apk/app-release.apk

# For AAB:
keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab
```

### Install onto Test Device:
```bash
flutter install --release
```
*(Or transfer `app-release.apk` to an Android phone and enable "Install from Unknown Sources" for staging tests).*
