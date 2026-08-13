// lib/features/admin/presentation/dialogs/add_employee_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../cubit/admin_cubit.dart';

class AddEmployeeDialog extends StatefulWidget {
  final AdminCubit cubit;
  final List<String> existingEmails;

  const AddEmployeeDialog({
    super.key,
    required this.cubit,
    required this.existingEmails,
  });

  @override
  State<AddEmployeeDialog> createState() => _AddEmployeeDialogState();
}

class _AddEmployeeDialogState extends State<AddEmployeeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  int _selectedRoleId = 3; // Default: Employee

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
    widget.cubit.createEmployee({
      'firstName': _firstCtrl.text.trim(),
      'lastName': _lastCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'password': _passCtrl.text,
      'roleId': _selectedRoleId,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.r20.r),
      ),
      title: Text(
        'إضافة موظف جديد',
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
                  return 'البريد الإلكتروني مسجل مسبقاً';
                }
                return null;
              },
            ),
            AppSpacing.h12(),
            AppTextField(
              label: 'كلمة المرور',
              controller: _passCtrl,
              obscure: true,
              validator: (v) {
                if (v == null || v.isEmpty) return 'مطلوب';
                if (v.length < 4) return 'كلمة المرور قصيرة';
                return null;
              },
            ),
            AppSpacing.h12(),
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
                onPressed: _submit,
                child: const Text('إضافة'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
