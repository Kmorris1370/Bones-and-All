import 'package:flutter/material.dart';
import '../api/blocks_api.dart';
import '../api/questions_api.dart';
import '../theme.dart';
import 'add_block_screen.dart';
import 'notification_prompt_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final Set<String> _selected = {};
  bool _loading = false;

  Future<void> _continue() async {
    setState(() => _loading = true);
    for (final type in _selected) {
      final block = await BlocksApi.createBlock(
        type == 'pain' ? 'Pain' : 'Food',
        type,
      );
      if (type == 'pain') {
        final blockId = block['id'] as String;
        await QuestionsApi.createQuestion(blockId, 'Selected Body Area', 'text');
        await QuestionsApi.createQuestion(blockId, 'Pain Characteristics', 'tags');
        await QuestionsApi.createQuestion(blockId, 'Pain Scale', 'scale');
      }
    }
    if (mounted) {
      setState(() => _loading = false);
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const NotificationPromptScreen()));
    }
  }

  Widget _chip(String label, String type) {
    final selected = _selected.contains(type);
    return GestureDetector(
      onTap: () => setState(() =>
      selected ? _selected.remove(type) : _selected.add(type)),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontSize: 16,
              )),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text('What Do You\nWant To Track?',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600)),
              const SizedBox(height: 32),
              _chip('Pain', 'pain'),
              GestureDetector(
                onTap: () => Navigator.push(ctx,
                    MaterialPageRoute(builder: (_) => const AddBlockScreen())),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(child: Text('Create New', style: TextStyle(fontSize: 16))),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _loading ? null : _continue,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
