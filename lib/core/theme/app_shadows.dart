// lib/core/theme/app_shadows.dart
import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract class AppShadows {
  // Subtle shadow - for card surfaces in light mode
  static List<BoxShadow> get subtleShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  // Card shadow - standard card elevation
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  // Elevated shadow - for elevated/cards that need to stand out
  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  // Bottom navigation bar shadow
  static List<BoxShadow> get bottomNavShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 16,
          offset: const Offset(0, -2),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, -4),
        ),
      ];

  // Dialog shadow
  static List<BoxShadow> get dialogShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 48,
          offset: const Offset(0, 16),
        ),
      ];

  // Floating action button shadow
  static List<BoxShadow> get fabShadow => [
        BoxShadow(
          color: AppColors.navyBlue.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  // AppBar shadow
  static List<BoxShadow> get appBarShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  // Dropdown menu shadow
  static List<BoxShadow> get dropdownShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  // Get theme-aware shadows (for dark mode)
  static List<BoxShadow> themeAwareCardShadow(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
    }
    return cardShadow;
  }

  static List<BoxShadow> themeAwareSubtleShadow(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];
    }
    return subtleShadow;
  }
}
