import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryAqua,
        primary: AppColors.primaryAqua,
        secondary: AppColors.accentOrange,
        surface: AppColors.backgroundLight,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: GoogleFonts.quicksandTextTheme()
          .copyWith(
            displayLarge: AppTypography.header,
            titleLarge: AppTypography.title,
            bodyMedium: AppTypography.body,
            labelSmall: AppTypography.caption,
          )
          .apply(
            bodyColor: AppColors.textPrimary,
            displayColor: AppColors.textPrimary,
          ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      elevatedButtonTheme: _elevatedButtonTheme,
      inputDecorationTheme: _inputDecorationTheme(Brightness.light),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryAqua,
        brightness: Brightness.dark,
        primary: AppColors.primaryAqua,
        secondary: AppColors.accentOrange,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: GoogleFonts.quicksandTextTheme()
          .copyWith(
            displayLarge: AppTypography.header.copyWith(
              color: AppColors.textPrimaryDark,
            ),
            titleLarge: AppTypography.title.copyWith(
              color: AppColors.textPrimaryDark,
            ),
            bodyMedium: AppTypography.body.copyWith(
              color: AppColors.textPrimaryDark,
            ),
            labelSmall: AppTypography.caption.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          )
          .apply(
            bodyColor: AppColors.textPrimaryDark,
            displayColor: AppColors.textPrimaryDark,
          ),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      elevatedButtonTheme: _elevatedButtonTheme,
      inputDecorationTheme: _inputDecorationTheme(Brightness.dark),
    );
  }

  static ElevatedButtonThemeData get _elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAqua,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: AppTypography.button,
        ),
      );

  static InputDecorationTheme _inputDecorationTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return InputDecorationTheme(
      filled: true,
      fillColor: isDark ? AppColors.cardDark : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.primaryAqua, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      alignLabelWithHint: true,
      labelStyle: AppTypography.body.copyWith(
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
      ),
      hintStyle: AppTypography.body.copyWith(
        color: (isDark ? AppColors.textSecondaryDark : AppColors.textTertiary)
            .withValues(alpha: 0.5),
      ),
    );
  }
}
