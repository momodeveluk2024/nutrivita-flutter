import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/models/food_log.dart';
import '../core/models/nutrient_reference.dart';
import '../core/models/nutrition.dart';
import '../core/providers/auth_provider.dart';
import '../core/providers/nutrition_provider.dart';
import '../theme.dart';
import '../widgets.dart';
import 'meal_log_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() =>
      context.read<NutritionProvider>().refreshDashboard();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final auth = context.watch<AuthProvider>();
    final nutrition = context.watch<NutritionProvider>();
    final user = auth.user;
    final now = DateTime.now();
    final totals = nutrition.todayTotals;
    final pct = ((totals?.averagePercent ?? 0) / 100).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: c.bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/app/search'),
        backgroundColor: NV.accent,
        foregroundColor: Colors.white,
        elevation: 6,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          'Log meal',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Top bar ──
                _TopBar(user: user, now: now),
                const SizedBox(height: 18),

                // ── Hero progress card ──
                _HeroCard(
                  pct: pct,
                  streak: nutrition.streak,
                  mealCount: nutrition.logs.length,
                  trackedCount: totals?.nutrients.length ?? 0,
                  isLoading: nutrition.isLoading,
                ),
                const SizedBox(height: 20),

                // ── Quick actions row ──
                _QuickActionsRow(),
                const SizedBox(height: 22),

                // ── Recommendations ──
                if (nutrition.recommendations.isNotEmpty) ...[
                  _SectionEyebrow('RECOMMENDATIONS'),
                  const SizedBox(height: 8),
                  ...nutrition.recommendations.take(2).map(
                    (rec) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _RecommendationTile(rec: rec),
                    ),
                  ),
                  const SizedBox(height: 12),
                ] else ...[
                  _StarterCard(),
                  const SizedBox(height: 20),
                ],

                // ── Recent meals ──
                _SectionEyebrow('RECENT MEALS'),
                const SizedBox(height: 8),
                if (nutrition.logs.isEmpty)
                  _EmptyMealsCard()
                else
                  ...nutrition.logs.take(3).map(
                    (log) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _RecentMealCard(log: log),
                    ),
                  ),
                const SizedBox(height: 16),

                // ── Nutrient gaps ──
                _SectionEyebrow('NUTRIENT GAPS'),
                const SizedBox(height: 8),
                _NutrientGapsRow(totals: totals),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  TOP BAR
// ═══════════════════════════════════════════════════

class _TopBar extends StatelessWidget {
  const _TopBar({required this.user, required this.now});
  final dynamic user;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final h = now.hour;
    final greeting =
        h < 5 ? 'Night' : h < 12 ? 'Morning' : h < 17 ? 'Afternoon' : h < 21 ? 'Evening' : 'Night';
    final name = user?.displayName?.split(' ')?.first ?? 'friend';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_weekday(now).toUpperCase()} · ${_month(now).toUpperCase()} ${now.day}',
                style: TextStyle(
                  fontSize: 11,
                  color: c.textMuted,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.instrumentSerif(
                    fontWeight: FontWeight.w400,
                    fontSize: 28,
                    letterSpacing: -0.6,
                    height: 1.1,
                    color: c.text,
                  ),
                  children: [
                    TextSpan(text: '$greeting, '),
                    TextSpan(
                      text: name,
                      style: GoogleFonts.instrumentSerif(
                        fontStyle: FontStyle.italic,
                        fontSize: 28,
                        color: NV.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        UserAvatar(
          displayName: user?.displayName ?? 'User',
          avatarUrl: user?.avatarUrl,
          size: 44,
          onTap: () => context.push('/app/profile/body'),
        ),
      ],
    );
  }

  String _weekday(DateTime d) => const [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ][d.weekday - 1];

  String _month(DateTime d) => const [
    'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec',
  ][d.month - 1];
}

// ═══════════════════════════════════════════════════
//  HERO PROGRESS CARD
// ═══════════════════════════════════════════════════

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.pct,
    required this.streak,
    required this.mealCount,
    required this.trackedCount,
    required this.isLoading,
  });

  final double pct;
  final int streak, mealCount, trackedCount;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final pctLabel = '${(pct * 100).round()}%';
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.border),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.28 : 0.04),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Ring
              SizedBox(
                width: 88,
                height: 88,
                child: CustomPaint(
                  painter: _RingPainter(pct, context),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          pctLabel,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: NV.accent,
                            height: 1,
                          ),
                        ),
                        Text(
                          'of target',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: c.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLoading
                          ? 'Refreshing...'
                          : pct == 0
                              ? 'Log your first meal'
                              : 'Nutrient coverage',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: c.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pct == 0
                          ? 'Start tracking to see your daily progress here.'
                          : '$trackedCount nutrients tracked today',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: c.text,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Metric chips row
          Row(
            children: [
              _HeroChip(Icons.local_fire_department_rounded, '$streak day streak'),
              const SizedBox(width: 8),
              _HeroChip(Icons.restaurant_rounded, '$mealCount meals'),
              const SizedBox(width: 8),
              _HeroChip(Icons.bar_chart_rounded, '$trackedCount tracked'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF142C21) : const Color(0xFFE8F5ED),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: NV.accent),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: dark ? Colors.white : const Color(0xFF136136),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double pct;
  final BuildContext context;
  _RingPainter(this.pct, this.context);

  @override
  void paint(Canvas canvas, Size size) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;
    final bgPaint = Paint()
      ..color = dark ? const Color(0xFF1F362C) : const Color(0xFFE6F3EB)
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    if (pct > 0) {
      final fgPaint = Paint()
        ..color = NV.accent
        ..strokeWidth = 7
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final sweep = 2 * math.pi * pct;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweep,
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.pct != pct;
}

// ═══════════════════════════════════════════════════
//  QUICK ACTIONS
// ═══════════════════════════════════════════════════

class _QuickActionsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return Row(
      children: [
        _ActionTile(
          icon: Icons.search_rounded,
          label: 'Find food',
          color: const Color(0xFF1A6C74),
          bgColor: const Color(0xFFDDF0F2),
          onTap: () => context.push('/app/search'),
        ),
        const SizedBox(width: 10),
        _ActionTile(
          icon: Icons.favorite_rounded,
          label: 'Saved',
          color: const Color(0xFFB23A5C),
          bgColor: const Color(0xFFF4E0E6),
          onTap: () => context.push('/app/favorites'),
        ),
        const SizedBox(width: 10),
        _ActionTile(
          icon: Icons.bar_chart_rounded,
          label: 'Tracker',
          color: const Color(0xFF8A6010),
          bgColor: const Color(0xFFFBF3E0),
          onTap: () => context.push('/app/tracker'),
        ),
        const SizedBox(width: 10),
        _ActionTile(
          icon: Icons.notifications_rounded,
          label: 'Reminders',
          color: const Color(0xFF5A4592),
          bgColor: const Color(0xFFEBE6F6),
          onTap: () => context.push('/app/reminders'),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color, bgColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: c.border, width: 1),
          ),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: dark ? color.withValues(alpha: 0.2) : bgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: c.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  STARTER CARD (when no recommendations)
// ═══════════════════════════════════════════════════

class _StarterCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: NV.accentSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.lightbulb_outline_rounded, color: NV.accent, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Get personalized tips',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: c.text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Log a meal and we\'ll show food recommendations based on your nutrient gaps.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: c.textMuted,
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

// ═══════════════════════════════════════════════════
//  RECOMMENDATIONS
// ═══════════════════════════════════════════════════

class _RecommendationTile extends StatelessWidget {
  const _RecommendationTile({required this.rec});
  final Recommendation rec;

  @override
  Widget build(BuildContext context) {
    final nutrient = nutrientReferencesByCode[rec.code];
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final hue = vitaminColors[rec.code] ?? vitaminColors['D']!;
    return NVCard(
      onTap: () => context.push('/app/food/${rec.foodId}'),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FoodPhoto(
            label: rec.foodName,
            imageUrl: rec.foodImageUrl,
            width: 48,
            height: 48,
            radius: 12,
            tone: 'warm',
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Low on ${nutrient?.name ?? rec.name}',
                  style: TextStyle(
                    color: hue.fill,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rec.message,
                  style: TextStyle(
                    color: c.text,
                    fontSize: 15,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  rec.foodName,
                  style: TextStyle(color: c.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 20, color: c.textMuted),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  EMPTY MEALS
// ═══════════════════════════════════════════════════

class _EmptyMealsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return NVCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: c.surfaceMuted,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.restaurant_menu_outlined, color: c.textMuted, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No meals logged yet. Tap "Log meal" to get started!',
              style: TextStyle(color: c.textMuted, fontSize: 13, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  RECENT MEALS
// ═══════════════════════════════════════════════════

class _RecentMealCard extends StatelessWidget {
  const _RecentMealCard({required this.log});
  final MealLog log;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final itemText = log.items
        .map((i) => i.foodName)
        .where((n) => n.trim().isNotEmpty)
        .join(', ');
    final firstItem = log.items.isEmpty ? null : log.items.first;
    return NVCard(
      key: ValueKey('recent-meal-${log.id}'),
      onTap: () => showMealLogDetails(
        context,
        log,
        date: DateTime.tryParse(log.loggedOn),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              FoodPhoto(
                label: firstItem?.foodName ?? log.mealType,
                imageUrl: firstItem?.imageUrl,
                width: 46,
                height: 46,
                radius: 14,
                tone: 'cool',
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: dark ? const Color(0xFF123226) : NV.accentSoft,
                    shape: BoxShape.circle,
                    border: Border.all(color: c.surface, width: 2),
                  ),
                  child: const Icon(Icons.restaurant, size: 11, color: NV.accent),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _titleCase(log.mealType),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: c.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  itemText.isEmpty ? 'No food items attached' : itemText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: c.textMuted),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 18, color: c.textMuted),
        ],
      ),
    );
  }

  String _titleCase(String v) =>
      v.isEmpty ? v : v[0].toUpperCase() + v.substring(1);
}

// ═══════════════════════════════════════════════════
//  NUTRIENT GAPS (horizontal scroll)
// ═══════════════════════════════════════════════════

class _NutrientGapsRow extends StatelessWidget {
  const _NutrientGapsRow({required this.totals});
  final DayNutrientTotals? totals;

  @override
  Widget build(BuildContext context) {
    final gaps = _gaps(totals);
    final starters = ['B12', 'D', 'C']
        .map((code) => nutrientReferencesByCode[code]!)
        .toList();
    final nutrients = gaps.isEmpty ? starters : gaps;

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: nutrients.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final n = nutrients[i];
          final hue = vitaminColors[n.code] ?? vitaminColors['D']!;
          return GestureDetector(
            onTap: () => context.push('/app/vitamin/${n.code}'),
            child: _NutrientGapCard(nutrient: n, hue: hue),
          );
        },
      ),
    );
  }

  List<NutrientReference> _gaps(DayNutrientTotals? totals) {
    final nutrients = [
      ...?totals?.nutrients.where((item) => item.driPercent != null),
    ];
    nutrients.sort((a, b) => (a.driPercent ?? 0).compareTo(b.driPercent ?? 0));
    return nutrients
        .take(3)
        .map((item) => nutrientReferencesByCode[item.code])
        .whereType<NutrientReference>()
        .toList();
  }
}

class _NutrientGapCard extends StatelessWidget {
  const _NutrientGapCard({required this.nutrient, required this.hue});
  final NutrientReference nutrient;
  final VitaminHue hue;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return Container(
      width: 130,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VitaminChip(code: nutrient.code, size: 36),
          const Spacer(),
          Text(
            nutrient.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: c.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            nutrient.group,
            style: TextStyle(fontSize: 11, color: c.textMuted),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  SECTION EYEBROW
// ═══════════════════════════════════════════════════

class _SectionEyebrow extends StatelessWidget {
  const _SectionEyebrow(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 4, 2, 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.8,
              fontWeight: FontWeight.w800,
              color: c.textMuted,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(height: 1, color: c.border.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}
