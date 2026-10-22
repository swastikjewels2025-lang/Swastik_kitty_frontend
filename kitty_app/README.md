# Swastik Jewellers Kitty Mobile App (Flutter)

Welcome to the **Swastik Jewellers Kitty Mobile Application**, built with Flutter, Riverpod, Dio, and GoRouter for native iOS and Android deployment.

---

## 📚 Master Documentation

All architectural specifications, PRDs, API contracts, database schemas, and operational rules are centrally maintained in the root documentation directory:

👉 **[Master Documentation Index](../../../docs/README.md)**
* **[Product Requirements Document (PRD)](../../../docs/01_PRODUCT_REQUIREMENTS_DOCUMENT.md)**
* **[System Architecture & Integration](../../../docs/02_SYSTEM_ARCHITECTURE_AND_INTEGRATION.md)**
* **[Data Flow & API Contracts](../../../docs/03_DATA_FLOW_AND_API_CONTRACTS.md)**
* **[Folder Structure & File Manifest](../../../docs/04_FOLDER_STRUCTURE_AND_FILE_MANIFEST.md)**
* **[Developer & AI Agent Rules](../../../docs/05_DEVELOPER_AND_AI_AGENT_RULES.md)**

---

## 🚀 Quick Start

### 1. Install Flutter Dependencies
```bash
flutter pub get
```

### 2. Verify Code Quality
```bash
flutter analyze
```

### 3. Change Server IP (If Wi-Fi IP changes)
Edit `lib/core/config/server_ip.dart`:
```dart
const String kServerIp = '192.168.29.81';
```

### 4. Run on Device
```bash
flutter run
# OR
./run.sh
```

---

## 🎨 Design System
* **Primary Emerald Green:** `#063B2C`
* **Royal Gold Accent:** `#EAB308`
* **Warm Canvas:** `#FBF9F4`
* **Typography:** `Cinzel` / `Playfair` for luxury headlines; `Plus Jakarta Sans` for passbooks and tables.
