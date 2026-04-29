import 'dart:convert';
import 'api_client.dart';
import '../utils/logger.dart';

class QuestionnaireApi {
  static Future<List<dynamic>> saveResponses(
      String logId, List<Map<String, String>> responses) async {
    AppLogger.debug('QuestionnaireApi', 'Saving ${responses.length} responses for log $logId');
    final res = await ApiClient.post('/api/questionnaire', {
      'log_id': logId,
      'responses': responses,
    });
    if (res.statusCode != 201) {
      AppLogger.error('QuestionnaireApi', 'Failed to save responses: ${res.statusCode} ${res.body}');
    }
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getResponses(String logId) async {
    AppLogger.debug('QuestionnaireApi', 'Fetching responses for log $logId');
    final res = await ApiClient.get('/api/questionnaire/$logId');
    if (res.statusCode != 200) {
      AppLogger.error('QuestionnaireApi', 'Failed to fetch responses: ${res.statusCode}');
      return [];
    }
    final data = jsonDecode(res.body) as List;
    AppLogger.debug('QuestionnaireApi', 'Fetched ${data.length} responses for log $logId');
    return data;
  }
}
