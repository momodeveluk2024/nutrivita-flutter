import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/models/visual_catalog.dart';
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
          content: Text('Welcome. Let us tailor things to you.'),
        ),
      );
      context.go('/profile-setup');
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
      body: Stack(
        children: [
          const _AuthHero(category: 'fruit'),
          SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: NVCircleIconButton(
                        icon: Icons.chevron_left,
                        background: Colors.white.withValues(alpha: 0.88),
                        foreground: NV.text,
                        onTap: () => context.go('/'),
                      ),
                    ),
                    const SizedBox(height: 126),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                      decoration: BoxDecoration(
                        color: c.bg.withValues(alpha: dark ? 0.96 : 0.98),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: c.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: dark ? 0.36 : 0.10,
                            ),
                            blurRadius: 34,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'JOIN NUTRIMATE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.2,
                              color: NV.accent,
                            ),
                          ),
                          const SizedBox(height: 10),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.8,
                                height: 1.05,
                                color: c.text,
                              ),
                              children: [
                                const TextSpan(text: 'Create '),
                                TextSpan(
                                  text: 'account.',
                                  style: GoogleFonts.instrumentSerif(
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 36,
                                    letterSpacing: -0.8,
                                    height: 1.05,
                                    color: c.text,
                                  ),
                                ),
                              ],
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
                            icon: Icons.person_outline,
                            validator: (value) => (value ?? '').trim().isEmpty
                                ? 'Name is required'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          _Field(
                            controller: _email,
                            label: 'Email',
                            icon: Icons.mail_outline,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              final text = value?.trim() ?? '';
                              if (text.isEmpty) return 'Email is required';
                              if (!text.contains('@')) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _Field(
                            controller: _password,
                            label: 'Password',
                            icon: Icons.lock_outline,
                            obscure: true,
                            validator: (value) {
                              if ((value ?? '').length < 8) {
                                return 'Use at least 8 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
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
                                  padding: EdgeInsets.only(
                                    right: i == 3 ? 0 : 4,
                                  ),
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
                            padding: const EdgeInsets.only(top: 7, left: 2),
                            child: Text(
                              'Use 8+ characters with a number for a stronger password',
                              style: TextStyle(
                                fontSize: 11,
                                color: c.textMuted,
                              ),
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
                                  borderRadius: BorderRadius.circular(7),
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
                                        'I agree to Nutrimate Terms and Privacy Policy.',
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
                            label: auth.isLoading
                                ? 'Creating...'
                                : 'Create account',
                            radius: 20,
                            onPressed: auth.isLoading ? null : _submit,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Container(height: 1, color: c.border),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  'or',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: c.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(height: 1, color: c.border),
                              ),
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
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: c.textMuted,
                                  ),
                                  children: const [
                                    TextSpan(
                                      text: 'Sign in',
                                      style: TextStyle(
                                        color: NV.accent,
                                        fontWeight: FontWeight.w700,
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
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
            prefixIcon: Icon(icon, size: 19, color: c.textMuted),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: c.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: c.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.18 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
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

class _AuthHero extends StatelessWidget {
  const _AuthHero({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final visual = categoryVisualFor(category);
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            visual.imageUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
            errorBuilder: (context, error, stackTrace) =>
                const ColoredBox(color: Color(0xFF17211C)),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.04),
                  Colors.black.withValues(alpha: 0.32),
                  Colors.black.withValues(alpha: 0.68),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
