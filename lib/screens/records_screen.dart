import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api/logs_api.dart';
import '../models/block.dart';
import '../theme.dart';
import 'log_detail_screen.dart';
import 'graphs_screen.dart';

class RecordsScreen extends StatefulWidget {
  final Block block;
  const RecordsScreen({super.key, required this.block});
  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  List<dynamic> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await LogsApi.getLogs(widget.block.id);
    setState(() { _logs = data; _loading = false; });
  }

  Map<String, List<dynamic>> _groupByDate() {
    final Map<String, List<dynamic>> grouped = {};
    for (final log in _logs) {
      final key = log['log_date'] as String;
      grouped.putIfAbsent(key, () => []).add(log);
    }
    return grouped;
  }

  void _openEntry(BuildContext ctx, Map<String, dynamic> log) {
    Navigator.push(
      ctx,
      MaterialPageRoute(builder: (_) => LogDetailScreen(log: log)),
    ).then((deleted) {
      if (deleted == true) _load();
    });
  }

  void _showEntryPicker(BuildContext ctx, String dateLabel, List<dynamic> entries) {
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Text(dateLabel,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          const Divider(height: 1),
          ListView.builder(
            shrinkWrap: true,
            itemCount: entries.length,
            itemBuilder: (_, i) => ListTile(
              title: Text('Entry ${i + 1}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(ctx);
                _openEntry(ctx, Map<String, dynamic>.from(entries[i]));
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext ctx) {
    final grouped = _groupByDate();
    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('${widget.block.name} Records'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(
              ctx,
              MaterialPageRoute(
                  builder: (_) => GraphsScreen(block: widget.block, logs: _logs)),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
          ? const Center(
        child: Text(
          'No records yet.\nFill out your first questionnaire to get started.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dates.length,
        itemBuilder: (_, i) {
          final date = DateTime.parse(dates[i]);
          final entries = grouped[dates[i]]!;
          final dateLabel = DateFormat('MMMM d, yyyy').format(date);
          return Card(
            color: AppColors.surface,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              title: Text(dateLabel),
              subtitle: entries.length > 1
                  ? Text('${entries.length} entries',
                  style: const TextStyle(fontSize: 12, color: Colors.grey))
                  : null,
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                if (entries.length == 1) {
                  _openEntry(ctx, Map<String, dynamic>.from(entries[0]));
                } else {
                  _showEntryPicker(ctx, dateLabel, entries);
                }
              },
            ),
          );
        },
      ),
    );
  }
}