import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/rider_model.dart';
import '../state/driver_provider.dart';

class FrozenLockScreen extends StatelessWidget {
  const FrozenLockScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final driver = Provider.of<DriverProvider>(context);
    final rider = driver.rider;

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Alert Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: const Color(0xFFDC2626),
                child: const Row(
                  children: [
                    Icon(Icons.lock, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'CARRIER LOCKDOWN // SECOPS DIRECTIVE',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Title
              const Text(
                'ACCOUNT TEMPORARILY SUSPENDED FOR SECURITY AUDIT',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              // Explanation
              const Text(
                'High-confidence behavioral telemetry anomalies (unrecognized handset hash, foreign SIM swap, or impossible velocity delta) were detected on this account.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: Color(0xFF9CA3AF),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Incident Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937),
                  border: Border.all(color: const Color(0xFF374151), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIncidentRow('RIDER ASSET', '${rider?.name} (#${rider?.riderId ?? "RD-88492"})'),
                    _buildIncidentRow('RISK INDEX', '${driver.currentRiskScore.toStringAsFixed(2)} [CRITICAL]'),
                    _buildIncidentRow('FLAGGED VECTOR', rider?.activeRiskVector ?? 'SIM_CHANGE + HARDWARE_MISMATCH'),
                    _buildIncidentRow('INCIDENT KEY', '88492-X-LOCKDOWN'),
                    _buildIncidentRow('STATUS', 'ACCOUNT_QUARANTINED'),
                  ],
                ),
              ),
              const Spacer(),

              // Real-Time Sync Indicator
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      color: const Color(0xFFFBBF24),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'LISTENING LIVE FOR SECOPS ADMIN CLEARANCE...',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: Color(0xFFFBBF24),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Support Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'INCIDENT REPORT DISPATCHED TO CARRIER SUPPRESSION DESK',
                          style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11),
                        ),
                        backgroundColor: Color(0xFFDC2626),
                      ),
                    );
                  },
                  icon: const Icon(Icons.headset_mic, size: 16),
                  label: const Text(
                    'CONTACT DISPATCH SUPPRESSION DESK',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF111827),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Demo Testing Override Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    // Simulate admin clearing suspension
                    driver.overrideStatus(AccountStatus.active);
                  },
                  child: const Text(
                    '[ DEMO MODE: SIMULATE SECOPS ADMIN APPROVAL ]',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9CA3AF),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncidentRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key,
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 10,
              color: Color(0xFF9CA3AF),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
