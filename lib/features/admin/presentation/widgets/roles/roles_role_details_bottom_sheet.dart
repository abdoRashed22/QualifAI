// lib/features/admin/presentation/widgets/roles/roles_role_details_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../shared/widgets/data_display/app_meta_chip.dart';
import '../../cubit/admin_cubit.dart';
import 'roles_assign_employee_dialog.dart';

class RolesRoleDetailsBottomSheet extends StatelessWidget {
  final AdminCubit cubit;
  final int roleId;
  final int empCount;
  const RolesRoleDetailsBottomSheet({
    super.key,
    required this.cubit,
    required this.roleId,
    required this.empCount,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: cubit.fetchRoleDetails(roleId),
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
              Text(roleName, style: AppTypography.headlineSmall()),
              AppSpacing.h8(),
              Text(roleDescription, style: AppTypography.bodyMedium()),
              AppSpacing.h16(),
              AppMetaChip(
                icon: Icons.people_alt_outlined,
                label: 'عدد الموظفين: $empCount',
                color: AppColors.blue,
              ),
              AppSpacing.h16(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.r8.r),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    showDialog(
                      context: context,
                      builder: (c) => RolesAssignEmployeeDialog(
                        cubit: cubit,
                        roleId: roleId,
                      ),
                    );
                  },
                  icon:
                      const Icon(Icons.manage_accounts, color: AppColors.blue),
                  label: Text(
                    'تعديل دور موظف حالي لهذا الدور',
                    style: AppTypography.bodyMedium(color: AppColors.blue)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              AppSpacing.h12(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navyBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.r8.r),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'إغلاق',
                    style: AppTypography.buttonText(color: Colors.white),
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
