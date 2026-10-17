import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/rider_model.dart';
import '../state/driver_provider.dart';
import '../widgets/simulator_control_bar.dart';
import '../widgets/swiss_metric_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final driver = Provider.of<DriverProvider>(context);
    final rider = driver.rider;
    final telemetry = driver.lastTelemetry;

    Color riskColor = const Color(0xFF16A34A);
    if (driver.currentRiskScore > 0.65) {
      riskColor = const Color(0xFFDC2626);
    } else if (driver.currentRiskScore > 0.35) {
      riskColor = const Color(0xFFD97706);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FD),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      color: driver.isOnline
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      rider != null ? '${rider.name.toUpperCase()} (#${rider.riderId})' : 'DRIVER STANDBY',
                      style: const TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  color: const Color(0xFFF3F4F6),
                  child: const Text(
                    'BLR-SOUTH-01',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Online / Offline Shift Toggle Bar
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              driver.isOnline ? 'SHIFT ACTIVE // ONLINE' : 'SHIFT INACTIVE // OFFLINE',
                              style: TextStyle(
                                fontFamily: 'JetBrainsMono',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: driver.isOnline
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFF4B5563),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              driver.isOnline
                                  ? 'Continuous telemetry stream active (4s interval)'
                                  : 'Tap toggle to begin delivery shift and sensor sync',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: driver.isOnline,
                          onChanged: (_) => driver.toggleShiftOnline(),
                          activeColor: const Color(0xFF16A34A),
                          activeTrackColor: const Color(0xFFBBF7D0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. Metrics 2x2 Grid
                  Row(
                    children: [
                      Expanded(
                        child: SwissMetricCard(
                          label: 'RISK SCORE',
                          value: driver.currentRiskScore.toStringAsFixed(2),
                          valueColor: riskColor,
                          subLabel: driver.currentRiskScore > 0.60
                              ? 'CHALLENGE REQUIRED'
                              : 'NOMINAL BASELINE',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SwissMetricCard(
                          label: 'SPEED',
                          value: telemetry != null
                              ? '${telemetry.speed.toStringAsFixed(1)} KM/H'
                              : '0.0 KM/H',
                          subLabel: telemetry != null && telemetry.speed > 80
                              ? 'HIGH VELOCITY'
                              : 'NORMAL CRUISE',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: SwissMetricCard(
                          label: 'GPS DRIFT',
                          value: telemetry != null
                              ? '±${telemetry.accuracy.toStringAsFixed(1)} M'
                              : '±4.2 M',
                          subLabel: 'ZONE 4B CORRIDOR',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SwissMetricCard(
                          label: 'BATTERY HEALTH',
                          value: telemetry != null
                              ? '${telemetry.batteryHealth.toStringAsFixed(0)}%'
                              : '84%',
                          subLabel: 'DISCHARGING NOMINAL',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3. Hardware & Cryptographic Profile
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'REGISTERED BASELINE HARDWARE',
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDataRow('DEVICE FINGERPRINT', rider?.currentDeviceId ?? 'DEV-SM-G998B-9382'),
                        _buildDataRow('HANDSET MODEL', rider?.basePhoneModel ?? 'Samsung Galaxy S21 Ultra'),
                        _buildDataRow('SIM ICCID', rider?.baseSimIccid ?? '8991000123456789012F'),
                        _buildDataRow('VEHICLE CATEGORY', rider?.baseVehicleType ?? '2-Wheeler (EV Scooter)'),
                        _buildDataRow('ACTIVE RISK VECTOR', rider?.activeRiskVector ?? 'NOMINAL_BASELINE'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. Rolling Telemetry Event Stream Console
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: const Color(0xFF111827),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TELEMETRY INGESTION STREAM',
                              style: TextStyle(
                                fontFamily: 'JetBrainsMono',
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                            Text(
                              'AUTO-POLL: 4000MS',
                              style: TextStyle(
                                fontFamily: 'JetBrainsMono',
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4ADE80),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '> ${driver.activeLogMessage}',
                          style: const TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        if (telemetry != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '> LAT: ${telemetry.latitude.toStringAsFixed(4)} | LON: ${telemetry.longitude.toStringAsFixed(4)} | SPEED: ${telemetry.speed} km/h',
                            style: const TextStyle(
                              fontFamily: 'JetBrainsMono',
                              fontSize: 10,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                          Text(
                            '> HASH: ${telemetry.deviceFingerprintHash.substring(0, 16)}... | SIM: ${telemetry.simIccid}',
                            style: TextStyle(
                              fontFamily: 'JetBrainsMono',
                              fontSize: 10,
                              color: telemetry.isSimulatedAnomaly
                                  ? const Color(0xFFF87171)
                                  : const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Fixed Demo Simulator Control Bar
          const SimulatorControlBar(),
        ],
      ),
    );
  }

  Widget _buildDataRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key,
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 10,
              color: Color(0xFF6B7280),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}
