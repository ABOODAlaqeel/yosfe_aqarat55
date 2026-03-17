import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';
import 'sizes.dart';

class AppStyles {
  // العناوين
  static TextStyle get display => GoogleFonts.cairo(
        fontSize: AppSizes.fontDisplay,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get heading => GoogleFonts.cairo(
        fontSize: AppSizes.fontHeading,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get title => GoogleFonts.cairo(
        fontSize: AppSizes.fontTitle,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  // النصوص
  static TextStyle get bodyLarge => GoogleFonts.cairo(
        fontSize: AppSizes.fontLarge,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get body => GoogleFonts.cairo(
        fontSize: AppSizes.fontMedium,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get bodyBold => GoogleFonts.cairo(
        fontSize: AppSizes.fontMedium,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get caption => GoogleFonts.cairo(
        fontSize: AppSizes.fontSmall,
        fontWeight: FontWeight.w400,
        color: AppColors.textLight,
        height: 1.4,
      );

  // أنماط مخصصة
  static TextStyle get amountStyle => GoogleFonts.cairo(
        fontSize: AppSizes.fontLarge,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
      );

  static TextStyle get amountStyleLarge => GoogleFonts.cairo(
        fontSize: AppSizes.fontHeading,
        fontWeight: FontWeight.w800,
        color: AppColors.secondary,
      );

  static TextStyle get buttonText => GoogleFonts.cairo(
        fontSize: AppSizes.fontMedium,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      );

  // ظلال (Shadows)
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get deepShadow => [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.15),
          blurRadius: 24,
          offset: const Offset(0, 12),
          spreadRadius: -4,
        ),
      ];
}
