// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand
  static const Color navyBlue    = Color(0xFF1B2B5E);
  static const Color blue        = Color(0xFF2B4EAE);
  static const Color cyan        = Color(0xFF00C2FF);
  static const Color lightBlue   = Color(0xFFEEF3FF);

  // Status
  static const Color success     = Color(0xFF27AE60);
  static const Color warning     = Color(0xFFF39C12);
  static const Color error       = Color(0xFFE74C3C);
  static const Color info        = Color(0xFF2B4EAE);

  // Light Mode
  static const Color white       = Color(0xFFFFFFFF);
  static const Color bgLight     = Color(0xFFF4F6FA);
  static const Color textDark    = Color(0xFF1A1A2E);
  static const Color subTextLight= Color(0xFF6B7A99);
  static const Color borderLight = Color(0xFFE0E4EF);

  // Dark Mode
  static const Color bgDark      = Color(0xFF0F1626);
  static const Color surfaceDark = Color(0xFF1A2540);
  static const Color inputDark   = Color(0xFF212D4A);
  static const Color textLight   = Color(0xFFF0F4FF);
  static const Color subTextDark = Color(0xFF8A9BBF);
  static const Color borderDark  = Color(0xFF2D3D5C);

  // Chart Colors
  static const Color chartGreen  = Color(0xFF27AE60);
  static const Color chartOrange = Color(0xFFF39C12);
  static const Color chartRed    = Color(0xFFE74C3C);
  static const Color chartBlue   = Color(0xFF2B4EAE);
  static const Color chartGray   = Color(0xFFB0B9CC);

  // Role Badge Colors
  static const Color adminColor    = Color(0xFF7B2FBE);
  static const Color managerColor  = Color(0xFF185FA5);
  static const Color employeeColor = Color(0xFF3B6D11);
  static const Color reviewerColor = Color(0xFF854F0B);
}
