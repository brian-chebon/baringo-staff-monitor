import 'package:flutter/material.dart';

/// Baringo County visual identity, derived from the official flag adopted by
/// the Baringo County Symbols Act, 2014.
///
/// Flag tricolor: green (pristine environment), golden yellow (natural-resource
/// wealth), golden brown (arable soils / agriculture), with white stripes
/// (peace). The shield in the centre is light blue, evoking Lakes Baringo and
/// Bogoria.
class AppColors {
  AppColors._();

  // Primary tricolor.
  static const Color flagGreen = Color(0xFF1B5E20);
  static const Color flagGold = Color(0xFFF9A825);
  static const Color flagBrown = Color(0xFF6D4C41);

  // Supporting palette.
  static const Color lakeBlue = Color(0xFF0288D1);
  static const Color secondaryGreen = Color(0xFF4CAF50);
  static const Color background = Colors.white;
  static const Color surface = Color(0xFFF5F5F5);

  // Aliases used throughout the app — mapped to the official colors so
  // changing the brand later only requires editing this file.
  static const Color primaryGreen = flagGreen;
  static const Color accentBlue = lakeBlue;
  static const Color accentGold = flagGold;
  static const Color accentBrown = flagBrown;
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.flagGreen,
        secondary: AppColors.lakeBlue,
        tertiary: AppColors.flagGold,
        surface: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.flagGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.flagGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.flagGreen,
          foregroundColor: Colors.white,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.flagGreen,
        foregroundColor: Colors.white,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: AppColors.flagGold,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.flagGreen, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.flagGreen),
      ),
    );
  }

  /// Three-stripe gradient that mirrors the flag — used as the splash / login
  /// header background so the official identity is visible at-a-glance.
  static const LinearGradient flagGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.34, 0.36, 0.66, 0.68, 1.0],
    colors: [
      AppColors.flagGreen,
      AppColors.flagGreen,
      Colors.white,
      AppColors.flagGold,
      Colors.white,
      AppColors.flagBrown,
    ],
  );
}
