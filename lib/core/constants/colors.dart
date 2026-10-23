import 'package:flutter/material.dart';
import 'package:platku/core/theme_controller.dart';

class AppColors {
  static bool get isDark => ThemeController.instance.isDark;

  // ─── PlatKU brand palette: Graphite + Red Racing ───────────────────────────
  static const Color primary = Color(0xFFDC2626); // Red Racing
  static const Color primaryStrong = Color(0xFFB91C1C);
  static Color get primarySoft =>
      isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2);
  static Color get primarySofter =>
      isDark ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2);
  static const Color accent = Color(0xFFF97316); // Racing Amber
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ─── Graphite neutrals ─────────────────────────────────────────────────────
  static Color get bg =>
      isDark ? const Color(0xFF101215) : const Color(0xFFF5F6F7);
  static Color get surface =>
      isDark ? const Color(0xFF181B1F) : const Color(0xFFFFFFFF);
  static Color get surface2 =>
      isDark ? const Color(0xFF23272C) : const Color(0xFFF2F4F5);

  static const Color heroTop = Color(0xFF14171B);
  static const Color heroBottom = Color(0xFFB91C1C);

  // Chip / selector active surface: fixed dark graphite so it stays legible
  // (white label) in both light and dark themes.
  static const Color chipActive = Color(0xFF17191D);

  static Color get text =>
      isDark ? const Color(0xFFF8FAFC) : const Color(0xFF17191D);
  static Color get textMuted =>
      isDark ? const Color(0xFF9AA3AF) : const Color(0xFF5B6472);
  static Color get textSoft =>
      isDark ? const Color(0xFF5B6472) : const Color(0xFF9AA3AF);
  static Color get divider =>
      isDark ? const Color(0xFF24282E) : const Color(0xFFE5E7EB);
  static Color get border =>
      isDark ? const Color(0xFF333943) : const Color(0xFFD3D6DA);

  // ─── Semantic tints ────────────────────────────────────────────────────────
  static Color get tintGraphiteBg =>
      isDark ? const Color(0xFF2A2E34) : const Color(0xFFE5E7EB);
  static Color get tintGraphiteFg =>
      isDark ? const Color(0xFF9AA3AF) : const Color(0xFF374151);
  static Color get tintMintBg =>
      isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
  static Color get tintMintFg =>
      isDark ? const Color(0xFF34D399) : const Color(0xFF047857);
  static Color get tintPeachBg =>
      isDark ? const Color(0xFF7C2D12) : const Color(0xFFFFEDD5);
  static Color get tintPeachFg =>
      isDark ? const Color(0xFFFB923C) : const Color(0xFFC2410C);
  static Color get tintSlateBg =>
      isDark ? const Color(0xFF30363E) : const Color(0xFFE2E8F0);
  static Color get tintSlateFg =>
      isDark ? const Color(0xFF8B95A1) : const Color(0xFF475569);
  static Color get tintRoseBg =>
      isDark ? const Color(0xFF881337) : const Color(0xFFFFE4E6);
  static Color get tintRoseFg =>
      isDark ? const Color(0xFFFB7185) : const Color(0xFFBE123C);
  static Color get tintAmberBg =>
      isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7);
  static Color get tintAmberFg =>
      isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);

  // ─── Status ────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF059669);
  static const Color warning = Color(0xFFD97706);
  static const Color danger = Color(0xFFE11D48);

  // ─── Hero gradients: Graphite → Racing Red ────────────────────────────────
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF14171B), Color(0xFFB91C1C), Color(0xFFDC2626)],
  );

  static const LinearGradient heroGradientVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF14171B), Color(0xFFB91C1C), Color(0xFFDC2626)],
  );
}