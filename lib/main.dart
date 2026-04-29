import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/landing_screen.dart';
import 'screens/main_screen.dart';
import 'screens/biometric_screen.dart';
import 'services/biometric_service.dart';
import 'theme.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const BonesAndAllApp(),
    ),
  );
}

class BonesAndAllApp extends StatelessWidget {
  const BonesAndAllApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bones and All',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await context.read<AuthProvider>().checkAuth();
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) return;

    final biometricEnabled = await BiometricService.isBiometricEnabled();
    final needsAuth = await BiometricService.needsAuthentication();

    if (biometricEnabled && needsAuth && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BiometricScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext ctx) {
    final auth = ctx.watch<AuthProvider>();
    return auth.isLoggedIn ? const MainScreen() : const LandingScreen();
  }
}
