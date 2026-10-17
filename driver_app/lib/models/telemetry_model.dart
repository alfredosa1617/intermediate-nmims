import 'package:cloud_firestore/cloud_firestore.dart';

class SessionTelemetryModel {
  final String sessionId;
  final String riderId;
  final double latitude;
  final double longitude;
  final double accuracy;
  final double speed; // km/h
  final double velocityDelta;
  final String simIccid;
  final String deviceFingerprintHash;
  final String deviceModel;
  final double batteryHealth; // 0 - 100
  final bool isCharging;
  final DateTime timestamp;
  final bool isSimulatedAnomaly;

  const SessionTelemetryModel({
    required this.sessionId,
    required this.riderId,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.speed,
    required this.velocityDelta,
    required this.simIccid,
    required this.deviceFingerprintHash,
    required this.deviceModel,
    required this.batteryHealth,
    required this.isCharging,
    required this.timestamp,
    this.isSimulatedAnomaly = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'riderId': riderId,
      'gps': {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
      },
      'speed': speed,
      'velocityDelta': velocityDelta,
      'simIccid': simIccid,
      'deviceFingerprintHash': deviceFingerprintHash,
      'deviceModel': deviceModel,
      'batteryHealth': batteryHealth,
      'isCharging': isCharging,
      'timestamp': FieldValue.serverTimestamp(),
      'isSimulatedAnomaly': isSimulatedAnomaly,
      'processed': false,
    };
  }

  factory SessionTelemetryModel.fromMap(Map<String, dynamic> data, [String? id]) {
    final gps = (data['gps'] as Map<String, dynamic>?) ?? {};
    DateTime ts = DateTime.now();
    if (data['timestamp'] is Timestamp) {
      ts = (data['timestamp'] as Timestamp).toDate();
    }

    return SessionTelemetryModel(
      sessionId: id ?? data['sessionId'] ?? '',
      riderId: data['riderId'] ?? '',
      latitude: (gps['latitude'] as num?)?.toDouble() ?? 12.9352,
      longitude: (gps['longitude'] as num?)?.toDouble() ?? 77.6245,
      accuracy: (gps['accuracy'] as num?)?.toDouble() ?? 5.0,
      speed: (data['speed'] as num?)?.toDouble() ?? 0.0,
      velocityDelta: (data['velocityDelta'] as num?)?.toDouble() ?? 0.0,
      simIccid: data['simIccid'] ?? '',
      deviceFingerprintHash: data['deviceFingerprintHash'] ?? '',
      deviceModel: data['deviceModel'] ?? 'Android Handset',
      batteryHealth: (data['batteryHealth'] as num?)?.toDouble() ?? 85.0,
      isCharging: data['isCharging'] ?? false,
      timestamp: ts,
      isSimulatedAnomaly: data['isSimulatedAnomaly'] ?? false,
    );
  }
}
