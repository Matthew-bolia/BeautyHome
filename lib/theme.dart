// ce fichier permet de configurer le thème de l'appplication. 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFD4AF37); // Or
  static const Color secondaryColor = Color(0xFF121212); // Noir
  static const Color accentColor = Color(0xFFFFFFFF); // Blanc

  static final TextTheme appTextTheme = TextTheme(
    displayLarge: GoogleFonts.playfairDisplay(
      fontSize: 57,
      fontWeight: FontWeight.bold,
      color: primaryColor,
    ),
    titleLarge: GoogleFonts.roboto(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      color: accentColor,
    ),
    bodyMedium: GoogleFonts.openSans(fontSize: 14, color: accentColor),
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      secondary: secondaryColor,
    ),
    textTheme: appTextTheme.apply(
      bodyColor: secondaryColor,
      displayColor: primaryColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: secondaryColor,
      foregroundColor: primaryColor,
      titleTextStyle: GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: secondaryColor,
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: secondaryColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: accentColor,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: secondaryColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      secondary: primaryColor,
    ),
    textTheme: appTextTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: secondaryColor,
      foregroundColor: primaryColor,
      titleTextStyle: GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: secondaryColor,
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: secondaryColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: accentColor,
    ),
  );
}
