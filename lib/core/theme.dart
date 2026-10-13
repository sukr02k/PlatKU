import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants/colors.dart';

class AppTheme {
  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0B0F19) : const Color(0xFFF4F7FB);
    final surfaceColor =
        isDark ? const Color(0xFF151C2C) : const Color(0xFFFFFFFF);
    final textColor =
        isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textMutedColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final textSoftColor =
        isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
    final borderColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
    final dividerColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        surface: surfaceColor,
        onSurface: textColor,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: bgColor,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: textSoftColor,
        ),
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: textMutedColor,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          minimumSize: const Size(double.infinity, 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: BorderSide(color: borderColor),
          textStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 0,
      ),
    );
  }
}
