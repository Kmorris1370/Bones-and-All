import 'package:flutter/foundation.dart';

class AppLogger {
  static void debug(String tag, String message) {
    if (kDebugMode) debugPrint('[DEBUG][$tag] $message');
  }

  static void info(String tag, String message) {
    if (kDebugMode) debugPrint('[INFO][$tag] $message');
  }

  static void warn(String tag, String message) {
    if (kDebugMode) debugPrint('[WARN][$tag] $message');
  }

  static void error(String tag, String message, [Object? err]) {
    if (kDebugMode) {
      debugPrint('[ERROR][$tag] $message');
      if (err != null) debugPrint('[ERROR][$tag] Detail: $err');
    }
  }
}
