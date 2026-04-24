import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import 'app_shell.dart';
import 'sign_up.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Padding(
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
                style: TextStyle(fontSize: 15, color: c.textMuted, height: 1.4),
              ),
              const SizedBox(height: 28),
              _NVField(label: 'Email', value: 'amelia@example.com'),
              const SizedBox(height: 14),
              _NVField(label: 'Password', value: '••••••••', focused: true, obscure: true),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Text('Forgot password?',
                    style: TextStyle(fontSize: 13, color: NV.accent, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 20),
              NVPrimaryButton(
                label: 'Sign in',
                radius: 28,
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const AppShell()),
                ),
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
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    ),
                    child: Text.rich(
                      TextSpan(
                        text: 'Don’t have an account? ',
                        style: TextStyle(fontSize: 13, color: c.textMuted),
                        children: const [
                          TextSpan(
                            text: 'Sign up',
                            style: TextStyle(color: NV.accent, fontWeight: FontWeight.w600),
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
    );
  }
}

class _NVField extends StatelessWidget {
  final String label;
  final String value;
  final bool focused;
  final bool obscure;
  const _NVField({
    required this.label,
    required this.value,
    this.focused = false,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final hasValue = value.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(label,
              style: TextStyle(fontSize: 12, color: c.textMuted, fontWeight: FontWeight.w500)),
        ),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: focused ? NV.accent : c.border,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  obscure && hasValue ? '••••••••' : (hasValue ? value : label),
                  style: TextStyle(
                    fontSize: 15,
                    color: hasValue ? c.text : c.textMuted,
                  ),
                ),
              ),
              if (focused)
                Container(width: 1.5, height: 18, color: NV.accent),
            ],
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
          child: Text('or',
              style: TextStyle(fontSize: 12, color: c.textMuted, fontWeight: FontWeight.w500)),
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
          Text(label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.text)),
        ],
      ),
    );
  }
}
