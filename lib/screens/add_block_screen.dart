import 'package:flutter/material.dart';
import '../api/blocks_api.dart';
import '../api/questions_api.dart';
import '../theme.dart';

class AddBlockScreen extends StatefulWidget {
  const AddBlockScreen({super.key});
  @override
  State<AddBlockScreen> createState() => _AddBlockScreenState();
}

class _AddBlockScreenState extends State<AddBlockScreen> {
  final _nameCtrl = TextEditingController();
  final _questionCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  String _questionType = 'text';
  final List<Map<String, dynamic>> _questions = [];
  List<String> _currentTags = [];
  bool _loading = false;

  void _addTag() {
    if (_tagCtrl.text.trim().isEmpty) return;
    setState(() {
      _currentTags.add(_tagCtrl.text.trim());
      _tagCtrl.clear();
    });
  }

  void _addQuestion() {
    if (_questionCtrl.text.trim().isEmpty) return;
    setState(() {
      _questions.add({
        'text': _questionCtrl.text.trim(),
        'type': _questionType,
        'tags': List<String>.from(_currentTags),
      });
      _questionCtrl.clear();
      _currentTags = [];
      _questionType = 'text';
    });
  }

  Future<void> _create() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    final block = await BlocksApi.createBlock(_nameCtrl.text.trim(), 'custom');
    final blockId = block['id'];
    for (final q in _questions) {
      final text = q['type'] == 'tags' && (q['tags'] as List).isNotEmpty
          ? '${q['text']}|${(q['tags'] as List).join(',')}'
          : q['text'];
      await QuestionsApi.createQuestion(blockId, text, q['type']);
    }
    if (mounted) {
      setState(() => _loading = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('New Block'),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Block Name'),
            ),
            const SizedBox(height: 24),
            const Text('Questions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ..._questions.map((q) => Card(
              color: AppColors.surface,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.check, color: AppColors.primary),
                title: Text(q['text']),
                subtitle: Text(q['type'] == 'tags' && (q['tags'] as List).isNotEmpty
                    ? '${q['type']} — ${(q['tags'] as List).join(', ')}'
                    : q['type']),
              ),
            )),
            const SizedBox(height: 8),
            TextField(
              controller: _questionCtrl,
              decoration: const InputDecoration(labelText: 'Question text'),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _questionType,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'text', child: Text('Text')),
                DropdownMenuItem(value: 'scale', child: Text('Scale (0-10)')),
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
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
                onPressed: _addQuestion,
                icon: const Icon(Icons.add),
                label: const Text('Add Question'),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _loading ? null : _create,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Create'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
