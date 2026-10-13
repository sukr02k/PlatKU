import 'package:flutter/material.dart';
import 'package:flutter_kendaraanku_app/core/theme_controller.dart';

class AppColors {
  static bool get isDark => ThemeController.instance.isDark;

  static const Color primary = Color(0xFF2563EB);
  static const Color primaryStrong = Color(0xFF1D4ED8);
  static Color get primarySoft =>
      isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE);
  static Color get primarySofter =>
      isDark ? const Color(0xFF172554) : const Color(0xFFEFF6FF);
  static const Color accent = Color(0xFF06B6D4);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static Color get bg =>
      isDark ? const Color(0xFF0B0F19) : const Color(0xFFF4F7FB);
  static Color get surface =>
      isDark ? const Color(0xFF151C2C) : const Color(0xFFFFFFFF);
  static Color get surface2 =>
      isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);

  static const Color heroTop = Color(0xFF0F172A);
  static const Color heroBottom = Color(0xFF2563EB);

  static Color get text =>
      isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  static Color get textMuted =>
      isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  static Color get textSoft =>
      isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
  static Color get divider =>
      isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
  static Color get border =>
      isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);

  // Tints
  static Color get tintBlueBg =>
      isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE);
  static Color get tintBlueFg =>
      isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8);
  static Color get tintMintBg =>
      isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
  static Color get tintMintFg =>
      isDark ? const Color(0xFF34D399) : const Color(0xFF047857);
  static Color get tintPeachBg =>
      isDark ? const Color(0xFF7C2D12) : const Color(0xFFFFEDD5);
  static Color get tintPeachFg =>
      isDark ? const Color(0xFFFB923C) : const Color(0xFFC2410C);
  static Color get tintLavenderBg =>
      isDark ? const Color(0xFF4C1D95) : const Color(0xFFEDE9FE);
  static Color get tintLavenderFg =>
      isDark ? const Color(0xFFA78BFA) : const Color(0xFF6D28D9);
  static Color get tintRoseBg =>
      isDark ? const Color(0xFF881337) : const Color(0xFFFFE4E6);
  static Color get tintRoseFg =>
      isDark ? const Color(0xFFFB7185) : const Color(0xFFBE123C);
  static Color get tintAmberBg =>
      isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7);
  static Color get tintAmberFg =>
      isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);

  // Status
  static const Color success = Color(0xFF059669);
  static const Color warning = Color(0xFFD97706);
  static const Color danger = Color(0xFFE11D48);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F172A), Color(0xFF1D4ED8), Color(0xFF0284C7)],
  );

  static const LinearGradient heroGradientVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F172A), Color(0xFF1D4ED8), Color(0xFF0284C7)],
  );
}
