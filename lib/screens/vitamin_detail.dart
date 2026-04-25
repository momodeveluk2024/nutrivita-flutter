import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/models/food.dart';
import '../core/models/nutrient_reference.dart';
import '../core/providers/food_provider.dart';
import '../theme.dart';
import '../widgets.dart';

class VitaminDetailScreen extends StatefulWidget {
  const VitaminDetailScreen({super.key, this.code = 'D'});
  final String code;

  @override
  State<VitaminDetailScreen> createState() => _VitaminDetailScreenState();
}

class _VitaminDetailScreenState extends State<VitaminDetailScreen> {
  late final NutrientReference _nutrient;
  late Future<List<FoodSummary>> _sourcesFuture;

  @override
  void initState() {
    super.initState();
    _nutrient =
        nutrientReferencesByCode[widget.code] ?? nutrientReferencesByCode['D']!;
    final provider = context.read<FoodProvider>();
    _sourcesFuture = provider.searchFoods(nutrient: _nutrient.code, limit: 8);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final hue = vitaminColors[_nutrient.code] ?? vitaminColors['D']!;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: dark ? hue.fill.withValues(alpha: 0.13) : hue.bg,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NVCircleIconButton(
                        icon: Icons.chevron_left,
                        background: c.surface,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      NVCircleIconButton(
                        icon: Icons.search,
                        background: c.surface,
                        onTap: () => context.push('/app/search'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  VitaminChip(code: _nutrient.code, size: 64),
                  const SizedBox(height: 12),
                  Text(
                    _nutrient.name,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: c.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_nutrient.group} - ${_nutrient.summary}',
                    style: TextStyle(
                      fontSize: 14,
                      color: c.textMuted,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _DailyTargetCard(nutrient: _nutrient, hue: hue),
                  const SizedBox(height: 14),
                  _BenefitsCard(nutrient: _nutrient, hue: hue),
                  const SizedBox(height: 14),
                  _TopSources(
                    nutrient: _nutrient,
                    hue: hue,
                    sourcesFuture: _sourcesFuture,
                  ),
                  const SizedBox(height: 14),
                  _LowIntakeCard(nutrient: _nutrient),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyTargetCard extends StatelessWidget {
  const _DailyTargetCard({required this.nutrient, required this.hue});

  final NutrientReference nutrient;
  final VitaminHue hue;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final hasDailyTarget = nutrient.dailyTarget > 0;
    return NVCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          RingProgress(
            pct: hasDailyTarget ? 0.35 : 0,
            size: 72,
            color: hue.fill,
            label: hasDailyTarget ? 'DV' : '-',
            sub: 'adult',
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('Daily target'),
                const SizedBox(height: 2),
                Text(
                  hasDailyTarget ? nutrient.targetLabel : 'No established DV',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: c.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Adult Daily Value reference used for source ranking',
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

class _BenefitsCard extends StatelessWidget {
  const _BenefitsCard({required this.nutrient, required this.hue});

  final NutrientReference nutrient;
  final VitaminHue hue;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return NVCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Why it matters'),
          const SizedBox(height: 10),
          ...nutrient.benefits.map(
            (benefit) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: hue.bg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.check, size: 14, color: hue.fill),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      benefit,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: c.text,
                      ),
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
}

class _TopSources extends StatelessWidget {
  const _TopSources({
    required this.nutrient,
    required this.hue,
    required this.sourcesFuture,
  });

  final NutrientReference nutrient;
  final VitaminHue hue;
  final Future<List<FoodSummary>> sourcesFuture;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Top sources',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: c.text,
            ),
          ),
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<FoodSummary>>(
          future: sourcesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const NVCard(
                padding: EdgeInsets.all(18),
                child: Center(
                  child: CircularProgressIndicator(color: NV.accent),
                ),
              );
            }
            if (snapshot.hasError) {
              return NVCard(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Could not load sources: ${snapshot.error}',
                  style: TextStyle(fontSize: 13, color: c.textMuted),
                ),
              );
            }
            final foods = snapshot.data ?? const <FoodSummary>[];
            if (foods.isEmpty) {
              return NVCard(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No source foods found yet.',
                  style: TextStyle(fontSize: 13, color: c.textMuted),
                ),
              );
            }
            return NVCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: List.generate(foods.length, (i) {
                  final food = foods[i];
                  final pct = (food.driPercent ?? 0) / 100;
                  final isLast = i == foods.length - 1;
                  return InkWell(
                    onTap: () => context.push('/app/food/${food.id}'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: isLast
                            ? null
                            : Border(bottom: BorderSide(color: c.border)),
                      ),
                      child: Row(
                        children: [
                          FoodPhoto(
                            label: food.name,
                            imageUrl: food.imageUrl,
                            height: 42,
                            width: 42,
                            radius: 10,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  food.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: c.text,
                                  ),
                                ),
                                Text(
                                  food.category,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: c.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 72,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                BarProgress(
                                  pct: pct.clamp(0.0, 1.0),
                                  color: hue.fill,
                                  height: 5,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  food.driPercent == null
                                      ? '-'
                                      : '${food.driPercent!.round()}%',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: c.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Source rankings use the extracted percent-Daily-Value profile.',
            style: TextStyle(fontSize: 11, color: c.textMuted),
          ),
        ),
      ],
    );
  }
}

class _LowIntakeCard extends StatelessWidget {
  const _LowIntakeCard({required this.nutrient});

  final NutrientReference nutrient;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return NVCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('If intake is low'),
          const SizedBox(height: 6),
          Text(
            nutrient.lowNote,
            style: TextStyle(fontSize: 14, color: c.text, height: 1.5),
          ),
        ],
      ),
    );
  }
}
