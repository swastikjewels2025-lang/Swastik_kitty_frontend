# Design System & Token Specification

## 1. Overview & Source of Truth
The Swastik Jewel Kitty App design system is derived directly from the high-fidelity UI prototypes (`dashboard.css`, `login.css`, `kyc.css`, `scheme.css`, and `styles.css`) and planning documents.

The visual style embodies **Royal Indian Heritage Luxury** combined with **Bank-Grade Financial Clarity**. It operates on a dual-surface architecture:
1. **Surface Dark (Luxury & Branding):** Employed for Splash, Login, KYC, Hero Banners, and Modal sheets, utilizing Deep Emerald Forest (`#05241C`), Royal Dark Green (`#064E3B`), and Metallic Gold (`#C59B27`).
2. **Surface Light (Clarity & Ledger):** Employed for the 12-Month Passbook, Settings, and Detail views, utilizing soft off-white canvas (`#F8F9FA`), crisp white cards (`#FFFFFF`), deep slate typography (`#0F172A`), and emerald/gold accents.

---

## 2. Color Palette & Semantic Tokens

### 2.1 Brand & Metallic Gold Accents
| Token | Hex Value | Role & Usage |
| :--- | :--- | :--- |
| `color-brand-gold-primary` | `#C59B27` / `#C49746` | Primary luxury metallic gold. Used for logos, active badges, highlights. |
| `color-brand-gold-gradient-start` | `#E6C275` | Gradient start for primary CTAs ("PAY NEXT EMI"). |
| `color-brand-gold-gradient-end` | `#CCA043` | Gradient end for primary CTAs. |
| `color-brand-gold-subtle` | `rgba(197, 155, 39, 0.12)` | Frosted champagne background for gold icons and chip tags. |
| `color-brand-gold-border` | `rgba(197, 155, 39, 0.28)` | Subtle border for chips and card frames. |

### 2.2 Deep Emerald & Royal Green Palette
| Token | Hex Value | Role & Usage |
| :--- | :--- | :--- |
| `color-emerald-deep-base` | `#05241C` | Deepest emerald background (Splash, Login viewport canvas). |
| `color-emerald-card` | `#092B22` / `#0B3026`| Luxury card background, promo banners, and active scheme cards. |
| `color-emerald-primary` | `#064E3B` | Brand primary dark green. Used for active filter buttons and headers. |
| `color-emerald-text-subtle` | `#9FB8AE` / `#A3BCB2`| Secondary muted labels on dark emerald cards. |

### 2.3 Refined Modern Light Surface (Passbook & Settings)
| Token | Hex Value | Role & Usage |
| :--- | :--- | :--- |
| `color-surface-page-bg` | `#F8F9FA` | Modern soft off-white page background (eliminates yellow glare). |
| `color-surface-card-bg` | `#FFFFFF` | Crisp white container card background. |
| `color-surface-card-border` | `#E5E7EB` / `#EAECEF` | Subtle modern gray border for cards and inputs. |
| `color-surface-divider` | `#F1F5F9` | Table row separator and section dividers. |

### 2.4 Neutral Text Palette
| Token | Hex Value | Role & Usage |
| :--- | :--- | :--- |
| `color-text-primary-dark` | `#0F172A` | Primary heading and high-contrast text on light cards. |
| `color-text-secondary-muted`| `#64748B` | Subtitles, meta-labels, helper text, and timestamps on light cards. |
| `color-text-primary-light`| `#FFFFFF` / `#FAF8F2`| Headings and values on dark emerald cards. |
| `color-text-secondary-light`| `#8CA59B` / `#D1DCD6`| Labels and perk descriptions on dark emerald cards. |

### 2.5 Status & Feedback Colors
| Token | Hex Value | Role & Usage |
| :--- | :--- | :--- |
| `color-status-success-bg` | `#ECFDF5` | Green tint pill background (`PAID`, `Verified`). |
| `color-status-success-text` | `#047857` / `#10B981` | Green text and checkmark icon. |
| `color-status-warning-bg` | `#FFFBEB` | Current due month row highlight. |
| `color-status-warning-text` | `#D97706` | Warning badges and countdown highlights. |
| `color-status-bonus-bg` | `#FEFCE8` | Free bonus month 12 highlight. |
| `color-status-error-bg` | `#FEF2F2` | Form error banners and logout button background. |
| `color-status-error-text` | `#DC2626` | Destructive actions and validation errors. |

---

## 3. Typography Hierarchy

The typography pairs a **Classical Heritage Serif** for brand prestige with a **Geometric Sans-Serif** for high-density financial readability.

### 3.1 Font Families
* **Display / Brand Serif:** `'Cinzel'`, `'Cormorant Garamond'`, Georgia, serif.
* **Functional / UI Sans-Serif:** `'Plus Jakarta Sans'`, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif.

### 3.2 Type Scale

| Style Token | Font Family | Size | Weight | Line Height | Tracking | Usage |
| :--- | :--- | :--- | :---: | :---: | :---: | :--- |
| `type-display-brand` | Cinzel | 1.60rem (26px) | 700 | 1.25 | -0.2px | Section titles, Scheme names |
| `type-hero-title` | Cinzel | 1.35rem (22px) | 700 | 1.30 | +0.4px | Active scheme pass title |
| `type-card-title` | Plus Jakarta Sans | 1.08rem (17px) | 700 | 1.35 | 0.0px | Plan names, screen headings |
| `type-body-bold` | Plus Jakarta Sans | 0.88rem (14px) | 700 | 1.40 | +0.2px | Primary button labels, table text |
| `type-body-regular` | Plus Jakarta Sans | 0.84rem (13.5px)| 500 | 1.50 | 0.0px | Descriptions, sub-text |
| `type-label-meta` | Plus Jakarta Sans | 0.72rem (11.5px)| 600 | 1.30 | +0.6px | Table headers, secondary stats |
| `type-kicker-caps` | Plus Jakarta Sans | 0.62rem (10px) | 800 | 1.20 | +1.8px | Eyebrow badges, uppercase chips |

---

## 4. Spacing & Layout Grid

* **Base Grid Unit:** 4px
* **Scale:**
  - `space-xs`: 4px
  - `space-sm`: 8px
  - `space-md`: 12px
  - `space-base`: 16px
  - `space-lg`: 20px
  - `space-xl`: 24px
  - `space-2xl`: 32px
  - `space-3xl`: 48px
* **Mobile Viewport Boundaries:**
  - Max container width: `440px` (Home, Passbook) to `480px` (Settings, Offers).
  - Screen edge horizontal padding: `16px` (Default) or `18px` (Expanded).

---

## 5. Border Radius & Elevation Tokens

### 5.1 Border Radius
* `radius-sm`: `6px` (Progress tracks, inner badges)
* `radius-md`: `12px` (Inputs, sub-cards, toggle buttons, OTP boxes)
* `radius-lg`: `18px` – `20px` (Primary cards, passbook tables, scheme hero)
* `radius-xl`: `28px` (Container wraps on tablet previews)
* `radius-pill`: `999px` (Status badges, pill buttons, filter tabs)

### 5.2 Shadows & Glows
* `shadow-card-subtle`: `0 2px 8px rgba(0, 0, 0, 0.03)` (Settings & light cards)
* `shadow-card-elevated`: `0 6px 18px rgba(12, 43, 36, 0.04)` (Product cards)
* `shadow-card-luxury`: `0 14px 34px rgba(11, 48, 38, 0.22)` (Active emerald scheme card)
* `shadow-cta-gold`: `0 4px 16px rgba(197, 155, 39, 0.35)` (Primary gold action button)
* `glow-ambient-emerald`: `radial-gradient(circle, rgba(223, 193, 120, 0.15) 0%, transparent 70%)`

---

## 6. Core Component Styling Specifications

### 6.1 Primary Gold Action Button (`btn-primary-gold` / `scheme-pay-cta-btn`)
* **Background:** `linear-gradient(90deg, #E6C275 0%, #CCA043 100%)`
* **Text Color:** `#092B22` (Deep emerald black)
* **Typography:** 0.88rem, 800 ExtraBold, uppercase letter-spacing +1.2px
* **Padding:** 14px 20px
* **Border Radius:** 14px – 16px
* **States:**
  - **Hover:** `linear-gradient(90deg, #EDCA7E 0%, #D4A84B 100%)`, translateY(-1px)
  - **Active:** transform scale(0.97)
  - **Disabled:** Background `#D1D5DB`, text `#9CA3AF`, cursor not-allowed

### 6.2 Secondary Buttons
* **View Receipt Button:** Background `#FFFFFF`, Border `1px solid #D1D5DB`, Text `#0F172A`, radius 10px.
* **Close / Back Circular Button:** Diameter 40px, Background `#0C2B24`, Icon `#FFFFFF`, border-radius 50%.

### 6.3 Input Fields
* **Background:** `#FFFFFF` (on light surfaces) or `rgba(255, 255, 255, 0.08)` (on glassmorphic dark surfaces)
* **Border:** `1px solid #E5E7EB` (Default), `1px solid #C59B27` (Focused with 2px gold glow)
* **Height:** 48px – 52px
* **OTP Digit Box:** Width 44px, Height 50px, Center-aligned text, font-size 1.2rem, bold.

### 6.4 Status Badges
* **PAID Badge:** Background `#ECFDF5`, Border `#A7F3D0`, Text `#047857`, font-size 0.70rem, font-weight 700.
* **CURRENT Badge:** Background `#FFFBEB`, Border `#FDE68A`, Text `#B45309`.
* **CHIT TOKEN Pill:** Background `#FFFFFF`, Border `#E5E7EB`, Text `#0F172A`, font-weight 700.

---

## 7. Discovered Inconsistencies & Standardized Recommendations

| Component / Property | Discrepancy Found in Code | Recommended Standardized Token |
| :--- | :--- | :--- |
| **Gold Hue** | `#facc15` (UI plan) vs `#C59B27` (passbook) vs `#DFC178` (home) | Standardize on **`#C59B27`** as primary solid gold and **`#DFC178` / `#CCA043`** for gradients. Avoid `#facc15` (too bright/neon yellow). |
| **Page Background** | `styles.css` uses amber/yellow ambient glow vs `passbook.css` uses `#F8F9FA` | Adopt **`#F8F9FA`** for all transactional views (Dashboard, Passbook, Settings); retain dark emerald `#05241C` for Splash/Login. |
| **Header Toggle Icon** | SVGs vary in stroke width between 2.0 and 2.4 across screens | Standardize on **`stroke-width: 2.2`** with a 40px circular/rounded container. |
| **Chit Token Format** | `#SW-042` vs `#SW-98421` | Standardize on **`#SW-042`** format (`#SW-` prefix + 3-digit padded number). |
