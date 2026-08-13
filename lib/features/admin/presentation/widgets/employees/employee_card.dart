// lib/features/admin/presentation/widgets/employees/employee_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/app_card.dart';
import '../../../../../shared/widgets/data_display/app_badge.dart' as badges;

class EmployeeCard extends StatelessWidget {
  final Map<String, dynamic> employee;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EmployeeCard({
    super.key,
    required this.employee,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final id = (employee['id'] ?? employee['employeeId'] ?? 0) as int;
    final role =
        (employee['role'] ?? employee['roleName'] ?? 'موظف').toString();
    final profileImage = (employee['profileImage'] ?? '').toString();
    final fullName = (employee['fullName'] ?? '').toString().trim();
    final email = (employee['email'] ?? '').toString().trim();

    final displayName = fullName.isNotEmpty ? fullName : 'مستخدم رقم $id';
    final secondaryInfo = email.isNotEmpty ? email : 'ID: $id';

    return AppCard(
      padding: AppSpacing.all12(),
      child: Row(children: [
        // Action buttons column
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onEdit,
              child: Container(
                width: 70.w,
                padding: EdgeInsets.symmetric(vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.r8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_outlined,
                        color: AppColors.blue, size: 14.sp),
                    AppSpacing.w4(),
                    Text('تعديل',
                        style: AppTypography.bodySmall().copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.blue)),
                  ],
                ),
              ),
            ),
            AppSpacing.h6(),
            GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 70.w,
                padding: EdgeInsets.symmetric(vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.r8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_outline,
                        color: AppColors.error, size: 14.sp),
                    AppSpacing.w4(),
                    Text('حذف',
                        style: AppTypography.bodySmall().copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.error)),
                  ],
                ),
              ),
            ),
          ],
        ),
        AppSpacing.w12(),
        // Employee details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                displayName,
                style: AppTypography.titleSmall(),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              AppSpacing.h4(),
              Text(
                secondaryInfo,
                style: AppTypography.caption(),
                textAlign: TextAlign.right,
              ),
              AppSpacing.h6(),
              badges.AppBadge(
                label: role.isNotEmpty ? role : 'موظف',
                color: AppColors.navyBlue,
                small: true,
              ),
            ],
          ),
        ),
        AppSpacing.w10(),
        // Profile image
        CircleAvatar(
          backgroundColor: AppColors.navyBlue.withOpacity(0.1),
          backgroundImage:
              profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
          radius: 26.r,
          child: profileImage.isNotEmpty
              ? null
              : Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : "م",
                  style: AppTypography.titleMedium()
                      .copyWith(color: AppColors.navyBlue),
                ),
        ),
      ]),
    );
  }
}
