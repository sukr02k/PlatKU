import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

class Button extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double width;
  final double height;
  final double borderRadius;
  final double fontSize;
  final bool disabled;
  final _ButtonVariant _variant;

  const Button.filled({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.backgroundColor = AppColors.primary,
    this.textColor = Colors.white,
    this.borderColor,
    this.width = double.infinity,
    this.height = 50,
    this.borderRadius = 14,
    this.fontSize = 14,
    this.disabled = false,
  }) : _variant = _ButtonVariant.filled;

  const Button.ghost({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.width = double.infinity,
    this.height = 50,
    this.borderRadius = 14,
    this.fontSize = 14,
    this.disabled = false,
  }) : _variant = _ButtonVariant.ghost;

  const Button.soft({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.textColor = AppColors.primaryStrong,
    this.borderColor,
    this.width = double.infinity,
    this.height = 50,
    this.borderRadius = 14,
    this.fontSize = 14,
    this.disabled = false,
  }) : _variant = _ButtonVariant.soft;

  @override
  Widget build(BuildContext context) {
    final resolvedBg =
        backgroundColor ??
        switch (_variant) {
          _ButtonVariant.filled => AppColors.primary,
          _ButtonVariant.ghost => AppColors.surface,
          _ButtonVariant.soft => AppColors.primarySoft,
        };
    final resolvedText =
        textColor ??
        switch (_variant) {
          _ButtonVariant.filled => Colors.white,
          _ButtonVariant.ghost => AppColors.text,
          _ButtonVariant.soft => AppColors.primaryStrong,
        };
    final resolvedBorder =
        borderColor ??
        (_variant == _ButtonVariant.ghost ? AppColors.border : null);

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: disabled ? AppColors.border : resolvedBg,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: resolvedBorder != null
                  ? Border.all(color: resolvedBorder)
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[icon!, const SizedBox(width: 8)],
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    color: disabled ? AppColors.textMuted : resolvedText,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _ButtonVariant { filled, ghost, soft }
