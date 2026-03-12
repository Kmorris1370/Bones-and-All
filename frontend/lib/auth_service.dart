import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const baseUrl = 'http://10.0.2.2:3000/api'; // Use 10.0.2.2 for Android emulator
  static const storage = FlutterSecureStorage();

  // Register
  static Future<Map<String, dynamic>> register(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(res.body);
  }

  // Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(res.body);
  }

  // Save token
  static Future<void> saveToken(String token) async {
    await storage.write(key: 'jwt', value: token);
  }

  // Get token
  static Future<String?> getToken() async {
    return await storage.read(key: 'jwt');
  }

  // Logout
  static Future<void> logout() async {
    await storage.delete(key: 'jwt');
  }
}