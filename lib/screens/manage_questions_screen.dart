import 'package:flutter/material.dart';
import '../api/questions_api.dart';
import '../models/block.dart';
import '../theme.dart';

class ManageQuestionsScreen extends StatefulWidget {
  final Block block;
  const ManageQuestionsScreen({super.key, required this.block});
  @override
  State<ManageQuestionsScreen> createState() => _ManageQuestionsScreenState();
}

class _ManageQuestionsScreenState extends State<ManageQuestionsScreen> {
  List<dynamic> _questions = [];
  bool _loading = true;
  final _questionCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  String _questionType = 'text';
  List<String> _currentTags = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await QuestionsApi.getQuestions(widget.block.id);
    setState(() { _questions = data; _loading = false; });
  }

  void _addTag() {
    if (_tagCtrl.text.trim().isEmpty) return;
    setState(() {
      _currentTags.add(_tagCtrl.text.trim());
      _tagCtrl.clear();
    });
  }

  Future<void> _addQuestion() async {
    if (_questionCtrl.text.trim().isEmpty) return;
    final text = _questionType == 'tags' && _currentTags.isNotEmpty
        ? '${_questionCtrl.text.trim()}|${_currentTags.join(',')}'
        : _questionCtrl.text.trim();
    await QuestionsApi.createQuestion(widget.block.id, text, _questionType);
    _questionCtrl.clear();
    setState(() { _currentTags = []; _questionType = 'text'; });
    await _load();
  }

  Future<void> _deleteQuestion(String questionId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Question'),
        content: const Text('This will remove the question and all its recorded responses.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    await QuestionsApi.deleteQuestion(questionId);
    await _load();
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Manage Questions'),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_questions.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text('No questions yet.', style: TextStyle(color: Colors.grey)),
              )
            else
              ..._questions.map((q) {
                final raw = q['question_text'] as String;
                final parts = raw.split('|');
                final label = parts[0];
                final tags = parts.length > 1 ? parts[1] : null;
                return Card(
                  color: AppColors.surface,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(label),
                    subtitle: Text(tags != null
                        ? 'tags — $tags'
                        : q['question_type']),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteQuestion(q['id']),
                    ),
                  ),
                );
              }),
            const Divider(height: 32),
            const Text('Add Question',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            TextField(
              controller: _questionCtrl,
              decoration: const InputDecoration(
                labelText: 'Question text',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: _questionType,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'text', child: Text('Text')),
                DropdownMenuItem(value: 'scale', child: Text('Scale (0–10)')),
                DropdownMenuItem(value: 'tags', child: Text('Tags (multi-select)')),
              ],
              onChanged: (v) => setState(() {
                _questionType = v!;
                _currentTags = [];
              }),
            ),
            if (_questionType == 'tags') ...[
              const SizedBox(height: 8),
              const Text('Tag Options', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: _currentTags
                    .map((t) => Chip(
                  label: Text(t),
                  backgroundColor: AppColors.primary,
                  labelStyle: const TextStyle(color: Colors.white),
                  onDeleted: () => setState(() => _currentTags.remove(t)),
                  deleteIconColor: Colors.white,
                ))
                    .toList(),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagCtrl,
                      decoration: const InputDecoration(labelText: 'Add tag option'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: AppColors.primary),
                    onPressed: _addTag,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _addQuestion,
                icon: const Icon(Icons.add),
                label: const Text('Add Question'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}