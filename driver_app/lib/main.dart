import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'models/rider_model.dart';
import 'screens/dashboard_screen.dart';
import 'screens/frozen_lock_screen.dart';
import 'screens/liveness_prompt_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/firebase_service.dart';
import 'state/driver_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Attempt Firebase initialization if google-services.json / options are present
  try {
    await Firebase.initializeApp();
    debugPrint('[TrustJuggler] Firebase initialized successfully.');
  } catch (e) {
    debugPrint('[TrustJuggler] Running with simulated real-time Firebase bus: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DriverProvider()),
      ],
      child: const TrustJugglerDriverApp(),
    ),
  );
}

class TrustJugglerDriverApp extends StatelessWidget {
  const TrustJugglerDriverApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TRUST JUGGLER // DRIVER ENGINE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF7F9FD),
        primaryColor: const Color(0xFF111827),
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF111827),
          onPrimary: Colors.white,
          secondary: Color(0xFF4B5563),
          onSecondary: Colors.white,
          error: Color(0xFFDC2626),
          onError: Colors.white,
          surface: Color(0xFFFFFFFF),
          onSurface: Color(0xFF111827),
        ),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: const Color(0xFF111827),
          displayColor: const Color(0xFF111827),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            elevation: 0,
          ),
        ),
        cardTheme: const CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
      home: const RootNavigationController(),
    );
  }
}

class RootNavigationController extends StatefulWidget {
  const RootNavigationController({Key? key}) : super(key: key);

  @override
  State<RootNavigationController> createState() => _RootNavigationControllerState();
}

class _RootNavigationControllerState extends State<RootNavigationController> {
  bool _isOnboarded = true; // Set to true by default for immediate demo inspection

  @override
  Widget build(BuildContext context) {
    final driver = Provider.of<DriverProvider>(context);

    // 1. Initial Onboarding & e-KYC flow
    if (!_isOnboarded) {
      return OnboardingScreen(
        onCompleted: () {
          setState(() {
            _isOnboarded = true;
          });
        },
      );
    }

    // 2. Reactively switch views based on rider status from Firestore
    switch (driver.currentStatus) {
      case AccountStatus.frozen:
        return const FrozenLockScreen();
      case AccountStatus.livenessPending:
        return const LivenessPromptScreen();
      case AccountStatus.active:
      default:
        return const DashboardScreen();
    }
  }
}
