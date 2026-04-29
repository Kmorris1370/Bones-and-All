import 'dart:convert';
import 'api_client.dart';

class QuestionsApi {
  static Future<Map<String, dynamic>> createQuestion(
      String blockId, String questionText, String questionType) async {
    final res = await ApiClient.post('/api/questions', {
      'block_id': blockId,
      'question_text': questionText,
      'question_type': questionType,
    });
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getQuestions(String blockId) async {
    final res = await ApiClient.get('/api/questions/$blockId');
    return jsonDecode(res.body);
  }

  static Future<void> deleteQuestion(String questionId) async {
    await ApiClient.delete('/api/questions/$questionId');
  }
}