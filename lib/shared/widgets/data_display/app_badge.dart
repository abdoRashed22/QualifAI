// lib/shared/widgets/data_display/app_badge.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_colors.dart';

/// Replaces inline badge patterns across the app
/// Supports role badges, status badges, and custom badges
class AppBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;
  final bool small;
  final IconData? icon;
  final bool outlined;

  const AppBadge({
    super.key,
    required this.label,
    required this.color,
    this.textColor,
    this.small = false,
    this.icon,
    this.outlined = false,
  });

  /// Predefined role badges
  factory AppBadge.admin({bool small = false}) => AppBadge(
        label: 'مدير',
        color: AppColors.adminColor,
        small: small,
      );

  factory AppBadge.manager({bool small = false}) => AppBadge(
        label: 'مدير',
        color: AppColors.managerColor,
        small: small,
      );

  factory AppBadge.employee({bool small = false}) => AppBadge(
        label: 'موظف',
        color: AppColors.employeeColor,
        small: small,
      );

  factory AppBadge.reviewer({bool small = false}) => AppBadge(
        label: 'مراجع',
        color: AppColors.reviewerColor,
        small: small,
      );

  /// Predefined status badges
  factory AppBadge.active({bool small = false}) => AppBadge(
        label: 'نشط',
        color: AppColors.success,
        small: small,
      );

  factory AppBadge.inactive({bool small = false}) => AppBadge(
        label: 'غير نشط',
        color: AppColors.error,
        small: small,
      );

  factory AppBadge.pending({bool small = false}) => AppBadge(
        label: 'قيد الانتظار',
        color: AppColors.warning,
        small: small,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.chipPadding(small: small),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.r20.r),
        border: outlined ? Border.all(color: color, width: 1) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: small ? 10.sp : 12.sp,
              color: textColor ?? color,
            ),
            AppSpacing.w4(),
          ],
          Text(
            label,
            style: small
                ? AppTypography.badgeSmall(color: textColor ?? color)
                : AppTypography.badge(color: textColor ?? color),
          ),
        ],
      ),
    );
  }
}
