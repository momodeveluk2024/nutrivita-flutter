import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'core/api/api_endpoints.dart';
import 'core/models/nutrient_reference.dart';
import 'core/models/visual_catalog.dart';
import 'theme.dart';

/// Striped placeholder — signals "real food photo goes here".
class PhotoPlaceholder extends StatelessWidget {
  final String label;
  final double height;
  final double? width;
  final double radius;
  final String tone;

  const PhotoPlaceholder({
    super.key,
    this.label = '',
    this.height = 120,
    this.width,
    this.radius = 16,
    this.tone = 'warm',
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final initials = _initials(label);
    final base = tone == 'warm' ? const Color(0xFFB98B55) : NV.accent;
    final bg = dark ? const Color(0xFF17211C) : const Color(0xFFF0F4EC);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: bg,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              base.withValues(alpha: dark ? 0.30 : 0.18),
              bg,
              base.withValues(alpha: dark ? 0.18 : 0.10),
            ],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              right: -height * 0.12,
              bottom: -height * 0.18,
              child: Icon(
                Icons.eco,
                size: height * 0.78,
                color: base.withValues(alpha: dark ? 0.12 : 0.10),
              ),
            ),
            Center(
              child: Container(
                padding: EdgeInsets.all(math.max(6, height * 0.10)),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: dark ? 0.08 : 0.46),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: dark ? 0.08 : 0.55),
                  ),
                ),
                child: Text(
                  initials,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: math.max(9, height * 0.18),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: base.withValues(alpha: dark ? 0.88 : 0.95),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String value) {
    final words = value
        .split(RegExp(r'[^A-Za-z0-9]+'))
        .where((word) => word.isNotEmpty)
        .take(2)
        .toList();
    if (words.isEmpty) return 'NV';
    return words.map((word) => word[0]).join().toUpperCase();
  }
}

class FoodPhoto extends StatelessWidget {
  final String label;
  final String? imageUrl;
  final double height;
  final double? width;
  final double radius;
  final String tone;

  const FoodPhoto({
    super.key,
    required this.label,
    this.imageUrl,
    this.height = 120,
    this.width,
    this.radius = 16,
    this.tone = 'warm',
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) {
      return PhotoPlaceholder(
        label: label,
        height: height,
        width: width,
        radius: radius,
        tone: tone,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        url,
        width: width ?? double.infinity,
        height: height,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return PhotoPlaceholder(
            label: label,
            height: height,
            width: width,
            radius: 0,
            tone: tone,
          );
        },
        errorBuilder: (context, error, stackTrace) => PhotoPlaceholder(
          label: label,
          height: height,
          width: width,
          radius: radius,
          tone: tone,
        ),
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.displayName,
    this.avatarUrl,
    this.size = 72,
    this.editable = false,
    this.onTap,
  });

  final String displayName;
  final String? avatarUrl;
  final double size;
  final bool editable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final url = avatarUrl?.trim() ?? '';
    final content = ClipOval(
      child: Container(
        width: size,
        height: size,
        color: dark ? NV.accent.withValues(alpha: 0.24) : NV.accentSoft,
        alignment: Alignment.center,
        child: url.isEmpty
            ? Text(
                _initialsFor(displayName, fallback: '?'),
                style: TextStyle(
                  color: dark ? NV.textDark : NV.accent,
                  fontSize: size * 0.32,
                  fontWeight: FontWeight.w800,
                ),
              )
            : Image.network(
                ApiEndpoints.mediaUrl(url),
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Text(
                  _initialsFor(displayName, fallback: '?'),
                  style: TextStyle(
                    color: dark ? NV.textDark : NV.accent,
                    fontSize: size * 0.32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
      ),
    );

    final avatar = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: c.surface, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.35 : 0.10),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: content,
        ),
        if (editable)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: size * 0.34,
              height: size * 0.34,
              decoration: BoxDecoration(
                color: NV.accent,
                shape: BoxShape.circle,
                border: Border.all(color: c.surface, width: 2),
              ),
              child: Icon(
                Icons.photo_camera_outlined,
                color: Colors.white,
                size: size * 0.17,
              ),
            ),
          ),
      ],
    );

    if (onTap == null) return avatar;
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: avatar,
      ),
    );
  }
}

class VitaminChip extends StatelessWidget {
  final String code;
  final double size;
  const VitaminChip({super.key, required this.code, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final hue = vitaminColors[code] ?? vitaminColors['C']!;
    final visual = nutrientVisualFor(code);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: dark ? hue.fill.withValues(alpha: 0.2) : hue.bg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(visual.icon, size: size * 0.46, color: hue.fill),
    );
  }
}

class NutrientPill extends StatelessWidget {
  const NutrientPill({
    super.key,
    required this.code,
    required this.label,
    this.onTap,
    this.compact = false,
  });

  final String code;
  final String label;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final visual = nutrientVisualFor(code);
    final bg = dark
        ? visual.accent.withValues(alpha: 0.16)
        : visual.accent.withValues(alpha: 0.09);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.fromLTRB(6, 5, compact ? 8 : 10, 5),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: visual.accent.withValues(alpha: 0.10)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: compact ? 20 : 24,
                height: compact ? 20 : 24,
                decoration: BoxDecoration(
                  color: dark
                      ? Colors.white.withValues(alpha: 0.07)
                      : Colors.white.withValues(alpha: 0.76),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  visual.icon,
                  size: compact ? 11 : 13,
                  color: visual.accent,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: compact ? 11 : 12,
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

class NutrientCard extends StatelessWidget {
  const NutrientCard({
    super.key,
    required this.nutrient,
    this.onTap,
    this.trailing,
    this.compact = false,
  });

  final NutrientReference nutrient;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final hue = vitaminColors[nutrient.code] ?? vitaminColors['D']!;
    final visual = nutrientVisualFor(nutrient.code);
    final bg = dark ? hue.fill.withValues(alpha: 0.18) : hue.bg;
    return NVCard(
      onTap: onTap,
      radius: compact ? 16 : 18,
      padding: EdgeInsets.all(compact ? 12 : 14),
      child: Row(
        children: [
          Container(
            width: compact ? 48 : 58,
            height: compact ? 48 : 58,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(compact ? 15 : 18),
              border: Border.all(color: hue.fill.withValues(alpha: 0.12)),
            ),
            child: Icon(visual.icon, size: compact ? 22 : 26, color: hue.fill),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      nutrient.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: compact ? 14 : 16,
                        fontWeight: FontWeight.w800,
                        color: c.text,
                      ),
                    ),
                    _NutrientMetaChip(label: nutrient.group, color: hue.fill),
                    if (nutrient.dailyTarget > 0)
                      _NutrientMetaChip(
                        label: nutrient.targetLabel,
                        color: c.textMuted,
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  nutrient.summary,
                  maxLines: compact ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 12 : 13,
                    height: 1.35,
                    color: c.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing ??
              (onTap == null
                  ? const SizedBox.shrink()
                  : Icon(Icons.chevron_right, size: 20, color: c.textMuted)),
        ],
      ),
    );
  }
}

class _NutrientMetaChip extends StatelessWidget {
  const _NutrientMetaChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: dark ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class NutrientArtwork extends StatelessWidget {
  const NutrientArtwork({
    super.key,
    required this.code,
    required this.name,
    this.height = 150,
    this.radius = 24,
  });

  final String code;
  final String name;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final hue = vitaminColors[code] ?? vitaminColors['C']!;
    final visual = nutrientVisualFor(code);
    final icon = visual.icon;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              dark ? hue.fill.withValues(alpha: 0.28) : hue.bg,
              dark ? const Color(0xFF17211C) : Colors.white,
              hue.fill.withValues(alpha: dark ? 0.20 : 0.16),
            ],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              right: -26,
              top: -20,
              child: Icon(
                icon,
                size: height * 0.86,
                color: hue.fill.withValues(alpha: dark ? 0.12 : 0.10),
              ),
            ),
            Positioned(
              left: 18,
              bottom: 16,
              child: Row(
                children: [
                  VitaminChip(code: code, size: 58),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: dark ? NV.textDark : NV.text,
                        ),
                      ),
                      Text(
                        _artLabel(code),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: hue.fill,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              right: 18,
              bottom: 18,
              child: Icon(icon, size: 34, color: hue.fill),
            ),
          ],
        ),
      ),
    );
  }

  String _artLabel(String code) {
    if (code.startsWith('B')) return 'B-complex support';
    if ([
      'Fe',
      'Ca',
      'Zn',
      'Mg',
      'Kp',
      'Na',
      'P',
      'Se',
      'Mn',
      'S',
    ].contains(code)) {
      return 'Mineral profile';
    }
    if (['Protein', 'Fiber', 'Carbs', 'Fat'].contains(code)) {
      return 'Macro target';
    }
    return 'Daily value guide';
  }
}

class RingProgress extends StatelessWidget {
  final double pct;
  final double size;
  final double stroke;
  final Color? color;
  final String label;
  final String? sub;

  const RingProgress({
    super.key,
    this.pct = 0.7,
    this.size = 88,
    this.stroke = 8,
    this.color,
    required this.label,
    this.sub,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final ringColor = color ?? NV.accent;
    final trackColor = dark ? NV.borderDark : const Color(0xFFE5E8DF);

    final targetPct = pct.clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: targetPct),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        final animatedLabel = label.endsWith('%')
            ? '${(value * 100).round()}%'
            : label;
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _RingPainter(
                  pct: value,
                  color: ringColor,
                  track: trackColor,
                  stroke: stroke,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    animatedLabel,
                    style: TextStyle(
                      fontSize: size * 0.22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                      color: c.text,
                    ),
                  ),
                  if (sub != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Text(
                        sub!,
                        style: TextStyle(fontSize: 10, color: c.textMuted),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double pct;
  final Color color, track;
  final double stroke;
  _RingPainter({
    required this.pct,
    required this.color,
    required this.track,
    required this.stroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2 - stroke / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, r, trackPaint);

    final shadowPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke + 5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      -math.pi / 2,
      2 * math.pi * pct,
      false,
      shadowPaint,
    );

    final arcPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          color.withValues(alpha: 0.78),
          color,
          color.withValues(alpha: 0.88),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: r))
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      -math.pi / 2,
      2 * math.pi * pct,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.pct != pct || old.color != color || old.track != track;
}

class BarProgress extends StatelessWidget {
  final double pct;
  final Color? color;
  final double height;
  const BarProgress({super.key, this.pct = 0.5, this.color, this.height = 6});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final track = dark ? NV.borderDark : const Color(0xFFE5E8DF);
    final fill = color ?? NV.accent;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: pct.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 760),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(height),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: track,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: dark ? 0.22 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      fill.withValues(alpha: 0.78),
                      fill,
                      Color.lerp(fill, Colors.white, dark ? 0.10 : 0.20)!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(height),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class NVSelectField extends StatelessWidget {
  const NVSelectField({
    super.key,
    required this.label,
    required this.values,
    required this.onChanged,
    this.value,
    this.display,
  });

  final String label;
  final String? value;
  final List<String> values;
  final String Function(String value)? display;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final displayValue = value == null ? 'Choose' : _display(value!);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _open(context),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: c.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: dark ? 0.18 : 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: c.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayValue,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: value == null ? c.textMuted : c.text,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: dark
                        ? NV.accent.withValues(alpha: 0.14)
                        : NV.accentSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    color: NV.accent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final dark = Theme.of(sheetContext).brightness == Brightness.dark;
        final c = NVColors(dark);
        return SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: c.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: dark ? 0.42 : 0.12),
                  blurRadius: 30,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: c.border,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: c.text,
                    ),
                  ),
                ),
                ...values.map((option) {
                  final selected = option == value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Material(
                      color: selected
                          ? (dark
                                ? NV.accent.withValues(alpha: 0.14)
                                : NV.accentSoft)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.of(sheetContext).pop(option),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _display(option),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: c.text,
                                  ),
                                ),
                              ),
                              if (selected)
                                const Icon(
                                  Icons.check_circle,
                                  color: NV.accent,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
    if (selected != null) onChanged(selected);
  }

  String _display(String value) => display?.call(value) ?? value;
}

/// Reusable card surface.
class NVCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color? background;
  final bool noBorder;
  final VoidCallback? onTap;
  const NVCard({
    super.key,
    required this.child,
    this.padding,
    this.radius = 20,
    this.background,
    this.noBorder = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final bg = background ?? c.surface;
    final widget = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: noBorder ? null : Border.all(color: c.border, width: 1),
        boxShadow: noBorder
            ? null
            : [
                BoxShadow(
                  color: dark
                      ? Colors.black.withValues(alpha: 0.35)
                      : const Color(0xFF0F1E14).withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: child,
    );
    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: widget,
        ),
      );
    }
    return widget;
  }
}

/// Primary CTA button.
/// Primary CTA. Per Nutrimate Design System v2 the default is **ink**:
/// dark warm-near-black background (`--text` = `#14110E`) with light
/// text-on-ink. Set `accent: true` to flip to amber (used inside dark
/// recommendation cards or single-callout moments).
class NVPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? trailingIcon;
  final IconData? leadingIcon;
  final double height;
  final double? width;
  final double radius;
  final bool accent;

  const NVPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.trailingIcon,
    this.leadingIcon,
    this.height = 54,
    this.width,
    this.radius = 999,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = accent ? NV.accent : NV.surfaceInk;
    final fg = accent ? Colors.white : const Color(0xFFFAF4EC);
    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, size: 18),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              Icon(trailingIcon, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}

/// Small circular header button (back / bookmark / etc.)
class NVCircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? background;
  final Color? foreground;
  final double size;
  const NVCircleIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.background,
    this.foreground,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return Material(
      color: background ?? c.surfaceMuted,
      shape: const CircleBorder(),
      shadowColor: Colors.black.withValues(alpha: dark ? 0.40 : 0.12),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: c.border.withValues(alpha: 0.70)),
          ),
          child: Icon(icon, size: 18, color: foreground ?? c.text),
        ),
      ),
    );
  }
}

/// Section label (uppercase, tracked).
class SectionLabel extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry? padding;
  const SectionLabel(this.text, {super.key, this.padding});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: c.textMuted,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

String _initialsFor(String value, {String fallback = 'NV'}) {
  final words = value
      .split(RegExp(r'[^A-Za-z0-9]+'))
      .where((word) => word.isNotEmpty)
      .take(2)
      .toList();
  if (words.isEmpty) return fallback;
  return words.map((word) => word[0]).join().toUpperCase();
}
