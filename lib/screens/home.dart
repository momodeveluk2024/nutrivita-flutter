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

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
            child: Row(
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
                      const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.instrumentSerif(
                            fontWeight: FontWeight.w400,
                            fontSize: 32,
                            letterSpacing: -0.6,
                            height: 1.05,
                            color: c.text,
                          ),
                          children: [
                            TextSpan(
                              text: '${_capitalize(_timeOfDayWord(now))}, ',
                            ),
                            TextSpan(
                              text:
                                  user?.displayName.split(' ').first ?? 'friend',
                              style: GoogleFonts.instrumentSerif(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w400,
                                fontSize: 32,
                                letterSpacing: -0.6,
                                height: 1.05,
                                color: c.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                UserAvatar(
                  displayName: user?.displayName ?? 'Nutrimate user',
                  avatarUrl: user?.avatarUrl,
                  size: 46,
                  onTap: () => context.push('/app/profile/body'),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _CommandCenterCard(
                      pct: pct,
                      streak: nutrition.streak,
                      mealCount: nutrition.logs.length,
                      trackedCount: totals?.nutrients.length ?? 0,
                      isLoading: nutrition.isLoading,
                    ),
                    const SizedBox(height: 14),
                    _RecommendationPanel(
                      recommendations: nutrition.recommendations,
                    ),
                    const SizedBox(height: 14),
                    _RecentMealsSection(logs: nutrition.logs),
                    const SizedBox(height: 18),
                    _NutrientGapsSection(totals: totals),
                    const SizedBox(height: 14),
                    const _QuickActionGrid(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _timeOfDayWord(DateTime date) {
    final h = date.hour;
    if (h < 5) return 'night';
    if (h < 12) return 'morning';
    if (h < 17) return 'afternoon';
    if (h < 21) return 'evening';
    return 'night';
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _weekday(DateTime date) => const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ][date.weekday - 1];

  String _month(DateTime date) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][date.month - 1];
}

class _CommandCenterCard extends StatelessWidget {
  const _CommandCenterCard({
    required this.pct,
    required this.streak,
    required this.mealCount,
    required this.trackedCount,
    required this.isLoading,
  });

  final double pct;
  final int streak;
  final int mealCount;
  final int trackedCount;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final pctLabel = '${(pct * 100).round()}%';
    return NVCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily command',
                      style: TextStyle(
                        color: c.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      pct == 0
                          ? 'Build today\'s nutrient baseline'
                          : 'Today\'s nutrient coverage',
                      style: TextStyle(
                        color: c.text,
                        fontSize: 20,
                        height: 1.18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isLoading
                          ? 'Refreshing your dashboard...'
                          : pct == 0
                          ? 'Log one food to turn this into a personalized plan.'
                          : '$trackedCount nutrients tracked from today\'s meals.',
                      style: TextStyle(
                        color: c.textMuted,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              RingProgress(
                pct: pct,
                size: 92,
                stroke: 8,
                label: pctLabel,
                sub: 'of target',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetricPill(
                icon: Icons.local_fire_department_outlined,
                label: '$streak-day streak',
              ),
              _MetricPill(
                icon: Icons.restaurant_menu_outlined,
                label: '$mealCount meals today',
              ),
              _MetricPill(
                icon: Icons.query_stats_outlined,
                label: '$trackedCount nutrients',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: c.surfaceMuted,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: NV.accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: c.text,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationPanel extends StatelessWidget {
  const _RecommendationPanel({required this.recommendations});

  final List<Recommendation> recommendations;

  @override
  Widget build(BuildContext context) {
    final hasRecommendations = recommendations.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionEyebrow(
          hasRecommendations
              ? 'PERSONAL · RECOMMENDATIONS'
              : 'STARTER · RECOMMENDATIONS',
        ),
        if (hasRecommendations)
          ...recommendations.take(2).map((rec) => _RecommendationTile(rec: rec))
        else
          const _StarterRecommendations(),
      ],
    );
  }
}

class _StarterRecommendations extends StatelessWidget {
  const _StarterRecommendations();

  @override
  Widget build(BuildContext context) {
    return NVCard(
      padding: const EdgeInsets.all(16),
      background: NV.accent,
      noBorder: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Start with one meal',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Log a common food and Nutrimate will turn vitamin gaps into concrete food ideas.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StarterChip(
                code: 'B12',
                label: 'Energy',
                onTap: () => context.push('/app/vitamin/B12'),
              ),
              _StarterChip(
                code: 'D',
                label: 'Bones',
                onTap: () => context.push('/app/vitamin/D'),
              ),
              _StarterChip(
                code: 'C',
                label: 'Immunity',
                onTap: () => context.push('/app/vitamin/C'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StarterChip extends StatelessWidget {
  const _StarterChip({
    required this.code,
    required this.label,
    required this.onTap,
  });

  final String code;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              VitaminChip(code: code, size: 22),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: NV.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  const _RecommendationTile({required this.rec});

  final Recommendation rec;

  @override
  Widget build(BuildContext context) {
    final nutrient = nutrientReferencesByCode[rec.code];
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final hue = vitaminColors[rec.code] ?? vitaminColors['D']!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: NVCard(
        onTap: () => context.push('/app/food/${rec.foodId}'),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VitaminChip(code: rec.code, size: 46),
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
                  const SizedBox(height: 8),
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
      ),
    );
  }
}

class _NutrientGapsSection extends StatelessWidget {
  const _NutrientGapsSection({required this.totals});

  final DayNutrientTotals? totals;

  @override
  Widget build(BuildContext context) {
    final gaps = _gaps(totals);
    final starters = [
      'B12',
      'D',
      'C',
    ].map((code) => nutrientReferencesByCode[code]!).toList();
    final nutrients = gaps.isEmpty ? starters : gaps;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionEyebrow(
          'TOP · NUTRIENT GAPS',
          trailing: gaps.isEmpty ? 'STARTER' : 'TODAY',
        ),
        ...nutrients
            .take(3)
            .map(
              (nutrient) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: NutrientCard(
                  nutrient: nutrient,
                  compact: true,
                  onTap: () => context.push('/app/vitamin/${nutrient.code}'),
                ),
              ),
            ),
      ],
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

class _QuickActionGrid extends StatelessWidget {
  const _QuickActionGrid();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: NVCard(
            padding: const EdgeInsets.all(14),
            onTap: () => context.push('/app/search'),
            child: const _QuickAction(
              icon: Icons.search,
              label: 'Find food',
              sub: 'Browse sources',
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: NVCard(
            padding: const EdgeInsets.all(14),
            onTap: () => context.push('/app/search'),
            child: const _QuickAction(
              icon: Icons.add,
              label: 'Log meal',
              sub: 'Start tracking',
            ),
          ),
        ),
      ],
    );
  }
}

class _RecentMealsSection extends StatelessWidget {
  const _RecentMealsSection({required this.logs});

  final List<MealLog> logs;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionEyebrow('RECENT · MEALS'),
        if (logs.isEmpty)
          NVCard(
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
                  child: Icon(
                    Icons.restaurant_menu_outlined,
                    color: c.textMuted,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No meals logged yet. Add one food to unlock a richer dashboard.',
                    style: TextStyle(
                      color: c.textMuted,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...logs
              .take(3)
              .map(
                (log) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _RecentMealCard(log: log),
                ),
              ),
      ],
    );
  }
}

class _RecentMealCard extends StatelessWidget {
  const _RecentMealCard({required this.log});

  final MealLog log;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final itemText = log.items
        .map((item) => item.foodName)
        .where((name) => name.trim().isNotEmpty)
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
                  child: const Icon(
                    Icons.restaurant,
                    size: 11,
                    color: NV.accent,
                  ),
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

  String _titleCase(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.sub,
  });

  final IconData icon;
  final String label;
  final String sub;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: dark ? NV.accent.withValues(alpha: 0.2) : NV.accentSoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 19, color: NV.accent),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: c.text,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                sub,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: c.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Modernized section header used across home: small uppercase eyebrow,
/// hairline divider stretching to the right, optional badge on the far
/// right (e.g. "TODAY"). Replaces the old big "Recent meals" / "Top
/// nutrient gaps" / "Personal recommendations" bold sans labels.
class _SectionEyebrow extends StatelessWidget {
  const _SectionEyebrow(this.label, {this.trailing});

  final String label;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 4, 2, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
            child: Container(
              height: 1,
              color: c.border.withValues(alpha: 0.6),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 10),
            Text(
              trailing!,
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w700,
                color: c.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
