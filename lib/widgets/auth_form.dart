import 'package:flutter/material.dart';
import '../theme.dart';

class AuthForm extends StatefulWidget {
  final String title;
  final String submitLabel;
  final Future<String?> Function(String email, String password) onSubmit;
  final VoidCallback? onSwitch;
  final String? switchLabel;
  final bool showForgotPassword;

  const AuthForm({
    super.key,
    required this.title,
    required this.submitLabel,
    required this.onSubmit,
    this.onSwitch,
    this.switchLabel,
    this.showForgotPassword = false,
  });

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscurePassword = true;

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    final err = await widget.onSubmit(_emailCtrl.text.trim(), _passCtrl.text);
    if (mounted) setState(() { _loading = false; _error = err; });
  }

  void _forgotPassword() {
    showDialog(
      context: context,
      builder: (_) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('Reset Password'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(labelText: 'Enter your email'),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password reset instructions sent if account exists'),
                  ),
                );
              },
              child: const Text('Send', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
              const SizedBox(height: 32),
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passCtrl,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.primary,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                obscureText: _obscurePassword,
              ),
              if (widget.showForgotPassword) ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgotPassword,
                    child: const Text('Forgot Password?',
                        style: TextStyle(color: AppColors.primary)),
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(widget.submitLabel),
                ),
              ),
              if (widget.onSwitch != null) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: widget.onSwitch,
                  child: Text(widget.switchLabel ?? ''),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
