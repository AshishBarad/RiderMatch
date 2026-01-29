import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF121212); // Rich Charcoal Gray
  static const Color surfaceDark = Color(0xFF1E1E1E); // Industrial Gray Surface
  static const Color cardDark = Color(0xFF242424); // Slightly lighter for depth

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

  // Surface & Cards
  static const Color cardBackground = Colors.white;
  static const Color glassBackground = Color(0x1AFFFFFF);

  // Shadows
  static const Color shadowColor = Color(0x1A000000);
  static List<BoxShadow> softShadow = [
    BoxShadow(color: shadowColor, blurRadius: 20, offset: const Offset(0, 10)),
  ];

  // Typography Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);

  // Dark Mode Typography
  static const Color textPrimaryDark = Color(0xFFE2E8F0);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textOnGradient = Colors.white;

  // Accents & Status
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
}
