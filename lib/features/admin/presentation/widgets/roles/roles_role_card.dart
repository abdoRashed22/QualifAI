// lib/features/admin/presentation/widgets/roles/roles_role_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../shared/widgets/app_card.dart';
import '../../../../../../shared/widgets/data_display/app_meta_chip.dart';

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
      child: AppCard(
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
                        style: AppTypography.titleSmall(),
                        textAlign: TextAlign.right,
                      ),
                      AppSpacing.h4(),
                      Text(
                        roleDesc,
                        style: AppTypography.caption(),
                        maxLines: 2,
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
                AppSpacing.w12(),
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: AppColors.adminColor.withOpacity(0.12),
                  child: Icon(Icons.security, color: AppColors.adminColor),
                ),
              ],
            ),
            AppSpacing.h16(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppMetaChip(
                  icon: Icons.people_alt_outlined,
                  label: '$empCount موظف',
                  color: AppColors.blue,
                ),
              ],
            ),
            AppSpacing.h16(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onPermissions,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.navyBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.r8.r),
                      ),
                    ),
                    child: Text(
                      'الصلاحيات',
                      style:
                          AppTypography.bodyMedium(color: AppColors.navyBlue),
                    ),
                  ),
                ),
                AppSpacing.w8(),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navyBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.r8.r),
                      ),
                    ),
                    child: Text(
                      'التفاصيل',
                      style: AppTypography.buttonText(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
