import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class WeaverTheme {
  WeaverTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: WeaverColors.background,
      colorScheme: const ColorScheme.dark(
        primary: WeaverColors.accent,
        secondary: WeaverColors.success,
        surface: WeaverColors.surface,
        error: WeaverColors.error,
        onPrimary: WeaverColors.background,
        onSecondary: WeaverColors.background,
        onSurface: WeaverColors.textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: WeaverColors.textPrimary),
          displayMedium: TextStyle(color: WeaverColors.textPrimary),
          displaySmall: TextStyle(color: WeaverColors.textPrimary),
          headlineLarge: TextStyle(color: WeaverColors.textPrimary),
          headlineMedium: TextStyle(color: WeaverColors.textPrimary),
          headlineSmall: TextStyle(color: WeaverColors.textPrimary),
          titleLarge: TextStyle(color: WeaverColors.textPrimary, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: WeaverColors.textPrimary, fontWeight: FontWeight.w500),
          titleSmall: TextStyle(color: WeaverColors.textSecondary, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(color: WeaverColors.textPrimary),
          bodyMedium: TextStyle(color: WeaverColors.textSecondary),
          bodySmall: TextStyle(color: WeaverColors.textMuted),
          labelLarge: TextStyle(color: WeaverColors.textPrimary, fontWeight: FontWeight.w600),
          labelMedium: TextStyle(color: WeaverColors.textSecondary, fontWeight: FontWeight.w500),
          labelSmall: TextStyle(color: WeaverColors.textMuted),
        ),
      ),
      cardTheme: const CardThemeData(
        color: WeaverColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: WeaverColors.cardBorder, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: WeaverColors.cardBorder,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: WeaverColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: WeaverColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: WeaverColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: WeaverColors.accent, width: 1.5),
        ),
        hintStyle: const TextStyle(color: WeaverColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: WeaverColors.accent,
          foregroundColor: WeaverColors.background,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: WeaverColors.textPrimary,
          side: const BorderSide(color: WeaverColors.cardBorder),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: WeaverColors.textMuted,
          hoverColor: WeaverColors.cardHover,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return WeaverColors.background;
          return WeaverColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return WeaverColors.accent;
          return WeaverColors.cardBorder;
        }),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: WeaverColors.accent,
        thumbColor: WeaverColors.accent,
        overlayColor: WeaverColors.accentGlow,
        inactiveTrackColor: WeaverColors.cardBorder,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: WeaverColors.cardHover,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: WeaverColors.cardBorder),
        ),
        textStyle: const TextStyle(color: WeaverColors.textPrimary, fontSize: 12),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(WeaverColors.cardBorder),
        radius: const Radius.circular(4),
        thickness: WidgetStateProperty.all(4),
      ),
    );
  }
}
