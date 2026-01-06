import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppText {
  static TextTheme textTheme() {
    final base = GoogleFonts.interTextTheme();
    return base.copyWith(
      titleLarge: base.titleLarge?.copyWith(
        color: AppColors.text,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: base.titleMedium?.copyWith(
        color: AppColors.text,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.bodyLarge?.copyWith(color: AppColors.text),
      bodyMedium: base.bodyMedium?.copyWith(color: AppColors.text),
      bodySmall: base.bodySmall?.copyWith(color: AppColors.mutedText),
    );
  }
}
