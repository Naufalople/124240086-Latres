import 'package:flutter/material.dart';

class AppTheme {
  static const Color portalGreen = Color(0xFF97CE4C);
  static const Color portalGreenDark = Color(0xFF6DA329);
  static const Color rickCyan = Color(0xFF00B0C8);
  static const Color spaceDark = Color(0xFF0D131F);
  static const Color cardDark = Color(0xFF1B2333);
  static const Color cardDarkLight = Color(0xFF253046);
  static const Color textLight = Color(0xFFF0F6FC);
  static const Color textMuted = Color(0xFF8B949E);

  static const Color statusAlive = Color(0xFF43D675);
  static const Color statusDead = Color(0xFFFF5252);
  static const Color statusUnknown = Color(0xFF9E9E9E);

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'alive':
        return statusAlive;
      case 'dead':
        return statusDead;
      default:
        return statusUnknown;
    }
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: spaceDark,
      primaryColor: portalGreen,
      colorScheme: const ColorScheme.dark(
        primary: portalGreen,
        secondary: rickCyan,
        surface: cardDark,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: textLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: spaceDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textLight,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: textLight),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardDark,
        selectedItemColor: portalGreen,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDarkLight,
        hintStyle: const TextStyle(color: textMuted),
        prefixIconColor: portalGreen,
        suffixIconColor: textMuted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: portalGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: statusDead, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: portalGreen,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          elevation: 2,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardDarkLight,
        contentTextStyle: const TextStyle(color: textLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
