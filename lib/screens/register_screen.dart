import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_form.dart';
import 'onboarding_screen.dart'; // Phase 3

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext ctx) {
    return AuthForm(
      title: 'Create Account',
      submitLabel: 'Create Account',
      onSubmit: (email, pass) async {
        final err = await ctx.read<AuthProvider>().register(email, pass);
        if (err == null && ctx.mounted) {
          // New users go to onboarding, not main
          Navigator.of(ctx).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                (_) => false,
          );
        }
        return err;
      },
      switchLabel: 'Already have an account? Log In',
      onSwitch: () => Navigator.pop(ctx),
    );
  }
}