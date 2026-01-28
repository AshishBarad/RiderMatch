import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static const String fontName = 'Quicksand';

  static TextStyle get header => GoogleFonts.getFont(
    fontName,
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get title => GoogleFonts.getFont(
    fontName,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle get body => GoogleFonts.getFont(
    fontName,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle get caption => GoogleFonts.getFont(
    fontName,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  static TextStyle get button => GoogleFonts.getFont(
    fontName,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnGradient,
  );
}
