import 'dart:convert';
import 'api_client.dart';
import '../utils/logger.dart';

class LogsApi {
  static Future<Map<String, dynamic>> createLog({
    required String blockId,
    String? journalEntry,
  }) async {
    AppLogger.debug('LogsApi', 'Creating/updating log for block $blockId');
    final res = await ApiClient.post('/api/logs', {
      'block_id': blockId,
      if (journalEntry != null) 'journal_entry': journalEntry,
    });
    if (res.statusCode != 201) {
      AppLogger.error('LogsApi', 'Failed to create log: ${res.statusCode} ${res.body}');
    }
    return jsonDecode(res.body);
  }

  // Responses are now embedded in each log by the backend (no N+1)
  static Future<List<dynamic>> getLogs(String blockId) async {
    AppLogger.debug('LogsApi', 'Fetching logs for block $blockId');
    final res = await ApiClient.get('/api/logs/$blockId');
    if (res.statusCode != 200) {
      AppLogger.error('LogsApi', 'Failed to fetch logs: ${res.statusCode} ${res.body}');
      throw Exception('Failed to load logs');
    }
    final logs = jsonDecode(res.body) as List;
    AppLogger.debug('LogsApi', 'Fetched ${logs.length} logs for block $blockId');
    return logs;
  }

  static Future<Map<String, dynamic>> getLogByDate(
      String blockId, String date) async {
    AppLogger.debug('LogsApi', 'Fetching log for block $blockId on $date');
    final res = await ApiClient.get('/api/logs/$blockId/$date');
    return jsonDecode(res.body);
  }

  static Future<void> updateJournal(String logId, String journalEntry) async {
    AppLogger.debug('LogsApi', 'Updating journal for log $logId');
    await ApiClient.patch('/api/logs/$logId', {'journal_entry': journalEntry});
  }

  static Future<void> deleteLog(String logId) async {
    AppLogger.debug('LogsApi', 'Deleting log $logId');
    await ApiClient.delete('/api/logs/$logId');
  }
}
