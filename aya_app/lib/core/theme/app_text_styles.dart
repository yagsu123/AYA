import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// AYA typography scale — Plus Jakarta Sans everywhere.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle display = GoogleFonts.plusJakartaSans(
      fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary);

  static TextStyle heading = GoogleFonts.plusJakartaSans(
      fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary);

  static TextStyle body = GoogleFonts.plusJakartaSans(
      fontSize: 14, fontWeight: FontWeight.w400, height: 1.6, color: AppColors.textPrimary);

  static TextStyle label = GoogleFonts.plusJakartaSans(
      fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.66, color: AppColors.textMuted);

  static TextStyle caption = GoogleFonts.plusJakartaSans(
      fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textMuted);

  static TextStyle button = GoogleFonts.plusJakartaSans(
      fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white);
}
