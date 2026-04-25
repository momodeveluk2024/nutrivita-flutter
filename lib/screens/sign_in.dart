import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/providers/auth_provider.dart';
import '../theme.dart';
import '../widgets.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await context.read<AuthProvider>().login(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (mounted) context.go('/app');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: NVCircleIconButton(
                    icon: Icons.chevron_left,
                    onTap: () => context.go('/'),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                    height: 1.15,
                    color: c.text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to keep tracking your nutrition.',
                  style: TextStyle(
                    fontSize: 15,
                    color: c.textMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                _Field(
                  controller: _email,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return 'Email is required';
                    if (!text.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _Field(
                  controller: _password,
                  label: 'Password',
                  obscure: true,
                  validator: (value) {
                    if ((value ?? '').isEmpty) return 'Password is required';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: auth.isLoading
                        ? null
                        : () => context.go('/forgot-password'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontSize: 13,
                        color: NV.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                NVPrimaryButton(
                  label: auth.isLoading ? 'Signing in...' : 'Sign in',
                  radius: 28,
                  onPressed: auth.isLoading ? null : _submit,
                ),
                const SizedBox(height: 24),
                _Divider(c: c),
                const SizedBox(height: 24),
                _SocialButton(provider: 'apple'),
                const SizedBox(height: 10),
                _SocialButton(provider: 'google'),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Center(
                    child: GestureDetector(
                      onTap: () => context.go('/sign-up'),
                      child: Text.rich(
                        TextSpan(
                          text: 'Do not have an account? ',
                          style: TextStyle(fontSize: 13, color: c.textMuted),
                          children: const [
                            TextSpan(
                              text: 'Sign up',
                              style: TextStyle(
                                color: NV.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.obscure = false,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: c.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: c.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: c.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: c.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: NV.accent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  final NVColors c;
  const _Divider({required this.c});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: c.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or',
            style: TextStyle(
              fontSize: 12,
              color: c.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: c.border)),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String provider;
  const _SocialButton({required this.provider});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final label = provider == 'apple'
        ? 'Continue with Apple'
        : 'Continue with Google';
    final icon = provider == 'apple' ? Icons.apple : Icons.g_mobiledata;
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: dark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: provider == 'google' ? 28 : 18, color: c.text),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: c.text,
            ),
          ),
        ],
      ),
    );
  }
}
