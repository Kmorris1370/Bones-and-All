import 'package:flutter/foundation.dart';

class AppConfig {
  static const String _prodUrl =
      'https://bones-and-all-backend-production.up.railway.app';
  static const String _devUrl = 'http://10.0.2.2:3000';

  // Flip to true when running a local backend for development
  static const bool useLocalBackend = false;

  static String get baseUrl => useLocalBackend ? _devUrl : _prodUrl;
  static bool get isDebug => kDebugMode;
}
