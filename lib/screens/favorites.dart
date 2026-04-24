import 'package:flutter/material.dart';
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
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);

    final foods = [
      ['Salmon, Atlantic', 'Seafood · added 2d ago', ['D', 'B12']],
      ['Spinach, raw', 'Vegetables · added 5d ago', ['K', 'B9', 'A']],
      ['Greek yogurt', 'Dairy · added 1w ago', ['Ca', 'B12']],
      ['Almonds, dry roast', 'Nuts · added 2w ago', ['E', 'Mg']],
      ['Sweet potato, baked', 'Vegetables · added 3w ago', ['A', 'C']],
      ['Lentils, cooked', 'Legumes · added 1mo ago', ['B9', 'Fe']],
    ];

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Saved',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                        color: c.text)),
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
                                      offset: const Offset(0, 1))
                                ]
                              : null,
                        ),
                        child: Text(labels[i],
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: active ? c.text : c.textMuted)),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              itemCount: foods.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final f = foods[i];
                final name = f[0] as String;
                final sub = f[1] as String;
                final vs = f[2] as List<String>;
                return NVCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const PhotoPlaceholder(label: '', height: 52, width: 52, radius: 12),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600, color: c.text)),
                            const SizedBox(height: 2),
                            Text(sub, style: TextStyle(fontSize: 11, color: c.textMuted)),
                            const SizedBox(height: 6),
                            Row(
                              children: vs
                                  .map((v) => Padding(
                                        padding: const EdgeInsets.only(right: 4),
                                        child: VitaminChip(code: v, size: 18),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.favorite, size: 18, color: NV.accent),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
