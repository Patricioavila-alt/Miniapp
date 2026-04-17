import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Paleta de colores (Organic & Earthy) ──────────────────────────────────
  static const Color background    = Color(0xFFF9F8F6);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color primary       = Color(0xFFE07A5F); // Terracota (CTAs)
  static const Color primaryLight  = Color(0xFFF2B8A7);
  static const Color secondary     = Color(0xFF2A433A); // Verde oscuro
  static const Color accent        = Color(0xFF819E8E); // Verde gris
  static const Color textPrimary   = Color(0xFF1F2321);
  static const Color textSecondary = Color(0xFF5C6B64);
  static const Color border        = Color(0xFFE5E1DA);
  static const Color success       = Color(0xFF4CAF50);
  static const Color error         = Color(0xFFE53935);
  static const Color blue          = Color(0xFF3B82F6); // Azul FDA (avatar ring, acento)

  // ─── Radios de borde ───────────────────────────────────────────────────────
  static const double radiusSm  = 12.0;
  static const double radiusMd  = 16.0;
  static const double radiusLg  = 20.0;
  static const double radiusXl  = 32.0;

  // ─── Sombras ───────────────────────────────────────────────────────────────
  static List<BoxShadow> get shadowSoft => [
    BoxShadow(
      color: const Color(0xFF2A433A).withValues(alpha: 0.06),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowFloating => [
    BoxShadow(
      color: const Color(0xFF2A433A).withValues(alpha: 0.10),
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
  ];

  // ─── Padding estándar ──────────────────────────────────────────────────────
  static const EdgeInsets screenPadding =
      EdgeInsets.symmetric(horizontal: 24, vertical: 40);
  static const EdgeInsets cardPadding = EdgeInsets.all(24);
  static const double gap = 24.0;

  // ─── Tipografías ───────────────────────────────────────────────────────────
  static TextStyle heading1() => GoogleFonts.outfit(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle heading2() => GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.3,
  );

  static TextStyle heading3() => GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle body() => GoogleFonts.manrope(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.6,
  );

  static TextStyle bodyBold() => GoogleFonts.manrope(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle label() => GoogleFonts.manrope(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: accent,
    letterSpacing: 0.8,
  );

  static TextStyle caption() => GoogleFonts.manrope(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  // ─── ThemeData de MaterialApp ──────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: surface,
      error: error,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: heading2(),
      iconTheme: const IconThemeData(color: textPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: primary,
      unselectedItemColor: accent,
      type: BottomNavigationBarType.fixed,
      elevation: 12,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 11),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        side: const BorderSide(color: border, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: surface,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        textStyle: GoogleFonts.manrope(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: GoogleFonts.manrope(color: accent, fontSize: 14),
    ),
  );
}
