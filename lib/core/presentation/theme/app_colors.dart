import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds - Light Mode (Darker grays)
  static const Color backgroundLight = Color(0xFFE5E7EB); // Gray 200
  static const Color surfaceLight = Color(0xFFF3F4F6); // Gray 100
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF); // Backward compat

  // Backgrounds - Dark Mode
  static const Color backgroundDark = Color(0xFF111827); // Gray 900
  static const Color surfaceDark = Color(0xFF1F2937); // Gray 800
  static const Color cardDark = Color(0xFF374151); // Gray 700

  // Teal / Aqua Gradients
  static const List<Color> primaryGradient = [
    Color(0xFF2DD4BF), // Teal 400
    Color(0xFF0EA5E9), // Sky 500
  ];

  static const Color primaryAqua = Color(0xFF2DD4BF);
  static const Color primaryBlue = Color(0xFF0EA5E9);

  // Orange / Coral Gradients (CTA)
  static const List<Color> accentGradient = [
    Color(0xFFFB923C), // Orange 400
    Color(0xFFF87171), // Red 400
  ];

  static const Color accentOrange = Color(0xFFFB923C);
  static const Color accentCoral = Color(0xFFF87171);

  // Shadows
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowDark = Color(0x40000000);

  static List<BoxShadow> softShadow = [
    const BoxShadow(color: shadowLight, blurRadius: 20, offset: Offset(0, 10)),
  ];

  // Typography Colors - Light
  static const Color textPrimary = Color(0xFF111827); // Gray 900
  static const Color textSecondary = Color(0xFF6B7280); // Gray 500
  static const Color textTertiary = Color(0xFF9CA3AF); // Gray 400

  // Typography Colors - Dark
  static const Color textPrimaryDark = Color(0xFFF9FAFB); // Gray 50
  static const Color textSecondaryDark = Color(0xFFD1D5DB); // Gray 300
  static const Color textTertiaryDark = Color(0xFF9CA3AF); // Gray 400

  static const Color textOnGradient = Colors.white;

  // Accents & Status
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
}
