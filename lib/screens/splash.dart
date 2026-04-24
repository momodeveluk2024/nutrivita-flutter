import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import 'onboarding.dart';
import 'sign_in.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: NV.accent,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: NV.accent.withValues(alpha: 0.25),
                            blurRadius: 32,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.eco, size: 52, color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'NutriVita',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1,
                        color: c.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 260,
                      child: Text(
                        'Find the vitamins in every bite.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: c.textMuted, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              NVPrimaryButton(
                label: 'Get started',
                radius: 32,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 54,
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: c.text,
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  child: const Text('I already have an account'),
                ),
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  text: 'By continuing you agree to our\nTerms and Privacy Policy.',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: c.textMuted, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
