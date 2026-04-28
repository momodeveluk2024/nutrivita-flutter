import 'package:flutter/material.dart';

class NV {
  // Brand
  static const accent = Color(0xFF2F7D4A);
  static const accentSoft = Color(0xFFE6F1E9);
  static const accentDeep = Color(0xFF1E5A34);

  // Neutrals (clean off-white, no green tint)
  static const bg = Color(0xFFFBFAF6);
  static const bgDark = Color(0xFF0F1512);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF18201C);
  static const surfaceMuted = Color(0xFFF2F0EA);
  static const surfaceMutedDark = Color(0xFF1F2823);
  static const border = Color(0xFFE8E6DE);
  static const borderDark = Color(0xFF2A332D);

  // Text
  static const text = Color(0xFF131A16);
  static const textDark = Color(0xFFF1F3EE);
  static const textMuted = Color(0xFF5E6A63);
  static const textMutedDark = Color(0xFF9AA89F);

  // Semantic
  static const warn = Color(0xFFC57420);
  static const err = Color(0xFFB23A3A);
  static const ok = Color(0xFF2F7D4A);
}

class VitaminHue {
  final Color fill;
  final Color bg;
  const VitaminHue(this.fill, this.bg);
}

const Map<String, VitaminHue> vitaminColors = {
  'A': VitaminHue(Color(0xFFE88A3D), Color(0xFFFBEADB)),
  'B1': VitaminHue(Color(0xFFC68B1C), Color(0xFFF5E8C8)),
  'B2': VitaminHue(Color(0xFFB6A322), Color(0xFFF2EFCB)),
  'B3': VitaminHue(Color(0xFFC06B2F), Color(0xFFF5E1D3)),
  'B5': VitaminHue(Color(0xFF26827D), Color(0xFFDDEDEB)),
  'C': VitaminHue(Color(0xFF2F7D4A), Color(0xFFE6F1E9)),
  'D': VitaminHue(Color(0xFFC79B1A), Color(0xFFF7EFD3)),
  'E': VitaminHue(Color(0xFF7A5CC0), Color(0xFFEBE6F6)),
  'K': VitaminHue(Color(0xFF3A6B88), Color(0xFFE1ECF2)),
  'B6': VitaminHue(Color(0xFFB23A5C), Color(0xFFF4E0E6)),
  'B7': VitaminHue(Color(0xFF9B4A8B), Color(0xFFF1E1EE)),
  'B12': VitaminHue(Color(0xFF1E7A82), Color(0xFFDCECEE)),
  'B9': VitaminHue(Color(0xFF6B8E3A), Color(0xFFE9EFDA)),
  'Fe': VitaminHue(Color(0xFF8A4B3D), Color(0xFFF1DFDB)),
  'Zn': VitaminHue(Color(0xFF4A5B70), Color(0xFFDEE3EA)),
  'Mg': VitaminHue(Color(0xFF2B8079), Color(0xFFDAEDEA)),
  'Ca': VitaminHue(Color(0xFFA07DBB), Color(0xFFECE3F2)),
  'Kp': VitaminHue(Color(0xFFC0782E), Color(0xFFF5E4D0)),
  'Na': VitaminHue(Color(0xFF687684), Color(0xFFE4E8EC)),
  'P': VitaminHue(Color(0xFF2E7E95), Color(0xFFDCECF0)),
  'Se': VitaminHue(Color(0xFFAA7B24), Color(0xFFF0E5CD)),
  'Mn': VitaminHue(Color(0xFF954C72), Color(0xFFF0DFE8)),
  'S': VitaminHue(Color(0xFF77723B), Color(0xFFECEAD7)),
  'Protein': VitaminHue(Color(0xFF7A3F34), Color(0xFFF0DDD9)),
  'Fiber': VitaminHue(Color(0xFF47743C), Color(0xFFE2ECDE)),
  'Carbs': VitaminHue(Color(0xFF786D32), Color(0xFFEDE8CF)),
  'Fat': VitaminHue(Color(0xFF8A6E43), Color(0xFFEDE5D8)),
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
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: NV.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: NV.accent,
        primary: NV.accent,
        surface: NV.surface,
      ),
      fontFamily: 'Inter',
      textTheme: _textTheme(NV.text, NV.textMuted),
    );
  }

  static ThemeData dark() {
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
      fontFamily: 'Inter',
      textTheme: _textTheme(NV.textDark, NV.textMutedDark),
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
