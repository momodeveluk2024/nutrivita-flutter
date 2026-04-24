import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';

class VitaminDetailScreen extends StatelessWidget {
  const VitaminDetailScreen({super.key, this.code = 'D'});
  final String code;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final hue = vitaminColors[code] ?? vitaminColors['D']!;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: dark ? hue.fill.withValues(alpha: 0.13) : hue.bg,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NVCircleIconButton(
                        icon: Icons.chevron_left,
                        background: c.surface,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      NVCircleIconButton(
                        icon: Icons.bookmark_border,
                        background: c.surface,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  VitaminChip(code: code, size: 64),
                  const SizedBox(height: 12),
                  Text('Vitamin $code',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.6,
                          color: c.text)),
                  const SizedBox(height: 4),
                  Text('The sunshine vitamin · Fat-soluble',
                      style: TextStyle(fontSize: 14, color: c.textMuted)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _DailyTargetCard(hue: hue),
                  const SizedBox(height: 14),
                  _BenefitsCard(hue: hue),
                  const SizedBox(height: 14),
                  _TopSources(hue: hue),
                  const SizedBox(height: 14),
                  _DeficiencyCard(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyTargetCard extends StatelessWidget {
  final VitaminHue hue;
  const _DailyTargetCard({required this.hue});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return NVCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          RingProgress(pct: 0.35, size: 72, color: hue.fill, label: '35%', sub: 'today'),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('Daily target'),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    text: '15 ',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: c.text,
                    ),
                    children: [
                      TextSpan(
                          text: 'µg',
                          style: TextStyle(
                              fontSize: 13, color: c.textMuted, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text('Personalized for you · Age 28',
                    style: TextStyle(fontSize: 12, color: c.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitsCard extends StatelessWidget {
  final VitaminHue hue;
  const _BenefitsCard({required this.hue});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final items = [
      ['Bone health', 'Absorbs calcium, strengthens bones'],
      ['Immune support', 'Regulates immune response'],
      ['Mood', 'Linked to serotonin regulation'],
    ];

    return NVCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Benefits'),
          const SizedBox(height: 10),
          ...items.map((b) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                          color: hue.bg, borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.check, size: 14, color: hue.fill),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b[0],
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600, color: c.text)),
                          const SizedBox(height: 1),
                          Text(b[1],
                              style: TextStyle(fontSize: 12, color: c.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _TopSources extends StatelessWidget {
  final VitaminHue hue;
  const _TopSources({required this.hue});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final foods = [
      ['Salmon, Atlantic', 1.40, '21 µg / 3 oz'],
      ['Rainbow trout', 1.20, '18 µg / 3 oz'],
      ['Fortified milk', 0.20, '3 µg / 1 cup'],
      ['Egg yolks', 0.05, '1 µg / 1 large'],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Top sources',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: c.text)),
              Text('See all',
                  style: TextStyle(
                      fontSize: 12, color: hue.fill, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        NVCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: List.generate(foods.length, (i) {
              final f = foods[i];
              final name = f[0] as String;
              final pct = f[1] as double;
              final amt = f[2] as String;
              final isLast = i == foods.length - 1;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : Border(bottom: BorderSide(color: c.border)),
                ),
                child: Row(
                  children: [
                    const PhotoPlaceholder(label: '', height: 40, width: 40, radius: 10),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600, color: c.text)),
                          Text(amt, style: TextStyle(fontSize: 12, color: c.textMuted)),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 64,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          BarProgress(pct: pct.clamp(0.0, 1.0), color: hue.fill, height: 5),
                          const SizedBox(height: 4),
                          Text('${(pct * 100).round()}%',
                              style: TextStyle(
                                fontSize: 10,
                                color: c.textMuted,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _DeficiencyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return NVCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('If you’re low'),
          const SizedBox(height: 6),
          Text(
            'Fatigue, muscle weakness, and frequent colds can signal low Vitamin D. Winter months and limited sun exposure are common causes.',
            style: TextStyle(fontSize: 14, color: c.text, height: 1.5),
          ),
        ],
      ),
    );
  }
}
