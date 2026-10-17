import 'dart:math';
import '../models/rider_model.dart';
import '../models/telemetry_model.dart';

class TelemetryService {
  final Random _random = Random();
  double _currentLat = 12.9352;
  double _currentLon = 77.6245;
  double _currentSpeed = 26.4;
  double _batteryLevel = 84.0;
  int _sequenceCounter = 1000;

  /// Generates a normal telemetry reading conforming to the rider's baseline
  SessionTelemetryModel generateNormalTelemetry(RiderModel rider) {
    _sequenceCounter++;
    // Minor route drift (standard urban logistics delivery path)
    _currentLat += (_random.nextDouble() - 0.48) * 0.0005;
    _currentLon += (_random.nextDouble() - 0.48) * 0.0005;
    _currentSpeed = (20.0 + _random.nextDouble() * 15.0); // 20 - 35 km/h
    _batteryLevel = max(10.0, _batteryLevel - 0.02);

    return SessionTelemetryModel(
      sessionId: 'SES-${rider.riderId}-$_sequenceCounter',
      riderId: rider.riderId,
      latitude: _currentLat,
      longitude: _currentLon,
      accuracy: 4.2 + _random.nextDouble() * 2.0,
      speed: double.parse(_currentSpeed.toStringAsFixed(1)),
      velocityDelta: double.parse(((_random.nextDouble() - 0.5) * 4.0).toStringAsFixed(1)),
      simIccid: rider.baseSimIccid, // Baseline match
      deviceFingerprintHash: rider.currentDeviceId, // Baseline match
      deviceModel: rider.basePhoneModel,
      batteryHealth: double.parse(_batteryLevel.toStringAsFixed(1)),
      isCharging: false,
      timestamp: DateTime.now(),
      isSimulatedAnomaly: false,
    );
  }

  /// Generates threat telemetry simulating an unauthorized handset swap and impossible travel
  SessionTelemetryModel generateAnomalousTelemetry(RiderModel rider) {
    _sequenceCounter++;
    // Instant 14.8 km jump to trigger impossible travel / teleportation heuristic
    _currentLat += 0.125;
    _currentLon += 0.098;
    const anomalousSpeed = 132.5; // Impossible speed for 2-wheeler EV in city traffic
    const anomalousVelocityDelta = 54.0; // High instant velocity acceleration

    return SessionTelemetryModel(
      sessionId: 'SES-THREAT-${rider.riderId}-$_sequenceCounter',
      riderId: rider.riderId,
      latitude: _currentLat,
      longitude: _currentLon,
      accuracy: 25.0,
      speed: anomalousSpeed,
      velocityDelta: anomalousVelocityDelta,
      simIccid: '8991999988887777666F', // Threat: Unauthorized SIM Swap
      deviceFingerprintHash: 'UNRECOGNIZED-DEV-HASH-PIXEL7-REV3', // Threat: Unauthorized Device
      deviceModel: 'Google Pixel 7 (REV-3)',
      batteryHealth: 42.0,
      isCharging: true,
      timestamp: DateTime.now(),
      isSimulatedAnomaly: true,
    );
  }
}
