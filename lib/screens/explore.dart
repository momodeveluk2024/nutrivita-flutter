import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/models/nutrient_reference.dart';
import '../core/providers/food_provider.dart';
import '../theme.dart';
import '../widgets.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoodProvider>().searchFoods(limit: 100);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final foodProvider = context.watch<FoodProvider>();
    final categories = <String, int>{};
    for (final food in foodProvider.foods) {
      categories.update(food.category, (value) => value + 1, ifAbsent: () => 1);
    }
    final cats = categories.entries.toList();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Explore',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.8,
                          color: c.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${foodProvider.foods.length} foods across ${cats.length} categories',
                        style: TextStyle(fontSize: 14, color: c.textMuted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search, color: c.text),
                  onPressed: () => context.push('/app/search'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 150,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: cats.map((cat) {
                    return _CategoryTile(
                      name: cat.key,
                      count: cat.value,
                      tone: _toneFor(cat.key),
                      onTap: () {
                        context.read<FoodProvider>().searchFoods(
                          category: cat.key,
                        );
                        context.push('/app/search');
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                _NutrientSection(
                  title: 'Vitamins',
                  nutrients: nutrientCatalog
                      .where((n) => n.group == 'vitamin')
                      .toList(),
                ),
                const SizedBox(height: 14),
                _NutrientSection(
                  title: 'Minerals',
                  nutrients: nutrientCatalog
                      .where((n) => n.group == 'mineral')
                      .toList(),
                ),
                const SizedBox(height: 14),
                _NutrientSection(
                  title: 'Macros',
                  nutrients: nutrientCatalog
                      .where((n) => n.group == 'macro')
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _toneFor(String category) {
    return switch (category) {
      'vegetables' => const Color(0xFFCDE1C2),
      'seafood' => const Color(0xFFCDD9E3),
      'dairy' => const Color(0xFFE6ECF0),
      'nuts' => const Color(0xFFE3D6C8),
      'legumes' => const Color(0xFFD4DCC2),
      _ => const Color(0xFFF3D9B5),
    };
  }
}

class _NutrientSection extends StatelessWidget {
  const _NutrientSection({required this.title, required this.nutrients});

  final String title;
  final List<NutrientReference> nutrients;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
          child: SectionLabel(title),
        ),
        NVCard(
          padding: const EdgeInsets.all(14),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: nutrients.map((nutrient) {
              return GestureDetector(
                onTap: () => context.push('/app/vitamin/${nutrient.code}'),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(6, 6, 10, 6),
                  decoration: BoxDecoration(
                    color: c.surfaceMuted,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      VitaminChip(code: nutrient.code, size: 24),
                      const SizedBox(width: 6),
                      Text(
                        nutrient.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: c.text,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String name;
  final int count;
  final Color tone;
  final VoidCallback onTap;
  const _CategoryTile({
    required this.name,
    required this.count,
    required this.tone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: c.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: dark
                        ? [
                            tone.withValues(alpha: 0.13),
                            tone.withValues(alpha: 0.27),
                          ]
                        : [tone, tone.withValues(alpha: 0.87)],
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      bottom: -10,
                      right: -10,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: c.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$count items',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: c.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
