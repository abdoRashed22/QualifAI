// lib/features/admin/presentation/widgets/roles/roles_assign_employee_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_typography.dart';

class RolesAssignEmployeeDialog extends StatefulWidget {
  final dynamic cubit;
  final int roleId;
  const RolesAssignEmployeeDialog({
    super.key,
    required this.cubit,
    required this.roleId,
  });

  @override
  State<RolesAssignEmployeeDialog> createState() =>
      _RolesAssignEmployeeDialogState();
}

class _RolesAssignEmployeeDialogState extends State<RolesAssignEmployeeDialog> {
  Map<String, dynamic>? _selectedEmployee;

  @override
  Widget build(BuildContext context) {
    final future = widget.cubit.fetchEmployeesList();

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.r20.r),
            ),
            title: Text(
              'نقل موظف حالي لهذا الدور',
              textAlign: TextAlign.right,
              style: AppTypography.titleMedium(),
            ),
            content: const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final employees = snapshot.data ?? [];
        if (employees.isEmpty) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.r20.r),
            ),
            title: Text(
              'نقل موظف حالي لهذا الدور',
              textAlign: TextAlign.right,
              style: AppTypography.titleMedium(),
            ),
            content: Text(
              'لا يوجد موظفون حالياً في النظام',
              textAlign: TextAlign.right,
              style: AppTypography.bodyMedium(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('إغلاق', style: AppTypography.bodyMedium()),
              ),
            ],
          );
        }

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.r20.r),
              ),
              title: Text(
                'نقل موظف حالي لهذا الدور',
                textAlign: TextAlign.right,
                style: AppTypography.titleMedium(),
              ),
              content: SingleChildScrollView(
                child: DropdownButtonFormField<Map<String, dynamic>>(
                  decoration: InputDecoration(
                    labelText: 'اختر الموظف',
                    labelStyle: AppTypography.bodyMedium(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.r12.r),
                    ),
                  ),
                  isExpanded: true,
                  items: employees.map((emp) {
                    final fName = (emp['fullName']?.toString().trim() ?? '');
                    final emailStr = (emp['email']?.toString() ?? '');
                    final display = fName.isNotEmpty
                        ? fName
                        : (emailStr.isNotEmpty
                            ? emailStr
                            : 'مستخدم ${emp['id']}');

                    return DropdownMenuItem(
                      value: emp,
                      child: Text(
                        '$display (${emp['role']})',
                        textAlign: TextAlign.right,
                        style: AppTypography.bodyMedium(),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedEmployee = val),
                ),
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'إلغاء',
                          style: AppTypography.bodyMedium(
                            color: AppColors.subTextLight,
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.w12(),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navyBlue,
                        ),
                        onPressed: _selectedEmployee == null
                            ? null
                            : () {
                                Navigator.of(context).pop();
                                widget.cubit.updateEmployeeData(
                                  _selectedEmployee!['id'] as int,
                                  {
                                    'firstName':
                                        _selectedEmployee!['firstName'],
                                    'lastName': _selectedEmployee!['lastName'],
                                    'email': _selectedEmployee!['email'],
                                    'roleId': widget.roleId,
                                  },
                                );
                              },
                        child: Text(
                          'تأكيد النقل',
                          style: AppTypography.buttonText(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
