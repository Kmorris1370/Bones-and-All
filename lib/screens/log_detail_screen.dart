import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api/questionnaire_api.dart';
import '../api/logs_api.dart';

class LogDetailScreen extends StatefulWidget {
  final Map<String, dynamic> log;
  const LogDetailScreen({super.key, required this.log});
  @override
  State<LogDetailScreen> createState() => _LogDetailScreenState();
}

class _LogDetailScreenState extends State<LogDetailScreen> {
  List<dynamic> _responses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await QuestionnaireApi.getResponses(widget.log['id']);
    setState(() { _responses = data; _loading = false; });
  }

  Future<void> _deleteLog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('This will permanently delete this entry. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    await LogsApi.deleteLog(widget.log['id']);
    if (mounted) Navigator.pop(context, true); // return true to trigger refresh
  }

  @override
  Widget build(BuildContext ctx) {
    final dateStr = widget.log['log_date'] != null
        ? DateFormat('MMMM d, yyyy')
        .format(DateTime.parse(widget.log['log_date']))
        : 'Record';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F2EB),
        title: Text(dateStr),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _deleteLog,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Questionnaire Responses',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          if (_responses.isEmpty)
            const Text('No responses recorded.',
                style: TextStyle(color: Colors.grey))
          else
            ..._responses.map((r) => Card(
              color: const Color(0xFFDDD8CC),
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(r['question_text'] ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600)),
                subtitle: Text(r['response_value'] ?? ''),
              ),
            )),
          const SizedBox(height: 24),
          const Text('Journal Entry',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            widget.log['journal_entry'] != null &&
                widget.log['journal_entry']
                    .toString()
                    .isNotEmpty
                ? widget.log['journal_entry']
                : 'No journal entry.',
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
        ],
      ),
    );
  }
}