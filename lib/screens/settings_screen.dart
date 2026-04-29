import 'package:flutter/material.dart';
import '../api/notifications_api.dart';
import '../services/biometric_service.dart';
import '../theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _enabled = false;
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  bool _loading = true;
  bool _saving = false;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await NotificationsApi.getPreferences();
    final biometric = await BiometricService.isBiometricEnabled();
    setState(() {
      _enabled = prefs['notifications_enabled'] ?? false;
      if (prefs['notification_time'] != null) {
        final parts = (prefs['notification_time'] as String).split(':');
        _time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
      _biometricEnabled = biometric;
      _loading = false;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final timeStr =
        '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';
    await NotificationsApi.updatePreferences(enabled: _enabled, time: timeStr);
    setState(() => _saving = false);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')));
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Security',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Biometric / PIN Login'),
            subtitle: const Text('Use fingerprint or PIN to unlock'),
            value: _biometricEnabled,
            activeColor: AppColors.primary,
            onChanged: (v) async {
              if (v) {
                final success = await BiometricService.authenticate();
                if (success) {
                  await BiometricService.setBiometricEnabled(true);
                  await BiometricService.saveLastAuthTime();
                  setState(() => _biometricEnabled = true);
                }
              } else {
                await BiometricService.setBiometricEnabled(false);
                setState(() => _biometricEnabled = false);
              }
            },
          ),
          const Divider(),
          const SizedBox(height: 16),
          const Text('Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Daily Reminder'),
            value: _enabled,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _enabled = v),
          ),
          if (_enabled)
            ListTile(
              title: const Text('Reminder Time'),
              trailing: Text(_time.format(ctx), style: const TextStyle(fontSize: 16)),
              onTap: _pickTime,
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _saving ? null : _save,
            child: _saving
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Save Settings'),
          ),
        ],
      ),
    );
  }
}
