import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/models/food.dart';
import '../core/providers/food_provider.dart';
import '../core/providers/nutrition_provider.dart';
import '../theme.dart';
import '../widgets.dart';

class FoodDetailScreen extends StatefulWidget {
  const FoodDetailScreen({super.key, this.foodId});

  final String? foodId;

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  late Future<FoodDetail> _future;

  @override
  void initState() {
    super.initState();
    final foodId = widget.foodId ?? '018f0000-0000-7000-8002-000000000001';
    final provider = context.read<FoodProvider>();
    _future = Future.microtask(() {
      provider.loadFavorites();
      return provider.getFood(foodId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);

    return Scaffold(
      backgroundColor: c.bg,
      body: FutureBuilder<FoodDetail>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: NV.accent),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: NVCard(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    'Could not load food: ${snapshot.error}',
                    style: TextStyle(color: c.textMuted),
                  ),
                ),
              ),
            );
          }
          final food = snapshot.data!;
          return _FoodDetailBody(food: food);
        },
      ),
    );
  }
}

class _FoodDetailBody extends StatelessWidget {
  const _FoodDetailBody({required this.food});

  final FoodDetail food;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final provider = context.watch<FoodProvider>();
    final isFavorite = provider.isFavorite(food.id);
    final isReferenceProfile = food.source.contains('percent Daily Value');
    final canLog = food.breakdown.any((nutrient) => nutrient.amountPer100G > 0);

    return Column(
      children: [
        Stack(
          children: [
            FoodPhoto(
              label: food.name,
              imageUrl: food.imageUrl,
              height: 260,
              radius: 0,
              tone: 'warm',
            ),
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
                    icon: isFavorite ? Icons.favorite : Icons.favorite_outline,
                    background: Colors.white.withValues(alpha: 0.85),
                    onTap: () {
                      if (isFavorite) {
                        context.read<FoodProvider>().removeFavorite(food.id);
                      } else {
                        context.read<FoodProvider>().addFavorite(food.id);
                      }
                    },
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
              Text(
                food.category.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  color: c.textMuted,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                food.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                  color: c.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isReferenceProfile
                    ? food.source
                    : '${food.source} - ${food.servingSizeG.toStringAsFixed(0)}g serving',
                style: TextStyle(fontSize: 13, color: c.textMuted),
              ),
              const SizedBox(height: 14),
              NVCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Metric(
                      value: food.servingSizeG.toStringAsFixed(0),
                      label: 'grams',
                    ),
                    _Metric(
                      value: '${food.breakdown.length}',
                      label: 'nutrients',
                    ),
                    _Metric(
                      value: food.verified ? 'Yes' : 'No',
                      label: 'verified',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 10),
                child: Text(
                  'Nutrient breakdown',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: c.text,
                  ),
                ),
              ),
              NVCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: food.breakdown.map((nutrient) {
                    final code = nutrient.code;
                    final pct = (nutrient.driPercent ?? 0) / 100;
                    final hue = vitaminColors[code] ?? vitaminColors['D']!;
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      nutrient.name,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: c.text,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      nutrient.driPercent == null
                                          ? '-'
                                          : '${nutrient.driPercent!.round()}%',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: pct >= 1
                                            ? hue.fill
                                            : c.textMuted,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                BarProgress(
                                  pct: pct.clamp(0.0, 1.0),
                                  color: hue.fill,
                                ),
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
                child: Text(
                  isReferenceProfile
                      ? '% Daily Value from imported source profile'
                      : '% of your daily recommended intake per 100g',
                  style: TextStyle(fontSize: 11, color: c.textMuted),
                ),
              ),
              if (isReferenceProfile)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Text(
                    'This imported VitaminFinder profile is stored as percent Daily Value for source browsing.',
                    style: TextStyle(fontSize: 11, color: c.textMuted),
                  ),
                ),
              if (!canLog)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Text(
                    'Logging is limited until raw USDA nutrient amounts are added for this food.',
                    style: TextStyle(fontSize: 11, color: c.textMuted),
                  ),
                ),
              const SizedBox(height: 16),
              NVPrimaryButton(
                label: canLog ? 'Log this food' : 'Reference profile only',
                leadingIcon: canLog ? Icons.add : Icons.info_outline,
                radius: 27,
                onPressed: canLog
                    ? () => _showLogSheet(context, food)
                    : () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Raw USDA amounts are needed before logging this food.',
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  void _showLogSheet(BuildContext context, FoodDetail food) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => _LogFoodSheet(food: food),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: c.text,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            color: c.textMuted,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _LogFoodSheet extends StatefulWidget {
  const _LogFoodSheet({required this.food});

  final FoodDetail food;

  @override
  State<_LogFoodSheet> createState() => _LogFoodSheetState();
}

class _LogFoodSheetState extends State<_LogFoodSheet> {
  String _mealType = 'breakfast';
  double _servingG = 100;
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await context.read<NutritionProvider>().createLog(
        foodId: widget.food.id,
        servingG: _servingG,
        mealType: _mealType,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logged ${widget.food.name}')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Log ${widget.food.name}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: c.text,
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _mealType,
              decoration: const InputDecoration(labelText: 'Meal'),
              items: const [
                DropdownMenuItem(value: 'breakfast', child: Text('Breakfast')),
                DropdownMenuItem(value: 'lunch', child: Text('Lunch')),
                DropdownMenuItem(value: 'snack', child: Text('Snack')),
                DropdownMenuItem(value: 'dinner', child: Text('Dinner')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (value) =>
                  setState(() => _mealType = value ?? 'breakfast'),
            ),
            const SizedBox(height: 12),
            Text(
              'Serving: ${_servingG.round()}g',
              style: TextStyle(color: c.text),
            ),
            Slider(
              value: _servingG,
              min: 10,
              max: 500,
              divisions: 49,
              label: '${_servingG.round()}g',
              onChanged: (value) => setState(() => _servingG = value),
            ),
            const SizedBox(height: 12),
            NVPrimaryButton(
              label: _saving ? 'Logging...' : 'Log food',
              radius: 24,
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
