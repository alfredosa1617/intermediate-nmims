import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/rider_model.dart';
import '../models/telemetry_model.dart';
import '../services/firebase_service.dart';
import '../services/telemetry_service.dart';

class DriverProvider extends ChangeNotifier {
  final FirebaseService _firebaseService;
  final TelemetryService _telemetryService;

  RiderModel? _rider;
  bool _isOnline = false;
  Timer? _telemetryTicker;
  StreamSubscription<RiderModel>? _riderSubscription;
  SessionTelemetryModel? _lastTelemetry;
  String _activeLogMessage = 'SYSTEM STANDBY // READY FOR SHIFT';

  DriverProvider({
    FirebaseService? firebaseService,
    TelemetryService? telemetryService,
  })  : _firebaseService = firebaseService ?? FirebaseService(),
        _telemetryService = telemetryService ?? TelemetryService() {
    _initRider('RD-88492');
  }

  RiderModel? get rider => _rider;
  bool get isOnline => _isOnline;
  SessionTelemetryModel? get lastTelemetry => _lastTelemetry;
  String get activeLogMessage => _activeLogMessage;
  AccountStatus get currentStatus => _rider?.currentStatus ?? AccountStatus.active;
  double get currentRiskScore => _rider?.activeRiskScore ?? 0.05;

  void _initRider(String riderId) {
    _riderSubscription?.cancel();
    _riderSubscription = _firebaseService.streamRider(riderId).listen(
      (updatedRider) {
        _rider = updatedRider;
        debugPrint(
            '[DriverProvider] Rider updated from Firestore: status=${_rider?.currentStatus.value}, risk=${_rider?.activeRiskScore}');
        notifyListeners();
      },
      onError: (err) {
        debugPrint('[DriverProvider] Firestore listener error: $err');
      },
    );
  }

  /// Toggle Go Online / Go Offline
  void toggleShiftOnline() {
    _isOnline = !_isOnline;
    if (_isOnline) {
      _activeLogMessage = 'SHIFT ONLINE // TELEMETRY BUFFER ACTIVE';
      _startTelemetryStream();
    } else {
      _activeLogMessage = 'SHIFT OFFLINE // SENSORS PAUSED';
      _stopTelemetryStream();
    }
    notifyListeners();
  }

  void _startTelemetryStream() {
    _telemetryTicker?.cancel();
    _telemetryTicker = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_rider != null && _isOnline) {
        _pushNormalPing();
      }
    });
  }

  void _stopTelemetryStream() {
    _telemetryTicker?.cancel();
    _telemetryTicker = null;
  }

  /// DEMO MODE SIMULATOR 1: "Simulate Normal Shift" (Pushes green telemetry)
  Future<void> simulateNormalShift() async {
    if (_rider == null) return;
    _activeLogMessage = 'SIMULATION: INGESTING NOMINAL CORRIDOR TELEMETRY';
    notifyListeners();
    await _pushNormalPing();
  }

  /// DEMO MODE SIMULATOR 2: "Simulate Device Switch + GPS Jump" (Pushes anomalous telemetry)
  Future<void> simulateDeviceSwitchAndGpsJump() async {
    if (_rider == null) return;
    _activeLogMessage = 'SIMULATION: INJECTING HARDWARE SWAP + 14.8KM GPS TELEPORTATION';
    final anomalyTelemetry = _telemetryService.generateAnomalousTelemetry(_rider!);
    _lastTelemetry = anomalyTelemetry;
    notifyListeners();

    // 1. Send threat packet to Firestore `sessions` collection
    await _firebaseService.pushTelemetry(anomalyTelemetry);

    // 2. Optimistic local update for zero-latency presentation demonstration
    _rider = _rider?.copyWith(
      activeRiskScore: 0.84,
      currentStatus: AccountStatus.livenessPending,
      activeRiskVector: 'SIM_CHANGE + HARDWARE_MISMATCH',
    );
    notifyListeners();
  }

  Future<void> _pushNormalPing() async {
    if (_rider == null) return;
    final telemetry = _telemetryService.generateNormalTelemetry(_rider!);
    _lastTelemetry = telemetry;
    await _firebaseService.pushTelemetry(telemetry);
    notifyListeners();
  }

  /// Liveness challenge verified by camera & ML Kit
  Future<void> onLivenessVerified({
    required double confidence,
    required bool blinkPassed,
    required bool smilePassed,
  }) async {
    if (_rider == null) return;
    _activeLogMessage = 'BIOMETRIC VERIFIED // RISK DAMPENED TO NOMINAL';

    // Optimistically update locally
    _rider = _rider?.copyWith(
      activeRiskScore: 0.12,
      currentStatus: AccountStatus.active,
      facialMatchConfidence: (confidence * 100),
      activeRiskVector: 'NONE // BIOMETRIC_MATCH_OK',
    );
    notifyListeners();

    // Sync to Firestore
    await _firebaseService.resolveLivenessChallenge(
      riderId: _rider!.riderId,
      facialConfidence: confidence,
      blinkVerified: blinkPassed,
      smileVerified: smilePassed,
    );
  }

  /// Manual reset / override
  void overrideStatus(AccountStatus status) {
    _rider = _rider?.copyWith(currentStatus: status);
    notifyListeners();
  }

  @override
  void dispose() {
    _riderSubscription?.cancel();
    _telemetryTicker?.cancel();
    super.dispose();
  }
}
