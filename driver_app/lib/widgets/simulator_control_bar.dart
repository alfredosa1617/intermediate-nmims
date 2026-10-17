import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/driver_provider.dart';
import '../models/rider_model.dart';

class SimulatorControlBar extends StatelessWidget {
  const SimulatorControlBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final driver = Provider.of<DriverProvider>(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
        border: Border(top: BorderSide(color: Color(0xFF374151), width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.tune, color: Color(0xFFFBBF24), size: 14),
                  SizedBox(width: 6),
                  Text(
                    'DEMO MODE // PRESENTATION CONTROLLER',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: Color(0xFFFBBF24),
                    ),
                  ),
                ],
              ),
              Text(
                'STATUS: ${driver.currentStatus.value}',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: driver.currentStatus == AccountStatus.active
                      ? const Color(0xFF4ADE80)
                      : (driver.currentStatus == AccountStatus.frozen
                          ? const Color(0xFFF87171)
                          : const Color(0xFFFBBF24)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Button 1: Normal Shift
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => driver.simulateNormalShift(),
                  icon: const Icon(Icons.check_circle_outline, size: 15, color: Colors.white),
                  label: const Text(
                    'NORMAL SHIFT',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Button 2: Threat / Device Switch + GPS Jump
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => driver.simulateDeviceSwitchAndGpsJump(),
                  icon: const Icon(Icons.warning_amber_rounded, size: 15, color: Colors.white),
                  label: const Text(
                    'TRIGGER ANOMALY',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
