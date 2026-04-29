import 'package:flutter/material.dart';
import '../api/questions_api.dart';
import '../api/logs_api.dart';
import '../api/questionnaire_api.dart';
import '../models/block.dart';
import '../models/question.dart';
import '../theme.dart';
import '../widgets/body_map_widget.dart';
import '../widgets/tags_selector_widget.dart';
import 'summary_screen.dart';

class QuestionnaireScreen extends StatefulWidget {
  final Block block;
  const QuestionnaireScreen({super.key, required this.block});
  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  List<Question> _questions = [];
  final Map<String, String> _responses = {};
  String _journalEntry = '';
  bool _loading = true;
  bool _submitting = false;

  String? _selectedBodyArea;
  List<String> _selectedChars = [];
  double _painScale = 0;

  static const _painCharacteristics = [
    'Throbbing', 'Stabbing', 'Aching', 'Sharp', 'Burning', 'Dull', 'Stiffness'
  ];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final data = await QuestionsApi.getQuestions(widget.block.id);
    setState(() {
      _questions = data.map((q) => Question.fromJson(q)).toList();
      _loading = false;
    });
  }

  Future<void> _submit() async {
    if (_submitting) return; // prevent double tap
    setState(() => _submitting = true);

    final log = await LogsApi.createLog(
      blockId: widget.block.id,
      journalEntry: _journalEntry.isNotEmpty ? _journalEntry : null,
    );

    List<Map<String, String>> responseList = [];

    if (widget.block.blockType == 'pain') {
      // Use already-loaded _questions instead of fetching again
      for (final q in _questions) {
        if (q.questionText == 'Selected Body Area') {
          responseList.add({'question_id': q.id, 'response_value': _selectedBodyArea ?? ''});
        } else if (q.questionText == 'Pain Characteristics') {
          responseList.add({'question_id': q.id, 'response_value': _selectedChars.join(', ')});
        } else if (q.questionText == 'Pain Scale') {
          responseList.add({'question_id': q.id, 'response_value': _painScale.toStringAsFixed(1)});
        }
      }
    } else {
      responseList = _responses.entries
          .where((e) => e.key.length == 36)
          .map((e) => {'question_id': e.key, 'response_value': e.value})
          .toList();
    }

    if (responseList.isNotEmpty) {
      await QuestionnaireApi.saveResponses(log['id'], responseList);
    }

    if (mounted) {
      setState(() => _submitting = false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SummaryScreen(
            block: widget.block,
            bodyArea: _selectedBodyArea,
            characteristics: _selectedChars,
            painScale: _painScale,
            responses: _responses,
          ),
        ),
      );
    }
  }

  Widget _buildPainBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Area', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        BodyMapWidget(
          selectedArea: _selectedBodyArea,
          onAreaSelected: (area) => setState(() => _selectedBodyArea = area),
        ),
        const SizedBox(height: 24),
        const Text('Pain Characteristics',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TagsSelectorWidget(
          options: _painCharacteristics,
          selected: _selectedChars,
          onChanged: (s) => setState(() => _selectedChars = s),
        ),
        const SizedBox(height: 24),
        const Text('Pain Scale', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        Row(
          children: [
            const Text('0'),
            Expanded(
              child: Slider(
                value: _painScale,
                min: 0,
                max: 10,
                divisions: 20,
                label: _painScale.toString(),
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _painScale = v),
              ),
            ),
            const Text('10'),
          ],
        ),
        Center(
          child: Text(_painScale.toStringAsFixed(1),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildCustomQuestion(Question q) {
    switch (q.questionType) {
      case 'scale':
        final val = double.tryParse(_responses[q.id] ?? '0') ?? 0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q.questionText,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Slider(
              value: val,
              min: 0,
              max: 10,
              divisions: 20,
              label: val.toString(),
              activeColor: AppColors.primary,
              onChanged: (v) =>
                  setState(() => _responses[q.id] = v.toStringAsFixed(1)),
            ),
          ],
        );
      case 'tags':
        final parts = q.questionText.split('|');
        final questionLabel = parts[0];
        final tagOptions = parts.length > 1 ? parts[1].split(',') : <String>[];
        final selected = (_responses[q.id] ?? '').isEmpty
            ? <String>[]
            : _responses[q.id]!.split(', ');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(questionLabel,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TagsSelectorWidget(
              options: tagOptions,
              selected: selected,
              onChanged: (s) => setState(() => _responses[q.id] = s.join(', ')),
            ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q.questionText,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(border: OutlineInputBorder()),
              onChanged: (v) => _responses[q.id] = v,
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(widget.block.name),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.block.blockType == 'pain')
              _buildPainBlock()
            else
              ..._questions.map((q) => Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: _buildCustomQuestion(q),
              )),
            const SizedBox(height: 24),
            const Text('Journal',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Optional notes for today...',
              ),
              onChanged: (v) => _journalEntry = v,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
