import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/models/food_log.dart';
import '../core/providers/nutrition_provider.dart';
import '../theme.dart';
import '../widgets.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    final nutrition = context.read<NutritionProvider>();
    await nutrition.refreshDashboard();
    await nutrition.loadWeek();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final nutrition = context.watch<NutritionProvider>();
    final todayPct = ((nutrition.todayTotals?.averagePercent ?? 0) / 100).clamp(0.0, 1.0);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Text(
              'Today',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.8, color: c.text),
            ),
          ),
          _WeekStrip(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                children: [
                  NVCard(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        RingProgress(
                          pct: todayPct,
                          size: 96,
                          label: '${(todayPct * 100).round()}%',
                          sub: 'of daily goal',
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SectionLabel('On track'),
                              const SizedBox(height: 4),
                              Text(
                                '${nutrition.todayTotals?.nutrients.length ?? 0} nutrients logged today',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: -0.2, height: 1.3, color: c.text),
                              ),
                              const SizedBox(height: 4),
                              Text('${nutrition.streak}-day logging streak', style: TextStyle(fontSize: 12, color: c.textMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 10),
                    child: Text('Meals', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: c.text)),
                  ),
                  if (nutrition.logs.isEmpty)
                    NVCard(
                      padding: const EdgeInsets.all(18),
                      child: Text('Nothing logged yet. Open a food and tap Log this food.', style: TextStyle(color: c.textMuted)),
                    )
                  else
                    ...nutrition.logs.map((log) => _MealLogCard(log: log)),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final days = context.watch<NutritionProvider>().weekTotals;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Row(
        children: List.generate(7, (i) {
          final date = DateTime.now().subtract(Duration(days: 6 - i));
          final pct = i < days.length ? (days[i].averagePercent / 100).clamp(0.0, 1.0) : 0.0;
          final isToday = i == 6;
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
                    Text(
                      ['M', 'T', 'W', 'T', 'F', 'S', 'S'][date.weekday - 1],
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isToday ? Colors.white.withValues(alpha: 0.7) : c.textMuted, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 6),
                    Text('${date.day}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isToday ? Colors.white : c.text)),
                    const SizedBox(height: 6),
                    Container(
                      width: 18,
                      height: 18,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: isToday ? Colors.white.withValues(alpha: 0.18) : c.surfaceMuted),
                      child: Text('${(pct * 100).round()}', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: isToday ? Colors.white : c.text)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _MealLogCard extends StatelessWidget {
  const _MealLogCard({required this.log});

  final MealLog log;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final items = log.items.map((item) => '${item.foodName} (${item.servingG.round()}g)').join(', ');
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
              decoration: BoxDecoration(color: c.surfaceMuted, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.restaurant, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(log.mealType, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.text)),
                  const SizedBox(height: 2),
                  Text(items.isEmpty ? 'Nothing logged yet' : items, style: TextStyle(fontSize: 12, color: c.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
