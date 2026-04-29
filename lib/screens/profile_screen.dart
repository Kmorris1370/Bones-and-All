import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../api/profile_api.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';
import 'landing_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  final _nameCtrl = TextEditingController();
  bool _saving = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ProfileApi.getProfile();
    setState(() {
      _profile = data;
      _nameCtrl.text = data['display_name'] ?? '';
      _loading = false;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await ProfileApi.updateProfile(displayName: _nameCtrl.text.trim());
    setState(() => _saving = false);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')));
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'This will permanently delete your account and all your data. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    await ProfileApi.deleteAccount();
    if (mounted) {
      await context.read<AuthProvider>().logout();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LandingScreen()),
            (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext ctx) {
    final name = _profile?['display_name'] ?? 'U';
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Profile'),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: AppColors.primary,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : null,
                    child: _imageFile == null
                        ? Text(initial,
                        style: const TextStyle(fontSize: 36, color: Colors.white))
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text('Tap to change photo',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Display Name'),
          ),
          const SizedBox(height: 8),
          Text(_profile?['email'] ?? '', style: const TextStyle(color: Colors.grey)),
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
                : const Text('Save Changes'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () async {
              await ctx.read<AuthProvider>().logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LandingScreen()),
                      (_) => false,
                );
              }
            },
            child: const Text('Log Out'),
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: _deleteAccount,
            child: const Text('Delete Account',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
