import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/rider_model.dart';
import '../services/firebase_service.dart';
import '../services/mlkit_face_service.dart';
import '../state/driver_provider.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onCompleted;

  const OnboardingScreen({Key? key, required this.onCompleted}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0; // 0: Phone Auth, 1: OTP, 2: Camera e-KYC Baseline
  final TextEditingController _phoneController =
      TextEditingController(text: '+91 98765 43210');
  final TextEditingController _otpController =
      TextEditingController(text: '884920');

  bool _isLoading = false;
  bool _faceEnrolled = false;
  String _statusMsg = '';

  final MLKitFaceService _faceService = MLKitFaceService();

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _faceService.dispose();
    super.dispose();
  }

  void _sendOtp() {
    setState(() {
      _isLoading = true;
      _statusMsg = 'DISPATCHING CARRIER SMS VIA FIREBASE AUTH...';
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      setState(() {
        _isLoading = false;
        _currentStep = 1;
        _statusMsg = 'OTP SENT TO ${_phoneController.text}';
      });
    });
  }

  void _verifyOtp() {
    setState(() {
      _isLoading = true;
      _statusMsg = 'VERIFYING CRYPTOGRAPHIC TOKEN...';
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      setState(() {
        _isLoading = false;
        _currentStep = 2;
        _statusMsg = 'AUTH TOKEN CONFIRMED // PROCEED TO E-KYC BASELINE';
      });
    });
  }

  void _simulateCaptureBaseline() async {
    setState(() {
      _isLoading = true;
      _statusMsg = 'ANALYZING FACIAL MESH VIA GOOGLE ML KIT...';
    });

    // Simulated ML Kit embedding extraction
    await Future.delayed(const Duration(milliseconds: 1400));
    final embeddings = [0.428, 0.185, 0.762, 0.551, 0.912];

    final rider = RiderModel(
      riderId: 'RD-88492',
      name: 'Rajesh Kumar',
      phone: _phoneController.text.trim(),
      baselineEmbeddings: embeddings,
      aadhaarMasterPhotoUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuATXHtS1hx20mrHfzsdg2hem9hr5EWVr1I8OeO3ttq2UEIqgmxnqCwgc0J2w98ugKNjUgaP1ydRy51v8WFk6fdcMFAH_7YTSDxmXKJ-uHuEi75sa348L3KzIHuBI6sRCRqtI4ba4HPe6KaLHxS-sm6v1XD7pNbXNQlSFbIJsPY_W_4A5pWgAXJqeKzImmRvFIXvKqren2VK2masxwhWYmtRotHqPTI57JFqzqtCYztZzk-zuhBMLnzOPg',
      lastLiveScanPhotoUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBl1xVgnT55F3SFZknlEBs8XKP_oFL5QgxTYiClyd74thpyZKNz6x4Wf6vHAqXxOr3ZkSdpaV_f6AM8B-sBP8dyWeXdX9XZkraj_0Z1GmhEmMgQJzNlRl_Sfs-ivCIV1BgIXCFxy2w2_Dr_9Jjpj5hDC-iw_MthxZrA9GQ7vE35YELN0pRPqoq8m9AAk_InDnkeVxoPV4hQuwF2D5VNBtKPngWN_F4-J5SrwQ5AjVAlcmHQuMA0l8AVtg',
      currentDeviceId: 'DEV-SM-G998B-9382',
      basePhoneModel: 'Samsung Galaxy S21 Ultra',
      baseVehicleType: '2-Wheeler (EV Scooter)',
      baseSimIccid: '8991000123456789012F',
      activeRiskScore: 0.05,
      currentStatus: AccountStatus.active,
      zone: 'Zone 4B (South Corridor)',
      facialMatchConfidence: 98.4,
      activeRiskVector: 'NONE // NOMINAL_BASELINE',
    );

    // Persist baseline to Firestore
    final firebaseService = FirebaseService();
    await firebaseService.saveRiderBaseline(rider);

    setState(() {
      _isLoading = false;
      _faceEnrolled = true;
      _statusMsg = 'E-KYC BASELINE ENROLLED [HASH: 9B08F441]';
    });

    await Future.delayed(const Duration(milliseconds: 800));
    widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FD),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TRUST JUGGLER // ONBOARDING',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    color: const Color(0xFFE5E7EB),
                    child: Text(
                      'STEP ${_currentStep + 1}/3',
                      style: const TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFE5E7EB), height: 1),
              const SizedBox(height: 24),

              // Title
              Text(
                _currentStep == 0
                    ? 'CARRIER IDENTITY'
                    : (_currentStep == 1 ? 'SECURITY TOKEN' : 'BIOMETRIC BASELINE'),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _currentStep == 0
                    ? 'Enter carrier-verified phone number registered with logistics hub.'
                    : (_currentStep == 1
                        ? 'Enter the 6-digit one-time authorization code sent via SMS.'
                        : 'Align your face in natural light to generate your encrypted baseline hash.'),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Dynamic Step View
              Expanded(
                child: _buildStepContent(),
              ),

              // Footer Status
              if (_statusMsg.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _statusMsg,
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),

              // Primary Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_currentStep == 0) _sendOtp();
                          else if (_currentStep == 1) _verifyOtp();
                          else _simulateCaptureBaseline();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111827),
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _currentStep == 0
                              ? 'DISPATCH OTP CODE'
                              : (_currentStep == 1
                                  ? 'AUTHENTICATE & PROCEED'
                                  : 'CAPTURE BIOMETRIC BASELINE'),
                          style: const TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
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

  Widget _buildStepContent() {
    if (_currentStep == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MOBILE NUMBER (E.164)',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _phoneController,
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: Color(0xFF111827)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
        ],
      );
    } else if (_currentStep == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ENTER OTP CODE',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 6.0,
              color: Color(0xFF111827),
            ),
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: Color(0xFF111827)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
        ],
      );
    } else {
      return Center(
        child: Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFF111827), width: 1.5),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuATXHtS1hx20mrHfzsdg2hem9hr5EWVr1I8OeO3ttq2UEIqgmxnqCwgc0J2w98ugKNjUgaP1ydRy51v8WFk6fdcMFAH_7YTSDxmXKJ-uHuEi75sa348L3KzIHuBI6sRCRqtI4ba4HPe6KaLHxS-sm6v1XD7pNbXNQlSFbIJsPY_W_4A5pWgAXJqeKzImmRvFIXvKqren2VK2masxwhWYmtRotHqPTI57JFqzqtCYztZzk-zuhBMLnzOPg',
                fit: BoxFit.cover,
                width: 240,
                height: 240,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF16A34A), width: 2),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  color: Colors.black.withOpacity(0.8),
                  child: const Text(
                    'AADHAAR E-KYC MASTER',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
