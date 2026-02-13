import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/shared_manager.util.dart';

const kThemeModeKey = '__theme_mode__';

/// --- Utils ---------------------------------------------------------------

class ColorUtils {
  const ColorUtils._();

  static Color fromHex(String code) => Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);

  static String toHex(Color color, {bool leadingHashSign = true}) =>
      '${leadingHashSign ? '#' : ''}'
      '${color.alpha.toRadixString(16).padLeft(2, '0')}'
      '${color.red.toRadixString(16).padLeft(2, '0')}'
      '${color.green.toRadixString(16).padLeft(2, '0')}'
      '${color.blue.toRadixString(16).padLeft(2, '0')}';
}

/// --- Theme root ----------------------------------------------------------

abstract class CLTheme {
  const CLTheme({
    required this.primary,
    required this.secondary,
    required this.alternate,
    required this.primaryText,
    required this.secondaryText,
    required this.primaryBackground,
    required this.secondaryBackground,
    required this.tertiaryBackground,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.borderColor,
    required this.background,
    required this.fillColor,
  });

  static Color hexToColor(String code) => ColorUtils.fromHex(code);

  static String toHex(Color color, {bool leadingHashSign = true}) => ColorUtils.toHex(color, leadingHashSign: leadingHashSign);

  static ThemeMode get themeMode {
    final darkMode = SharedManager.getBool(kThemeModeKey);
    return darkMode == null ? ThemeMode.system : (darkMode ? ThemeMode.dark : ThemeMode.light);
  }

  static Future<void> saveThemeMode(ThemeMode mode) async {
    await SharedManager.setBool(
      kThemeModeKey,
      mode == ThemeMode.dark,
    );
  }

  static CLTheme of(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? dark : light;

  // Singletons
  static const CLTheme light = LightModeTheme();
  static const CLTheme dark = DarkModeTheme();

  // Palette
  final Color primary;
  final Color secondary;
  final Color alternate;
  final Color primaryText;
  final Color secondaryText;
  final Color primaryBackground;
  final Color secondaryBackground;
  final Color tertiaryBackground;
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;
  final Color borderColor;
  final Color background;
  final Color fillColor;

  /// Typography provider
  Typography get typography => ThemeTypography(this);

  /// --------- Getter compatibili (no refactor in app) ----------
  TextStyle get heading1 => typography.heading1;

  TextStyle get heading2 => typography.heading2;

  TextStyle get heading3 => typography.heading3;

  TextStyle get heading4 => typography.heading4;

  TextStyle get heading5 => typography.heading5;

  TextStyle get heading6 => typography.heading6;

  TextStyle get title => typography.title;

  TextStyle get subTitle => typography.subTitle;

  TextStyle get bodyText => typography.bodyText;

  TextStyle get smallText => typography.smallText;

  TextStyle get bodyLabel => typography.bodyLabel;

  TextStyle get bodyLabelTableHead => typography.bodyLabelTableHead;

  TextStyle get smallLabel => typography.smallLabel;

  /// ------------------------------------------------------------

  // Utility stabile (niente stato)
  Color generateColorFromText(String text) {
    final int hash = text.hashCode;
    final Random random = Random(hash);
    return Color.fromARGB(255, 100 + random.nextInt(155), 100 + random.nextInt(155), 100 + random.nextInt(155));
  }
}

/// --- Light / Dark --------------------------------------------------------

class LightModeTheme extends CLTheme {
  const LightModeTheme()
    : super(
        primary: const Color(0xFFFC1484),           // Pink vibrante - colore principale
        secondary: const Color(0xFF1C2082),         // Blu navy professionale
        alternate: const Color(0xFFE5E7EB),         // Grigio chiaro per elementi alternativi
        primaryText: const Color(0xFF15161E),       // Quasi nero per testo principale
        secondaryText: const Color(0xFF6B7280),     // Grigio medio per testo secondario
        primaryBackground: const Color(0xFFF9FAFB), // Grigio chiarissimo per background principale
        secondaryBackground: const Color(0xFFFFFFFF), // Bianco per card e superfici
        tertiaryBackground: const Color(0xFFF3F4F6), // Grigio per background alternativo
        success: const Color(0xFF10B981),           // Verde moderno
        warning: const Color(0xFFF59E0B),           // Arancione/amber
        danger: const Color(0xFFEF4444),            // Rosso per errori
        info: const Color(0xFF3B82F6),              // Blu per informazioni
        borderColor: const Color(0xFFE5E7EB),       // Grigio per bordi
        background: const Color(0xFFF9FAFB),        // Stesso del primaryBackground
        fillColor: const Color(0xFFF9FAFB),         // Grigio chiarissimo per riempimenti
      );
}

class DarkModeTheme extends CLTheme {
  const DarkModeTheme()
    : super(
        primary: const Color(0xFFFF6BB3),           // Pink più chiaro per dark mode
        secondary: const Color(0xFF5156B8),         // Blu più chiaro per migliore contrasto
        alternate: const Color(0xFF374151),         // Grigio scuro per elementi alternativi
        primaryText: const Color(0xFFF9FAFB),       // Bianco off-white per testo principale
        secondaryText: const Color(0xFF9CA3AF),     // Grigio chiaro per testo secondario
        primaryBackground: const Color(0xFF111827), // Slate molto scuro per background principale
        secondaryBackground: const Color(0xFF1F2937), // Slate scuro per card e superfici
        tertiaryBackground: const Color(0xFF374151), // Grigio scuro per background alternativo
        success: const Color(0xFF34D399),           // Verde più chiaro per dark mode
        warning: const Color(0xFFFBBF24),           // Giallo più vibrante
        danger: const Color(0xFFF87171),            // Rosso più chiaro
        info: const Color(0xFF60A5FA),              // Blu più chiaro
        borderColor: const Color(0xFF374151),       // Grigio scuro per bordi
        background: const Color(0xFF111827),        // Stesso del primaryBackground
        fillColor: const Color(0xFF1F2937),         // Grigio scuro per riempimenti
      );
}

/// --- Typography ----------------------------------------------------------

abstract class Typography {
  TextStyle get heading1;

  TextStyle get heading2;

  TextStyle get heading3;

  TextStyle get heading4;

  TextStyle get heading5;

  TextStyle get heading6;

  TextStyle get title;

  TextStyle get subTitle;

  TextStyle get bodyText;

  TextStyle get smallText;

  TextStyle get bodyLabel;

  TextStyle get bodyLabelTableHead;

  TextStyle get smallLabel;
}

class ThemeTypography extends Typography {
  ThemeTypography(this.theme);

  final CLTheme theme;
  static const _family = 'Inter';

  TextStyle _text(
    double size, {
    FontWeight? weight,
    Color? color,
    double? letterSpacing,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? lineHeight,
  }) {
    return GoogleFonts.getFont(
      _family,
      color: color ?? theme.primaryText,
      fontSize: size,
      letterSpacing: 0.01,
      fontWeight: weight,
      fontStyle: fontStyle,
      decoration: decoration,
      height: lineHeight,
    );
  }

  @override
  TextStyle get heading1 => _text(32);

  @override
  TextStyle get heading2 => _text(30);

  @override
  TextStyle get heading3 => _text(28);

  @override
  TextStyle get heading4 => _text(26);

  @override
  TextStyle get heading5 => _text(24);

  @override
  TextStyle get heading6 => _text(22);

  @override
  TextStyle get title => _text(18);

  @override
  TextStyle get subTitle => _text(16);

  @override
  TextStyle get bodyText => _text(14);

  @override
  TextStyle get smallText => _text(12);

  @override
  TextStyle get bodyLabel => _text(14, color: theme.secondaryText);

  @override
  TextStyle get bodyLabelTableHead => _text(14, color: theme.secondaryText);

  @override
  TextStyle get smallLabel => _text(12, color: theme.secondaryText);
}

/// --- TextStyle extension --------------------------------------------------

extension TextStyleHelper on TextStyle {
  TextStyle override({
    String? fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    FontStyle? fontStyle,
    bool useGoogleFonts = true,
    TextDecoration? decoration,
    double? lineHeight,
  }) {
    if (useGoogleFonts) {
      return GoogleFonts.getFont(
        fontFamily ?? 'Inter',
        color: color ?? this.color,
        fontSize: fontSize ?? this.fontSize,
        letterSpacing: letterSpacing ?? this.letterSpacing,
        fontWeight: fontWeight ?? this.fontWeight,
        fontStyle: fontStyle ?? this.fontStyle,
        decoration: decoration,
        height: lineHeight,
      );
    }
    return copyWith(
      fontFamily: fontFamily,
      color: color,
      fontSize: fontSize,
      letterSpacing: letterSpacing,
      fontWeight: FontWeight.w300,
      fontStyle: fontStyle,
      decoration: decoration,
      height: lineHeight,
    );
  }
}
