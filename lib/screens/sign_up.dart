import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/providers/auth_provider.dart';
import '../theme.dart';
import '../widgets.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    _password.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  double get _passwordStrength {
    final password = _password.text;
    var strength = 0.0;
    if (password.length >= 8) strength += 0.25;
    if (password.contains(RegExp('[A-Z]'))) strength += 0.25;
    if (password.contains(RegExp('[0-9]'))) strength += 0.25;
    if (password.contains(RegExp(r'[!@#$%^&*]'))) strength += 0.25;
    return strength;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await context.read<AuthProvider>().signup(
        displayName: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created. Verify your email when ready.'),
        ),
      );
      context.go('/verify-email');
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
    final pwPct = _passwordStrength;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                  'Create account',
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
                  'Get personalized nutrition tailored to you.',
                  style: TextStyle(
                    fontSize: 15,
                    color: c.textMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                _Field(
                  controller: _name,
                  label: 'Full name',
                  validator: (value) =>
                      (value ?? '').trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 14),
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
                    if ((value ?? '').length < 8) {
                      return 'Use at least 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(4, (i) {
                    final filled = i < (pwPct * 4).round();
                    Color color;
                    if (!filled) {
                      color = c.border;
                    } else if (pwPct > 0.75) {
                      color = NV.ok;
                    } else if (pwPct > 0.4) {
                      color = NV.warn;
                    } else {
                      color = NV.err;
                    }
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i == 3 ? 0 : 4),
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 2),
                  child: Text(
                    'Use 8+ characters with a number for a stronger password',
                    style: TextStyle(fontSize: 11, color: c.textMuted),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(top: 1),
                      decoration: BoxDecoration(
                        color: NV.accent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text:
                              'I agree to NutriVita Terms and Privacy Policy.',
                          style: TextStyle(
                            fontSize: 12,
                            color: c.textMuted,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                NVPrimaryButton(
                  label: auth.isLoading ? 'Creating...' : 'Create account',
                  radius: 28,
                  onPressed: auth.isLoading ? null : _submit,
                ),
                const SizedBox(height: 20),
                Row(
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
                ),
                const SizedBox(height: 20),
                _Social('apple'),
                const SizedBox(height: 10),
                _Social('google'),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () => context.go('/sign-in'),
                    child: Text.rich(
                      TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(fontSize: 13, color: c.textMuted),
                        children: const [
                          TextSpan(
                            text: 'Sign in',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    this.obscure = false,
    this.keyboardType,
    this.validator,
  });

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

class _Social extends StatelessWidget {
  final String provider;
  const _Social(this.provider);

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
