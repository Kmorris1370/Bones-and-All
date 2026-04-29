import 'package:flutter/material.dart';
import '../api/notifications_api.dart';
import '../theme.dart';
import 'main_screen.dart';

class NotificationPromptScreen extends StatefulWidget {
  const NotificationPromptScreen({super.key});
  @override
  State<NotificationPromptScreen> createState() => _NotificationPromptScreenState();
}

class _NotificationPromptScreenState extends State<NotificationPromptScreen> {
  TimeOfDay? _selectedTime;
  bool _loading = false;

  Future<void> _enableNotifications() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked == null) return;
    setState(() { _selectedTime = picked; _loading = true; });
    final timeStr =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    await NotificationsApi.updatePreferences(enabled: true, time: timeStr);
    if (mounted) _goToMain();
  }

  void _skip() async {
    await NotificationsApi.updatePreferences(enabled: false);
    _goToMain();
  }

  void _goToMain() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainScreen()),
          (_) => false,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.notifications_outlined,
                  size: 64, color: AppColors.primary),
              const SizedBox(height: 24),
              const Text(
                'Allow Push Notifications for the Daily Questionnaire?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _loading ? null : _enableNotifications,
                      child: const Text('Yes'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _skip,
                      child: const Text('No'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
