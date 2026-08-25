import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global dark-mode switch. The app root listens to this and rebuilds with
/// a different [ThemeData], and every [AppColors] getter below reads it too —
/// so toggling it re-themes the whole app in one rebuild, not just widgets
/// that go through `Theme.of(context)`.
class ThemeController {
  ThemeController._();
  static const _prefsKey = 'dark_mode';
  static final ValueNotifier<bool> isDark = ValueNotifier(false);

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    isDark.value = prefs.getBool(_prefsKey) ?? false;
  }

  static Future<void> setDark(bool value) async {
    isDark.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, value);
  }
}

/// Central design system for the Pre-Study IT Knowledge Assessment System.
/// Material Design 3, matched to USEA's web portal (navy/gold/teal), 20px
/// rounded corners, Inter type.
class AppColors {
  AppColors._();
  static bool get _dark => ThemeController.isDark.value;

  static const Color primary = Color(0xFF002060); // USEA navy
  static const Color primaryDark = Color(0xFF001540);
  static const Color primaryLight = Color(0xFF3F5C99);
  static const Color secondary = Color(0xFF63C7DF); // USEA teal accent
  static const Color secondaryLight = Color(0xFFA5DEEA);
  static const Color accent = Color(0xFFE4AC40); // USEA gold accent

  static Color get background => _dark ? const Color(0xFF0B1220) : const Color(0xFFF7F9FC);
  static Color get surface => _dark ? const Color(0xFF141C2E) : Colors.white;
  static Color get textPrimary => _dark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
  static Color get textSecondary => _dark ? const Color(0xFFA3B0C4) : const Color(0xFF64748B);
  static Color get textMuted => _dark ? const Color(0xFF6B7A94) : const Color(0xFF94A3B8);
  static Color get border => _dark ? const Color(0xFF283349) : const Color(0xFFE2E8F0);
  static Color get skeleton => _dark ? const Color(0xFF1E2B42) : const Color(0xFFE9EEF6);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFD71818);
  static const Color info = Color(0xFF3B82F6);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, Color(0xFF059669)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF0E4C8C)],
  );
}

class AppRadius {
  AppRadius._();
  static const double lg = 20;
  static const double md = 16;
  static const double sm = 12;
  static const double pill = 100;
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFFF7F9FC),
      fontFamily: GoogleFonts.inter().fontFamily,
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        headlineLarge: GoogleFonts.inter(
            fontSize: 28, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A), letterSpacing: -0.5),
        headlineMedium: GoogleFonts.inter(
            fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A), letterSpacing: -0.3),
        titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
        titleMedium: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
        bodyLarge: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF0F172A), height: 1.4),
        bodyMedium: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFF64748B), height: 1.4),
        labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: Color(0xFF0F172A),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
          textStyle: GoogleFonts.inter(fontSize: 15.5, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF0F172A),
          minimumSize: const Size.fromHeight(54),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
          textStyle: GoogleFonts.inter(fontSize: 15.5, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 14),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFE2E8F0), thickness: 1, space: 1),
    );
  }

  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primaryLight,
        secondary: AppColors.secondary,
        surface: const Color(0xFF141C2E),
      ),
      scaffoldBackgroundColor: const Color(0xFF0B1220),
      fontFamily: GoogleFonts.inter().fontFamily,
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        headlineLarge: GoogleFonts.inter(
            fontSize: 28, fontWeight: FontWeight.w700, color: const Color(0xFFF1F5F9), letterSpacing: -0.5),
        headlineMedium: GoogleFonts.inter(
            fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFFF1F5F9), letterSpacing: -0.3),
        titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFFF1F5F9)),
        titleMedium: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFFF1F5F9)),
        bodyLarge: GoogleFonts.inter(fontSize: 15, color: const Color(0xFFF1F5F9), height: 1.4),
        bodyMedium: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFFA3B0C4), height: 1.4),
        labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFFF1F5F9)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: Color(0xFFF1F5F9),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF141C2E),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
          textStyle: GoogleFonts.inter(fontSize: 15.5, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFF1F5F9),
          minimumSize: const Size.fromHeight(54),
          side: const BorderSide(color: Color(0xFF283349), width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
          textStyle: GoogleFonts.inter(fontSize: 15.5, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1B2436),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.6),
        ),
        hintStyle: GoogleFonts.inter(color: const Color(0xFF6B7A94), fontSize: 14),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF283349), thickness: 1, space: 1),
    );
  }
}

/// Reusable glassmorphism-style card decoration.
BoxDecoration glassCardDecoration({double radius = AppRadius.lg, Color? tint}) {
  return BoxDecoration(
    color: (tint ?? AppColors.surface).withValues(alpha: 0.65),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.2),
    boxShadow: [
      BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 12)),
    ],
  );
}

BoxDecoration softCardDecoration({double radius = AppRadius.lg}) {
  return BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 8)),
    ],
  );
}
