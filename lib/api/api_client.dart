import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../utils/logger.dart';

class ApiClient {
  static const _storage = FlutterSecureStorage();

  static Future<String?> getToken() async {
    return await _storage.read(key: 'jwt');
  }

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<http.Response> get(String path) async {
    AppLogger.debug('ApiClient', 'GET $path');
    final res = await http.get(
      Uri.parse('${AppConfig.baseUrl}$path'),
      headers: await _headers(),
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        AppLogger.warn('ApiClient', 'GET $path timed out');
        return http.Response('{"error": "Connection timed out"}', 408);
      },
    );
    AppLogger.debug('ApiClient', 'GET $path → ${res.statusCode}');
    return res;
  }

  static Future<http.Response> post(String path, Map<String, dynamic> body,
      {bool auth = true}) async {
    AppLogger.debug('ApiClient', 'POST $path');
    final res = await http.post(
      Uri.parse('${AppConfig.baseUrl}$path'),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        AppLogger.warn('ApiClient', 'POST $path timed out');
        return http.Response('{"error": "Connection timed out"}', 408);
      },
    );
    AppLogger.debug('ApiClient', 'POST $path → ${res.statusCode}');
    return res;
  }

  static Future<http.Response> patch(String path, Map<String, dynamic> body) async {
    AppLogger.debug('ApiClient', 'PATCH $path');
    final res = await http.patch(
      Uri.parse('${AppConfig.baseUrl}$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        AppLogger.warn('ApiClient', 'PATCH $path timed out');
        return http.Response('{"error": "Connection timed out"}', 408);
      },
    );
    AppLogger.debug('ApiClient', 'PATCH $path → ${res.statusCode}');
    return res;
  }

  static Future<http.Response> delete(String path) async {
    AppLogger.debug('ApiClient', 'DELETE $path');
    final res = await http.delete(
      Uri.parse('${AppConfig.baseUrl}$path'),
      headers: await _headers(),
    );
    AppLogger.debug('ApiClient', 'DELETE $path → ${res.statusCode}');
    return res;
  }
}
