import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ── Brand Colors ────────────────────────────────────────────
  static const Color primary      = Color(0xFF6C63FF);  // violeta vibrante
  static const Color primaryDark  = Color(0xFF4B44CC);
  static const Color secondary    = Color(0xFFFF6B6B);  // coral
  static const Color accent       = Color(0xFF43E97B);  // verde encontrado
  static const Color warning      = Color(0xFFFFD93D);  // amarelo recompensa

  // ── Neutros Light ────────────────────────────────────────────
  static const Color bgLight      = Color(0xFFF8F7FF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight    = Color(0xFFFFFFFF);
  static const Color textPrimary  = Color(0xFF1A1A2E);
  static const Color textSecond   = Color(0xFF6B7280);
  static const Color divider      = Color(0xFFE5E7EB);

  // ── Neutros Dark ─────────────────────────────────────────────
  static const Color bgDark       = Color(0xFF0F0E1A);
  static const Color surfaceDark  = Color(0xFF1A1930);
  static const Color cardDark     = Color(0xFF242340);
  static const Color textDarkPrim = Color(0xFFF1F0FF);
  static const Color textDarkSec  = Color(0xFF9CA3AF);

  // ── Status Colors ────────────────────────────────────────────
  static const Color statusActive = Color(0xFF6C63FF);
  static const Color statusFound  = Color(0xFF43E97B);
  static const Color statusClosed = Color(0xFF9CA3AF);
  static const Color error        = Color(0xFFEF4444);

  // ── Gradientes ───────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFFFF6B6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient foundGradient = LinearGradient(
    colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Sombras ─────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get primaryShadow => [
    BoxShadow(
      color: primary.withOpacity(0.35),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // ── Text Theme ──────────────────────────────────────────────
  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return GoogleFonts.nunitoTextTheme().copyWith(
      displayLarge: GoogleFonts.nunito(
        fontSize: 32, fontWeight: FontWeight.w800, color: primary,
      ),
      displayMedium: GoogleFonts.nunito(
        fontSize: 26, fontWeight: FontWeight.w700, color: primary,
      ),
      displaySmall: GoogleFonts.nunito(
        fontSize: 22, fontWeight: FontWeight.w700, color: primary,
      ),
      headlineMedium: GoogleFonts.nunito(
        fontSize: 20, fontWeight: FontWeight.w700, color: primary,
      ),
      headlineSmall: GoogleFonts.nunito(
        fontSize: 18, fontWeight: FontWeight.w600, color: primary,
      ),
      titleLarge: GoogleFonts.nunito(
        fontSize: 16, fontWeight: FontWeight.w700, color: primary,
      ),
      titleMedium: GoogleFonts.nunito(
        fontSize: 15, fontWeight: FontWeight.w600, color: primary,
      ),
      titleSmall: GoogleFonts.nunito(
        fontSize: 14, fontWeight: FontWeight.w600, color: primary,
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16, fontWeight: FontWeight.w400, color: primary,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 14, fontWeight: FontWeight.w400, color: secondary,
      ),
      bodySmall: GoogleFonts.nunito(
        fontSize: 12, fontWeight: FontWeight.w400, color: secondary,
      ),
      labelLarge: GoogleFonts.nunito(
        fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5,
      ),
    );
  }

  // ── Light Theme ─────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      secondary: secondary,
      surface: surfaceLight,
      error: error,
    ),
    scaffoldBackgroundColor: bgLight,
    textTheme: _buildTextTheme(textPrimary, textSecond),
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceLight,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.nunito(
        fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.black.withOpacity(0.08),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF3F4F6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 1.5),
      ),
      hintStyle: GoogleFonts.nunito(color: textSecond, fontSize: 14),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: bgLight,
      selectedColor: primary.withOpacity(0.15),
      labelStyle: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600),
      side: const BorderSide(color: divider),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceLight,
      selectedItemColor: primary,
      unselectedItemColor: textSecond,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    dividerTheme: const DividerThemeData(color: divider, thickness: 1),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
  );

  // ── Dark Theme ──────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      primary: primary,
      secondary: secondary,
      surface: surfaceDark,
      error: error,
    ),
    scaffoldBackgroundColor: bgDark,
    textTheme: _buildTextTheme(textDarkPrim, textDarkSec),
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceDark,
      foregroundColor: textDarkPrim,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.nunito(
        fontSize: 20, fontWeight: FontWeight.w700, color: textDarkPrim,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      hintStyle: GoogleFonts.nunito(color: textDarkSec, fontSize: 14),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceDark,
      selectedItemColor: primary,
      unselectedItemColor: textDarkSec,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF2D2C4A),
      thickness: 1,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
    ),
  );
}

// ignore: constant_identifier_names
const Darkness = Brightness;
