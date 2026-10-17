# TRUST JUGGLER // RISK ENGINE
> **Continuous Behavioral Telemetry Scoring & Micro-Friction Biometrics to Solve "The Rented Account Problem" in Delivery Logistics**

---

## 🎯 Mission & System Architecture

Delivery platforms suffer from severe security, compliance, and insurance liabilities caused by **"The Rented Account Problem"**—unauthorized individuals operating delivery shifts under legitimate riders' credentials. Traditional re-auth protocols (e.g. daily selfies at shift start) fail because accounts are handed off after the initial check, while aggressive random pauses frustrate legitimate drivers and hurt delivery SLAs.

**TRUST JUGGLER** solves this with **Asymmetric Passive Verification & Micro-Friction Challenges**:
1. **Continuous Passive Telemetry:** The Driver mobile application silently monitors hardware fingerprint hashes, SIM ICCID stability, GPS speed/velocity delta, and cell-tower drift.
2. **Real-Time Risk Engine (Cloud Functions):** Ingests telemetry packets and scores behavioral deviations against the driver's verified baseline.
3. **Micro-Friction Liveness Prompt:** If Risk Score $> 0.60$, the driver is prompted with a 3-second challenge (blink twice or smile) verified on-device via Google ML Kit. Passing immediately resets the risk score ($< 0.20$).
4. **Hard Quarantine:** If Risk Score $> 0.85$ (e.g., immediate device swap accompanied by impossible GPS teleportation), the account is instantly locked into `FROZEN` mode pending SecOps review.
5. **Swiss-Precision Admin Console:** SecOps supervisors monitor fleet telemetry, audit streams, and Aadhaar vs. live scan facial comparisons in real time.

---

## 🏗️ Project Folder Layout

```
trust-juggler-risk-engine/
├── admin_web/                              # Swiss Minimalist High-Density Admin Web Panel
│   ├── index.html                          # Main SecOps dashboard wired to Firestore
│   ├── css/
│   │   └── admin.css                       # Swiss typography & telemetry styles
│   ├── js/
│   │   ├── firebase-config.js              # Modular Firebase Web SDK configuration
│   │   └── admin-controller.js             # Live Firestore stream listeners & action handlers
│   └── assets/                             # Baseline and scan images
│
├── backend_functions/                      # Firebase Cloud Functions (Node.js/TypeScript)
│   ├── package.json                        # Functions manifest & dependencies
│   ├── tsconfig.json                       # TypeScript compiler options
│   └── src/
│       ├── index.ts                        # evaluateRiskScore, submitLiveness, adminOverride triggers
│       ├── types.ts                        # TypeScript interfaces for Rider, Session, AuditLog
│       ├── risk_scoring_engine.ts          # Multi-factor Bayesian telemetry risk scoring heuristics
│       ├── seed.ts                         # Database seeder with sample logistics fleet data
│       └── test_risk_engine.ts             # Automated test suite for scoring thresholds
│
├── driver_app/                             # Flutter Cross-Platform Driver Mobile App
│   ├── pubspec.yaml                        # Dependencies (Firebase, ML Kit, Camera, Provider)
│   ├── analysis_options.yaml               # Linter configuration
│   ├── android/app/src/main/
│   │   └── AndroidManifest.xml             # Camera, Location, and ML Kit permissions
│   ├── lib/
│   │   ├── main.dart                       # App entrypoint, Swiss theme, and reactive state router
│   │   ├── models/
│   │   │   ├── rider_model.dart            # Rider schema & Firestore serialization
│   │   │   └── telemetry_model.dart        # SessionTelemetry data entity
│   │   ├── services/
│   │   │   ├── firebase_service.dart       # Live Firestore streams & batch operations
│   │   │   ├── telemetry_service.dart      # Real & simulated sensor data provider
│   │   │   └── mlkit_face_service.dart     # Google ML Kit Face Detection & blink/smile tracker
│   │   ├── state/
│   │   │   └── driver_provider.dart        # Core provider managing telemetry ticks & state
│   │   ├── screens/
│   │   │   ├── onboarding_screen.dart      # Step 1: Phone OTP + e-KYC baseline photo capture
│   │   │   ├── dashboard_screen.dart       # Step 2: Active shift telemetry & demo simulator tabs
│   │   │   ├── liveness_prompt_screen.dart # Step 3: ML Kit micro-friction liveness challenge
│   │   │   └── frozen_lock_screen.dart     # Step 4: Security audit hard lock screen
│   │   └── widgets/
│   │       ├── swiss_metric_card.dart      # Monospace high-density metric card
│   │       ├── camera_face_overlay.dart    # Biometric HUD target reticle
│   │       └── simulator_control_bar.dart  # One-tap judge presentation toolbar
│   └── test/
│       └── widget_test.dart                # Unit tests for state & models
│
├── firestore.rules                         # Production-grade Firestore security rules
├── firestore.indexes.json                  # Query composite indexes
└── firebase.json                           # Root Firebase configuration for hosting & functions
```

---

## ⚡ Step-by-Step Setup & Quickstart

### 1. Backend & Cloud Functions
```bash
cd backend_functions
npm install
npm run build

# Run unit tests verifying risk scoring thresholds:
node lib/test_risk_engine.js

# (Optional) Seed demo riders and audit logs to Firestore:
npm run seed
```

### 2. Admin Web Dashboard
The web panel is located in `admin_web/`. You can serve it using any HTTP server:
```bash
# Option A: using npx serve
npx serve admin_web -p 3000

# Option B: using python
python -m http.server 3000 --directory admin_web
```
Open `http://localhost:3000` in your browser.
- **Top Data Strip:** Displays active sessions, aggregate risk index, pending challenges, and locked accounts.
- **Live Audit Stream:** Updates in real time without page refresh.
- **Verification Inspection Drawer:** Click any row in the audit stream to inspect Aadhaar vs. Live Scan face comparisons, hardware hashes, and GPS deltas.
- **Action Buttons:** `FREEZE ACCOUNT`, `APPROVE SESSION`, `TRIGGER SPOT-CHECK` instantly dispatch field updates to Firestore.

### 3. Flutter Driver Mobile App
```bash
cd driver_app
flutter pub get
flutter run
```
- **Demo Mode Simulator Tabs:**
  - `NORMAL SHIFT`: Pushes baseline-aligned telemetry.
  - `TRIGGER ANOMALY`: Injects a foreign device ID, unauthorized SIM ICCID, and a 14.8 km instant GPS jump.
  - Watch the app immediately trigger **The Trust Challenge Screen** or **Hard Lock Screen**!
  - Click **Confirm Biometrics & Unlock** or verify through the ML Kit camera overlay to return to nominal status ($< 0.20$ risk).

---

## 🛡️ Risk Scoring Heuristic Matrix

| Factor | Baseline Condition | Anomaly Trigger | Score Impact |
| :--- | :--- | :--- | :--- |
| **Hardware Fingerprint** | Matches enrolled device ID | Unrecognized device hash | **+0.35** |
| **SIM ICCID** | Registered carrier ICCID | Foreign / swapped SIM | **+0.30** |
| **Impossible Travel** | $< 40$ km/h urban speed | Derived speed $> 110$ km/h or $> 5$ km in $< 30$s | **+0.45** |
| **Handset Model** | e.g. Samsung S21 Ultra | Discrepancy (e.g. Pixel 7) | **+0.15** |
| **Velocity Delta** | Normal acceleration | Instant delta $> 45$ m/s² | **+0.15** |
| **Liveness Resolution** | Pass blink & smile ML Kit | Confidence $> 80\%$ | **Score resets to 0.12** |
