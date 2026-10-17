import 'package:flutter_test/flutter_test.dart';
import 'package:trust_juggler_driver/models/rider_model.dart';
import 'package:trust_juggler_driver/models/telemetry_model.dart';
import 'package:trust_juggler_driver/services/telemetry_service.dart';

void main() {
  group('Trust Juggler Telemetry & Risk Scoring Tests', () {
    final telemetryService = TelemetryService();

    final testRider = RiderModel(
      riderId: 'RD-88492',
      name: 'Rajesh Kumar',
      phone: '+919876543210',
      baselineEmbeddings: const [0.42, 0.18, 0.76, 0.55, 0.91],
      aadhaarMasterPhotoUrl: '',
      lastLiveScanPhotoUrl: '',
      currentDeviceId: 'DEV-SM-G998B-9382',
      basePhoneModel: 'Samsung Galaxy S21 Ultra',
      baseVehicleType: '2-Wheeler (EV Scooter)',
      baseSimIccid: '8991000123456789012F',
      activeRiskScore: 0.05,
      currentStatus: AccountStatus.active,
      zone: 'Zone 4B (South Corridor)',
      facialMatchConfidence: 94.2,
      activeRiskVector: 'NONE // NOMINAL_BASELINE',
    );

    test('generateNormalTelemetry produces valid matching hardware fingerprint', () {
      final normal = telemetryService.generateNormalTelemetry(testRider);
      expect(normal.deviceFingerprintHash, equals(testRider.currentDeviceId));
      expect(normal.simIccid, equals(testRider.baseSimIccid));
      expect(normal.speed, lessThan(60.0));
      expect(normal.isSimulatedAnomaly, isFalse);
    });

    test('generateAnomalousTelemetry produces threat flags and hardware mismatch', () {
      final anomaly = telemetryService.generateAnomalousTelemetry(testRider);
      expect(anomaly.deviceFingerprintHash, isNot(equals(testRider.currentDeviceId)));
      expect(anomaly.simIccid, isNot(equals(testRider.baseSimIccid)));
      expect(anomaly.speed, greaterThan(100.0));
      expect(anomaly.isSimulatedAnomaly, isTrue);
    });

    test('Rider status transitions correctly from string values', () {
      expect(AccountStatusExtension.fromString('ACTIVE'), equals(AccountStatus.active));
      expect(AccountStatusExtension.fromString('LIVENESS_PENDING'), equals(AccountStatus.livenessPending));
      expect(AccountStatusExtension.fromString('FROZEN'), equals(AccountStatus.frozen));
    });
  });
}
