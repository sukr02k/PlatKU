import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryStrong = Color(0xFF1D4ED8);
  static const Color primarySoft = Color(0xFFDBEAFE);
  static const Color primarySofter = Color(0xFFEFF6FF);
  static const Color accent = Color(0xFF06B6D4);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color bg = Color(0xFFF4F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surface2 = Color(0xFFF8FAFC);

  static const Color heroTop = Color(0xFF0F172A);
  static const Color heroBottom = Color(0xFF2563EB);

  static const Color text = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textSoft = Color(0xFF94A3B8);
  static const Color divider = Color(0xFFE2E8F0);
  static const Color border = Color(0xFFCBD5E1);

  // Tints
  static const Color tintBlueBg = Color(0xFFDBEAFE);
  static const Color tintBlueFg = Color(0xFF1D4ED8);
  static const Color tintMintBg = Color(0xFFD1FAE5);
  static const Color tintMintFg = Color(0xFF047857);
  static const Color tintPeachBg = Color(0xFFFFEDD5);
  static const Color tintPeachFg = Color(0xFFC2410C);
  static const Color tintLavenderBg = Color(0xFFEDE9FE);
  static const Color tintLavenderFg = Color(0xFF6D28D9);
  static const Color tintRoseBg = Color(0xFFFFE4E6);
  static const Color tintRoseFg = Color(0xFFBE123C);
  static const Color tintAmberBg = Color(0xFFFEF3C7);
  static const Color tintAmberFg = Color(0xFFB45309);

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
