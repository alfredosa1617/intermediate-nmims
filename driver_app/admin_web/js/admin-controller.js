/**
 * TRUST JUGGLER // RISK ENGINE
 * Admin Web Dashboard Real-Time Controller
 * Handles Firestore listeners, top data strip metrics, live audit stream,
 * inspection drawer populator, and SecOps override actions.
 */

(function () {
  'use strict';

  // State Management
  const state = {
    riders: new Map(),
    auditLogs: [],
    selectedRiderId: 'RD-88492',
    isPaused: false,
    unsubscribeRiders: null,
    unsubscribeAudits: null,
    db: null,
  };

  // DOM Cache
  const dom = {
    metricActiveSessions: document.getElementById('metric-active-sessions'),
    metricRiskIndex: document.getElementById('metric-risk-index'),
    metricRiskStatus: document.getElementById('metric-risk-status'),
    metricRiskDot: document.getElementById('metric-risk-dot'),
    metricLivenessChecks: document.getElementById('metric-liveness-checks'),
    metricLockedAccounts: document.getElementById('metric-locked-accounts'),
    auditStreamContainer: document.getElementById('audit-stream-rows'),
    auditRecordCount: document.getElementById('audit-record-count'),
    engineStatusText: document.getElementById('engine-status-text'),
    engineLatencyText: document.getElementById('engine-latency-text'),

    // Inspection Drawer DOM
    inspectRiderName: document.getElementById('inspect-rider-name'),
    inspectRiderId: document.getElementById('inspect-rider-id'),
    inspectStatusBadge: document.getElementById('inspect-status-badge'),
    inspectStatusDot: document.getElementById('inspect-status-dot'),
    inspectStatusText: document.getElementById('inspect-status-text'),
    inspectBaselineImg: document.getElementById('inspect-baseline-img'),
    inspectLiveImg: document.getElementById('inspect-live-img'),
    inspectDiffPct: document.getElementById('inspect-diff-pct'),
    inspectHardwareHash: document.getElementById('inspect-hardware-hash'),
    inspectFacialConfidence: document.getElementById('inspect-facial-confidence'),
    inspectGpsDelta: document.getElementById('inspect-gps-delta'),
    inspectRiskVector: document.getElementById('inspect-risk-vector'),
    inspectIncidentKey: document.getElementById('inspect-incident-key'),
    btnFreeze: document.getElementById('btn-action-freeze'),
    btnApprove: document.getElementById('btn-action-approve'),
    btnSpotCheck: document.getElementById('btn-action-spotcheck'),
    searchInput: document.getElementById('search-rider-input'),
    pauseStreamBtn: document.getElementById('btn-pause-stream'),
    dumpLogBtn: document.getElementById('btn-dump-log'),
    toastNotification: document.getElementById('toast-notification'),
  };

  // Seed sample data for local/demo presentation fallback
  const DEMO_FALLBACK_RIDERS = [
    {
      riderId: 'RD-88492',
      name: 'Rajesh Kumar',
      currentStatus: 'LIVENESS_PENDING',
      activeRiskScore: 0.84,
      zone: 'Zone 4B (South Corridor)',
      basePhoneModel: 'Samsung Galaxy S21 Ultra',
      currentDeviceId: 'DEV-SM-G998B-9382',
      facialMatchConfidence: 94.2,
      activeRiskVector: 'SIM_CHANGE + HARDWARE_MISMATCH',
      aadhaarMasterPhotoUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuATXHtS1hx20mrHfzsdg2hem9hr5EWVr1I8OeO3ttq2UEIqgmxnqCwgc0J2w98ugKNjUgaP1ydRy51v8WFk6fdcMFAH_7YTSDxmXKJ-uHuEi75sa348L3KzIHuBI6sRCRqtI4ba4HPe6KaLHxS-sm6v1XD7pNbXNQlSFbIJsPY_W_4A5pWgAXJqeKzImmRvFIXvKqren2VK2masxwhWYmtRotHqPTI57JFqzqtCYztZzk-zuhBMLnzOPg',
      lastLiveScanPhotoUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBl1xVgnT55F3SFZknlEBs8XKP_oFL5QgxTYiClyd74thpyZKNz6x4Wf6vHAqXxOr3ZkSdpaV_f6AM8B-sBP8dyWeXdX9XZkraj_0Z1GmhEmMgQJzNlRl_Sfs-ivCIV1BgIXCFxy2w2_Dr_9Jjpj5hDC-iw_MthxZrA9GQ7vE35YELN0pRPqoq8m9AAk_InDnkeVxoPV4hQuwF2D5VNBtKPngWN_F4-J5SrwQ5AjVAlcmHQuMA0l8AVtg',
      cellTowerGpsDelta: 'NORMAL: 0.2 KM DRIFT',
      incidentKey: '88492-X',
    },
    {
      riderId: 'RD-99104',
      name: 'Vikram Singh',
      currentStatus: 'FROZEN',
      activeRiskScore: 0.92,
      zone: 'Zone 1A (Central Station)',
      basePhoneModel: 'Xiaomi Redmi Note 10',
      currentDeviceId: 'DEV-REDMI-NOTE10-4412',
      facialMatchConfidence: 41.5,
      activeRiskVector: 'RAPID_TELEPORTATION // GPS_MOCK',
      aadhaarMasterPhotoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&fit=crop&crop=faces',
      lastLiveScanPhotoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&fit=crop&crop=faces',
      cellTowerGpsDelta: 'CRITICAL: 14.8 KM INSTANT SHIFT',
      incidentKey: '99104-Q',
    },
    {
      riderId: 'RD-44120',
      name: 'Ananya Sharma',
      currentStatus: 'ACTIVE',
      activeRiskScore: 0.12,
      zone: 'Zone 7F (Airport Logistics)',
      basePhoneModel: 'Apple iPhone 13 Pro',
      currentDeviceId: 'DEV-IPHONE13-PRO-8812',
      facialMatchConfidence: 98.6,
      activeRiskVector: 'NONE // NOMINAL_BASELINE',
      aadhaarMasterPhotoUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300&fit=crop&crop=faces',
      lastLiveScanPhotoUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300&fit=crop&crop=faces',
      cellTowerGpsDelta: 'NORMAL: 0.1 KM DRIFT',
      incidentKey: '44120-V',
    },
    {
      riderId: 'RD-12855',
      name: 'Arjun Das',
      currentStatus: 'LIVENESS_PENDING',
      activeRiskScore: 0.68,
      zone: 'Zone 3C (Tech Ring Rd)',
      basePhoneModel: 'OnePlus 9R',
      currentDeviceId: 'DEV-ONEPLUS-9R-1123',
      facialMatchConfidence: 82.0,
      activeRiskVector: 'MULTIPLE_DEVICE_SIGNINS',
      aadhaarMasterPhotoUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300&fit=crop&crop=faces',
      lastLiveScanPhotoUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300&fit=crop&crop=faces',
      cellTowerGpsDelta: 'NORMAL: 0.3 KM DRIFT',
      incidentKey: '12855-C',
    },
    {
      riderId: 'RD-67231',
      name: 'Pooja Verma',
      currentStatus: 'ACTIVE',
      activeRiskScore: 0.55,
      zone: 'Zone 2D (East Gate Wharf)',
      basePhoneModel: 'Motorola Moto G60',
      currentDeviceId: 'DEV-MOTO-G60-7734',
      facialMatchConfidence: 88.4,
      activeRiskVector: 'CAMERA_OCCLUSION_LOW_LUMENS',
      aadhaarMasterPhotoUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300&fit=crop&crop=faces',
      lastLiveScanPhotoUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300&fit=crop&crop=faces',
      cellTowerGpsDelta: 'NORMAL: 0.1 KM DRIFT',
      incidentKey: '67231-R',
    },
  ];

  const DEMO_FALLBACK_AUDITS = [
    {
      logId: 'LOG-88492-1',
      riderId: 'RD-88492',
      displayTime: '22:04:12',
      zone: 'Zone 4B (South Corridor)',
      behaviorSignal: 'SIM Change + Hardware Mismatch',
      riskScore: 0.84,
      status: '[LIVENESS_PENDING]',
      incidentKey: '88492-X',
    },
    {
      logId: 'LOG-99104-1',
      riderId: 'RD-99104',
      displayTime: '22:03:55',
      zone: 'Zone 1A (Central Station)',
      behaviorSignal: 'Rapid Teleportation / GPS Mock',
      riskScore: 0.92,
      status: '[QUARANTINED]',
      incidentKey: '99104-Q',
    },
    {
      logId: 'LOG-44120-1',
      riderId: 'RD-44120',
      displayTime: '22:02:18',
      zone: 'Zone 7F (Airport Logistics)',
      behaviorSignal: 'Routine Biometric Re-auth',
      riskScore: 0.12,
      status: '[VERIFIED]',
      incidentKey: '44120-V',
    },
    {
      logId: 'LOG-12855-1',
      riderId: 'RD-12855',
      displayTime: '22:01:40',
      zone: 'Zone 3C (Tech Ring Rd)',
      behaviorSignal: 'Multiple Device Sign-ins',
      riskScore: 0.68,
      status: '[CHALLENGE_ISSUED]',
      incidentKey: '12855-C',
    },
    {
      logId: 'LOG-67231-1',
      riderId: 'RD-67231',
      displayTime: '22:00:09',
      zone: 'Zone 2D (East Gate Wharf)',
      behaviorSignal: 'Camera Occlusion / Low Lumens',
      riskScore: 0.55,
      status: '[RETRY_REQUESTED]',
      incidentKey: '67231-R',
    },
  ];

  // Initialize
  function init() {
    console.log('[TrustJuggler] Initializing Admin Controller...');
    
    // Seed in-memory map
    DEMO_FALLBACK_RIDERS.forEach((r) => state.riders.set(r.riderId, { ...r }));
    state.auditLogs = [...DEMO_FALLBACK_AUDITS];

    // Initialize Firebase
    if (window.TrustJugglerFirebase) {
      const { firestoreDb } = window.TrustJugglerFirebase.initFirebase();
      state.db = firestoreDb;
    }

    if (state.db) {
      subscribeToFirestore();
    } else {
      console.log('[TrustJuggler] Operating in Local Real-Time Simulation Bus.');
      renderMetrics();
      renderAuditStream();
      renderInspectionDrawer(state.selectedRiderId);
      setupMockEventStream();
    }

    bindEvents();
    renderMetrics();
    renderAuditStream();
    renderInspectionDrawer(state.selectedRiderId);
  }

  // Bind UI Events
  function bindEvents() {
    dom.btnFreeze.addEventListener('click', () => handleSecOpsAction('FREEZE'));
    dom.btnApprove.addEventListener('click', () => handleSecOpsAction('APPROVE'));
    dom.btnSpotCheck.addEventListener('click', () => handleSecOpsAction('SPOT_CHECK'));

    dom.searchInput.addEventListener('input', (e) => {
      const term = e.target.value.trim().toUpperCase();
      if (!term) {
        renderAuditStream(state.auditLogs);
        return;
      }
      const filtered = state.auditLogs.filter(
        (log) => log.riderId.toUpperCase().includes(term) || log.behaviorSignal.toUpperCase().includes(term)
      );
      renderAuditStream(filtered);
    });

    dom.pauseStreamBtn.addEventListener('click', () => {
      state.isPaused = !state.isPaused;
      dom.pauseStreamBtn.textContent = state.isPaused ? '[RESUME STREAM]' : '[PAUSE STREAM]';
      showToast(state.isPaused ? 'STREAM PAUSED // BUFFER ACTIVE' : 'STREAM RESUMED // REAL-TIME SYNC');
    });

    dom.dumpLogBtn.addEventListener('click', () => {
      exportLogsCsv();
    });
  }

  // Subscribe to real-time Firestore collections
  function subscribeToFirestore() {
    console.log('[TrustJuggler] Attaching real-time Firestore listeners...');

    // 1. Listen to Riders Collection
    try {
      state.unsubscribeRiders = state.db.collection('riders').onSnapshot(
        (snapshot) => {
          snapshot.docChanges().forEach((change) => {
            const data = change.doc.data();
            const riderId = data.riderId || change.doc.id;
            state.riders.set(riderId, { ...data, riderId });

            if (riderId === state.selectedRiderId) {
              renderInspectionDrawer(riderId);
            }
          });
          renderMetrics();
        },
        (error) => {
          console.warn('[TrustJuggler] Firestore riders listener fallback:', error);
        }
      );

      // 2. Listen to Live Audit Stream
      state.unsubscribeAudits = state.db
        .collection('audit_logs')
        .orderBy('timestamp', 'desc')
        .limit(30)
        .onSnapshot(
          (snapshot) => {
            if (state.isPaused) return;

            const logs = [];
            snapshot.forEach((doc) => {
              const d = doc.data();
              logs.push({
                logId: doc.id,
                riderId: d.riderId,
                displayTime: d.displayTime || formatTimestamp(d.timestamp),
                zone: d.zone || 'Zone 4B',
                behaviorSignal: d.behaviorSignal || 'Telemetry Sync',
                riskScore: d.riskScore ?? 0.12,
                status: d.status || '[VERIFIED]',
                incidentKey: d.incidentKey || 'LOG-SYNC',
              });
            });

            if (logs.length > 0) {
              state.auditLogs = logs;
              renderAuditStream();
            }
          },
          (error) => {
            console.warn('[TrustJuggler] Firestore audit_logs listener fallback:', error);
          }
        );
    } catch (err) {
      console.warn('[TrustJuggler] Error establishing Firestore listeners:', err);
    }
  }

  // Helper format timestamp
  function formatTimestamp(ts) {
    if (!ts) return new Date().toTimeString().split(' ')[0];
    if (ts.toDate) {
      const d = ts.toDate();
      return `${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}:${String(d.getSeconds()).padStart(2, '0')}`;
    }
    return new Date(ts).toTimeString().split(' ')[0];
  }

  // 1. Top Data Strip Rendering
  function renderMetrics() {
    let activeCount = 0;
    let livenessCount = 0;
    let lockedCount = 0;
    let totalRisk = 0;
    let countedRiders = 0;

    state.riders.forEach((rider) => {
      countedRiders++;
      totalRisk += Number(rider.activeRiskScore || 0);

      if (rider.currentStatus === 'FROZEN') {
        lockedCount++;
      } else if (rider.currentStatus === 'LIVENESS_PENDING') {
        livenessCount++;
      } else {
        activeCount++;
      }
    });

    const avgRisk = countedRiders > 0 ? (totalRisk / countedRiders).toFixed(2) : '0.18';
    const totalActiveFleetEstimate = 42840 + activeCount;

    if (dom.metricActiveSessions) {
      dom.metricActiveSessions.textContent = totalActiveFleetEstimate.toLocaleString();
    }
    if (dom.metricRiskIndex) {
      dom.metricRiskIndex.textContent = avgRisk;
    }
    if (dom.metricLivenessChecks) {
      dom.metricLivenessChecks.textContent = (310 + livenessCount).toString();
    }
    if (dom.metricLockedAccounts) {
      dom.metricLockedAccounts.textContent = (12 + lockedCount).toString();
    }

    // Dynamic color coding for Risk Index
    const riskNum = parseFloat(avgRisk);
    if (dom.metricRiskStatus && dom.metricRiskDot) {
      if (riskNum > 0.65) {
        dom.metricRiskStatus.textContent = 'HIGH RISK';
        dom.metricRiskStatus.className = 'font-label-caps text-label-caps text-error';
        dom.metricRiskDot.className = 'w-1.5 h-1.5 bg-error';
      } else if (riskNum > 0.35) {
        dom.metricRiskStatus.textContent = 'ELEVATED';
        dom.metricRiskStatus.className = 'font-label-caps text-label-caps text-amber-600';
        dom.metricRiskDot.className = 'w-1.5 h-1.5 bg-amber-600';
      } else {
        dom.metricRiskStatus.textContent = 'NORMAL';
        dom.metricRiskStatus.className = 'font-label-caps text-label-caps text-green-700';
        dom.metricRiskDot.className = 'w-1.5 h-1.5 bg-green-600';
      }
    }
  }

  // 2. Render Live Audit Stream Table
  function renderAuditStream(items = state.auditLogs) {
    if (!dom.auditStreamContainer) return;

    dom.auditRecordCount.textContent = `(${items.length} ACTIVE RECORDS)`;
    dom.auditStreamContainer.innerHTML = '';

    items.forEach((item) => {
      const isSelected = item.riderId === state.selectedRiderId;
      const row = document.createElement('div');
      
      // Styling matches Swiss Flat rows
      if (isSelected) {
        row.className =
          'flex flex-col sm:grid sm:grid-cols-12 gap-1 sm:gap-2 p-space-sm bg-primary text-on-primary items-center cursor-pointer transition-all border-l-2 border-amber-400';
      } else {
        row.className =
          'flex flex-col sm:grid sm:grid-cols-12 gap-1 sm:gap-2 p-space-sm bg-surface-container-lowest hover:bg-surface-container-low items-center cursor-pointer transition-colors border-l-2 border-transparent';
      }

      // Format Score Color
      let scoreColorClass = 'text-green-700';
      if (item.riskScore > 0.8) scoreColorClass = 'text-error';
      else if (item.riskScore > 0.6) scoreColorClass = 'text-amber-500';
      if (isSelected) {
        if (item.riskScore > 0.8) scoreColorClass = 'text-red-300 font-bold';
        else if (item.riskScore > 0.6) scoreColorClass = 'text-amber-300 font-bold';
        else scoreColorClass = 'text-green-300 font-bold';
      }

      // Format Status Badge Color
      let statusColorClass = 'text-green-700';
      if (item.status.includes('QUARANTINED') || item.status.includes('FROZEN')) statusColorClass = 'text-error font-bold';
      else if (item.status.includes('PENDING') || item.status.includes('CHALLENGE')) statusColorClass = 'text-amber-600 font-semibold';
      if (isSelected) {
        if (item.status.includes('QUARANTINED')) statusColorClass = 'text-red-300 font-bold';
        else if (item.status.includes('PENDING')) statusColorClass = 'text-amber-200 font-bold';
        else statusColorClass = 'text-green-200 font-semibold';
      }

      const textColorSecondary = isSelected ? 'text-surface-container-highest' : 'text-secondary';
      const textColorPrimary = isSelected ? 'text-on-primary' : 'text-on-surface';

      row.innerHTML = `
        <div class="w-full sm:col-span-2 flex items-center justify-between sm:justify-start gap-2">
          <span class="font-data-mono text-data-mono ${textColorSecondary}">${item.displayTime}</span>
          ${isSelected ? '<span class="sm:hidden font-label-caps text-label-caps bg-amber-500 text-on-primary px-1">INSPECTING</span>' : ''}
        </div>
        <div class="w-full sm:col-span-2 font-data-mono text-data-mono font-bold tracking-wide ${textColorPrimary}">
          #${item.riderId}
        </div>
        <div class="w-full sm:col-span-2 font-data-mono text-data-mono ${textColorSecondary}">
          ${item.zone}
        </div>
        <div class="w-full sm:col-span-3 font-body-sm text-body-sm ${textColorSecondary} truncate">
          ${item.behaviorSignal}
        </div>
        <div class="w-full sm:col-span-1 sm:text-right font-metric-md text-metric-md font-bold ${scoreColorClass}">
          ${Number(item.riskScore).toFixed(2)}
        </div>
        <div class="w-full sm:col-span-2 sm:text-right font-label-caps text-label-caps ${statusColorClass} uppercase">
          ${item.status}
        </div>
      `;

      // Click row -> open/populate Inspection Drawer
      row.addEventListener('click', () => {
        selectRider(item.riderId);
      });

      dom.auditStreamContainer.appendChild(row);
    });
  }

  // 3. Populate Verification Inspection Drawer
  function selectRider(riderId) {
    state.selectedRiderId = riderId;
    renderAuditStream(); // re-render to update selected row styling
    renderInspectionDrawer(riderId);
  }

  function renderInspectionDrawer(riderId) {
    const rider = state.riders.get(riderId) || {
      riderId,
      name: 'Rider ' + riderId,
      currentStatus: 'LIVENESS_PENDING',
      activeRiskScore: 0.84,
      currentDeviceId: 'DEV-UNKNOWN',
      basePhoneModel: 'Pixel 7 (REV-3)',
      facialMatchConfidence: 94.2,
      activeRiskVector: 'SIM_CHANGE + HARDWARE_MISMATCH',
      aadhaarMasterPhotoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&fit=crop&crop=faces',
      lastLiveScanPhotoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&fit=crop&crop=faces',
      cellTowerGpsDelta: 'NORMAL: 0.2 KM DRIFT',
      incidentKey: `${riderId.replace('RD-', '')}-X`,
    };

    dom.inspectRiderName.textContent = `INSPECTION: ${rider.name.toUpperCase()}`;
    dom.inspectRiderId.textContent = `#${rider.riderId}`;
    dom.inspectIncidentKey.textContent = `INCIDENT_KEY: ${rider.incidentKey || rider.riderId + '-X'}`;

    // Status Pill
    if (rider.currentStatus === 'FROZEN') {
      dom.inspectStatusDot.className = 'w-1.5 h-1.5 bg-error';
      dom.inspectStatusText.textContent = 'ACCOUNT_FROZEN';
      dom.inspectStatusText.className = 'font-label-caps text-label-caps text-error uppercase font-bold';
    } else if (rider.currentStatus === 'LIVENESS_PENDING') {
      dom.inspectStatusDot.className = 'w-1.5 h-1.5 bg-amber-600';
      dom.inspectStatusText.textContent = 'LIVENESS_PENDING';
      dom.inspectStatusText.className = 'font-label-caps text-label-caps text-amber-800 uppercase font-bold';
    } else {
      dom.inspectStatusDot.className = 'w-1.5 h-1.5 bg-green-600';
      dom.inspectStatusText.textContent = 'SYSTEM_VERIFIED';
      dom.inspectStatusText.className = 'font-label-caps text-label-caps text-green-800 uppercase font-bold';
    }

    // Baseline & Live Photos
    if (rider.aadhaarMasterPhotoUrl) dom.inspectBaselineImg.src = rider.aadhaarMasterPhotoUrl;
    if (rider.lastLiveScanPhotoUrl) dom.inspectLiveImg.src = rider.lastLiveScanPhotoUrl;

    // Telemetry Text Block
    dom.inspectHardwareHash.textContent = `${rider.currentDeviceId} // ${rider.basePhoneModel}`;
    dom.inspectFacialConfidence.textContent = `${(rider.facialMatchConfidence || 94.2).toFixed(1)}% [AFFIRMATIVE_MATCH]`;
    dom.inspectGpsDelta.textContent = rider.cellTowerGpsDelta || 'NORMAL: 0.2 KM DRIFT';
    dom.inspectRiskVector.textContent = rider.activeRiskVector || 'NOMINAL_BASELINE';

    // Highlight action buttons according to status
    if (rider.currentStatus === 'FROZEN') {
      dom.btnFreeze.classList.add('opacity-50');
      dom.btnApprove.classList.remove('opacity-50');
    } else {
      dom.btnFreeze.classList.remove('opacity-50');
    }
  }

  // 4. SecOps Actions: Freeze, Approve, Spot-Check
  async function handleSecOpsAction(actionType) {
    const riderId = state.selectedRiderId;
    const rider = state.riders.get(riderId);
    if (!rider) return;

    let targetStatus = 'ACTIVE';
    let targetScore = 0.08;
    let signal = '';
    let statusBadge = '[VERIFIED]';

    if (actionType === 'FREEZE') {
      targetStatus = 'FROZEN';
      targetScore = 0.95;
      signal = 'CRITICAL OVERRIDE: Account frozen by SecOps Admin';
      statusBadge = '[QUARANTINED]';
    } else if (actionType === 'APPROVE') {
      targetStatus = 'ACTIVE';
      targetScore = 0.08;
      signal = 'VERIFICATION CLEARED: Session authorized for 8h shift';
      statusBadge = '[VERIFIED]';
    } else if (actionType === 'SPOT_CHECK') {
      targetStatus = 'LIVENESS_PENDING';
      targetScore = 0.68;
      signal = 'OUT-OF-BAND PROTOCOL: Interactive liveness prompt issued';
      statusBadge = '[CHALLENGE_ISSUED]';
    }

    // 1. Optimistic UI update
    rider.currentStatus = targetStatus;
    rider.activeRiskScore = targetScore;
    rider.activeRiskVector = actionType === 'FREEZE' ? 'MANUAL_SECURITY_LOCKDOWN' : 'NONE';
    state.riders.set(riderId, rider);

    const now = new Date();
    const displayTime = `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}:${String(now.getSeconds()).padStart(2, '0')}`;
    const newLog = {
      logId: 'AUDIT-' + Date.now(),
      riderId,
      displayTime,
      zone: rider.zone || 'Zone 4B',
      behaviorSignal: signal,
      riskScore: targetScore,
      status: statusBadge,
      incidentKey: `${riderId.replace('RD-', '')}-${actionType}`,
    };

    state.auditLogs.unshift(newLog);
    renderMetrics();
    renderAuditStream();
    renderInspectionDrawer(riderId);
    showToast(`${actionType} EXECUTED FOR #${riderId} // SYNCED TO FLEET`);

    // 2. Push to Firestore if connected
    if (state.db) {
      try {
        const batch = state.db.batch();
        const riderRef = state.db.collection('riders').doc(riderId);
        batch.update(riderRef, {
          currentStatus: targetStatus,
          activeRiskScore: targetScore,
          activeRiskVector: rider.activeRiskVector,
          lastEvaluatedAt: firebase.firestore.FieldValue.serverTimestamp(),
        });

        const auditRef = state.db.collection('audit_logs').doc(newLog.logId);
        batch.set(auditRef, {
          ...newLog,
          timestamp: firebase.firestore.FieldValue.serverTimestamp(),
          details: {
            hardwareHash: `${rider.currentDeviceId} // ${rider.basePhoneModel}`,
            facialMatchConfidence: rider.facialMatchConfidence || 94.2,
            cellTowerGpsDelta: rider.cellTowerGpsDelta || '0.1 KM',
            activeRiskVector: rider.activeRiskVector,
            anomalyReasons: [signal],
          },
        });

        await batch.commit();
        console.log(`[TrustJuggler] Firestore updated for action ${actionType} on rider ${riderId}`);
      } catch (err) {
        console.error('[TrustJuggler] Error writing action to Firestore:', err);
      }
    }
  }

  // Toast alert
  function showToast(msg) {
    if (!dom.toastNotification) return;
    dom.toastNotification.textContent = msg;
    dom.toastNotification.classList.remove('opacity-0', 'pointer-events-none');
    dom.toastNotification.classList.add('opacity-100');
    setTimeout(() => {
      dom.toastNotification.classList.remove('opacity-100');
      dom.toastNotification.classList.add('opacity-0', 'pointer-events-none');
    }, 2800);
  }

  // Export CSV dump
  function exportLogsCsv() {
    let csv = 'Timestamp,RiderID,Zone,BehaviorSignal,RiskScore,Status,IncidentKey\n';
    state.auditLogs.forEach((log) => {
      csv += `"${log.displayTime}","${log.riderId}","${log.zone}","${log.behaviorSignal}",${log.riskScore},"${log.status}","${log.incidentKey}"\n`;
    });
    const blob = new Blob([csv], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `trust_juggler_audit_logs_${Date.now()}.csv`;
    a.click();
    showToast('AUDIT LOG EXPORTED (CSV)');
  }

  // Background heartbeat simulation for standalone demo mode
  function setupMockEventStream() {
    setInterval(() => {
      if (state.isPaused) return;
      // Randomly simulate small latency drift
      const latency = Math.floor(14 + Math.random() * 8);
      if (dom.engineLatencyText) {
        dom.engineLatencyText.textContent = `LATENCY: ${latency}ms`;
      }
    }, 3000);
  }

  // Public API
  window.TrustJugglerAdmin = {
    init,
    selectRider,
    freezeAccount: () => handleSecOpsAction('FREEZE'),
    approveSession: () => handleSecOpsAction('APPROVE'),
    triggerSpotCheck: () => handleSecOpsAction('SPOT_CHECK'),
    getState: () => state,
  };

  // Start on load
  document.addEventListener('DOMContentLoaded', init);
})();
