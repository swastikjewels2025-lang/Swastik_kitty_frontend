# Responsive Design & Multi-Platform Specification — Kitty App

**Project**: Swastik Jewellers Kitty App (Sub-Brand: Kitty Vault)  
**Primary Codebase**: `D:\kitty_app\`  
**Document Status**: Synchronized with Current Implementation  
**Last Audit Date**: 2026-09-23  

---

## 1. Viewport Hierarchy & Layout Constraints

The application is built **Mobile-First** with adaptive constraints for tablets, foldable devices, and desktop web browsers:

```text
┌────────────────────────────────────────────────────────┐
│ BREAKPOINT SCALE                                       │
│ 1. Mobile Handset:    < 600px   (Full-width fluid)     │
│ 2. Tablet / Foldable: 600px – 1024px (Expanded columns)│
│ 3. Desktop / Web:     > 1024px  (Centered 480px shell) │
└────────────────────────────────────────────────────────┘
```

---

## 2. Platform-Specific Responsive Implementations

### 2.1 Mobile Handset Devices (<600px)
* Full-width fluid rendering.
* `SafeArea` wrapping ensures content clears Android gesture bars and iOS notches/dynamic islands.
* Bottom navigation dock height: 66px + device bottom safe-area inset.
* Top sticky header height: 66px + device top safe-area inset.

### 2.2 Tablets & Foldables (600px – 1024px)
* `PassbookTimelineTable` expands into full 6-column table mode.
* Curated jewelry grid displays 3 to 4 items per row instead of 2.
* Modals center as floating dialog cards (`max-width: 520px`) rather than full-width bottom sheets.

### 2.3 Desktop & Web (>1024px)
* The entire application viewport is constrained to a centered luxury phone canvas (`AppDimensions.maxContentWidth = 480px`).
* Ambient damask wallpaper and radial glow fill the surrounding desktop browser background.

---

## 3. Touch Ergonomics & Haptic Feedback

1. **Touch Targets**:
   - All interactive controls (buttons, navigation dock icons, table action triggers) maintain an absolute minimum touch bounding box of **$48 \times 48$ logical pixels**.
2. **Haptic Feedback Integration**:
   - Tab switching: `HapticFeedback.selectionClick()`
   - Button tap: `HapticFeedback.lightImpact()`
   - OTP Error / Form validation failure: `HapticFeedback.heavyImpact()`
