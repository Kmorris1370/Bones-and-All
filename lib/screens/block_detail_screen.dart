import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/block.dart';
import '../api/notifications_api.dart';
import '../theme.dart';
import 'questionnaire_screen.dart';
import 'records_screen.dart';
import 'graphs_screen.dart';
import '../api/logs_api.dart';
import 'manage_questions_screen.dart';

class BlockDetailScreen extends StatefulWidget {
  final Block block;
  const BlockDetailScreen({super.key, required this.block});
  @override
  State<BlockDetailScreen> createState() => _BlockDetailScreenState();
}

class _BlockDetailScreenState extends State<BlockDetailScreen> {
  bool _blockNotifEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadBlockNotif();
  }

  Future<void> _loadBlockNotif() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _blockNotifEnabled =
          prefs.getBool('block_notif_${widget.block.id}') ?? false;
    });
  }

  Future<void> _toggleBlockNotif(bool value) async {
    if (value) {
      final globalPrefs = await NotificationsApi.getPreferences();
      final globalEnabled = globalPrefs['notifications_enabled'] ?? false;

      if (!globalEnabled) {
        if (!mounted) return;
        final enable = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Enable Notifications'),
            content: const Text(
                'Notifications are currently off. Would you like to turn them on?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('No')),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Yes',
                      style: TextStyle(color: AppColors.primary))),
            ],
          ),
        );

        if (enable != true) return;

        if (!mounted) return;
        final picked = await showTimePicker(
          context: context,
          initialTime: const TimeOfDay(hour: 9, minute: 0),
        );
        if (picked == null) return;

        final timeStr =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        await NotificationsApi.updatePreferences(enabled: true, time: timeStr);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notifications enabled')),
          );
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('block_notif_${widget.block.id}', true);
      setState(() => _blockNotifEnabled = true);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('block_notif_${widget.block.id}', false);
      setState(() => _blockNotifEnabled = false);
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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _option(
              ctx,
              icon: Icons.edit_note,
              title: "Fill Today's Questionnaire",
              subtitle: 'Log your daily entry',
              onTap: () => Navigator.push(
                ctx,
                MaterialPageRoute(
                    builder: (_) => QuestionnaireScreen(block: widget.block)),
              ),
            ),
            const SizedBox(height: 12),
            _option(
              ctx,
              icon: Icons.history,
              title: 'View Records',
              subtitle: 'See past entries and logs',
              onTap: () => Navigator.push(
                ctx,
                MaterialPageRoute(
                    builder: (_) => RecordsScreen(block: widget.block)),
              ),
            ),
            const SizedBox(height: 12),
            _option(
              ctx,
              icon: Icons.bar_chart,
              title: 'View Graphs',
              subtitle: 'Visualize your data over time',
              onTap: () async {
                final logs = await LogsApi.getLogs(widget.block.id);
                if (ctx.mounted) {
                  Navigator.push(
                    ctx,
                    MaterialPageRoute(
                        builder: (_) =>
                            GraphsScreen(block: widget.block, logs: logs)),
                  );
                }
              },
            ),
            if (widget.block.blockType == 'custom') ...[
              const SizedBox(height: 12),
              _option(
                ctx,
                icon: Icons.edit,
                title: 'Manage Questions',
                subtitle: 'Add or remove questions for this block',
                onTap: () => Navigator.push(
                  ctx,
                  MaterialPageRoute(
                      builder: (_) => ManageQuestionsScreen(block: widget.block)),
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Divider(),
            SwitchListTile(
              title: const Text('Daily Reminder',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(
                  _blockNotifEnabled
                      ? 'You will be reminded to fill this block'
                      : 'No reminder for this block',
                  style: const TextStyle(fontSize: 12)),
              value: _blockNotifEnabled,
              activeColor: AppColors.primary,
              onChanged: _toggleBlockNotif,
            ),
          ],
        ),
      ),
    );
  }

  Widget _option(BuildContext ctx,
      {required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
