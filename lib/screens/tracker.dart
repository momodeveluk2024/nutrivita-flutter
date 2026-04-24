import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';

class TrackerScreen extends StatelessWidget {
  const TrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);

    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final percents = [0.82, 0.65, 0.9, 0.71, 0.78, null, null];
    const todayIndex = 4;

    final meals = [
      ['Breakfast', 'Oatmeal, almonds, blueberries', 380, '☀'],
      ['Lunch', 'Salmon salad, quinoa', 510, '🕛'],
      ['Snack', 'Greek yogurt, honey', 180, '✦'],
      ['Dinner', '', 0, '🌙'],
    ];

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Text('Today',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                    color: c.text)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: Row(
              children: List.generate(7, (i) {
                final isToday = i == todayIndex;
                final pct = percents[i];
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i == 6 ? 0 : 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                      decoration: BoxDecoration(
                        color: isToday ? NV.accent : c.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: isToday ? null : Border.all(color: c.border),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(days[i],
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isToday
                                      ? Colors.white.withValues(alpha: 0.7)
                                      : c.textMuted,
                                  letterSpacing: 0.5)),
                          const SizedBox(height: 6),
                          Text('${20 + i}',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isToday ? Colors.white : c.text)),
                          const SizedBox(height: 6),
                          if (pct != null)
                            Container(
                              width: 18,
                              height: 18,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isToday
                                    ? Colors.white.withValues(alpha: 0.18)
                                    : c.surfaceMuted,
                              ),
                              child: Text('${(pct * 100).round()}',
                                  style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w700,
                                      color: isToday ? Colors.white : c.text)),
                            )
                          else
                            const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              children: [
                NVCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      const RingProgress(pct: 0.78, size: 96, label: '78%', sub: 'of daily goal'),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionLabel('On track'),
                            const SizedBox(height: 4),
                            Text('8 of 12 nutrients hit today',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.2,
                                    height: 1.3,
                                    color: c.text)),
                            const SizedBox(height: 4),
                            Text('Keep going — Vit D and Iron below target',
                                style: TextStyle(fontSize: 12, color: c.textMuted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 10),
                  child: Text('Meals',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: c.text)),
                ),
                ...meals.map((m) {
                  final name = m[0] as String;
                  final items = m[1] as String;
                  final cal = m[2] as int;
                  final icon = m[3] as String;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: NVCard(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: c.surfaceMuted,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(icon, style: const TextStyle(fontSize: 16)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: c.text)),
                                const SizedBox(height: 2),
                                Text(
                                  items.isEmpty ? 'Nothing logged yet' : items,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: c.textMuted,
                                    fontStyle:
                                        items.isEmpty ? FontStyle.italic : FontStyle.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (cal > 0)
                            Text('$cal',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: c.text,
                                    fontFeatures: const [FontFeature.tabularFigures()]))
                          else
                            Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: NV.accentSoft,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add, size: 16, color: NV.accent),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
