import 'package:flutter/material.dart';

class RaqeemColors {
  const RaqeemColors._();

  static const primary = Color(0xFFB49464);
  static const background = Color(0xFFF5F0E5);
  static const surface = Color(0xFFEFE6D5);
  static const primaryText = Color(0xFF3E2723);
  static const secondaryText = Color(0xFF7D6E5D);
  static const accentGold = Color(0xFFD4B982);
  static const softWhite = Color(0xFFFAF8F2);

  static const nightBackground = Color(0xFF161411);
  static const nightSurface = Color(0xFF242019);
  static const nightText = Color(0xFFF7EBD8);
  static const nightSecondaryText = Color(0xFFC8B99F);
  static const success = Color(0xFF4F7D57);
  static const warning = Color(0xFF9B6A20);
  static const error = Color(0xFF9C3B32);
}

class RaqeemSpacing {
  const RaqeemSpacing._();

  static const xSmall = 4.0;
  static const small = 8.0;
  static const medium = 16.0;
  static const large = 24.0;
  static const xLarge = 32.0;
}

class RaqeemRadii {
  const RaqeemRadii._();

  static const small = 6.0;
  static const medium = 8.0;
}

class RaqeemTheme {
  const RaqeemTheme._();

  static ThemeData light() {
    return _base(
      brightness: Brightness.light,
      background: RaqeemColors.background,
      surface: RaqeemColors.surface,
      onSurface: RaqeemColors.primaryText,
      secondaryText: RaqeemColors.secondaryText,
    );
  }

  static ThemeData night() {
    return _base(
      brightness: Brightness.dark,
      background: RaqeemColors.nightBackground,
      surface: RaqeemColors.nightSurface,
      onSurface: RaqeemColors.nightText,
      secondaryText: RaqeemColors.nightSecondaryText,
    );
  }

  static ThemeData quranReaderTheme(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return _base(
        brightness: Brightness.dark,
        background: RaqeemColors.nightBackground,
        surface: RaqeemColors.nightSurface,
        onSurface: RaqeemColors.nightText,
        secondaryText: RaqeemColors.nightSecondaryText,
        useMaterial3: false,
      );
    }

    return _base(
      brightness: Brightness.light,
      background: RaqeemColors.background,
      surface: RaqeemColors.surface,
      onSurface: RaqeemColors.primaryText,
      secondaryText: RaqeemColors.secondaryText,
      useMaterial3: false,
    );
  }

  static ThemeData _base({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color onSurface,
    required Color secondaryText,
    bool useMaterial3 = true,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: RaqeemColors.primary,
      brightness: brightness,
      primary: RaqeemColors.primary,
      secondary: RaqeemColors.accentGold,
      surface: surface,
      onSurface: onSurface,
    );

    return ThemeData(
      useMaterial3: useMaterial3,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: onSurface,
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RaqeemRadii.medium),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: RaqeemColors.primary,
          foregroundColor: RaqeemColors.softWhite,
          minimumSize: const Size(44, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RaqeemRadii.medium),
          ),
        ),
      ),
      iconTheme: IconThemeData(color: onSurface, size: 24),
      dividerTheme: DividerThemeData(
        color: secondaryText.withValues(alpha: .2),
      ),
      textTheme: _textTheme(onSurface, secondaryText),
    );
  }

  static TextTheme _textTheme(Color primary, Color secondary) {
    return TextTheme(
      headlineMedium: TextStyle(
        color: primary,
        fontSize: 28,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        color: primary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(color: primary, fontSize: 16),
      bodyMedium: TextStyle(color: secondary, fontSize: 14),
    );
  }
}
