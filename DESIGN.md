---
name: Swiss Logistics Precision
colors:
  surface: '#f7f9fd'
  surface-dim: '#d8dade'
  surface-bright: '#f7f9fd'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f8'
  surface-container: '#eceef2'
  surface-container-high: '#e6e8ec'
  surface-container-highest: '#e0e2e6'
  on-surface: '#191c1f'
  on-surface-variant: '#45464c'
  inverse-surface: '#2d3134'
  inverse-on-surface: '#eff1f5'
  outline: '#76777d'
  outline-variant: '#c6c6cd'
  surface-tint: '#575e70'
  primary: '#000000'
  on-primary: '#ffffff'
  primary-container: '#141b2b'
  on-primary-container: '#7d8497'
  inverse-primary: '#c0c6db'
  secondary: '#555f6d'
  on-secondary: '#ffffff'
  secondary-container: '#d6e0f1'
  on-secondary-container: '#596372'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#410002'
  on-tertiary-container: '#f63a35'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dce2f7'
  primary-fixed-dim: '#c0c6db'
  on-primary-fixed: '#141b2b'
  on-primary-fixed-variant: '#404758'
  secondary-fixed: '#d9e3f4'
  secondary-fixed-dim: '#bdc7d8'
  on-secondary-fixed: '#121c28'
  on-secondary-fixed-variant: '#3e4755'
  tertiary-fixed: '#ffdad6'
  tertiary-fixed-dim: '#ffb4ab'
  on-tertiary-fixed: '#410002'
  on-tertiary-fixed-variant: '#93000b'
  background: '#f7f9fd'
  on-background: '#191c1f'
  surface-variant: '#e0e2e6'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 36px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.015em
  headline-sm:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 22px
    letterSpacing: -0.01em
  metric-xl:
    fontFamily: JetBrains Mono
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.03em
  metric-md:
    fontFamily: JetBrains Mono
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: -0.02em
  body-md:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
    letterSpacing: -0.005em
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
    letterSpacing: 0em
  data-mono:
    fontFamily: JetBrains Mono
    fontSize: 11px
    fontWeight: '400'
    lineHeight: 14px
    letterSpacing: 0em
  label-caps:
    fontFamily: JetBrains Mono
    fontSize: 10px
    fontWeight: '600'
    lineHeight: 12px
    letterSpacing: 0.08em
spacing:
  gutter: 0.5rem
  gutter-lg: 1rem
  margin: 1rem
  margin-mobile: 0.75rem
  space-xs: 0.25rem
  space-sm: 0.375rem
  space-md: 0.5rem
  space-lg: 0.75rem
  space-xl: 1rem
  space-2xl: 1.5rem
---

## Brand & Style

The design system delivers an austere, mission-critical interface engineered for enterprise global supply chain security, telemetry monitoring, and facility threat mitigation. The visual ethos is anchored in International Typographic Style (Swiss Design)—prioritizing objective clarity, mathematical density, and structural honesty above ornamental styling.

### Design Principles
- **Utilitarian Discipline:** Every pixel, boundary, and label directly serves data interpretation. Decorative artifacts, skeuomorphism, elevation gradients, backdrop filters, and ambient blurs are strictly banned.
- **Micro-Hierarchy via Typography & Position:** Hierarchy is communicated through rigid font weight contrasts, uppercase metadata tags, and spatial coordinates rather than card elevation or saturated backgrounds.
- **High-Density Legibility:** Optimized for terminal environments, multi-monitor operations centers, and dense telemetry analysis. High scanning speeds and low cognitive latency govern all spatial decisions.
- **Instrument-Grade Restraint:** The visual field maintains a neutral baseline. Saturated chroma is reserved exclusively for immediate, actionable operational alerts.

## Colors

The palette is engineered around an asymmetric high-contrast monochrome foundation, supplemented by functional telemetry signals.

### Palette Construction
- **Canvas Base (`#F8F9FA`):** An optical off-white that suppresses screen glare during sustained operational shifts while preserving contrast ratios exceeding WCAG AAA standards.
- **Surface Layer (`#FFFFFF`):** Pure white used for active viewport panels, focused inputs, and metric cells.
- **Structural Borders (`#E5E7EB`):** Subtle 1px dividers establishing grid containment without generating heavy optical mass.
- **Primary Text & Monoliths (`#111827`):** Dark charcoal/black for headlines, mission-critical metrics, and key structural anchors.
- **Secondary Supporting (`#4B5563`):** Neutral gray applied to secondary telemetry indicators, column headers, and structural metadata.
- **Tertiary Structural (`#9CA3AF`):** Muted slate used exclusively for inactive tabs, disabled states, and auxiliary grid tick marks.

### Signal Accent Hierarchy
- **Critical / Threat Trigger (`#DC2626`):** Applied strictly to security breach states, route diversions, offline sensors, and unauthorized container access.
- **Operational / Clear (`#16A34A`):** Applied to sealed containers, nominal telemetry runs, and certified nodes.
- **Warning / Stasis (`#D97706`):** Secondary operational signal used for customs holdbacks, temperature drifts, and transit delays.
- **Rules of Engagement:** Signal colors must never be used for non-state elements such as decorative badges, primary call-to-action buttons, or brand illustrations.

## Typography

The typographic system utilizes a dual-engine architecture: **Inter** for natural-reading hierarchy and executive interaction points; **JetBrains Mono** for alphanumeric telemetry, coordinates, tracking hashes, timestamps, and column headers.

### Application Rules
- **Tabular Alignment:** JetBrains Mono must be used for all tabular data, sensor timestamps (ISO 8601), cargo manifests, and status badges to eliminate jitter during real-time web-socket stream refreshes.
- **Case Standardization:** Structural table heads, status indicators, and tracking metrics use `label-caps` in uppercase styling with `+0.08em` tracking.
- **Data Densification:** Body text scales down to 13px (`body-md`) and 12px (`body-sm`) with tight line heights to accommodate dense multi-pane matrices.

## Layout & Spacing

The layout model is governed by a strict, mathematical 4px/8px baselined grid. Density takes absolute priority over sprawling white space.

### Structural Framework
- **Grid Architecture:** Multi-pane fluid split-screen with fixed structural rails. The screen spans a continuous perimeter grid utilizing 1px internal divider boundaries (`#E5E7EB`) rather than floating cards with outer margins.
- **Gutters & Dividers:** Columns butt together directly along 1px rules, or maintain narrow `0.5rem` (`gutter`) gaps for distinct modular groupings.
- **Reflow & Responsiveness:**
  - **Desktop (≥1440px):** 4-pane layout containing manifest navigation, live telemetry feed, geo-spatial schematic, and detail inspection rail.
  - **Compact Desktop / Tablet Landscape (1024px–1439px):** 3-pane layout; inspection rail transitions to an anchored side drawer.
  - **Mobile / Diagnostic Viewport (<1024px):** Single-column stacked stream. Secondary rails collapse behind a segmented fixed controller. Gutters contract to `0.375rem`.

## Elevation & Depth

This design system is strictly flat. Depth is created through surface partitioning, 1px hairline rules, and structural contrast.

### Rules of Elevation
- **Shadow Elimination:** No CSS box shadows (`box-shadow: none`), filters, or simulated light sources are permitted.
- **Hairline Partitioning:** Visual boundaries between nested panels, table headers, and structural regions are created solely using `1px solid #E5E7EB`.
- **Active State Differentiation:** Selected, hovered, or active states rely on solid tone-on-tone inversion:
  - Default row: `#FFFFFF`
  - Hover row: `#F8F9FA`
  - Selected row: `#111827` (with text inverted to `#FFFFFF` and telemetry mono to `#F8F9FA`)
- **Modals and Drawers:** Layering is handled by hard non-blurred overlays (`rgba(17, 24, 39, 0.4)`) paired with a crisp 1px solid `#111827` border bounding the overlay panel.

## Shapes

The interface is entirely sharp, adhering to strict architectural rectangular geometry.

### Radius Constraints
- **Global Border Radius:** Fixed to `0px` (`roundedness: 0`).
- **Permissible Tolerance:** For ultra-small UI primitives (such as nested status dot housings or active cursor chips), border-radius must not exceed `2px` under any circumstances.
- **Form Primitives:** Text inputs, dropdown selectors, alert banners, tables, and buttons must preserve pure 90-degree orthogonal corners to sustain the uncompromising Swiss grid.

## Components

### Buttons & Action Controls
- **Primary:** Background `#111827`, text `#FFFFFF`, 1px border `#111827`, 0px radius. Hover shifts to `#1F2937`.
- **Secondary:** Background `#FFFFFF`, text `#111827`, 1px border `#E5E7EB`, 0px radius. Hover shifts to `#F8F9FA` and border `#111827`.
- **Destructive / Halt:** Background `#FFFFFF`, text `#DC2626`, 1px border `#DC2626`, 0px radius. Hover inverts to background `#DC2626`, text `#FFFFFF`.
- **Padding:** Compact sizing (`4px 10px` for utility actions; `6px 14px` for primary submission).

### Data Tables & Logs
- **Header:** Background `#F8F9FA`, bottom border `1px solid #111827`, text `label-caps` in `#4B5563`.
- **Cells:** Vertical padding `6px`, horizontal padding `8px`, bottom border `1px solid #E5E7EB`.
- **Alignment:** Alphanumeric IDs and numeric telemetry align strictly right; status flags and route strings align left.

### Status Indicators & Badges
- **Status Pills:** Background `#FFFFFF`, border `1px solid #E5E7EB`, font `label-caps`. 
- **Operational Status:** Preceded by a 6px geometric square (0px radius):
  - Normal: `#16A34A`
  - Breach/Lockdown: `#DC2626`
  - Pending: `#D97706`
- **Text:** Uppercase, no background pill tinting. Pure monochrome text with colored indicator squares prevents visual fatigue.

### Form Inputs
- **Base Input:** Background `#FFFFFF`, 1px border `#E5E7EB`, font `Inter` or `JetBrains Mono` depending on data format. Height `32px`, padding `4px 8px`.
- **Focus:** 1px solid `#111827` (no halo, no outer focus ring blur).
- **Error:** 1px solid `#DC2626`.

### Panels & Cards
- **Boundary:** Pure 1px solid `#E5E7EB` housing with `#FFFFFF` background.
- **Card Header:** Separated from content by a 1px solid `#E5E7EB` horizontal rule. Includes an uppercase section title (`label-caps`) paired with live node telemetry on the opposite boundary.