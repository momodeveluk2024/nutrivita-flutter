import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/models/food_log.dart';
import '../core/providers/nutrition_provider.dart';
import '../theme.dart';
import '../widgets.dart';
import 'meal_log_detail.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  DateTime _selectedDate = _dateOnly(DateTime.now());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    final nutrition = context.read<NutritionProvider>();
    await nutrition.refreshDashboard(date: _selectedDate);
    await nutrition.loadWeek(endDate: _selectedDate);
  }

  Future<void> _selectDate(DateTime date) async {
    setState(() => _selectedDate = _dateOnly(date));
    await _refresh();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Choose tracking day',
    );
    if (picked != null) await _selectDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final nutrition = context.watch<NutritionProvider>();
    final todayPct = ((nutrition.todayTotals?.averagePercent ?? 0) / 100).clamp(
      0.0,
      1.0,
    );

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _dateTitle(_selectedDate),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                      color: c.text,
                    ),
                  ),
                ),
                NVCircleIconButton(
                  icon: Icons.calendar_month_outlined,
                  onTap: _pickDate,
                ),
              ],
            ),
          ),
          _WeekStrip(selectedDate: _selectedDate, onSelected: _selectDate),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                children: [
                  NVCard(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        RingProgress(
                          pct: todayPct,
                          size: 96,
                          label: '${(todayPct * 100).round()}%',
                          sub: 'of daily goal',
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SectionLabel('On track'),
                              const SizedBox(height: 4),
                              Text(
                                '${nutrition.todayTotals?.nutrients.length ?? 0} nutrients logged',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                  height: 1.3,
                                  color: c.text,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${nutrition.streak}-day logging streak',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: c.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 10),
                    child: Text(
                      'Meals',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: c.text,
                      ),
                    ),
                  ),
                  if (nutrition.logs.isEmpty)
                    NVCard(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        'Nothing logged for this day. Open a food and log it to this date.',
                        style: TextStyle(color: c.textMuted),
                      ),
                    )
                  else
                    ...nutrition.logs.map(
                      (log) => _MealLogCard(log: log, date: _selectedDate),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekStrip extends StatefulWidget {
  const _WeekStrip({required this.selectedDate, required this.onSelected});

  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelected;

  @override
  State<_WeekStrip> createState() => _WeekStripState();
}

class _WeekStripState extends State<_WeekStrip> {
  static final DateTime _firstDate = DateTime(2020);
  static const double _itemExtent = 58;
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _centerSelected(jump: true),
    );
  }

  @override
  void didUpdateWidget(covariant _WeekStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameDay(oldWidget.selectedDate, widget.selectedDate)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _centerSelected());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _centerSelected({bool jump = false}) {
    if (!_controller.hasClients) return;
    final index = _dayIndex(widget.selectedDate);
    final viewport = _controller.position.viewportDimension;
    final max = _controller.position.maxScrollExtent;
    final target = (index * _itemExtent - viewport / 2 + _itemExtent / 2).clamp(
      0.0,
      max,
    );
    if (jump) {
      _controller.jumpTo(target);
      return;
    }
    _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  int _dayIndex(DateTime date) => _dateOnly(date).difference(_firstDate).inDays;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final days = context.watch<NutritionProvider>().weekTotals;
    final totalsByDate = {for (final day in days) day.date: day};
    final today = _dateOnly(DateTime.now());
    final count = today.difference(_firstDate).inDays + 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: SizedBox(
        key: const ValueKey('track-date-strip'),
        height: 92,
        child: ListView.builder(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: count,
          itemExtent: _itemExtent,
          itemBuilder: (context, i) {
            final date = _firstDate.add(Duration(days: i));
            final key = _dateString(date);
            final pct = ((totalsByDate[key]?.averagePercent ?? 0) / 100).clamp(
              0.0,
              1.0,
            );
            final active = _sameDay(date, widget.selectedDate);
            return SizedBox(
              key: ValueKey('track-day-$key'),
              width: _itemExtent,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => widget.onSelected(date),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 4,
                    ),
                    decoration: BoxDecoration(
                      color: active ? NV.accent : c.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: active ? null : Border.all(color: c.border),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: NV.accent.withValues(alpha: 0.24),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ['M', 'T', 'W', 'T', 'F', 'S', 'S'][date.weekday - 1],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: active
                                ? Colors.white.withValues(alpha: 0.72)
                                : c.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: active ? Colors.white : c.text,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 18,
                          height: 18,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: active
                                ? Colors.white.withValues(alpha: 0.18)
                                : c.surfaceMuted,
                          ),
                          child: Text(
                            '${(pct * 100).round()}',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: active ? Colors.white : c.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MealLogCard extends StatelessWidget {
  const _MealLogCard({required this.log, required this.date});

  final MealLog log;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: NVCard(
        key: ValueKey('meal-log-${log.id}'),
        onTap: () => showMealLogDetails(context, log, date: date),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MealImageMosaic(
              items: log.items,
              fallbackLabel: log.mealType,
              size: 54,
              radius: 16,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.mealType,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: c.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (log.items.isEmpty)
                    Text(
                      'Tap to review meal',
                      style: TextStyle(fontSize: 12, color: c.textMuted),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _mealSummary(log.items.length),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: NV.accent,
                          ),
                        ),
                        const SizedBox(height: 5),
                        ...log.items.take(3).map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text(
                              '${item.foodName} - ${item.servingG.round()}g',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.15,
                                color: c.textMuted,
                              ),
                            ),
                          );
                        }),
                      ],
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

String _mealSummary(int count) {
  if (count == 1) return '1 food';
  return '$count foods';
}

String _dateTitle(DateTime date) {
  final today = _dateOnly(DateTime.now());
  if (_sameDay(date, today)) return 'Today';
  if (_sameDay(date, today.subtract(const Duration(days: 1)))) {
    return 'Yesterday';
  }
  return '${_weekdayName(date.weekday)}, ${_monthName(date.month)} ${date.day}';
}

String _weekdayName(int weekday) {
  return const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];
}

String _monthName(int month) {
  return const [
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
  ][month - 1];
}

String _dateString(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
