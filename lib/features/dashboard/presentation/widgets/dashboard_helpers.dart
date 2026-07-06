import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

String roleLabel(String role) {
  switch (role) {
    case 'system_admin':
      return 'مدير النظام';
    case 'quality_manager':
      return 'مديرة الجودة';
    case 'quality_employee':
      return 'موظف الجودة';
    case 'reviewer':
      return 'المراجع';
    default:
      return role;
  }
}

Color pctColor(double pct) {
  if (pct >= 0.7) return AppColors.success;
  if (pct >= 0.4) return AppColors.warning;
  return AppColors.error;
}
