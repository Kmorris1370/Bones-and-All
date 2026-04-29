import 'package:flutter/material.dart';
import '../theme.dart';

class ManualScreen extends StatelessWidget {
  const ManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Manual & FAQ'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('Getting Started', [
            _item('What is Bones and All?',
                'Bones and All is a chronic condition tracking app that lets you log daily health data through personalized questionnaires. You can track pain, food, or create your own custom tracking sections.'),
           ]),
          _section('Tracking Blocks', [
            _item('What is a block?',
                'A block is a customizable tracking section. Each block represents something you want to track — for example Pain, Food, or a custom topic you create yourself.'),
            _item('How do I add a new block?',
                'On the main page tap "+ add section" at the bottom. You can choose from the Pain or Food templates, or create a fully custom block with your own questions.'),
            _item('How do I rename or delete a block?',
                'On the main page tap the pencil icon next to a block to rename it, or the trash icon to delete it. Deleting a block permanently removes all its records.'),
            _item('How do I reorder my blocks?',
                'Press and hold the drag handle (the two lines on the left of each block) and drag it to your preferred position.'),
            _item('What question types can I add to a custom block?',
                'You can add three types of questions: Text (free response), Scale (a 0-10 slider), and Tags (multi-select chips). When creating a tags question you can define your own tag options.'),
          ]),
          _section('Daily Questionnaire', [
            _item('How do I fill out a questionnaire?',
                'Tap a block on the main page, then tap "Fill Today\'s Questionnaire". Answer each question and optionally add a journal entry at the bottom. Tap Submit when done.'),
            _item('Can I fill out the questionnaire more than once a day?',
                'Submitting a questionnaire on the same day updates your existing entry rather than creating a duplicate.'),
            _item('What is the Pain block questionnaire?',
                'The Pain block has a body map to select the affected area, a characteristics selector to describe the pain type (throbbing, aching, sharp, etc.), and a 0-10 pain scale slider.'),
            _item('What is the journal entry for?',
                'The journal entry is an optional free-text note at the bottom of every questionnaire. Use it to add any extra details about your day that the questions don\'t cover.'),
          ]),
          _section('Records & Data', [
            _item('How do I view my past entries?',
                'Tap a block on the main page, then tap "View Records". Your entries are listed by date — tap any entry to see the full questionnaire responses and journal entry.'),
            _item('How do I view my graphs?',
                'Tap a block on the main page, then tap "View Graphs". You will see a pain trend line chart and a weekly frequency bar chart based on your logged data.'),
            _item('Is my data saved securely?',
                'Yes. All data is stored in a secure PostgreSQL database. Passwords are hashed and never stored in plain text. All API communication uses HTTPS encryption.'),
            _item('What happens if I delete my account?',
                'Deleting your account permanently removes all your data including blocks, questions, logs, questionnaire responses and notification history. This cannot be undone.'),
          ]),
          _section('Notifications', [
            _item('How do I set up daily reminders?',
                'Go to Settings from the side menu and toggle on "Daily Reminder". Set your preferred reminder time. You can also enable reminders per block from the block detail screen.'),
            _item('How do I turn off notifications for a specific block?',
                'Tap the block on the main page, then toggle off "Daily Reminder" at the bottom of the block detail screen.'),
            _item('Why did my notification arrive at the wrong time?',
                'Notification times are currently stored in UTC. If your notification arrived early or late, this is a known issue that will be fixed in a future update.'),
          ]),
          _section('Account & Security', [
            _item('How do I enable fingerprint or PIN login?',
                'Go to Settings from the side menu and toggle on "Biometric / PIN Login". You will be prompted to verify your fingerprint to confirm. After enabling, the app will use biometric authentication when reopened after 15 minutes of inactivity.'),
            _item('How do I change my display name?',
                'Go to Profile from the side menu, update your display name in the text field, and tap "Save Changes".'),
            _item('How do I log out?',
                'Go to Profile from the side menu and tap "Log Out" at the bottom.'),
            _item('How do I delete my account?',
                'Go to Profile from the side menu and tap "Delete Account" at the bottom. You will be asked to confirm before your account and all data are permanently deleted.'),
          ]),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary)),
        ),
        ...items,
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _item(String question, String answer) {
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        title: Text(question,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.primary,
        children: [
          Text(answer, style: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}
