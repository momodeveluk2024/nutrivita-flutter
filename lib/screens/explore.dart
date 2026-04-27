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
    final cats =
        categories.entries
            .map((entry) => _CategoryCount(entry.key, entry.value))
            .toList()
          ..sort((a, b) {
            final byCount = b.count.compareTo(a.count);
            if (byCount != 0) return byCount;
            return categoryVisualFor(
              a.name,
            ).label.compareTo(categoryVisualFor(b.name).label);
          });

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
                _NutrientGroupPickers(onSelected: _openNutrientBrowser),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 176,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: cats.map((cat) {
                    return _CategoryTile(
                      name: cat.name,
                      count: cat.count,
                      onTap: () => context.push(
                        '/app/search?category=${Uri.encodeComponent(cat.name)}',
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openNutrientBrowser(_NutrientGroup group) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _NutrientBrowserSheet(group: group),
    );
    if (!mounted || selected == null) return;
    context.push('/app/vitamin/$selected');
  }
}

class _CategoryCount {
  const _CategoryCount(this.name, this.count);

  final String name;
  final int count;
}

enum _NutrientGroup {
  vitamins(
    'Vitamins',
    'vitamin',
    Icons.auto_awesome,
    'Vitamin Suite',
    'Curated essentials for everyday vitality',
    Color(0xFF2F7D4A),
    Color(0xFFEAF5EE),
    Color(0xFF173D2A),
  ),
  minerals(
    'Minerals',
    'mineral',
    Icons.diamond_outlined,
    'Mineral Reserve',
    'Trace elements that keep the body steady',
    Color(0xFF2B7E7A),
    Color(0xFFE8F4F2),
    Color(0xFF123E42),
  ),
  macros(
    'Macros',
    'macro',
    Icons.pie_chart_outline,
    'Macro Balance',
    'The main building blocks for every meal',
    Color(0xFF946B2D),
    Color(0xFFF5EFE3),
    Color(0xFF4A3518),
  );

  const _NutrientGroup(
    this.label,
    this.catalogGroup,
    this.icon,
    this.sheetTitle,
    this.sheetSubtitle,
    this.accent,
    this.soft,
    this.deep,
  );

  final String label;
  final String catalogGroup;
  final IconData icon;
  final String sheetTitle;
  final String sheetSubtitle;
  final Color accent;
  final Color soft;
  final Color deep;

  List<NutrientReference> get nutrients => nutrientCatalog
      .where((nutrient) => nutrient.group == catalogGroup)
      .toList();

  String get countLabel => catalogGroup == 'macro'
      ? '${nutrients.length} foundations'
      : '${nutrients.length} essentials';
}

class _NutrientGroupPickers extends StatelessWidget {
  const _NutrientGroupPickers({required this.onSelected});

  final ValueChanged<_NutrientGroup> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _NutrientGroup.values.map((group) {
        final last = group == _NutrientGroup.values.last;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: last ? 0 : 8),
            child: _NutrientGroupPicker(
              group: group,
              onTap: () => onSelected(group),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _NutrientGroupPicker extends StatelessWidget {
  const _NutrientGroupPicker({required this.group, required this.onTap});

  final _NutrientGroup group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final cardRadius = BorderRadius.circular(24);
    final base = dark ? c.surfaceMuted : c.surface;
    final glow = dark
        ? group.accent.withValues(alpha: 0.22)
        : group.soft.withValues(alpha: 0.88);

    return Material(
      color: Colors.transparent,
      borderRadius: cardRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: cardRadius,
        child: Container(
          height: 98,
          padding: const EdgeInsets.fromLTRB(11, 11, 9, 10),
          decoration: BoxDecoration(
            borderRadius: cardRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                glow,
                base,
                dark ? group.deep.withValues(alpha: 0.18) : Colors.white,
              ],
              stops: const [0, 0.58, 1],
            ),
            border: Border.all(
              color: dark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.white.withValues(alpha: 0.92),
            ),
            boxShadow: [
              BoxShadow(
                color: dark
                    ? Colors.black.withValues(alpha: 0.30)
                    : group.accent.withValues(alpha: 0.10),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: dark
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.white.withValues(alpha: 0.90),
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: dark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.white.withValues(alpha: 0.86),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: group.accent.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Icon(group.icon, size: 17, color: group.accent),
                  ),
                  const Spacer(),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: dark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.white.withValues(alpha: 0.68),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: c.textMuted,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                group.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: c.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                group.countLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: c.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NutrientBrowserSheet extends StatelessWidget {
  const _NutrientBrowserSheet({required this.group});

  final _NutrientGroup group;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.76;
    final count = group.nutrients.length;

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(34),
          border: Border.all(
            color: dark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.white.withValues(alpha: 0.92),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.52 : 0.20),
              blurRadius: 42,
              offset: const Offset(0, 22),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 46,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: dark
                      ? Colors.white.withValues(alpha: 0.18)
                      : const Color(0xFFD7DDD4),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    group.deep,
                    Color.lerp(group.deep, group.accent, 0.50)!,
                    dark
                        ? c.surfaceMuted
                        : Color.lerp(group.soft, Colors.white, 0.20)!,
                  ],
                  stops: const [0, 0.58, 1],
                ),
                border: Border.all(
                  color: dark
                      ? Colors.white.withValues(alpha: 0.09)
                      : Colors.white.withValues(alpha: 0.70),
                ),
                boxShadow: [
                  BoxShadow(
                    color: group.accent.withValues(alpha: dark ? 0.18 : 0.16),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -24,
                    top: -28,
                    child: Icon(
                      group.icon,
                      size: 108,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Icon(group.icon, size: 27, color: Colors.white),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.label.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                                color: Colors.white.withValues(alpha: 0.68),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              group.sheetTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.4,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              group.sheetSubtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                height: 1.25,
                                color: Colors.white.withValues(alpha: 0.76),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  _NutrientSheetSection(
                    title: group.label,
                    nutrients: group.nutrients,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NutrientSheetSection extends StatelessWidget {
  const _NutrientSheetSection({required this.title, required this.nutrients});

  final String title;
  final List<NutrientReference> nutrients;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 0, 6, 12),
          child: SectionLabel(title),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 10.0;
            final useTwoColumns = constraints.maxWidth >= 520;
            final itemWidth = useTwoColumns
                ? (constraints.maxWidth - spacing) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: spacing,
              runSpacing: 10,
              children: nutrients.map((nutrient) {
                return SizedBox(
                  width: itemWidth,
                  child: _LuxuryNutrientChip(
                    nutrient: nutrient,
                    onTap: () => Navigator.of(context).pop(nutrient.code),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _LuxuryNutrientChip extends StatelessWidget {
  const _LuxuryNutrientChip({required this.nutrient, required this.onTap});

  final NutrientReference nutrient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final visual = nutrientVisualFor(nutrient.code);

    return Material(
      key: ValueKey('luxury-nutrient-chip-${nutrient.code}'),
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: 56,
          padding: const EdgeInsets.fromLTRB(8, 8, 10, 8),
          decoration: BoxDecoration(
            color: dark
                ? visual.accent.withValues(alpha: 0.15)
                : visual.accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: visual.accent.withValues(alpha: dark ? 0.18 : 0.13),
            ),
            boxShadow: [
              BoxShadow(
                color: dark
                    ? Colors.black.withValues(alpha: 0.16)
                    : visual.accent.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: dark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: dark ? 0.05 : 0.76),
                  ),
                ),
                child: Icon(visual.icon, size: 18, color: visual.accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  nutrient.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: c.text,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                constraints: const BoxConstraints(minWidth: 28),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                decoration: BoxDecoration(
                  color: dark
                      ? Colors.white.withValues(alpha: 0.07)
                      : Colors.white.withValues(alpha: 0.62),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  nutrient.code,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: visual.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.name,
    required this.count,
    required this.onTap,
  });

  final String name;
  final int count;
  final VoidCallback onTap;

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
