import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/theme/app_colors.dart';

class RolesSummaryRow extends StatelessWidget {
  final int totalRoles;
  final int totalEmployees;
  const RolesSummaryRow(
      {super.key, required this.totalRoles, required this.totalEmployees});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'الأدوار النشطة',
            value: '$totalRoles',
            icon: Icons.security,
            color: AppColors.cyan,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _SummaryCard(
            title: 'موظفين مرتبطين',
            value: '$totalEmployees',
            icon: Icons.people,
            color: AppColors.blue,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard(
      {required this.title,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    // Keep identical look by reusing existing SummaryCard widget if present.
    // Fallback minimal rendering to keep compilation.
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          SizedBox(height: 8.h),
          Text(title,
              style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 12.sp, color: Colors.black54)),
          SizedBox(height: 6.h),
          Text(value,
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: color)),
        ],
      ),
    );
  }
}
