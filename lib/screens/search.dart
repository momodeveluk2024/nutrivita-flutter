import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import 'food_detail.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);

    final results = [
      ['Salmon, Atlantic — cooked', '3 oz · 175 cal', ['D', 'B12']],
      ['Salmon, sockeye — raw', '3 oz · 143 cal', ['D', 'B12']],
      ['Salmon roe', '1 tbsp · 40 cal', ['B12', 'D']],
    ];

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
                          onTap: () => Navigator.of(context).maybePop()),
                      const SizedBox(width: 10),
                      Text('Search',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.8,
                              color: c.text)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: c.surfaceMuted,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, size: 18, color: c.textMuted),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Row(
                            children: [
                              Text('salmon',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: c.text)),
                              Container(
                                  width: 1.5,
                                  height: 16,
                                  margin: const EdgeInsets.only(left: 1),
                                  color: NV.accent),
                            ],
                          ),
                        ),
                        Icon(Icons.mic_none_outlined, size: 18, color: c.textMuted),
                      ],
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
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 10, 4, 4),
                    child: const SectionLabel('3 results'),
                  ),
                  ...results.map((r) {
                    final name = r[0] as String;
                    final sub = r[1] as String;
                    final hls = r[2] as List<String>;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: NVCard(
                        padding: const EdgeInsets.all(12),
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const FoodDetailScreen())),
                        child: Row(
                          children: [
                            const PhotoPlaceholder(
                                label: 'food', height: 56, width: 56, radius: 12),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: c.text)),
                                  const SizedBox(height: 2),
                                  Text(sub, style: TextStyle(fontSize: 12, color: c.textMuted)),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: hls
                                        .map((h) => Padding(
                                              padding: const EdgeInsets.only(right: 4),
                                              child: VitaminChip(code: h, size: 20),
                                            ))
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
                  }),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
                    child: const SectionLabel('Recent'),
                  ),
                  ...['spinach', 'greek yogurt', 'almonds'].map((t) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                        child: Row(
                          children: [
                            Icon(Icons.search, size: 16, color: c.textMuted),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Text(t, style: TextStyle(fontSize: 14, color: c.text))),
                            Icon(Icons.close, size: 14, color: c.textMuted),
                          ],
                        ),
                      )),
                ],
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
            color: active ? Colors.white : c.text),
      ),
    );
  }
}
