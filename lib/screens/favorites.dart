import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/models/food.dart';
import '../core/providers/food_provider.dart';
import '../theme.dart';
import '../widgets.dart';

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
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final provider = context.watch<FoodProvider>();

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
              onRefresh: () => context.read<FoodProvider>().loadFavorites(),
              child: _tab == 0
                  ? _FoodsList(foods: provider.favorites)
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      children: [
                        _EmptyState(
                          title: _tab == 1
                              ? 'No saved vitamins yet'
                              : 'No saved meals yet',
                          subtitle: _tab == 1
                              ? 'Vitamin saving will be added after the food MVP.'
                              : 'Meal templates will be added after logging is wired.',
                        ),
                      ],
                    ),
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
