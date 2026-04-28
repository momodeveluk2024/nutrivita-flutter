import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/models/food.dart';
import '../core/models/food_log.dart';
import '../core/models/nutrient_reference.dart';
import '../core/providers/food_provider.dart';
import '../core/providers/nutrition_provider.dart';
import '../theme.dart';
import '../widgets.dart';
import 'meal_log_detail.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoodProvider>().loadFavorites();
      context.read<NutritionProvider>().refreshDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final provider = context.watch<FoodProvider>();
    final nutrition = context.watch<NutritionProvider>();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saved',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                    color: c.text,
                  ),
                ),
                Icon(Icons.tune, size: 20, color: c.text),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: c.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: List.generate(3, (i) {
                  final labels = ['Foods', 'Vitamins', 'Meals'];
                  final active = i == _tab;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tab = i),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? c.surface : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: active
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          labels[i],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: active ? c.text : c.textMuted,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await context.read<FoodProvider>().loadFavorites();
                if (context.mounted) {
                  await context.read<NutritionProvider>().refreshDashboard();
                }
              },
              child: _tab == 0
                  ? _FoodsList(foods: provider.favorites)
                  : _tab == 1
                  ? const _NutrientsList()
                  : _MealsList(logs: nutrition.logs),
            ),
          ),
        ],
      ),
    );
  }
}

class _NutrientsList extends StatelessWidget {
  const _NutrientsList();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final groups = <String, List<NutrientReference>>{};
    for (final n in nutrientCatalog) {
      groups.putIfAbsent(n.group.toLowerCase(), () => []).add(n);
    }
    final ordered = ['vitamin', 'mineral', 'macro', 'other']
        .where((g) => groups.containsKey(g))
        .toList();
    for (final g in groups.keys) {
      if (!ordered.contains(g)) ordered.add(g);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      itemCount: ordered.length,
      itemBuilder: (context, gi) {
        final group = ordered[gi];
        final items = groups[group]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (gi > 0) const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 0, 2, 10),
              child: Row(
                children: [
                  Text(
                    _groupTitle(group),
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w800,
                      color: c.textMuted,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: c.border.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    items.length.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: 11,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      fontWeight: FontWeight.w700,
                      color: c.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            ...List.generate(items.length, (i) {
              final n = items[i];
              return Padding(
                padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 8),
                child: _VitaminTile(
                  nutrient: n,
                  onTap: () => context.push('/app/vitamin/${n.code}'),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  String _groupTitle(String group) {
    switch (group) {
      case 'vitamin':
        return 'VITAMINS';
      case 'mineral':
        return 'MINERALS';
      case 'macro':
        return 'MACROS';
      default:
        return group.toUpperCase();
    }
  }
}

/// Modern vitamin tile — color-coded badge, eyebrow group, big name,
/// one-line summary, tabular daily target on the right. No chevron;
/// the whole card is tappable. Replaces the old cramped row layout.
class _VitaminTile extends StatelessWidget {
  const _VitaminTile({required this.nutrient, required this.onTap});

  final NutrientReference nutrient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final hue = vitaminColors[nutrient.code] ?? vitaminColors['D']!;
    final tintBg = dark
        ? hue.fill.withValues(alpha: 0.14)
        : hue.fill.withValues(alpha: 0.06);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: c.border.withValues(alpha: 0.5)),
            boxShadow: dark
                ? null
                : [
                    BoxShadow(
                      color: hue.fill.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      hue.fill.withValues(alpha: dark ? 0.28 : 0.16),
                      tintBg,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hue.fill.withValues(alpha: 0.18),
                  ),
                ),
                child: Text(
                  nutrient.code,
                  style: TextStyle(
                    fontSize: nutrient.code.length >= 3 ? 14 : 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: hue.fill,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nutrient.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: c.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      nutrient.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.35,
                        color: c.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (nutrient.dailyTarget > 0) ...[
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      nutrient.targetLabel,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: c.text,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'DAILY',
                      style: TextStyle(
                        fontSize: 9.5,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w700,
                        color: c.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MealsList extends StatelessWidget {
  const _MealsList({required this.logs});

  final List<MealLog> logs;

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        children: const [
          _EmptyState(
            title: 'No meals logged today',
            subtitle: 'Open a food and log it to see recent meals here.',
          ),
        ],
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      itemCount: logs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _SavedMeal(log: logs[index]),
    );
  }
}

class _SavedMeal extends StatelessWidget {
  const _SavedMeal({required this.log});

  final MealLog log;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final items = log.items
        .map((item) => '${item.foodName} (${item.servingG.round()}g)')
        .join(', ');
    final firstItem = log.items.isEmpty ? null : log.items.first;
    return NVCard(
      onTap: () => showMealLogDetails(
        context,
        log,
        date: DateTime.tryParse(log.loggedOn),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          FoodPhoto(
            label: firstItem?.foodName ?? log.mealType,
            imageUrl: firstItem?.imageUrl,
            width: 48,
            height: 48,
            radius: 15,
            tone: 'cool',
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.mealType,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: c.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  items.isEmpty ? 'No items attached' : items,
                  maxLines: 2,
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
}

class _FoodsList extends StatelessWidget {
  const _FoodsList({required this.foods});

  final List<FoodSummary> foods;

  @override
  Widget build(BuildContext context) {
    if (foods.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        children: const [
          _EmptyState(
            title: 'No saved foods yet',
            subtitle: 'Tap the heart on a food to save it here.',
          ),
        ],
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      itemCount: foods.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final food = foods[i];
        return _FavoriteFood(food: food);
      },
    );
  }
}

class _FavoriteFood extends StatelessWidget {
  const _FavoriteFood({required this.food});

  final FoodSummary food;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return NVCard(
      padding: const EdgeInsets.all(12),
      onTap: () => context.push('/app/food/${food.id}'),
      child: Row(
        children: [
          FoodPhoto(
            label: food.name,
            imageUrl: food.imageUrl,
            height: 52,
            width: 52,
            radius: 12,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: c.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  food.category,
                  style: TextStyle(fontSize: 11, color: c.textMuted),
                ),
                const SizedBox(height: 6),
                Row(
                  children: food.nutrients
                      .take(4)
                      .map(
                        (v) => Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: VitaminChip(code: v, size: 18),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.favorite, size: 18, color: NV.accent),
            onPressed: () =>
                context.read<FoodProvider>().removeFavorite(food.id),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return NVCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Icon(Icons.favorite_outline, color: c.textMuted),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: c.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: c.textMuted),
          ),
        ],
      ),
    );
  }
}
