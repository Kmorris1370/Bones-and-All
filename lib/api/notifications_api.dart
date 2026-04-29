import 'dart:convert';
import 'api_client.dart';

class NotificationsApi {
  static Future<void> updatePreferences({
    required bool enabled,
    String? time,
    String? fcmToken,
  }) async {
    final body = <String, dynamic>{'notifications_enabled': enabled};
    if (time != null) {
      body['notification_time'] = time;
      body['timezone_offset'] = DateTime.now().timeZoneOffset.inMinutes;
    }
    if (fcmToken != null) body['fcm_token'] = fcmToken;
    await ApiClient.patch('/api/notifications/preferences', body);
  }

  static Future<Map<String, dynamic>> getPreferences() async {
    final res = await ApiClient.get('/api/notifications/preferences');
    return jsonDecode(res.body);
  }
}