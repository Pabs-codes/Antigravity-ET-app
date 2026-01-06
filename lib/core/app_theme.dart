import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color backgroundLight = Color(0xFFF2F4F6); // Light Grey
  static const Color surfaceWhite = Color(0xFFFFFFFF);    // Pure White
  static const Color accentDark = Color(0xFF1A1A1A);      // Dark Gunmetal
  static const Color accentGreen = Color(0xFF4CAF50);     // Vibrant Green
  static const Color textMain = Color(0xFF1A1A1A);
  static const Color textSub = Color(0xFF757575);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: accentDark,
        secondary: accentGreen,
        surface: surfaceWhite,
        background: backgroundLight,
        onBackground: textMain,
        onSurface: textMain,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: textMain,
        displayColor: textMain,
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0, // We will use manual shadows for "soft" look
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          color: textMain,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: textMain),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accentDark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentDark,
        foregroundColor: Colors.white,
      ),
    );
  }
}
