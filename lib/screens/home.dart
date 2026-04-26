import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/models/food_log.dart';
import '../core/providers/auth_provider.dart';
import '../core/providers/nutrition_provider.dart';
import '../theme.dart';
import '../widgets.dart';
import 'meal_log_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() =>
      context.read<NutritionProvider>().refreshDashboard();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final auth = context.watch<AuthProvider>();
    final nutrition = context.watch<NutritionProvider>();
    final now = DateTime.now();
    final pct = ((nutrition.todayTotals?.averagePercent ?? 0) / 100).clamp(
      0.0,
      1.0,
    );

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
                      Text(
                        '${_weekday(now)}, ${_month(now)} ${now.day}',
                        style: TextStyle(
                          fontSize: 13,
                          color: c.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Morning, ${auth.user?.displayName.split(' ').first ?? 'friend'}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.6,
                          color: c.text,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: c.surfaceMuted,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    auth.user?.initials ?? '?',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: c.text,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                children: [
                  NVCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionLabel('Today intake'),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            RingProgress(
                              pct: pct,
                              size: 92,
                              label: '${(pct * 100).round()}%',
                              sub: 'of daily goal',
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                children:
                                    (nutrition.todayTotals?.nutrients
                                                .take(3)
                                                .toList() ??
                                            const [])
                                        .map((n) {
                                          final npct =
                                              ((n.driPercent ?? 0) / 100).clamp(
                                                0.0,
                                                1.0,
                                              );
                                          final hue =
                                              vitaminColors[n.code] ??
                                              vitaminColors['D']!;
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 10,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      n.name,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: c.text,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${(npct * 100).round()}%',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: c.textMuted,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                BarProgress(
                                                  pct: npct,
                                                  color: hue.fill,
                                                ),
                                              ],
                                            ),
                                          );
                                        })
                                        .toList(),
                              ),
                            ),
                          ],
                        ),
                        if ((nutrition.todayTotals?.nutrients.isEmpty ?? true))
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              'Log a food to see today nutrient progress.',
                              style: TextStyle(
                                color: c.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _RecommendationCard(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: NVCard(
                          padding: const EdgeInsets.all(14),
                          onTap: () => context.push('/app/search'),
                          child: _QuickAction(
                            icon: Icons.search,
                            label: 'Find food',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: NVCard(
                          padding: const EdgeInsets.all(14),
                          onTap: () => context.push('/app/search'),
                          child: _QuickAction(
                            icon: Icons.add,
                            label: 'Log meal',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Recent meals',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: c.text,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (nutrition.logs.isEmpty)
                    NVCard(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        'No meals logged yet today.',
                        style: TextStyle(color: c.textMuted),
                      ),
                    )
                  else
                    ...nutrition.logs
                        .take(3)
                        .map(
                          (log) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _RecentMealCard(log: log),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _weekday(DateTime date) => const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ][date.weekday - 1];
  String _month(DateTime date) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][date.month - 1];
}

class _RecentMealCard extends StatelessWidget {
  const _RecentMealCard({required this.log});

  final MealLog log;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final itemText = log.items
        .map((item) => item.foodName)
        .where((name) => name.trim().isNotEmpty)
        .join(', ');
    final firstItem = log.items.isEmpty ? null : log.items.first;
    return NVCard(
      key: ValueKey('recent-meal-${log.id}'),
      onTap: () => showMealLogDetails(
        context,
        log,
        date: DateTime.tryParse(log.loggedOn),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              FoodPhoto(
                label: firstItem?.foodName ?? log.mealType,
                imageUrl: firstItem?.imageUrl,
                width: 42,
                height: 42,
                radius: 13,
                tone: 'cool',
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: dark ? const Color(0xFF123226) : NV.accentSoft,
                    shape: BoxShape.circle,
                    border: Border.all(color: c.surface, width: 2),
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    size: 11,
                    color: NV.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _titleCase(log.mealType),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: c.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  itemText.isEmpty ? 'No food items attached' : itemText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: c.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _titleCase(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _RecommendationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final recommendations = context.watch<NutritionProvider>().recommendations;
    final rec = recommendations.isEmpty ? null : recommendations.first;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NV.accent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rec == null
                ? 'READY WHEN YOU LOG FOOD'
                : 'LOW ON ${rec.name.toUpperCase()}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            rec?.message ??
                'Search the catalog and log a meal to unlock recommendations.',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              height: 1.3,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => rec == null
                ? context.push('/app/search')
                : context.push('/app/food/${rec.foodId}'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Text(
                'See foods',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: NV.accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return Row(
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
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: c.text,
            ),
          ),
        ),
      ],
    );
  }
}
