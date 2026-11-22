import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens for Verra. Ink + cobalt carry the brand, citron is the single
/// "act now" accent used for primary calls to action on dark surfaces.
class AppColors {
  static const ink = Color(0xFF151515);
  static const cobalt = Color(0xFFE8622C);
  static const citron = Color(0xFFD14A33);
  static const mist = Color(0xFFFBF6F1);
  static const slate = Color(0xFF6B6660);
  static const danger = Color(0xFFE5484D);
  static const success = Color(0xFF1FA971);
  static const star = Color(0xFFF5A623);
  static const darkBg = Color(0xFF111111);
  static const darkSurface = Color(0xFF1E1E20);
}

class AppSpace {
  static const double xs = 4, sm = 8, md = 16, lg = 24, xl = 32;
  static const double radius = 16, radiusLg = 24;
}

class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final dark = b == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.cobalt,
      brightness: b,
    ).copyWith(
      primary: dark ? Colors.white : AppColors.ink,
      onPrimary: dark ? AppColors.ink : Colors.white,
      surface: dark ? AppColors.darkSurface : Colors.white,
      onSurface: dark ? Colors.white : AppColors.ink,
      surfaceContainerHighest: dark ? const Color(0xFF2A2A2D) : const Color(0xFFEFEBE6),
      outlineVariant: dark ? const Color(0xFF38383B) : const Color(0xFFE6E0D9),
    );

    final base = ThemeData(brightness: b, useMaterial3: true, colorScheme: scheme);
    final text = GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    return base.copyWith(
      scaffoldBackgroundColor: dark ? AppColors.darkBg : AppColors.mist,
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: scheme.onSurface,
        titleTextStyle: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? scheme.surface : const Color(0xFFEFEBE6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpace.radius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpace.radius),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpace.radius),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          backgroundColor: dark ? Colors.white : AppColors.ink,
          foregroundColor: dark ? AppColors.ink : Colors.white,
          textStyle: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpace.radius)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outlineVariant, width: 1.4),
          textStyle: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpace.radius)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: scheme.surface,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStatePropertyAll(
          text.labelSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return IconThemeData(
            color: sel ? (dark ? Colors.white : AppColors.ink) : AppColors.slate,
          );
        }),
      ),
      chipTheme: base.chipTheme.copyWith(
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: text.labelLarge,
      ),
    );
  }
}
