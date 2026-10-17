import 'package:cloud_firestore/cloud_firestore.dart';

enum AccountStatus {
  active,
  livenessPending,
  frozen,
}

extension AccountStatusExtension on AccountStatus {
  String get value {
    switch (this) {
      case AccountStatus.active:
        return 'ACTIVE';
      case AccountStatus.livenessPending:
        return 'LIVENESS_PENDING';
      case AccountStatus.frozen:
        return 'FROZEN';
    }
  }

  static AccountStatus fromString(String? str) {
    switch (str?.toUpperCase()) {
      case 'FROZEN':
        return AccountStatus.frozen;
      case 'LIVENESS_PENDING':
        return AccountStatus.livenessPending;
      case 'ACTIVE':
      default:
        return AccountStatus.active;
    }
  }
}

class RiderModel {
  final String riderId;
  final String name;
  final String phone;
  final List<double> baselineEmbeddings;
  final String aadhaarMasterPhotoUrl;
  final String lastLiveScanPhotoUrl;
  final String currentDeviceId;
  final String basePhoneModel;
  final String baseVehicleType;
  final String baseSimIccid;
  final double activeRiskScore;
  final AccountStatus currentStatus;
  final String zone;
  final double facialMatchConfidence;
  final String activeRiskVector;
  final DateTime? lastEvaluatedAt;

  const RiderModel({
    required this.riderId,
    required this.name,
    required this.phone,
    required this.baselineEmbeddings,
    required this.aadhaarMasterPhotoUrl,
    required this.lastLiveScanPhotoUrl,
    required this.currentDeviceId,
    required this.basePhoneModel,
    required this.baseVehicleType,
    required this.baseSimIccid,
    required this.activeRiskScore,
    required this.currentStatus,
    required this.zone,
    required this.facialMatchConfidence,
    required this.activeRiskVector,
    this.lastEvaluatedAt,
  });

  factory RiderModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return RiderModel.fromMap(data, doc.id);
  }

  factory RiderModel.fromMap(Map<String, dynamic> data, [String? id]) {
    DateTime? evaluatedDate;
    final lastEval = data['lastEvaluatedAt'];
    if (lastEval is Timestamp) {
      evaluatedDate = lastEval.toDate();
    } else if (lastEval is String) {
      evaluatedDate = DateTime.tryParse(lastEval);
    }

    List<double> embeddings = [];
    if (data['baselineEmbeddings'] is List) {
      embeddings = (data['baselineEmbeddings'] as List)
          .map((e) => (e as num).toDouble())
          .toList();
    }

    return RiderModel(
      riderId: id ?? data['riderId'] ?? 'RD-88492',
      name: data['name'] ?? 'Rajesh Kumar',
      phone: data['phone'] ?? '+919876543210',
      baselineEmbeddings: embeddings,
      aadhaarMasterPhotoUrl: data['aadhaarMasterPhotoUrl'] ?? '',
      lastLiveScanPhotoUrl: data['lastLiveScanPhotoUrl'] ?? '',
      currentDeviceId: data['currentDeviceId'] ?? 'DEV-SM-G998B-9382',
      basePhoneModel: data['basePhoneModel'] ?? 'Samsung Galaxy S21 Ultra',
      baseVehicleType: data['baseVehicleType'] ?? '2-Wheeler (EV Scooter)',
      baseSimIccid: data['baseSimIccid'] ?? '8991000123456789012F',
      activeRiskScore: (data['activeRiskScore'] as num?)?.toDouble() ?? 0.05,
      currentStatus: AccountStatusExtension.fromString(data['currentStatus']),
      zone: data['zone'] ?? 'Zone 4B (South Corridor)',
      facialMatchConfidence:
          (data['facialMatchConfidence'] as num?)?.toDouble() ?? 94.2,
      activeRiskVector: data['activeRiskVector'] ?? 'NOMINAL_BASELINE',
      lastEvaluatedAt: evaluatedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'riderId': riderId,
      'name': name,
      'phone': phone,
      'baselineEmbeddings': baselineEmbeddings,
      'aadhaarMasterPhotoUrl': aadhaarMasterPhotoUrl,
      'lastLiveScanPhotoUrl': lastLiveScanPhotoUrl,
      'currentDeviceId': currentDeviceId,
      'basePhoneModel': basePhoneModel,
      'baseVehicleType': baseVehicleType,
      'baseSimIccid': baseSimIccid,
      'activeRiskScore': activeRiskScore,
      'currentStatus': currentStatus.value,
      'zone': zone,
      'facialMatchConfidence': facialMatchConfidence,
      'activeRiskVector': activeRiskVector,
      'lastEvaluatedAt': FieldValue.serverTimestamp(),
    };
  }

  RiderModel copyWith({
    String? riderId,
    String? name,
    String? phone,
    List<double>? baselineEmbeddings,
    String? aadhaarMasterPhotoUrl,
    String? lastLiveScanPhotoUrl,
    String? currentDeviceId,
    String? basePhoneModel,
    String? baseVehicleType,
    String? baseSimIccid,
    double? activeRiskScore,
    AccountStatus? currentStatus,
    String? zone,
    double? facialMatchConfidence,
    String? activeRiskVector,
    DateTime? lastEvaluatedAt,
  }) {
    return RiderModel(
      riderId: riderId ?? this.riderId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      baselineEmbeddings: baselineEmbeddings ?? this.baselineEmbeddings,
      aadhaarMasterPhotoUrl: aadhaarMasterPhotoUrl ?? this.aadhaarMasterPhotoUrl,
      lastLiveScanPhotoUrl: lastLiveScanPhotoUrl ?? this.lastLiveScanPhotoUrl,
      currentDeviceId: currentDeviceId ?? this.currentDeviceId,
      basePhoneModel: basePhoneModel ?? this.basePhoneModel,
      baseVehicleType: baseVehicleType ?? this.baseVehicleType,
      baseSimIccid: baseSimIccid ?? this.baseSimIccid,
      activeRiskScore: activeRiskScore ?? this.activeRiskScore,
      currentStatus: currentStatus ?? this.currentStatus,
      zone: zone ?? this.zone,
      facialMatchConfidence: facialMatchConfidence ?? this.facialMatchConfidence,
      activeRiskVector: activeRiskVector ?? this.activeRiskVector,
      lastEvaluatedAt: lastEvaluatedAt ?? this.lastEvaluatedAt,
    );
  }
}
