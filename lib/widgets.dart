import 'dart:math' as math;
import 'package:flutter/material.dart';
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
    final Color a, b;
    if (tone == 'warm') {
      a = dark ? const Color(0xFF2A2420) : const Color(0xFFE9E0D2);
      b = dark ? const Color(0xFF322A24) : const Color(0xFFF0E8DB);
    } else {
      a = dark ? const Color(0xFF1F2A23) : const Color(0xFFDFE8DE);
      b = dark ? const Color(0xFF253128) : const Color(0xFFE7EFE5);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CustomPaint(
        painter: _StripePainter(a: a, b: b),
        child: SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: Center(
            child: Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                letterSpacing: 0.5,
                color: dark ? Colors.white.withValues(alpha: 0.45) : Colors.black.withValues(alpha: 0.42),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  final Color a, b;
  _StripePainter({required this.a, required this.b});

  @override
  void paint(Canvas canvas, Size size) {
    final pa = Paint()..color = a;
    final pb = Paint()..color = b;
    canvas.drawRect(Offset.zero & size, pa);

    const stripeWidth = 10.0;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(135 * math.pi / 180);
    final diag = math.sqrt(size.width * size.width + size.height * size.height);
    for (double x = -diag; x < diag; x += stripeWidth * 2) {
      canvas.drawRect(
        Rect.fromLTWH(x + stripeWidth, -diag, stripeWidth, diag * 2),
        pb,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _StripePainter old) => old.a != a || old.b != b;
}

class VitaminChip extends StatelessWidget {
  final String code;
  final double size;
  const VitaminChip({super.key, required this.code, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final hue = vitaminColors[code] ?? vitaminColors['C']!;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: dark ? hue.fill.withValues(alpha: 0.2) : hue.bg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        code,
        style: TextStyle(
          fontSize: size * 0.36,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: hue.fill,
        ),
      ),
    );
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

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(pct: pct, color: ringColor, track: trackColor, stroke: stroke),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
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
  }
}

class _RingPainter extends CustomPainter {
  final double pct;
  final Color color, track;
  final double stroke;
  _RingPainter({required this.pct, required this.color, required this.track, required this.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2 - stroke / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(center, r, trackPaint);

    final arcPaint = Paint()
      ..color = color
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        color: track,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: pct.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              color: color ?? NV.accent,
              borderRadius: BorderRadius.circular(height),
            ),
          ),
        ),
      ),
    );
  }
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
        border: noBorder
            ? null
            : Border.all(color: c.border, width: 1),
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
class NVPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? trailingIcon;
  final IconData? leadingIcon;
  final double height;
  final double? width;
  final double radius;
  const NVPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.trailingIcon,
    this.leadingIcon,
    this.height = 54,
    this.width,
    this.radius = 28,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: onPressed ?? () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: NV.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(label),
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
  final double size;
  const NVCircleIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.background,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return Material(
      color: background ?? c.surfaceMuted,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: 18, color: c.text),
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
