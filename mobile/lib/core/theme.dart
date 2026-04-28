import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color darkBackground = Color(0xFF000A10);
  static const Color whiteText = Color(0xFFFFFFFF);
  static const Color neutralGray = Color(0xFF959EA8);
  static const Color mutedBlueGray = Color(0xFF3C525C);

  // Accent Colors
  static const Color pinkAccent = Color(0xFFED51DC);
  static const Color greenAccent = Color(0xFF3C9A4E);
  static const Color brightGreenAccent = Color(0xFF007609);
  static const Color purpleAccent = Color(0xFF82378E);
  static const Color errorRed = Color(0xFFE53935);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: pinkAccent,
      colorScheme: const ColorScheme.dark(
        primary: pinkAccent,
        secondary: greenAccent,
        surface: mutedBlueGray,
        error: errorRed,
        onPrimary: whiteText,
        onSecondary: whiteText,
        onSurface: whiteText,
        onError: whiteText,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: whiteText),
        headlineLarge: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: whiteText),
        headlineMedium: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: whiteText),
        titleLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: whiteText),
        bodyLarge: const TextStyle(fontSize: 16, color: whiteText),
        bodyMedium: const TextStyle(fontSize: 14, color: neutralGray),
        labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: whiteText),
      ),
      cardTheme: CardTheme(
        color: mutedBlueGray.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: pinkAccent,
          foregroundColor: whiteText,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: mutedBlueGray.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: pinkAccent),
        ),
        hintStyle: const TextStyle(color: neutralGray),
      ),
    );
  }
}
