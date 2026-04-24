import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';

class FoodDetailScreen extends StatelessWidget {
  const FoodDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);

    final vitamins = [
      ['D', 1.40],
      ['B12', 1.20],
      ['B6', 0.48],
      ['C', 0.08],
      ['Fe', 0.18],
      ['Mg', 0.24],
    ];

    final macros = [
      ['175', 'cal'],
      ['19g', 'protein'],
      ['11g', 'fat'],
      ['0g', 'carb'],
    ];

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        children: [
          Stack(
            children: [
              const PhotoPlaceholder(
                  label: 'salmon fillet', height: 260, radius: 0, tone: 'warm'),
              Positioned(
                top: MediaQuery.of(context).padding.top + 14,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    NVCircleIconButton(
                      icon: Icons.chevron_left,
                      background: Colors.white.withValues(alpha: 0.85),
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    NVCircleIconButton(
                      icon: Icons.favorite_outline,
                      background: Colors.white.withValues(alpha: 0.85),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text('SEAFOOD',
                    style: TextStyle(
                        fontSize: 12,
                        color: c.textMuted,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text('Salmon, Atlantic',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6,
                        color: c.text)),
                const SizedBox(height: 4),
                Text('Cooked, dry heat · 3 oz (85g)',
                    style: TextStyle(fontSize: 13, color: c.textMuted)),
                const SizedBox(height: 14),
                NVCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: macros
                        .map((m) => Column(
                              children: [
                                Text(m[0],
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: c.text,
                                        fontFeatures: const [FontFeature.tabularFigures()])),
                                const SizedBox(height: 2),
                                Text(m[1].toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: c.textMuted,
                                        letterSpacing: 0.5)),
                              ],
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 10),
                  child: Text('Vitamin breakdown',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: c.text)),
                ),
                NVCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: vitamins.map((v) {
                      final code = v[0] as String;
                      final pct = v[1] as double;
                      final hue = vitaminColors[code]!;
                      final label = ['Fe', 'Zn', 'Mg', 'Ca'].contains(code) ? code : 'Vit $code';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            VitaminChip(code: code, size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(label,
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: c.text,
                                              fontWeight: FontWeight.w500)),
                                      Text('${(pct * 100).round()}%',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: pct >= 1 ? hue.fill : c.textMuted,
                                            fontFeatures: const [FontFeature.tabularFigures()],
                                          )),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  BarProgress(pct: pct.clamp(0.0, 1.0), color: hue.fill),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Text('% of your daily recommended intake',
                      style: TextStyle(fontSize: 11, color: c.textMuted)),
                ),
                const SizedBox(height: 16),
                NVPrimaryButton(
                  label: 'Log this food',
                  leadingIcon: Icons.add,
                  radius: 27,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
