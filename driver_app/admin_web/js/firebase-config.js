/**
 * TRUST JUGGLER // RISK ENGINE
 * Firebase Configuration & Real-Time Sync Provider
 */

const DEFAULT_FIREBASE_CONFIG = {
  apiKey: "AIzaSyDemoDummyKey-TrustJugglerSecOps",
  authDomain: "trust-juggler-risk-engine.firebaseapp.com",
  projectId: "trust-juggler-risk-engine",
  storageBucket: "trust-juggler-risk-engine.appspot.com",
  messagingSenderId: "109876543210",
  appId: "1:109876543210:web:9b08f44158e2a1b9",
  measurementId: "G-DEMO998822"
};

// Allow custom credentials saved in localStorage
function getActiveFirebaseConfig() {
  try {
    const saved = localStorage.getItem('TRUST_JUGGLER_FIREBASE_CONFIG');
    if (saved) {
      return JSON.parse(saved);
    }
  } catch (e) {
    console.warn("Could not read local storage config", e);
  }
  return DEFAULT_FIREBASE_CONFIG;
}

let firebaseApp = null;
let firestoreDb = null;
let isDemoMode = false;

function initFirebase() {
  const config = getActiveFirebaseConfig();
  try {
    if (!firebase.apps.length) {
      firebaseApp = firebase.initializeApp(config);
    } else {
      firebaseApp = firebase.app();
    }
    firestoreDb = firebase.firestore();

    // Check for emulator configuration if running on localhost
    if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
      const useEmulator = localStorage.getItem('USE_FIREBASE_EMULATOR') === 'true';
      if (useEmulator) {
        console.log("[TrustJuggler] Connecting to local Firestore emulator on port 8080...");
        firestoreDb.useEmulator('localhost', 8080);
      }
    }
    console.log("[TrustJuggler] Firebase Cloud Firestore initialized successfully.");
  } catch (err) {
    console.warn("[TrustJuggler] Live Firebase initialization fallback. Running in Local Memory / Offline Stream Mode:", err);
    isDemoMode = true;
  }
  return { firebaseApp, firestoreDb, isDemoMode };
}

window.TrustJugglerFirebase = {
  initFirebase,
  getDb: () => firestoreDb,
  getConfig: getActiveFirebaseConfig,
  saveConfig: (cfg) => {
    localStorage.setItem('TRUST_JUGGLER_FIREBASE_CONFIG', JSON.stringify(cfg));
    window.location.reload();
  },
  resetConfig: () => {
    localStorage.removeItem('TRUST_JUGGLER_FIREBASE_CONFIG');
    window.location.reload();
  }
};
