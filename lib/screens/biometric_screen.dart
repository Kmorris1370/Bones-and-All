import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/biometric_service.dart';
import 'main_screen.dart';
import 'landing_screen.dart';

class BiometricScreen extends StatefulWidget {
  const BiometricScreen({super.key});
  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen> {
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    final success = await BiometricService.authenticate();
    if (success && mounted) {
      await BiometricService.saveLastAuthTime();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else if (mounted) {
      setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fingerprint, size: 80, color: AppColors.primary),
              const SizedBox(height: 24),
              const Text('Bones and All',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text('Authenticate to continue',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              if (_failed) ...[
                const Text('Authentication failed',
                    style: TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _authenticate,
                  child: const Text('Try Again'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    ctx,
                    MaterialPageRoute(builder: (_) => const LandingScreen()),
                  ),
                  child: const Text('Log in with email instead'),
                ),
              ] else
                const CircularProgressIndicator(color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
