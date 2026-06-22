import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF6C3FF5);
  static const Color primaryLight = Color(0xFF9B6DFF);
  static const Color secondary = Color(0xFFFF6B6B);
  static const Color accent = Color(0xFFFFD93D);
  static const Color success = Color(0xFF6BCB77);
  static const Color background = Color(0xFFF0EEFF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color wrongRed = Color(0xFFFF4757);
  static const Color textDark = Color(0xFF2D1B69);
  static const Color textMid = Color(0xFF6B5B9E);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          surface: background,
        ),
        textTheme: GoogleFonts.nunitoTextTheme(
          const TextTheme(
            displayLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: textDark,
            ),
            headlineMedium: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
            bodyLarge: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: textDark,
              height: 1.6,
            ),
            bodyMedium: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textMid,
            ),
            labelLarge: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      );
}
