import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import 'app_shell.dart';
import 'sign_in.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    const pwPct = 0.66;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: NVCircleIconButton(
                  icon: Icons.chevron_left,
                  onTap: () => Navigator.of(context).maybePop(),
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
                style: TextStyle(fontSize: 15, color: c.textMuted, height: 1.4),
              ),
              const SizedBox(height: 24),
              _Field(label: 'Full name', value: 'Amelia Chen'),
              const SizedBox(height: 14),
              _Field(label: 'Email', value: 'amelia@example.com'),
              const SizedBox(height: 14),
              _Field(label: 'Password', value: '••••••••', focused: true, obscure: true),
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
                  'Good — use 8+ characters with a number',
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
                    child: const Icon(Icons.check, size: 12, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'I agree to NutriVita’s ',
                        style: TextStyle(fontSize: 12, color: c.textMuted, height: 1.45),
                        children: const [
                          TextSpan(text: 'Terms', style: TextStyle(color: NV.accent, fontWeight: FontWeight.w600)),
                          TextSpan(text: ' and '),
                          TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(color: NV.accent, fontWeight: FontWeight.w600)),
                          TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              NVPrimaryButton(
                label: 'Create account',
                radius: 28,
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const AppShell()),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: Container(height: 1, color: c.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or',
                        style: TextStyle(fontSize: 12, color: c.textMuted, fontWeight: FontWeight.w500)),
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
                  onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                  ),
                  child: Text.rich(
                    TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(fontSize: 13, color: c.textMuted),
                      children: const [
                        TextSpan(
                            text: 'Sign in',
                            style: TextStyle(color: NV.accent, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  final bool focused;
  final bool obscure;
  const _Field({required this.label, required this.value, this.focused = false, this.obscure = false});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(label, style: TextStyle(fontSize: 12, color: c.textMuted, fontWeight: FontWeight.w500)),
        ),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: focused ? NV.accent : c.border, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  obscure && value.isNotEmpty ? '••••••••' : (value.isNotEmpty ? value : label),
                  style: TextStyle(fontSize: 15, color: value.isNotEmpty ? c.text : c.textMuted),
                ),
              ),
              if (focused) Container(width: 1.5, height: 18, color: NV.accent),
            ],
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
    final label = provider == 'apple' ? 'Continue with Apple' : 'Continue with Google';
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
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.text)),
        ],
      ),
    );
  }
}
