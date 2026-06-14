import 'package:flutter/material.dart';

class AppTheme {
  static const indigo = Color(0xFF6366F1);
  static const cyan = Color(0xFF55E4FF);
  static const orange = Color(0xFFFF8A3D);
  static const darkBg = Color(0xFF060B13);
  static const darkSurface = Color(0xFF0E1623);
  static const darkCard = Color(0xFF111B2E);
  static const textMuted = Color(0xFF8A94A6);

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: indigo,
        scaffoldBackgroundColor: darkBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: darkSurface,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: darkCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: darkCard,
          indicatorColor: indigo.withValues(alpha: 0.15),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
}
