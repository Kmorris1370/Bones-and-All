import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/auth_api.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../api/notifications_api.dart';

class AuthProvider extends ChangeNotifier {
  static const _storage = FlutterSecureStorage();
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> checkAuth() async {
    final token = await _storage.read(key: 'jwt');
    _isLoggedIn = token != null;
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    try {
      final data = await AuthApi.login(email, password);
      if (data['token'] != null) {
        await _storage.write(key: 'jwt', value: data['token']);
        _isLoggedIn = true;
        // ADD THIS
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await NotificationsApi.updatePreferences(
            enabled: true,
            fcmToken: fcmToken,
          );
        }
        notifyListeners();
        return null;
      }
      return data['error'] ?? 'Login failed';
    } catch (_) {
      return 'Could not connect to server';
    }
  }

  Future<String?> register(String email, String password) async {
    try {
      final data = await AuthApi.register(email, password);
      if (data['token'] != null) {
        await _storage.write(key: 'jwt', value: data['token']);
        _isLoggedIn = true;
        // ADD THIS
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await NotificationsApi.updatePreferences(
            enabled: true,
            fcmToken: fcmToken,
          );
        }
        notifyListeners();
        return null;
      }
      return data['error'] ?? 'Registration failed';
    } catch (_) {
      return 'Could not connect to server';
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt');
    _isLoggedIn = false;
    notifyListeners();
  }
}