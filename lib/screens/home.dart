import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import 'vitamin_detail.dart';
import 'food_detail.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Friday, Apr 24',
                          style: TextStyle(fontSize: 13, color: c.textMuted, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text('Morning, Amelia',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.6,
                              color: c.text)),
                    ],
                  ),
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: c.surfaceMuted,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.notifications_outlined, size: 18, color: c.text),
                    ),
                    Positioned(
                      top: 10,
                      right: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: NV.accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: c.surface, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              children: [
                _TodayIntakeCard(onViewAll: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const VitaminDetailScreen()));
                }),
                const SizedBox(height: 16),
                _ForYouHero(),
                const SizedBox(height: 16),
                _QuickActions(),
                const SizedBox(height: 16),
                _VitaminSpotlight(),
                const SizedBox(height: 16),
                _MealIdeas(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayIntakeCard extends StatelessWidget {
  final VoidCallback? onViewAll;
  const _TodayIntakeCard({this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final bars = [
      ['Vitamin C', 0.92, 'C'],
      ['Iron', 0.55, 'Fe'],
      ['Vitamin D', 0.35, 'D'],
    ];

    return NVCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionLabel('Today’s intake'),
              GestureDetector(
                onTap: onViewAll,
                child: const Text('View all',
                    style: TextStyle(fontSize: 12, color: NV.accent, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const RingProgress(pct: 0.78, size: 92, label: '78%', sub: 'of daily goal'),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: bars.map((b) {
                    final name = b[0] as String;
                    final pct = b[1] as double;
                    final key = b[2] as String;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(name,
                                  style: TextStyle(
                                      fontSize: 12, color: c.text, fontWeight: FontWeight.w500)),
                              Text('${(pct * 100).round()}%',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: c.textMuted,
                                      fontFeatures: const [FontFeature.tabularFigures()])),
                            ],
                          ),
                          const SizedBox(height: 4),
                          BarProgress(pct: pct, color: vitaminColors[key]!.fill),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ForYouHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('For you',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: c.text)),
              Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 12, color: NV.accent),
                  const SizedBox(width: 4),
                  Text('Personalized', style: TextStyle(fontSize: 12, color: c.textMuted)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: NV.accent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YOU’RE LOW ON VITAMIN D',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Try salmon or fortified oats today',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  height: 1.3,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '3 days below target. A 3-oz salmon fillet covers 140% of your daily needs.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.85),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _pill(context, 'See foods', Colors.white, NV.accent),
                  const SizedBox(width: 8),
                  _pill(context, 'Remind me', Colors.white.withValues(alpha: 0.18), Colors.white),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pill(BuildContext context, String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100)),
      child: Text(label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final actions = [
      ['Scan food', Icons.camera_alt_outlined],
      ['Log meal', Icons.add],
    ];

    return Row(
      children: actions.map((a) {
        final label = a[0] as String;
        final icon = a[1] as IconData;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: label == 'Scan food' ? 10 : 0),
            child: NVCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: dark ? NV.accent.withValues(alpha: 0.2) : NV.accentSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 18, color: NV.accent),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(label,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600, color: c.text)),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _VitaminSpotlight extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final vits = [
      ['C', 'Vitamin C', 'Immunity'],
      ['D', 'Vitamin D', 'Bones'],
      ['B12', 'Vitamin B12', 'Energy'],
      ['Fe', 'Iron', 'Oxygen'],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Vitamin spotlight',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: c.text)),
              const Text('All',
                  style: TextStyle(fontSize: 12, color: NV.accent, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: vits.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final v = vits[i];
              return SizedBox(
                width: 130,
                child: NVCard(
                  padding: const EdgeInsets.all(14),
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const VitaminDetailScreen())),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VitaminChip(code: v[0], size: 40),
                      const SizedBox(height: 10),
                      Text(v[1],
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700, color: c.text)),
                      const SizedBox(height: 2),
                      Text(v[2], style: TextStyle(fontSize: 11, color: c.textMuted)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MealIdeas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Meal ideas',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: c.text)),
              const Text('More',
                  style: TextStyle(fontSize: 12, color: NV.accent, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        NVCard(
          padding: EdgeInsets.zero,
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const FoodDetailScreen())),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PhotoPlaceholder(
                    label: 'bowl · spinach + citrus',
                    height: 140,
                    radius: 0,
                    tone: 'cool'),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Citrus-spinach power bowl',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              color: c.text)),
                      const SizedBox(height: 4),
                      Text('Rich in Vitamin C, Folate, and Iron',
                          style: TextStyle(fontSize: 12, color: c.textMuted)),
                      const SizedBox(height: 10),
                      Row(
                        children: const [
                          VitaminChip(code: 'C', size: 24),
                          SizedBox(width: 6),
                          VitaminChip(code: 'B9', size: 24),
                          SizedBox(width: 6),
                          VitaminChip(code: 'Fe', size: 24),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
