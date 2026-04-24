import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import 'sign_up.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _slide = 0;

  static const _slides = <_Slide>[
    _Slide(
      title: 'Know what you’re eating',
      body: 'See the full vitamin and mineral breakdown for 12,000+ foods — down to the micro-gram.',
      illo: _Illo.vitaminGrid,
    ),
    _Slide(
      title: 'Built around you',
      body: 'Tell us a little about yourself and we’ll tailor daily targets to your age, sex, and goals.',
      illo: _Illo.profile,
    ),
    _Slide(
      title: 'Track without the hassle',
      body: 'A gentle daily log — no calorie counting, just the nutrients that matter most.',
      illo: _Illo.rings,
    ),
  ];

  void _next() {
    if (_slide < _slides.length - 1) {
      setState(() => _slide++);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SignUpScreen()),
      );
    }
  }

  void _skip() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final s = _slides[_slide];

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: _skip,
                    child: Text(
                      'Skip',
                      style: TextStyle(fontSize: 14, color: c.textMuted, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Center(child: _buildIllo(s.illo, dark)),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: Column(
                  children: [
                    Text(
                      s.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6,
                        height: 1.2,
                        color: c.text,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      s.body,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: c.textMuted, height: 1.5),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_slides.length, (i) {
                      final active = i == _slide;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: active ? 22 : 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: active ? NV.accent : (dark ? NV.borderDark : const Color(0xFFD5DACD)),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                  NVPrimaryButton(
                    label: 'Next',
                    width: 140,
                    height: 52,
                    radius: 26,
                    trailingIcon: Icons.chevron_right,
                    onPressed: _next,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIllo(_Illo kind, bool dark) {
    final c = NVColors(dark);
    switch (kind) {
      case _Illo.vitaminGrid:
        return Container(
          width: 260,
          height: 260,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: dark
                    ? Colors.black.withValues(alpha: 0.4)
                    : const Color(0xFF0F1E14).withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            physics: const NeverScrollableScrollPhysics(),
            children: const ['A', 'C', 'D', 'E', 'K', 'B6', 'B12', 'B9', 'Fe']
                .map((k) => Center(child: VitaminChip(code: k, size: 56)))
                .toList(),
          ),
        );
      case _Illo.profile:
        final rows = [['Age', '28'], ['Sex', 'Female'], ['Goal', 'Immunity']];
        return SizedBox(
          width: 260,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: rows.map((r) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: NVCard(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(r[0], style: TextStyle(color: c.textMuted, fontSize: 14)),
                      Text(r[1],
                          style: TextStyle(color: c.text, fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      case _Illo.rings:
        final bars = [
          ['Vit C', 0.92, vitaminColors['C']!.fill],
          ['Iron', 0.55, vitaminColors['Fe']!.fill],
          ['Vit D', 0.35, vitaminColors['D']!.fill],
        ];
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const RingProgress(pct: 0.78, size: 92, label: '78%', sub: 'Today'),
            const SizedBox(width: 18),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: bars.map((b) {
                final name = b[0] as String;
                final pct = b[1] as double;
                final color = b[2] as Color;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SizedBox(
                    width: 140,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(name, style: TextStyle(fontSize: 11, color: c.textMuted)),
                            Text('${(pct * 100).round()}%',
                                style: TextStyle(fontSize: 11, color: c.textMuted)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        BarProgress(pct: pct, color: color),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
    }
  }
}

enum _Illo { vitaminGrid, profile, rings }

class _Slide {
  final String title;
  final String body;
  final _Illo illo;
  const _Slide({required this.title, required this.body, required this.illo});
}
