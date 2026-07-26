// lib/core/theme/app_typography.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract class AppTypography {
  // Font weights as constants for consistency
  static const FontWeight w400 = FontWeight.w400;
  static const FontWeight w500 = FontWeight.w500;
  static const FontWeight w600 = FontWeight.w600;
  static const FontWeight w700 = FontWeight.w700;

  // Base text style generator using Cairo font
  static TextStyle _cairo({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? height,
    TextDecoration? decoration,
  }) =>
      GoogleFonts.cairo(
        fontSize: fontSize.sp,
        fontWeight: fontWeight,
        color: color,
        height: height,
        decoration: decoration,
      );

  // ── Headlines ──────────────────────────────────────────────────────────
  static TextStyle headlineLarge({Color? color, Brightness? brightness}) =>
      _cairo(
        fontSize: 28,
        fontWeight: w700,
        color: color ?? _textColor(brightness),
      );

  static TextStyle headlineMedium({Color? color, Brightness? brightness}) =>
      _cairo(
        fontSize: 24,
        fontWeight: w700,
        color: color ?? _textColor(brightness),
      );

  static TextStyle headlineSmall({Color? color, Brightness? brightness}) =>
      _cairo(
        fontSize: 20,
        fontWeight: w600,
        color: color ?? _textColor(brightness),
      );

  // ── Titles ─────────────────────────────────────────────────────────────
  static TextStyle titleLarge({Color? color, Brightness? brightness}) => _cairo(
        fontSize: 18,
        fontWeight: w700,
        color: color ?? _textColor(brightness),
      );

  static TextStyle titleMedium({Color? color, Brightness? brightness}) =>
      _cairo(
        fontSize: 16,
        fontWeight: w600,
        color: color ?? _textColor(brightness),
      );

  static TextStyle titleSmall({Color? color, Brightness? brightness}) => _cairo(
        fontSize: 14,
        fontWeight: w600,
        color: color ?? _textColor(brightness),
      );

  // ── Body ───────────────────────────────────────────────────────────────
  static TextStyle bodyLarge({Color? color, Brightness? brightness}) => _cairo(
        fontSize: 16,
        fontWeight: w400,
        color: color ?? _textColor(brightness),
      );

  static TextStyle bodyMedium({Color? color, Brightness? brightness}) => _cairo(
        fontSize: 14,
        fontWeight: w400,
        color: color ?? _textColor(brightness),
      );

  static TextStyle bodySmall({Color? color, Brightness? brightness}) => _cairo(
        fontSize: 12,
        fontWeight: w400,
        color: color ?? _subTextColor(brightness),
      );

  // ── Labels & Captions ──────────────────────────────────────────────────
  static TextStyle caption({Color? color, Brightness? brightness}) => _cairo(
        fontSize: 11,
        fontWeight: w400,
        color: color ?? _subTextColor(brightness),
      );

  static TextStyle label({Color? color, Brightness? brightness}) => _cairo(
        fontSize: 13,
        fontWeight: w500,
        color: color ?? _textColor(brightness),
      );

  static TextStyle buttonText({Color? color}) => _cairo(
        fontSize: 16,
        fontWeight: w600,
        color: color ?? Colors.white,
      );

  static TextStyle overline({Color? color, Brightness? brightness}) => _cairo(
        fontSize: 10,
        fontWeight: w500,
        color: color ?? _subTextColor(brightness),
        height: 1.2,
      );

  // ── Special Styles ─────────────────────────────────────────────────────
  static TextStyle badge({Color? color}) => _cairo(
        fontSize: 12,
        fontWeight: w600,
        color: color,
      );

  static TextStyle badgeSmall({Color? color}) => _cairo(
        fontSize: 10,
        fontWeight: w600,
        color: color,
      );

  static TextStyle link({Color? color, Brightness? brightness}) => _cairo(
        fontSize: 14,
        fontWeight: w600,
        color: color ?? AppColors.blue,
        decoration: TextDecoration.underline,
      );

  static TextStyle price({Color? color}) => _cairo(
        fontSize: 28,
        fontWeight: w700,
        color: color,
      );

  static TextStyle priceLabel({Color? color}) => _cairo(
        fontSize: 12,
        fontWeight: w400,
        color: color,
      );

  static TextStyle inputLabel({Color? color, Brightness? brightness}) => _cairo(
        fontSize: 14,
        fontWeight: w400,
        color: color ?? _subTextColor(brightness),
      );

  static TextStyle inputError({Color? color}) => _cairo(
        fontSize: 11,
        fontWeight: w400,
        color: color ?? AppColors.error,
      );

  // ── Helper Methods ─────────────────────────────────────────────────────
  static Color _textColor(Brightness? brightness) =>
      brightness == Brightness.dark ? AppColors.textLight : AppColors.textDark;

  static Color _subTextColor(Brightness? brightness) =>
      brightness == Brightness.dark
          ? AppColors.subTextDark
          : AppColors.subTextLight;
}
