import 'dart:convert';
import 'api_client.dart';

class AuthApi {
  static Future<Map<String, dynamic>> register(String email, String password) async {
    final res = await ApiClient.post(
      '/api/auth/register',
      {'email': email, 'password': password},
      auth: false,
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await ApiClient.post(
      '/api/auth/login',
      {'email': email, 'password': password},
      auth: false,
    );
    return jsonDecode(res.body);
  }
}