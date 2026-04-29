import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  static final _auth = LocalAuthentication();

  // Check if biometric is available on device
  static Future<bool> isAvailable() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  // Authenticate with biometric or PIN fallback
  static Future<bool> authenticate() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      final available = await _auth.getAvailableBiometrics();
      print('canCheck: $canCheck, supported: $isSupported, available: $available');

      return await _auth.authenticate(
        localizedReason: 'Authenticate to access Bones and All',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      print('Biometric error: $e');
      return false;
    }
  }

  // Save the time the user last authenticated
  static Future<void> saveLastAuthTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_auth_time', DateTime.now().millisecondsSinceEpoch);
  }

  // Check if 15 minutes have passed since last auth
  static Future<bool> needsAuthentication() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAuth = prefs.getInt('last_auth_time');
    if (lastAuth == null) return true;
    final diff = DateTime.now().millisecondsSinceEpoch - lastAuth;
    return diff > 15 * 60 * 1000; // 15 minutes in milliseconds
  }

  // Check if user has enabled biometric
  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('biometric_enabled') ?? false;
  }

  // Enable or disable biometric
  static Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', enabled);
  }
}