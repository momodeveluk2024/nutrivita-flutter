import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/models/food.dart';
import '../core/providers/food_provider.dart';
import '../theme.dart';
import '../widgets.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoodProvider>().searchFoods(query: 'salmon');
      _controller.text = 'salmon';
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      context.read<FoodProvider>().searchFoods(query: value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final provider = context.watch<FoodProvider>();

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      NVCircleIconButton(
                        icon: Icons.chevron_left,
                        onTap: () => context.pop(),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Search',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.8,
                          color: c.text,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _controller,
                    onChanged: _onChanged,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search foods',
                      prefixIcon: Icon(
                        Icons.search,
                        size: 18,
                        color: c.textMuted,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.close, size: 18, color: c.textMuted),
                        onPressed: () {
                          _controller.clear();
                          _onChanged('');
                        },
                      ),
                      filled: true,
                      fillColor: c.surfaceMuted,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _tab('Foods', true, c),
                      const SizedBox(width: 8),
                      _tab('Vitamins', false, c),
                      const SizedBox(width: 8),
                      _tab('Recipes', false, c),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context.read<FoodProvider>().searchFoods(
                  query: _controller.text.trim(),
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 10, 4, 8),
                      child: SectionLabel(
                        provider.isLoading
                            ? 'Searching'
                            : '${provider.foods.length} results',
                      ),
                    ),
                    if (provider.error != null)
                      _MessageCard(
                        message: provider.error!,
                        icon: Icons.error_outline,
                      )
                    else if (provider.isLoading)
                      const _LoadingList()
                    else if (provider.foods.isEmpty)
                      const _MessageCard(
                        message: 'No foods found',
                        icon: Icons.search_off,
                      )
                    else
                      ...provider.foods.map((food) => _FoodResult(food: food)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tab(String label, bool active, NVColors c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: active ? NV.accent : c.surface,
        borderRadius: BorderRadius.circular(100),
        border: active ? null : Border.all(color: c.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: active ? Colors.white : c.text,
        ),
      ),
    );
  }
}

class _FoodResult extends StatelessWidget {
  const _FoodResult({required this.food});

  final FoodSummary food;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: NVCard(
        padding: const EdgeInsets.all(12),
        onTap: () => context.push('/app/food/${food.id}'),
        child: Row(
          children: [
            FoodPhoto(
              label: food.name,
              imageUrl: food.imageUrl,
              height: 56,
              width: 56,
              radius: 12,
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
                  const SizedBox(height: 2),
                  Text(
                    '${food.category} - ${food.servingSizeG.toStringAsFixed(0)}g serving',
                    style: TextStyle(fontSize: 12, color: c.textMuted),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: food.nutrients
                        .take(4)
                        .map(
                          (h) => Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: VitaminChip(code: h, size: 20),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: c.textMuted),
          ],
        ),
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (_) => const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: PhotoPlaceholder(label: 'loading', height: 76, radius: 16),
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message, required this.icon});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return NVCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Icon(icon, color: c.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: TextStyle(color: c.textMuted)),
          ),
        ],
      ),
    );
  }
}
