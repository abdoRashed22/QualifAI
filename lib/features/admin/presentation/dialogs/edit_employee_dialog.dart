// lib/features/admin/presentation/dialogs/edit_employee_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../cubit/admin_cubit.dart';

class EditEmployeeDialog extends StatefulWidget {
  final AdminCubit cubit;
  final Map<String, dynamic> employee;
  final List<String> existingEmails;

  const EditEmployeeDialog({
    super.key,
    required this.cubit,
    required this.employee,
    required this.existingEmails,
  });

  @override
  State<EditEmployeeDialog> createState() => _EditEmployeeDialogState();
}

class _EditEmployeeDialogState extends State<EditEmployeeDialog> {
  late final TextEditingController _firstCtrl;
  late final TextEditingController _lastCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passCtrl;
  late int _selectedRoleId;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _firstCtrl = TextEditingController(
        text: widget.employee['firstName']?.toString() ?? '');
    _lastCtrl = TextEditingController(
        text: widget.employee['lastName']?.toString() ?? '');
    _emailCtrl =
        TextEditingController(text: widget.employee['email']?.toString() ?? '');
    _passCtrl = TextEditingController();

    final roleName = widget.employee['role']?.toString().toLowerCase() ?? '';
    if (roleName.contains('admin') || roleName.contains('نظام')) {
      _selectedRoleId = 1;
    } else if (roleName.contains('manager') || roleName.contains('مدير')) {
      _selectedRoleId = 2;
    } else {
      _selectedRoleId = 3;
    }
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop();
    widget.cubit.updateEmployeeData(
      widget.employee['id'] as int,
      {
        'firstName': _firstCtrl.text.trim(),
        'lastName': _lastCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'password': _passCtrl.text,
        'roleId': _selectedRoleId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.r20.r),
      ),
      title: Text(
        'تعديل بيانات الموظف',
        textAlign: TextAlign.right,
        style: AppTypography.titleMedium(),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            AppTextField(
              label: 'الاسم الأول',
              controller: _firstCtrl,
              validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
            ),
            AppSpacing.h12(),
            AppTextField(
              label: 'اسم العائلة',
              controller: _lastCtrl,
              validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
            ),
            AppSpacing.h12(),
            AppTextField(
              label: 'البريد الإلكتروني',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'مطلوب';
                if (!v.contains('@')) return 'بريد غير صحيح';
                if (widget.existingEmails.contains(v.trim().toLowerCase())) {
                  return 'البريد الإلكتروني مسجل مسبقاً لموظف آخر';
                }
                return null;
              },
            ),
            AppSpacing.h12(),
            AppTextField(
              label: 'كلمة المرور الجديدة (اختياري)',
              controller: _passCtrl,
              obscure: true,
            ),
            SizedBox(height: 18.h),
            DropdownButtonFormField<int>(
              value: _selectedRoleId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'الصلاحية (الدور)',
                labelStyle: AppTypography.bodyMedium(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.r12.r),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 1,
                  child: Text('مدير النظام (Admin)',
                      style: TextStyle(fontFamily: 'Cairo')),
                ),
                DropdownMenuItem(
                  value: 2,
                  child: Text('مدير الجودة (Manager)',
                      style: TextStyle(fontFamily: 'Cairo')),
                ),
                DropdownMenuItem(
                  value: 3,
                  child: Text('موظف الجودة (Employee)',
                      style: TextStyle(fontFamily: 'Cairo')),
                ),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedRoleId = val);
              },
            ),
          ]),
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('إلغاء',
                    style: AppTypography.bodyMedium(
                        color: AppColors.subTextLight)),
              ),
            ),
            AppSpacing.w12(),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navyBlue,
                  foregroundColor: Colors.white,
                ),
                onPressed: _submit,
                child: const Text('حفظ التعديلات'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
