import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/models/food.dart';
import '../core/models/nutrient_reference.dart';
import '../core/models/visual_catalog.dart';
import '../core/providers/food_provider.dart';
import '../theme.dart';
import '../widgets.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<FoodSummary> _foods = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCatalog();
    });
  }

  Future<void> _loadCatalog() async {
    setState(() => _loading = true);
    final foods = await context.read<FoodProvider>().fetchFoods(limit: 100);
    if (!mounted) return;
    setState(() {
      _foods = foods;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final categories = <String, int>{};
    for (final food in _foods) {
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
                        _loading
                            ? 'Loading catalog'
                            : '${_foods.length} foods across ${cats.length} categories',
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
                  mainAxisExtent: 176,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: cats.map((cat) {
                    return _CategoryTile(
                      name: cat.key,
                      count: cat.value,
                      onTap: () => context.push(
                        '/app/search?category=${Uri.encodeComponent(cat.key)}',
                      ),
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
}

class _NutrientSection extends StatelessWidget {
  const _NutrientSection({required this.title, required this.nutrients});

  final String title;
  final List<NutrientReference> nutrients;

  @override
  Widget build(BuildContext context) {
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
              return NutrientPill(
                code: nutrient.code,
                label: nutrient.name,
                compact: true,
                onTap: () => context.push('/app/vitamin/${nutrient.code}'),
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
  final VoidCallback onTap;
  const _CategoryTile({
    required this.name,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final visual = categoryVisualFor(name);
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
              SizedBox(
                height: 98,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    FoodPhoto(
                      label: name,
                      imageUrl: visual.imageUrl,
                      height: 98,
                      radius: 0,
                      tone: 'cool',
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.02),
                            visual.accent.withValues(alpha: dark ? 0.30 : 0.16),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.82),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          visual.icon,
                          size: 18,
                          color: visual.accent,
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
                      visual.label,
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
