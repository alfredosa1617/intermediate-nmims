import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mlkit_face_service.dart';
import '../state/driver_provider.dart';
import '../widgets/camera_face_overlay.dart';

class LivenessPromptScreen extends StatefulWidget {
  const LivenessPromptScreen({Key? key}) : super(key: key);

  @override
  State<LivenessPromptScreen> createState() => _LivenessPromptScreenState();
}

class _LivenessPromptScreenState extends State<LivenessPromptScreen> {
  final MLKitFaceService _faceService = MLKitFaceService();
  int _blinkCount = 0;
  bool _smileDetected = false;
  bool _isFaceAligned = true;
  double _confidence = 0.942;
  String _statusMsg = 'ALIGN FACE IN RETICLE // BLINK OR SMILE';
  bool _isProcessing = false;
  Timer? _mockDetectionTimer;

  @override
  void initState() {
    super.initState();
    _startSimulatedDetectionLoop();
  }

  /// Automatically cycles through biometric landmark detection
  void _startSimulatedDetectionLoop() {
    _mockDetectionTimer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (!mounted) return;
      setState(() {
        if (_blinkCount < 2) {
          _blinkCount++;
          _statusMsg = 'BLINK DETECTED [$_blinkCount/2] // VERIFYING';
        } else if (!_smileDetected) {
          _smileDetected = true;
          _statusMsg = 'SMILE RECOGNIZED // BIOMETRIC CONFIRMATION';
        } else {
          timer.cancel();
          _finalizeVerification();
        }
      });
    });
  }

  void _finalizeVerification() async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
      _statusMsg = 'LIVENESS VERIFIED // DAMPENING RISK SCORE';
    });

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final driver = Provider.of<DriverProvider>(context, listen: false);
    await driver.onLivenessVerified(
      confidence: _confidence,
      blinkPassed: _blinkCount >= 2,
      smilePassed: _smileDetected,
    );
  }

  @override
  void dispose() {
    _mockDetectionTimer?.cancel();
    _faceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Simulated Camera Viewfinder with Aadhaar photo comparison
          Positioned.fill(
            child: Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBl1xVgnT55F3SFZknlEBs8XKP_oFL5QgxTYiClyd74thpyZKNz6x4Wf6vHAqXxOr3ZkSdpaV_f6AM8B-sBP8dyWeXdX9XZkraj_0Z1GmhEmMgQJzNlRl_Sfs-ivCIV1BgIXCFxy2w2_Dr_9Jjpj5hDC-iw_MthxZrA9GQ7vE35YELN0pRPqoq8m9AAk_InDnkeVxoPV4hQuwF2D5VNBtKPngWN_F4-J5SrwQ5AjVAlcmHQuMA0l8AVtg',
              fit: BoxFit.cover,
            ),
          ),

          // Google ML Kit HUD Overlay
          Positioned.fill(
            child: CameraFaceOverlay(
              statusMessage: _statusMsg,
              isFaceAligned: _isFaceAligned,
              blinkCount: _blinkCount,
              smileDetected: _smileDetected,
              confidence: _confidence,
            ),
          ),

          // Micro-Friction Challenge Header Bar
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: const Color(0xFF111827).withOpacity(0.92),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        color: const Color(0xFFD97706),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'TRUST CHALLENGE // SPOT-CHECK',
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: Color(0xFFFBBF24),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Anomalous behavioral telemetry was flagged by the Risk Engine. Please blink twice or smile to confirm authorized driver presence.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Color(0xFFE5E7EB),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Manual One-Tap Verification (For presentation / emulator testing)
          Positioned(
            bottom: 90,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _finalizeVerification,
              icon: const Icon(Icons.verified_user_outlined, size: 16),
              label: const Text(
                'CONFIRM BIOMETRICS & UNLOCK',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
