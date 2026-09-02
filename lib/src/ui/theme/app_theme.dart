import 'package:flutter/material.dart';

class AppTheme {
  // Cultural tribal earth palette
  static const Color primaryColor = Color(0xFFC84B31); // Terracotta Red
  static const Color primaryDark = Color(0xFF9D321D);
  static const Color accentColor = Color(0xFFD97724);  // Warm Ochre
  static const Color secondaryColor = Color(0xFF2D6A4F); // Forest Emerald
  static const Color darkBg = Color(0xFF141923);
  static const Color darkCard = Color(0xFF1E2638);
  static const Color lightBg = Color(0xFFF9F7F2);
  static const Color lightCard = Color(0xFFFFFFFF);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: lightCard,
      ),
      scaffoldBackgroundColor: lightBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Color(0xFF1F2937),
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
        iconTheme: IconThemeData(color: Color(0xFF1F2937)),
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: Color(0xFF52B788),
        surface: darkCard,
      ),
      scaffoldBackgroundColor: darkBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
