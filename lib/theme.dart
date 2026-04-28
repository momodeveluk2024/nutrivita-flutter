import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NV {
  // Brand — healthy green (Nutrimate Design System v3: clean white + green)
  static const accent = Color(0xFF1FA85C);
  static const accentSoft = Color(0xFFE0F5EA);
  static const accentDeep = Color(0xFF147A3E);

  // Sage — secondary muted green
  static const sage = Color(0xFF4E7A59);
  static const sageSoft = Color(0xFFDDE9E1);

  // Surfaces — barely-green white
  static const bg = Color(0xFFF5F8F5);
  static const bgAlt = Color(0xFFECF0EB);
  static const bgDark = Color(0xFF0C1410);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF172219);
  static const surfaceMuted = Color(0xFFF0F6F2);
  static const surfaceMutedDark = Color(0xFF1D2C20);
  static const surfaceInk = Color(0xFF101810);
  static const border = Color(0xFFD8E4DC);
  static const borderDark = Color(0xFF243328);
  static const borderStrong = Color(0xFFB8CCB8);

  // Text — near-black with green undertone
  static const text = Color(0xFF101810);
  static const textDark = Color(0xFFEEF6F1);
  static const textMuted = Color(0xFF526A5C);
  static const textMutedDark = Color(0xFF7DA88E);
  static const textSoft = Color(0xFF8AA698);

  // Semantic
  static const warn = Color(0xFFB07A18);
  static const warnSoft = Color(0xFFFBF3E0);
  static const err = Color(0xFFC0383A);
  static const errSoft = Color(0xFFFCEDED);
  static const ok = Color(0xFF1FA85C);
}

class VitaminHue {
  final Color fill;
  final Color bg;
  const VitaminHue(this.fill, this.bg);
}

const Map<String, VitaminHue> vitaminColors = {
  'A': VitaminHue(Color(0xFF8A6010), Color(0xFFFBF3E0)),
  'B1': VitaminHue(Color(0xFFC68B1C), Color(0xFFF5E8C8)),
  'B2': VitaminHue(Color(0xFFB6A322), Color(0xFFF2EFCB)),
  'B3': VitaminHue(Color(0xFFC06B2F), Color(0xFFF5E1D3)),
  'B5': VitaminHue(Color(0xFF26827D), Color(0xFFDDEDEB)),
  'C': VitaminHue(Color(0xFF147A3E), Color(0xFFE0F5EA)),
  'D': VitaminHue(Color(0xFF8A6010), Color(0xFFFBF3E0)),
  'E': VitaminHue(Color(0xFF5A4592), Color(0xFFEBE6F6)),
  'K': VitaminHue(Color(0xFF3A6B88), Color(0xFFDDE7EE)),
  'B6': VitaminHue(Color(0xFFB23A5C), Color(0xFFF4E0E6)),
  'B7': VitaminHue(Color(0xFF9B4A8B), Color(0xFFF1E1EE)),
  'B12': VitaminHue(Color(0xFF1A6C74), Color(0xFFDDF0F2)),
  'B9': VitaminHue(Color(0xFF6B8E3A), Color(0xFFE9EFDA)),
  'Fe': VitaminHue(Color(0xFF7A3530), Color(0xFFF0E0DC)),
  'Zn': VitaminHue(Color(0xFF3F4F62), Color(0xFFE1E5EC)),
  'Mg': VitaminHue(Color(0xFF1A6E68), Color(0xFFDDF0ED)),
  'Ca': VitaminHue(Color(0xFF6B4A8A), Color(0xFFEDE0F5)),
  'Kp': VitaminHue(Color(0xFFC0782E), Color(0xFFF5E4D0)),
  'Na': VitaminHue(Color(0xFF687684), Color(0xFFE4E8EC)),
  'P': VitaminHue(Color(0xFF2E7E95), Color(0xFFDCECF0)),
  'Se': VitaminHue(Color(0xFFAA7B24), Color(0xFFF0E5CD)),
  'Mn': VitaminHue(Color(0xFF954C72), Color(0xFFF0DFE8)),
  'S': VitaminHue(Color(0xFF77723B), Color(0xFFECEAD7)),
  'Protein': VitaminHue(Color(0xFF7A3830), Color(0xFFF0DED8)),
  'Fiber': VitaminHue(Color(0xFF3A6030), Color(0xFFDDE8D8)),
  'Carbs': VitaminHue(Color(0xFF6A5C20), Color(0xFFEDE8D0)),
  'Fat': VitaminHue(Color(0xFF7A5830), Color(0xFFEDE0D0)),
};

const Map<String, String> nutrientShortLabels = {
  'Kp': 'K+',
  'Protein': 'PRO',
  'Fiber': 'FIB',
  'Carbs': 'CARB',
  'Fat': 'FAT',
};

class NVTheme {
  static ThemeData light() {
    final base = _textTheme(NV.text, NV.textMuted);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: NV.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: NV.accent,
        primary: NV.accent,
        surface: NV.surface,
      ),
      textTheme: GoogleFonts.interTightTextTheme(base),
    );
  }

  static ThemeData dark() {
    final base = _textTheme(NV.textDark, NV.textMutedDark);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: NV.bgDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: NV.accent,
        brightness: Brightness.dark,
        primary: NV.accent,
        surface: NV.surfaceDark,
      ),
      textTheme: GoogleFonts.interTightTextTheme(base),
    );
  }

  static TextTheme _textTheme(Color tc, Color mc) {
    return TextTheme(
      displayLarge: TextStyle(
        color: tc,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
      ),
      headlineLarge: TextStyle(
        color: tc,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
      ),
      headlineMedium: TextStyle(
        color: tc,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
      ),
      titleLarge: TextStyle(
        color: tc,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleMedium: TextStyle(color: tc, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: tc, fontSize: 15),
      bodyMedium: TextStyle(color: tc, fontSize: 13),
      bodySmall: TextStyle(color: mc, fontSize: 12),
      labelSmall: TextStyle(
        color: mc,
        fontSize: 11,
        letterSpacing: 1,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// Helper to pick dark/light colors.
class NVColors {
  final bool dark;
  NVColors(this.dark);

  Color get bg => dark ? NV.bgDark : NV.bg;
  Color get surface => dark ? NV.surfaceDark : NV.surface;
  Color get surfaceMuted => dark ? NV.surfaceMutedDark : NV.surfaceMuted;
  Color get border => dark ? NV.borderDark : NV.border;
  Color get text => dark ? NV.textDark : NV.text;
  Color get textMuted => dark ? NV.textMutedDark : NV.textMuted;
}
