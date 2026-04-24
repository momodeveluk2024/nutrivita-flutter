import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import 'search.dart';
import 'vitamin_detail.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);

    final cats = [
      ['Fruits', 142, const Color(0xFFF3D9B5)],
      ['Vegetables', 218, const Color(0xFFCDE1C2)],
      ['Proteins', 184, const Color(0xFFEAD1C4)],
      ['Grains', 96, const Color(0xFFF0E5C3)],
      ['Dairy', 64, const Color(0xFFE6ECF0)],
      ['Nuts & seeds', 72, const Color(0xFFE3D6C8)],
      ['Legumes', 58, const Color(0xFFD4DCC2)],
      ['Seafood', 110, const Color(0xFFCDD9E3)],
    ];

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
                        '12,486 foods across 8 categories',
                        style: TextStyle(fontSize: 14, color: c.textMuted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search, color: c.text),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  ),
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
                    final name = cat[0] as String;
                    final count = cat[1] as int;
                    final tone = cat[2] as Color;
                    return _CategoryTile(name: name, count: count, tone: tone);
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
                  child: const SectionLabel('Browse by vitamin'),
                ),
                NVCard(
                  padding: const EdgeInsets.all(14),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: vitaminColors.keys.map((k) {
                      final label =
                          (k.startsWith('B') ||
                              ['Fe', 'Zn', 'Mg', 'Ca'].contains(k))
                          ? k
                          : 'Vit $k';
                      return GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => VitaminDetailScreen(code: k),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(6, 6, 10, 6),
                          decoration: BoxDecoration(
                            color: c.surfaceMuted,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              VitaminChip(code: k, size: 22),
                              const SizedBox(width: 6),
                              Text(
                                label,
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
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String name;
  final int count;
  final Color tone;
  const _CategoryTile({
    required this.name,
    required this.count,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
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
    );
  }
}
