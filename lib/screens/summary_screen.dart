import 'package:flutter/material.dart';
import '../models/block.dart';
import '../theme.dart';
import 'main_screen.dart';

class SummaryScreen extends StatelessWidget {
  final Block block;
  final String? bodyArea;
  final List<String> characteristics;
  final double painScale;
  final Map<String, String> responses;

  const SummaryScreen({
    super.key,
    required this.block,
    this.bodyArea,
    required this.characteristics,
    required this.painScale,
    required this.responses,
  });

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Summary'),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (block.blockType == 'pain') ...[
              const Text('Pain Characteristics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: characteristics
                    .map((c) => Chip(
                  label: Text(c),
                  backgroundColor: AppColors.primary,
                  labelStyle: const TextStyle(color: Colors.white),
                ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              if (bodyArea != null)
                Row(
                  children: [
                    const Text('Selected Area: ',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(bodyArea!),
                  ],
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Pain Rating: ',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      painScale.toStringAsFixed(1),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ] else
              ...responses.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(e.key,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    Expanded(flex: 3, child: Text(e.value)),
                  ],
                ),
              )),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4A6741),
                  side: const BorderSide(color: Color(0xFF4A6741)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => Navigator.pop(ctx), // goes back to questionnaire
                child: const Text('Go Back & Edit'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A6741),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => Navigator.of(ctx).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const MainScreen()),
                      (_) => false,
                ),
                child: const Text('Confirm'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
