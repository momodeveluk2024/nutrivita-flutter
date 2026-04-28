import 'package:flutter/material.dart';

class NV {
  // Brand — warm amber/orange (per Nutrimate Design System v2)
  static const accent = Color(0xFFE8743C);
  static const accentSoft = Color(0xFFFBE3D2);
  static const accentDeep = Color(0xFFC25A24);
  static const accentInk = Color(0xFF4A2412);

  // Sage — secondary accent (the old brand green)
  static const sage = Color(0xFF5C7A56);
  static const sageSoft = Color(0xFFDCE5D2);

  // Surfaces — warm peach palette
  static const bg = Color(0xFFF4E9DC);
  static const bgAlt = Color(0xFFEFE2D1);
  static const bgDark = Color(0xFF14110E);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF221D17);
  static const surfaceMuted = Color(0xFFFAF4EC);
  static const surfaceMutedDark = Color(0xFF2A241D);
  static const surfaceInk = Color(0xFF14110E);
  static const border = Color(0xFFE5D9C7);
  static const borderDark = Color(0xFF34291F);
  static const borderStrong = Color(0xFFD4C4AC);

  // Text — warm near-black
  static const text = Color(0xFF14110E);
  static const textDark = Color(0xFFFAF4EC);
  static const textMuted = Color(0xFF6B6359);
  static const textMutedDark = Color(0xFFB8AC9B);
  static const textSoft = Color(0xFF9C9285);

  // Semantic
  static const warn = Color(0xFFC57420);
  static const err = Color(0xFFB23A3A);
  static const ok = Color(0xFF5C7A56);
}

class VitaminHue {
  final Color fill;
  final Color bg;
  const VitaminHue(this.fill, this.bg);
}

const Map<String, VitaminHue> vitaminColors = {
  'A': VitaminHue(Color(0xFFB85820), Color(0xFFFBE3D2)),
  'B1': VitaminHue(Color(0xFFC68B1C), Color(0xFFF5E8C8)),
  'B2': VitaminHue(Color(0xFFB6A322), Color(0xFFF2EFCB)),
  'B3': VitaminHue(Color(0xFFC06B2F), Color(0xFFF5E1D3)),
  'B5': VitaminHue(Color(0xFF26827D), Color(0xFFDDEDEB)),
  'C': VitaminHue(Color(0xFF3F5A36), Color(0xFFDCE5D2)),
  'D': VitaminHue(Color(0xFF9C7818), Color(0xFFF7EAC8)),
  'E': VitaminHue(Color(0xFF5A4592), Color(0xFFEBE6F6)),
  'K': VitaminHue(Color(0xFF3A6B88), Color(0xFFDDE7EE)),
  'B6': VitaminHue(Color(0xFFB23A5C), Color(0xFFF4E0E6)),
  'B7': VitaminHue(Color(0xFF9B4A8B), Color(0xFFF1E1EE)),
  'B12': VitaminHue(Color(0xFF1E7A82), Color(0xFFDCECEE)),
  'B9': VitaminHue(Color(0xFF6B8E3A), Color(0xFFE9EFDA)),
  'Fe': VitaminHue(Color(0xFF8A4030), Color(0xFFF1DAD0)),
  'Zn': VitaminHue(Color(0xFF3F4F62), Color(0xFFE1E5EC)),
  'Mg': VitaminHue(Color(0xFF1F6E66), Color(0xFFD6E8E2)),
  'Ca': VitaminHue(Color(0xFF7A5CA0), Color(0xFFE8E0EE)),
  'Kp': VitaminHue(Color(0xFFC0782E), Color(0xFFF5E4D0)),
  'Na': VitaminHue(Color(0xFF687684), Color(0xFFE4E8EC)),
  'P': VitaminHue(Color(0xFF2E7E95), Color(0xFFDCECF0)),
  'Se': VitaminHue(Color(0xFFAA7B24), Color(0xFFF0E5CD)),
  'Mn': VitaminHue(Color(0xFF954C72), Color(0xFFF0DFE8)),
  'S': VitaminHue(Color(0xFF77723B), Color(0xFFECEAD7)),
  'Protein': VitaminHue(Color(0xFF7A3F34), Color(0xFFF0DDD9)),
  'Fiber': VitaminHue(Color(0xFF3F5A36), Color(0xFFDCE5D2)),
  'Carbs': VitaminHue(Color(0xFF8A6E2C), Color(0xFFF1E4C5)),
  'Fat': VitaminHue(Color(0xFF8A5C36), Color(0xFFEFDFD0)),
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
