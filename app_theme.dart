// lib/theme/app_theme.dart
// 🎨 THÈME PRINCIPAL DE L'APPLICATION
// Ce fichier centralise toutes les couleurs, polices et styles
// pour une cohérence visuelle dans toute l'app

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── PALETTE DE COULEURS ───────────────────────────────────────
  // Couleur principale : or chaud (luxe et élégance)
  static const Color primary = Color(0xFFB8860B);       // Or foncé
  static const Color primaryLight = Color(0xFFD4A017);  // Or clair
  static const Color primaryDark = Color(0xFF8B6508);   // Or très foncé

  // Couleurs secondaires
  static const Color secondary = Color(0xFF1A1A2E);     // Bleu nuit
  static const Color accent = Color(0xFFF5E6C8);        // Crème doré

  // Couleurs neutres
  static const Color background = Color(0xFFFAF8F5);    // Blanc cassé
  static const Color surface = Color(0xFFFFFFFF);       // Blanc pur
  static const Color cardBg = Color(0xFFF9F5EE);        // Fond carte

  // Couleurs de texte
  static const Color textDark = Color(0xFF1A1A1A);      // Texte principal
  static const Color textMedium = Color(0xFF555555);    // Texte secondaire
  static const Color textLight = Color(0xFF999999);     // Texte discret

  // Couleurs système
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);
  static const Color divider = Color(0xFFEEE8DC);

  // ─── ESPACEMENTS ──────────────────────────────────────────────
  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  // ─── BORDER RADIUS ────────────────────────────────────────────
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 20.0;
  static const double radiusXL = 30.0;
  static const double radiusCircle = 100.0;

  // ─── OMBRES ───────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: primary.withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: primary.withOpacity(0.35),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
  ];

  // ─── THÈME FLUTTER ────────────────────────────────────────────
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: background,

      // Typographie avec Google Fonts
      textTheme: GoogleFonts.playfairDisplayTextTheme().copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 36, fontWeight: FontWeight.w700, color: textDark,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 28, fontWeight: FontWeight.w700, color: textDark,
        ),
        headlineLarge: GoogleFonts.playfairDisplay(
          fontSize: 24, fontWeight: FontWeight.w600, color: textDark,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 20, fontWeight: FontWeight.w600, color: textDark,
        ),
        titleLarge: GoogleFonts.lato(
          fontSize: 18, fontWeight: FontWeight.w600, color: textDark,
        ),
        titleMedium: GoogleFonts.lato(
          fontSize: 16, fontWeight: FontWeight.w500, color: textDark,
        ),
        bodyLarge: GoogleFonts.lato(
          fontSize: 16, fontWeight: FontWeight.w400, color: textMedium,
        ),
        bodyMedium: GoogleFonts.lato(
          fontSize: 14, fontWeight: FontWeight.w400, color: textMedium,
        ),
        labelLarge: GoogleFonts.lato(
          fontSize: 14, fontWeight: FontWeight.w600, color: textDark,
          letterSpacing: 0.5,
        ),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20, fontWeight: FontWeight.w600, color: textDark,
        ),
        iconTheme: const IconThemeData(color: textDark),
      ),

      // Boutons élevés
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: paddingLG, vertical: paddingMD,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusCircle),
          ),
          textStyle: GoogleFonts.lato(
            fontSize: 16, fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Boutons outline
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: paddingLG, vertical: paddingMD,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusCircle),
          ),
          textStyle: GoogleFonts.lato(
            fontSize: 16, fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Barre de navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textLight,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: paddingMD, vertical: paddingMD,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.lato(color: textLight, fontSize: 14),
      ),
    );
  }
}
