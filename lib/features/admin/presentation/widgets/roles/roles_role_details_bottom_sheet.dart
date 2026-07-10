import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../cubit/admin_cubit.dart';
import 'roles_assign_employee_dialog.dart';

class RolesRoleDetailsBottomSheet extends StatelessWidget {
  final int roleId;
  final int empCount;
  const RolesRoleDetailsBottomSheet(
      {super.key, required this.roleId, required this.empCount});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: context.read<AdminCubit>().fetchRoleDetails(roleId),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data ?? {};
        final roleName = data['roleName'] ?? 'تفاصيل الدور';
        final roleDescription = data['roleDescription'] ?? 'لا يوجد وصف';

        return Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                roleName,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                roleDescription,
                style: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp),
              ),
              SizedBox(height: 16.h),
              // Keep simple chip representation.
              Chip(
                avatar: const Icon(Icons.people_alt_outlined,
                    color: AppColors.blue),
                label: Text(
                  'عدد الموظفين: $empCount',
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                backgroundColor: AppColors.blue.withOpacity(0.12),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    showDialog(
                      context: context,
                      builder: (c) => RolesAssignEmployeeDialog(roleId: roleId),
                    );
                  },
                  icon:
                      const Icon(Icons.manage_accounts, color: AppColors.blue),
                  label: const Text(
                    'تعديل دور موظف حالي لهذا الدور',
                    style: TextStyle(
                      color: AppColors.blue,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navyBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'إغلاق',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
