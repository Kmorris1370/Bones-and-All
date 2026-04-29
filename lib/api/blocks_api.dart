import 'dart:convert';
import 'api_client.dart';
import '../utils/logger.dart';

class BlocksApi {
  static Future<Map<String, dynamic>> createBlock(String name, String blockType) async {
    AppLogger.debug('BlocksApi', 'Creating block name="$name" type=$blockType');
    final res = await ApiClient.post('/api/blocks', {
      'name': name,
      'block_type': blockType,
    });
    if (res.statusCode != 201) {
      AppLogger.error('BlocksApi', 'Failed to create block: ${res.statusCode} ${res.body}');
    }
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getBlocks() async {
    AppLogger.debug('BlocksApi', 'Fetching blocks');
    try {
      final res = await ApiClient.get('/api/blocks');
      final decoded = jsonDecode(res.body);
      if (decoded is List) {
        AppLogger.debug('BlocksApi', 'Fetched ${decoded.length} blocks');
        return decoded;
      }
      AppLogger.warn('BlocksApi', 'getBlocks response was not a list: ${res.body}');
      return [];
    } catch (e) {
      AppLogger.error('BlocksApi', 'getBlocks threw an exception', e);
      return [];
    }
  }

  static Future<void> deleteBlock(String blockId) async {
    AppLogger.debug('BlocksApi', 'Deleting block $blockId');
    final res = await ApiClient.delete('/api/blocks/$blockId');
    if (res.statusCode != 200) {
      AppLogger.error('BlocksApi', 'Failed to delete block: ${res.statusCode}');
    }
  }

  static Future<void> updateBlock(String blockId, Map<String, dynamic> updates) async {
    AppLogger.debug('BlocksApi', 'Updating block $blockId');
    await ApiClient.patch('/api/blocks/$blockId', updates);
  }
}
