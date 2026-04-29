import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_form.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext ctx) {
    return AuthForm(
      title: 'Log In',
      submitLabel: 'Log In',
      showForgotPassword: true,
      onSubmit: (email, pass) async {
        final err = await ctx.read<AuthProvider>().login(email, pass);
        if (err == null && ctx.mounted) {
          Navigator.of(ctx).popUntil((r) => r.isFirst);
        }
        return err;
      },
      switchLabel: "Don't have an account? Register",
      onSwitch: () => Navigator.pushReplacement(
          ctx, MaterialPageRoute(builder: (_) => const RegisterScreen())),
    );
  }
}