import 'dart:convert';
import 'api_client.dart';

class ProfileApi {
  static Future<Map<String, dynamic>> getProfile() async {
    final res = await ApiClient.get('/api/profile');
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateProfile({
    String? displayName,
    String? profilePictureUrl,
  }) async {
    final body = <String, dynamic>{};
    if (displayName != null) body['display_name'] = displayName;
    if (profilePictureUrl != null) body['profile_picture_url'] = profilePictureUrl;
    final res = await ApiClient.patch('/api/profile', body);
    return jsonDecode(res.body);
  }

  static Future<void> deleteAccount() async {
    await ApiClient.delete('/api/profile');
  }
}