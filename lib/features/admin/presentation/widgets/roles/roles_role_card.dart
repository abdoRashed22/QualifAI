import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/theme/app_colors.dart';

class RolesRoleCard extends StatelessWidget {
  final String roleName;
  final String roleDesc;
  final int empCount;
  final VoidCallback onDelete;
  final VoidCallback onPermissions;
  final VoidCallback onDetails;

  const RolesRoleCard({
    super.key,
    required this.roleName,
    required this.roleDesc,
    required this.empCount,
    required this.onDelete,
    required this.onPermissions,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Card(
        elevation: 0,
        color: Theme.of(context).cardColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: onDelete,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          roleName,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          roleDesc,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  CircleAvatar(
                    radius: 24.r,
                    backgroundColor: AppColors.adminColor.withOpacity(0.12),
                    child: Icon(Icons.security, color: AppColors.adminColor),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Keep original InfoChip usage elsewhere; fallback minimal rendering here.
                  Chip(
                    avatar: Icon(Icons.people_alt_outlined,
                        size: 16.sp, color: AppColors.blue),
                    label: Text('$empCount موظف',
                        style: TextStyle(fontFamily: 'Cairo')),
                    backgroundColor: AppColors.blue.withOpacity(0.12),
                  )
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onPermissions,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.navyBlue),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r)),
                      ),
                      child: const Text(
                        'الصلاحيات',
                        style: TextStyle(
                            fontFamily: 'Cairo', color: AppColors.navyBlue),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navyBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r)),
                      ),
                      child: const Text(
                        'التفاصيل',
                        style:
                            TextStyle(fontFamily: 'Cairo', color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
